// lib/screens/inventory_screen.dart

import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/item.dart';
import '../services/inventory_service.dart';
import '../services/user_service.dart'; 
import '../widgets/top_up_convert_modal.dart'; 
import '../models/user_summary.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController; 
  final InventoryService _inventoryService = InventoryService();
  final UserService _userService = UserService(); 
  
  // Futures for data loading
  late Future<Map<String, dynamic>> _dataFuture;
  
  // State for current Balances
  int _currentGpBalance = 0; 
  int _currentDiamondBalance = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }
  
  void _refreshData() async {
    setState(() {
      _dataFuture = _inventoryService.fetchInventoryAndAchievements();
    });
    
    // FETCH USER SUMMARY UNTUK DATA BALANCE
    final summary = await _userService.fetchUserSummary();
    if (summary != null) {
      setState(() {
        _currentGpBalance = summary.gp;
        _currentDiamondBalance = summary.diamonds;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // --- UI ACTIONS ---

  void _handleBuy(ShopItem item) async {
    if (item.costGP > _currentGpBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient Green Points (GP)!'), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    final String resultMessage = await _inventoryService.buyItem(item.id);
    
    if (mounted) Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resultMessage), backgroundColor: resultMessage.startsWith('Success') ? Colors.green : Colors.red),
    );
    
    _refreshData(); 
  }

  void _showTopUpConvertModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TopUpConvertModal(
        initialDiamondBalance: _currentDiamondBalance,
        initialGPBalance: _currentGpBalance,
        onTransactionComplete: _refreshData,
      ),
    );
  }

  // --- WIDGET HELPERS ---
  
  IconData _getShopItemIcon(String id) {
    switch (id) {
      case 'flash': return Icons.flash_on;
      case 'seed': return Icons.eco;
      case 'magnet': return Icons.thunderstorm_outlined; 
      case 'food': return Icons.pets;
      case 'leaf': return Icons.grass;
      default: return Icons.shopping_bag;
    }
  }
  
  IconData _getAchievementIcon(String id) {
    switch (id) {
      case 'shoe': return Icons.directions_walk;
      case 'up_arrow': return Icons.trending_up;
      case 'handshake': return Icons.people;
      case 'recycle': return Icons.recycling;
      case 'trophy': return Icons.emoji_events;
      default: return Icons.star;
    }
  }

  // Widget Bantuan: Achievement Card
  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      color: isUnlocked ? Colors.amber.shade50 : Colors.grey.shade100,
      child: ListTile(
        leading: Icon(
          _getAchievementIcon(achievement.badgeIcon),
          color: isUnlocked ? Colors.amber.shade700 : Colors.grey.shade400,
          size: 30,
        ),
        title: Text(achievement.title, style: TextStyle(fontWeight: FontWeight.bold, color: isUnlocked ? Colors.black : Colors.grey.shade600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            if (!isUnlocked) 
              LinearProgressIndicator(
                value: achievement.currentProgress,
                backgroundColor: Colors.grey.shade300,
                color: Colors.green,
                minHeight: 5,
              ),
            Text(
              isUnlocked 
                ? 'Unlocked! (+${achievement.gpReward} GP)' 
                : 'Progress: ${(achievement.currentProgress * 100).toStringAsFixed(0)}% (${achievement.currentProgress > 0 ? (achievement.threshold * achievement.currentProgress).toInt() : 0} / ${achievement.threshold} ${achievement.criteria.split('_').last})',
              style: TextStyle(fontSize: 12, color: isUnlocked ? Colors.amber.shade900 : Colors.black54),
            ),
          ],
        ),
        trailing: isUnlocked
          ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
          : Text('+${achievement.gpReward} GP', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAchievementList(List<Achievement> achievements) {
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final locked = achievements.where((a) => !a.isUnlocked).toList();
    
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Unlocked Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
        ),
        if (unlocked.isEmpty) const Center(child: Text('No badges unlocked yet.', style: TextStyle(color: Colors.grey))),
        ...unlocked.map((a) => _buildAchievementCard(a, true)),
        
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Remaining Milestones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...locked.map((a) => _buildAchievementCard(a, false)),
      ],
    );
  }

  // Widget Bantuan BARU: Inventory Grid Card
  Widget _buildInventoryItemGridCard(BuildContext context, String itemName) {
    // Simulasi data item untuk icon/detail
    IconData itemIcon;
    Color itemColor;
    if (itemName.contains('Boost')) {
      itemIcon = Icons.bolt;
      itemColor = Colors.orange;
    } else if (itemName.contains('Food')) {
      itemIcon = Icons.pets;
      itemColor = Colors.brown;
    } else {
      itemIcon = Icons.inventory;
      itemColor = Colors.grey;
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Using $itemName... (Action simulated)')));
        },
        child: Padding(
          padding: const EdgeInsets.all(4.0), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
            children: [
              Icon(itemIcon, size: 35, color: itemColor), 
              
              // Item Name (Reduced font size and limited lines)
              Text(
                itemName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10), 
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Tombol Use
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), 
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text('Use', style: TextStyle(color: Colors.white, fontSize: 10)),
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildGeneralInventory(List<String> items) {
    if (items.isEmpty) {
        return const Center(child: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: Text('Your inventory is empty. Complete quests to earn items!'),
        ));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // <-- FIX: MENGGUNAKAN 3 KOLOM
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85, 
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildInventoryItemGridCard(context, items[index]);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory & Achievements'), 
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Display Diamond Balance
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.diamond, size: 17, color: Colors.cyan), 
                  const SizedBox(width: 4),
                  Text(
                    '$_currentDiamondBalance D', 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          // Display GP Balance
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 4.0),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, size: 17, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '$_currentGpBalance GP',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7), 
          indicatorColor: Colors.white,
          tabs: const [
            // Urutan: My Items dulu, Achievements kedua
            Tab(text: 'My Items'), 
            Tab(text: 'Achievements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: My Items
          FutureBuilder<Map<String, dynamic>>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!['error'] != null) {
                return Center(child: Text('Error loading Inventory: ${snapshot.data!['error'] ?? snapshot.error}'));
              }

              final List<String> items = List<String>.from(snapshot.data!['generalItems'] ?? []);
              return _buildGeneralInventory(items); 
            },
          ),

          // Tab 2: Achievements
          FutureBuilder<Map<String, dynamic>>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!['error'] != null) {
                return Center(child: Text('Error loading Achievements: ${snapshot.data!['error'] ?? snapshot.error}'));
              }

              final List<Achievement> achievements = snapshot.data!['achievements'] ?? [];
              return _buildAchievementList(achievements);
            },
          ),
        ],
      ),
      // Tombol FAB untuk Top-Up/Convert
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTopUpConvertModal,
        label: const Text('Top Up / Convert', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.diamond, color: Colors.white),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }
}
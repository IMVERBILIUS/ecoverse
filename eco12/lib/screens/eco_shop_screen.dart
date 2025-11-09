// lib/screens/eco_shop_screen.dart

import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/inventory_service.dart';
import '../services/user_service.dart'; 
import '../widgets/top_up_convert_modal.dart'; 
import '../models/user_summary.dart';

class EcoShopScreen extends StatefulWidget {
  const EcoShopScreen({super.key});

  @override
  State<EcoShopScreen> createState() => _EcoShopScreenState();
}

class _EcoShopScreenState extends State<EcoShopScreen> {
  final InventoryService _inventoryService = InventoryService();
  final UserService _userService = UserService();
  
  late Future<List<ShopItem>> _shopItemsFuture;
  late Future<UserSummary?> _userSummaryFuture; 
  
  ShopItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }
  
  void _refreshData() async {
    setState(() {
      _shopItemsFuture = _inventoryService.fetchShopItems();
      _userSummaryFuture = _userService.fetchUserSummary();
    });
    
    final summary = await _userService.fetchUserSummary();
    if (summary != null) {
      _currentGpBalance = summary.gp;
      _currentDiamondBalance = summary.diamonds;
    }
  }

  // --- DATA STATES ---
  int _currentGpBalance = 0; 
  int _currentDiamondBalance = 0; 

  // --- UI ACTIONS ---

  // Fungsi untuk menampilkan Modal Top Up/Convert
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

  // Fungsi untuk menangani pembelian item
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
    
    _refreshData(); // Refresh data untuk update balance
  }

  // Fungsi helper untuk mendapatkan ikon (diambil dari InventoryScreen)
  IconData _getShopItemIcon(String id) {
    switch (id) {
      case 'flash': return Icons.flash_on;
      case 'seed': return Icons.eco;
      case 'magnet': return Icons.thunderstorm_outlined; 
      case 'food': return Icons.pets;
      case 'leaf': return Icons.grass;
      case 'cup': return Icons.local_cafe; 
      case 'shirt': return Icons.checkroom; 
      case 'bag': return Icons.shopping_bag; 
      default: return Icons.star;
    }
  }

  // Widget Grid Item Toko
  Widget _buildShopItemGrid(List<ShopItem> items, int userGpBalance) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8, // Sedikit lebih tinggi untuk teks
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = item == _selectedItem;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedItem = item;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0FFF0) : Colors.white, // Latar belakang yang dipilih
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade200,
                width: isSelected ? 3.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getShopItemIcon(item.icon), size: 40, color: Colors.teal),
                const SizedBox(height: 5),
                Text(
                  item.name.length > 10 ? '${item.name.substring(0, 9)}...' : item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.costGP} Points',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4CAF50)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget Detail Item & Pembelian
  Widget _buildItemDetailPanel(ShopItem item, int userGpBalance) {
    final canAfford = userGpBalance >= item.costGP;
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Item
          Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          
          // Deskripsi
          Text(item.description, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 10),

          // Kategori & Biaya
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Category: ${item.type}', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                'Cost: ${item.costGP} Points',
                style: TextStyle(fontWeight: FontWeight.bold, color: canAfford ? const Color(0xFF4CAF50) : Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Tombol Beli (Menggunakan lebar penuh)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canAfford ? () => _handleBuy(item) : null,
              icon: Icon(Icons.shopping_cart, color: Colors.white),
              label: Text(canAfford ? 'Buy Now' : 'Insufficient GP', style: const TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? const Color(0xFF4CAF50) : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco-Shop'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: FutureBuilder<List<ShopItem>>(
        future: _shopItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading Eco-Shop: ${snapshot.error}'));
          }
          
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Text('Eco-Shop is currently empty! Check back later.'),
            );
          }

          // Atur item yang dipilih (default ke item pertama jika belum ada)
          if (_selectedItem == null && items.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedItem = items.first;
              });
            });
            return const Center(child: CircularProgressIndicator()); 
          }
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Saldo DIBALUT DENGAN CARD
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul
                          const Text('Your Current Balance', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),

                          // Baris Diamond
                          Row(
                            children: [
                              const Icon(Icons.diamond, size: 24, color: Colors.cyan),
                              const SizedBox(width: 8),
                              Text('$_currentDiamondBalance', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              const Text(' Diamonds', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 5),

                          // Baris GP
                          Row(
                            children: [
                              const Icon(Icons.monetization_on, size: 24, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text('$_currentGpBalance', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              const Text(' Green Points', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),


                // 2. Grid View of Items
                _buildShopItemGrid(items, _currentGpBalance),

                // 3. Detail Panel
                if (_selectedItem != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildItemDetailPanel(_selectedItem!, _currentGpBalance),
                  ),

                const SizedBox(height: 80), // Jarak di bawah
              ],
            ),
          );
        },
      ),
      // Tombol FAB untuk Top-Up/Convert (Sekarang ada di sini)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTopUpConvertModal,
        label: const Text('Top Up / Convert', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.diamond, color: Colors.white),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }
}
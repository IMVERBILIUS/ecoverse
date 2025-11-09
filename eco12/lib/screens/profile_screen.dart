// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../models/user_summary.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart'; 
import '../widgets/edit_profile_modal.dart';
import 'inventory_screen.dart'; 
import 'eco_shop_screen.dart'; // <-- Import screen Eco-Shop yang sekarang terpisah

// Fungsi helper yang sama dengan di modal untuk konsistensi ikon
IconData _getIconData(String? id) {
  switch (id) {
    case 'nature': return Icons.nature_people;
    case 'star': return Icons.star;
    case 'leaf': return Icons.eco;
    case 'tree': return Icons.park;
    case 'sun': return Icons.wb_sunny;
    case 'flower': return Icons.local_florist;
    default: return Icons.person;
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  Future<UserSummary?>? _userProfileFuture; 
  
  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }
  
  // Fungsi untuk refresh data profile
  void _refreshProfile() {
    setState(() {
      _userProfileFuture = _userService.fetchFullProfile();
    });
  }
  
  void _logout() async {
    await AuthService().logout();
    
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/', 
        (Route<dynamic> route) => false,
      );
    }
  }
  
  void _showEditModal(UserSummary summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditProfileModal(
        currentSummary: summary,
        onProfileUpdated: _refreshProfile, // Refresh setelah update berhasil
      ),
    );
  }

  // Widget Header Kustom (Dibuat Klikable)
  Widget _buildProfileHeader(BuildContext context, UserSummary summary, int xpProgress, int xpRequiredThisLevel) {
    String motto = summary.motto ?? "No personal motto set.";
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final double topPadding = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () => _showEditModal(summary), // SELURUH HEADER KLIKABLE UNTUK EDIT
      child: Container(
        color: primaryColor, 
        padding: EdgeInsets.fromLTRB(16, topPadding + 10, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Tombol Logout
                IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  onPressed: _logout,
                  tooltip: 'Logout',
                ),
              ],
            ),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Level & Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: secondaryColor,
                      child: Icon(_getIconData(summary.avatarId), size: 40, color: Colors.white), 
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          summary.level.toString(), 
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                
                // Nama & XP Bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.username, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white38,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: summary.progressFraction, 
                            backgroundColor: Colors.transparent,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$xpProgress / $xpRequiredThisLevel XP', 
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Personal Motto: "$motto"', 
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white.withOpacity(0.8))
            ),
          ],
        ),
      ),
    );
  }

  // Widget Bantuan: Baris Statistik
  Widget _buildStatRow(IconData icon, String label, String value) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: secondaryColor),
          const SizedBox(width: 15),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
  
  // Widget untuk menampilkan Core Stats
  Widget _buildStatCard(UserSummary summary) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ecoverse Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildStatRow(Icons.email, 'Email', summary.email ?? 'N/A'),
            _buildStatRow(Icons.grade, 'Rank', summary.rank),
            _buildStatRow(Icons.star, 'Total XP', summary.xp.toString()),
            _buildStatRow(Icons.paid, 'Green Points (GP)', summary.gp.toString()),
            _buildStatRow(Icons.directions_walk, 'Distance Walked (km)', summary.distanceWalked != null ? (summary.distanceWalked! / 1000).toStringAsFixed(2) : '0.00'),
            _buildStatRow(Icons.diamond, 'Diamonds', summary.diamonds.toString()),
          ],
        ),
      ),
    );
  }

  // Widget BARU: Tombol Kiri Kanan untuk Fitur
  Widget _buildFeatureButton(BuildContext context, IconData icon, String title, Color color, {required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserSummary?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Failed to load profile data. Please log in again.'));
          }

          final summary = snapshot.data!;
          final int xpRequiredThisLevel = summary.xpRequiredThisLevel;
          final int xpProgress = summary.xpProgress;


          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Custom Header
                _buildProfileHeader(context, summary, xpProgress, xpRequiredThisLevel), 
                
                // 2. Feature Links (GRID 2 Kolom)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.0, 
                    children: [
                      // Tombol 1: Inventory & Achievements (Mengganti nama)
                      _buildFeatureButton(
                        context, 
                        Icons.emoji_events, 
                        'My Inventory', // <-- Mengganti label
                        Colors.amber.shade700,
                        onTap: () {
                          // Navigasi ke InventoryScreen
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryScreen()));
                        },
                      ),
                      
                      // Tombol 2: Eco-Shop (Terpisah)
                      _buildFeatureButton(
                        context, 
                        Icons.shopping_bag, 
                        'Eco-Shop', // <-- Label Eco-Shop
                        Colors.blue.shade600,
                        onTap: () {
                          // Navigasi ke EcoShopScreen
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const EcoShopScreen()));
                        },
                      ),
                    ],
                  ),
                ),
                
                // 3. Core Stats Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildStatCard(summary),
                ),
                
                const SizedBox(height: 30), // Spacing di bagian bawah
              ],
            ),
          );
        },
      ),
    );
  }
}
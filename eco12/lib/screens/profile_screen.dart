// lib/screens/profile_screen.dart (Full Code)

import 'package:flutter/material.dart';
import '../models/user_summary.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart'; 
import '../widgets/edit_profile_modal.dart'; // Import modal edit

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
    
    // Kembali ke layar login setelah logout 
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/', // Asumsi root route (/) di main.dart mengarah ke LoginScreen
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

  // Widget Header yang meniru desain (XP Bar)
  Widget _buildProfileHeader(UserSummary summary, int xpProgress, int xpRequiredThisLevel) {
    String motto = summary.motto ?? "No personal motto set.";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Level & Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.teal, // Warna background avatar
                    child: Icon(_getIconData(summary.avatarId), size: 40, color: Colors.white), // <-- AVATAR ICON
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: summary.progressFraction, 
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.lightGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$xpProgress / $xpRequiredThisLevel XP', 
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Personal Motto: "$motto"', 
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700)
          ),
        ],
      ),
    );
  }

  // Widget Bantuan: Baris Statistik
  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.teal),
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
          ],
        ),
      ),
    );
  }

  // Widget Bantuan: Link ke Fitur Lain
  Widget _buildFeatureLink(BuildContext context, IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigating to $title...'))
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco-Warrior Profile'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit), // Tombol Edit Profile
            onPressed: () {
                _userProfileFuture?.then((summary) {
                    if (summary != null) {
                        _showEditModal(summary);
                    }
                });
            },
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(summary, xpProgress, xpRequiredThisLevel),
                
                const Divider(height: 30),

                _buildStatCard(summary),
                
                const SizedBox(height: 20),
                
                _buildFeatureLink(context, Icons.star, 'Achievements (3 Unlocked)', Colors.amber),
                _buildFeatureLink(context, Icons.shopping_bag, 'Eco-Shop & Inventory', Colors.blue),
              ],
            ),
          );
        },
      ),
    );
  }
}
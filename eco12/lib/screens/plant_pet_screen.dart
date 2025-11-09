// lib/screens/plant_pet_screen.dart

import 'package:flutter/material.dart';
import '../models/plant_pet.dart';
import '../services/plant_pet_service.dart';

// --- THEME CONSTANTS ---
// Green is the dominant color of EcoVerse (like Blue in Pokemon Go's UI)
const Color primaryGreen = Color(0xFF2E7D32); // Deep Forest Green (Primary Frame/Borders)
const Color secondaryTeal = Color(0xFF00BFA5); // Vibrant Teal (Active Status/Hatching Progress)
const Color gpGold = Color(0xFFFFC107); // Gold for Green Points (Currency, similar to Stardust/Candy)
const Color backgroundLight = Color(0xFFF5F5F5); 
const Color backgroundDark = Color(0xFFE0F2F1);

// Helper for Rarity Styling (Game Element: Rarity/Tiers)
Map<String, dynamic> _getRarityTheme(String rarity) {
  final lowerRarity = rarity.toLowerCase();
  if (lowerRarity.contains('exotic')) {
    // Exotic/Legendary equivalent
    return {'color': Colors.purple.shade700, 'icon': Icons.local_fire_department, 'name': 'Exotic Apex'};
  }
  if (lowerRarity.contains('rare')) {
    // Rare equivalent
    return {'color': Colors.blue.shade600, 'icon': Icons.star_rate_rounded, 'name': 'Rare Bloom'};
  }
  // Common equivalent
  return {'color': Colors.brown.shade400, 'icon': Icons.filter_vintage, 'name': 'Common Wildflower'};
}

class PlantPetScreen extends StatefulWidget {
  const PlantPetScreen({super.key});

  @override
  State<PlantPetScreen> createState() => _PlantPetScreenState();
}

class _PlantPetScreenState extends State<PlantPetScreen> with SingleTickerProviderStateMixin {
  final PlantPetService _petService = PlantPetService();
  
  Future<PlantPet?>? _activePetFuture;
  Future<List<PlantPet>>? _inventoryFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _loadData() {
    setState(() {
      _activePetFuture = _petService.fetchPlantPet();
      _inventoryFuture = _petService.fetchInventory();
    });
  }

  void _setActivePet(String petId) async {
    setState(() {
      _inventoryFuture = null; 
      _activePetFuture = null;
    });

    bool success = await _petService.setActivePet(petId);
    
    if (success) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Companion set as Eco-Buddy!')), // Pokemon Go Terminology: Buddy
      );
      _loadData();
    } else {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to set companion. Retrying data load.'), backgroundColor: Colors.red),
      );
      _loadData();
    }
  }
  
  void _handleEvolvePet(String petId) async {
    if(mounted) showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
        final response = await _petService.evolvePet(petId); 
        
        if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response['msg'] ?? 'Evolution failed!'), 
                  backgroundColor: response['newStage'] != null ? secondaryTeal : Colors.red),
            );
            _loadData();
        }
    } catch (e) {
        if (mounted) Navigator.of(context).pop();
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Network error during evolution.'), backgroundColor: Colors.red),
        );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Widget Bantuan: Menampilkan Pet Inventory (Pokemon Go Style: Egg/Seed Hatching List)
  Widget _buildPetInventory(Future<List<PlantPet>>? future, String activePetId) {
    return FutureBuilder<List<PlantPet>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || future == null) { 
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Your Inventory is empty! Purchase Eco-Seeds from the Eco-Shop to start growing companions.')));
        }

        // Inventory list (Non-Active Pets)
        final inventory = snapshot.data!.where((pet) => !pet.isActive).toList();

        if (inventory.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('All companions are currently active or not available.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              // Pokemon Go Terminology: "Awaiting Activation"
              child: Text('Companion Inventory (Awaiting Activation)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen)),
            ),
            ...inventory.map((pet) {
              final rarityTheme = _getRarityTheme(pet.rarity);
              final rarityColor = rarityTheme['color'] as Color;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: rarityColor.withOpacity(0.5), width: 2),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  // Pokemon Go Terminology: Seed/Egg Icon
                  leading: Icon(Icons.grass_outlined, color: rarityColor, size: 30), 
                  title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Rarity: ${rarityTheme['name']} | Stage: ${pet.growthStage}', style: TextStyle(color: rarityColor)),
                  
                  trailing: ElevatedButton(
                    onPressed: () => _setActivePet(pet.id),
                    style: ElevatedButton.styleFrom(backgroundColor: secondaryTeal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10)),
                    child: const Text('ACTIVATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), 
                  ),
                  
                  children: <Widget>[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Passive Buffs:', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)),
                          const SizedBox(height: 8),
                          ...pet.buffs.entries.map((entry) => _buildStatRow(Icons.bolt, entry.key, entry.value.toString(), isBuff: true)).toList(),
                          const SizedBox(height: 10),
                          // Growth/Hatching Progress
                          Text('Growth Progress: ${(pet.growthProgress * 100).toStringAsFixed(0)}%', style: TextStyle(color: Colors.grey.shade600)),
                          Text('Distance Required for next stage: ${(pet.distanceRequired / 1000).toStringAsFixed(1)} km'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // Widget Bantuan: Statistik User (Game Element: Player Stats)
  Widget _buildUserStatsCard(PlantPet pet) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [primaryGreen.withOpacity(0.15), backgroundLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryGreen.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Eco-Warrior Stats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen)),
              const Divider(color: primaryGreen),
              _buildStatRow(Icons.grade, 'Current Rank', pet.userRank),
              _buildStatRow(Icons.star_border, 'Experience Points (XP)', pet.userXP.toString()),
              // Pokemon Go Terminology: GP is our primary currency
              _buildStatRow(Icons.monetization_on, 'Green Points (GP)', pet.userGP.toString(), isGP: true),
              _buildStatRow(Icons.directions_walk, 'Total Distance Walked (km)', (pet.userDistanceWalked / 1000).toStringAsFixed(1)),
            ],
          ),
        ),
      );
    }
    
  // Widget Bantuan: Visual Pet (Pokemon Go Style: Buddy Icon/Visual)
  Widget _buildPetVisual(PlantPet pet) {
      final rarityTheme = _getRarityTheme(pet.rarity);
      final rarityColor = rarityTheme['color'] as Color;
      
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: rarityColor.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Icon(
              rarityTheme['icon'] as IconData,
              size: 140, 
              color: pet.growthStage > 1 ? secondaryTeal : Colors.brown,
            ),
          ),
          const SizedBox(height: 15),
          // Pokemon Go Terminology: Buddy
          Text('ACTIVE ECO-BUDDY', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: secondaryTeal)),
          const SizedBox(height: 5),
          Text(pet.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text(
            'Rarity: ${rarityTheme['name']} | Stage: ${pet.growthStage}', 
            style: TextStyle(color: rarityColor, fontWeight: FontWeight.w700)
          ),
        ],
      );
    }

  // Widget Bantuan: Progress Pertumbuhan (Pokemon Go Style: Walking Progress)
  Widget _buildGrowthProgress(PlantPet pet, bool isMaxProgress) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isMaxProgress ? 'EVOLUTION READY!' : 'WALKING PROGRESS TO EVOLVE', // Thematic header
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isMaxProgress ? gpGold : primaryGreen),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: pet.growthProgress,
              backgroundColor: Colors.grey.shade300,
              color: isMaxProgress ? gpGold : secondaryTeal,
              minHeight: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              isMaxProgress 
                ? 'Your companion is ready to evolve! Claim new passive buffs!' 
                : 'Progress: ${(pet.growthProgress * 100).toStringAsFixed(0)}% (${((pet.distanceRequired - pet.userDistanceWalked).abs() / 1000).toStringAsFixed(1)} km remaining)',
              style: const TextStyle(fontSize: 15),
            ),
          ),
          // Evolve Button
          if (isMaxProgress)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gpGold.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [gpGold, Colors.amber.shade700], 
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _handleEvolvePet(pet.id),
                    icon: const Icon(Icons.upgrade, color: Colors.white, size: 24),
                    label: const Text('EVOLVE COMPANION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, 
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

  // Widget Bantuan: Daftar Buffs Aktif (Game Element: Passive Power-ups)
  Widget _buildBuffsList(PlantPet pet) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ExpansionTile(
          title: const Text('Active Passive Buffs', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)),
          initiallyExpanded: true,
          children: [
            ...pet.buffs.entries.map((entry) => _buildStatRow(Icons.bolt, entry.key, entry.value.toString(), isBuff: true)).toList(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Buffs provide passive benefits like increased XP gain or higher GP from deposits. ',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            )
          ],
        ),
      );
    }

  // Widget Bantuan: Baris Statistik
  Widget _buildStatRow(IconData icon, String label, String value, {bool isBuff = false, bool isGP = false}) {
      Color valueColor = isGP ? gpGold : (isBuff ? Colors.orange.shade700 : primaryGreen);
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, size: 22, color: valueColor),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
            Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: valueColor, fontSize: 16)),
          ],
        ),
      );
    }
  
  @override
  Widget build(BuildContext context) {
    final appBarColor = Theme.of(context).colorScheme.primary;
    final appBarTextColor = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundLight, backgroundDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('My Plant Companion', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
              backgroundColor: appBarColor,
              expandedHeight: 0,
              floating: true,
              pinned: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh, color: appBarTextColor),
                  onPressed: _loadData,
                ),
              ],
            ),
            
            FutureBuilder<PlantPet?>(
              future: _activePetFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                }
                
                final pet = snapshot.data;
                
                if (!snapshot.hasData || pet == null || pet.id == 'p0') {
                   return SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text('You currently do not have an Active Companion. Activate a pet from your Inventory below to start earning Buffs!', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          ),
                          _buildPetInventory(_inventoryFuture, 'p0'),
                        ],
                      ),
                   );
                }

                final isMaxProgress = pet.growthProgress >= 1.0;

                return SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildUserStatsCard(pet),
                            const SizedBox(height: 40),
                            _buildPetVisual(pet),
                            const SizedBox(height: 40),
                            _buildGrowthProgress(pet, isMaxProgress),
                            const SizedBox(height: 40),
                            _buildBuffsList(pet),
                          ],
                        ),
                      ),
                      
                      _buildPetInventory(_inventoryFuture, pet.id),
                      const SizedBox(height: 30),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
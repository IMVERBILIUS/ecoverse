// lib/screens/plant_pet_screen.dart

import 'package:flutter/material.dart';
import '../models/plant_pet.dart';
import '../services/plant_pet_service.dart';

class PlantPetScreen extends StatefulWidget {
  const PlantPetScreen({super.key});

  @override
  State<PlantPetScreen> createState() => _PlantPetScreenState();
}

class _PlantPetScreenState extends State<PlantPetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PlantPetService _petService = PlantPetService();
  
  // Futures are declared as nullable
  Future<PlantPet?>? _activePetFuture;
  Future<List<PlantPet>>? _inventoryFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }
  
  // Fungsi utama untuk memuat data
  void _loadData() {
    setState(() {
      _activePetFuture = _petService.fetchPlantPet();
      _inventoryFuture = _petService.fetchInventory();
    });
  }

  // Fungsi untuk mengganti pet aktif
  void _setActivePet(String petId) async {
    // 1. Set Futures menjadi null untuk memicu loading state secara instan
    setState(() {
      _inventoryFuture = null; 
      _activePetFuture = null;
    });

    bool success = await _petService.setActivePet(petId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet activated successfully!')),
      );
      _loadData(); // Reload semua data setelah ganti pet
      _tabController.animateTo(0); // Pindah ke tab Active Pet
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to activate pet. Retrying data load.')),
      );
      _loadData(); // Muat ulang data inventory jika gagal
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Widget Bantuan: Menampilkan Inventory List
  Widget _buildInventoryList(Future<List<PlantPet>>? future) {
    return FutureBuilder<List<PlantPet>>(
      future: future,
      builder: (context, snapshot) {
        // FIX: Periksa apakah future itu sendiri null (saat reload) atau waiting
        if (snapshot.connectionState == ConnectionState.waiting || future == null) { 
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Your inventory is empty! Use Green Points to acquire seeds.'));
        }

        final inventory = snapshot.data!;
        return ListView.builder(
          itemCount: inventory.length,
          itemBuilder: (context, index) {
            final pet = inventory[index];
            
            Color rarityColor;
            if (pet.rarity == 'Exotic') {
              rarityColor = Colors.purple;
            } else if (pet.rarity == 'Rare') {
              rarityColor = Colors.blue;
            } else {
              rarityColor = Colors.brown;
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              color: pet.isActive ? Colors.green.shade50 : Colors.white,
              child: ListTile(
                leading: Icon(
                  Icons.filter_vintage, 
                  color: rarityColor,
                ),
                title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Rarity: ${pet.rarity} | Stage: ${pet.growthStage}'),
                trailing: pet.isActive
                    ? const Text('ACTIVE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                    : ElevatedButton(
                        onPressed: () => _setActivePet(pet.id),
                        child: const Text('Activate'),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget Bantuan: Statistik User
  Widget _buildUserStatsCard(PlantPet pet) {
      return Card(
        elevation: 4,
        color: Colors.teal.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Eco-Warrior Rank: ${pet.userRank}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildStatRow(Icons.star, 'XP Total', pet.userXP.toString()),
              _buildStatRow(Icons.paid, 'Green Points (GP)', pet.userGP.toString()),
              _buildStatRow(Icons.directions_walk, 'Distance Walked (km)', (pet.userDistanceWalked / 1000).toStringAsFixed(1)),
            ],
          ),
        ),
      );
    }
    
  // Widget Bantuan: Visual Pet
  Widget _buildPetVisual(PlantPet pet) {
      return Column(
        children: [
          Icon(
            Icons.filter_vintage, 
            size: 100, 
            color: pet.growthStage > 1 ? Colors.green : Colors.brown,
          ),
          const SizedBox(height: 10),
          Text(pet.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Type: ${pet.type} | Stage: ${pet.growthStage} | Rarity: ${pet.rarity}', style: TextStyle(color: Colors.grey.shade600)),
        ],
      );
    }

  // Widget Bantuan: Progress Pertumbuhan
  Widget _buildGrowthProgress(PlantPet pet, bool isMaxProgress) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isMaxProgress ? 'READY TO EVOLVE!' : 'NEXT STAGE PROGRESS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isMaxProgress ? Colors.green : Colors.black),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: pet.growthProgress,
            backgroundColor: Colors.grey.shade300,
            color: isMaxProgress ? Colors.amber : Colors.green,
            minHeight: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              isMaxProgress ? 'Tap to evolve and get new buffs!' : '${(pet.growthProgress * 100).toStringAsFixed(0)}% (${(pet.distanceRequired - pet.userDistanceWalked).abs()}m remaining)',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (isMaxProgress)
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pet Evolved! New buffs unlocked.')));
                },
                child: const Text('Evolve Pet'),
              ),
            ),
        ],
      );
    }

  // Widget Bantuan: Daftar Buffs Aktif
  Widget _buildBuffsList(PlantPet pet) {
      return Card(
        elevation: 2,
        child: ExpansionTile(
          title: const Text('Active Buffs', style: TextStyle(fontWeight: FontWeight.bold)),
          initiallyExpanded: true,
          children: pet.buffs.entries.map((entry) => _buildStatRow(Icons.flash_on, entry.key, entry.value.toString(), isBuff: true)).toList(),
        ),
      );
    }

  // Widget Bantuan: Baris Statistik
  Widget _buildStatRow(IconData icon, String label, String value, {bool isBuff = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isBuff ? Colors.orange : Colors.teal),
            const SizedBox(width: 10),
            Expanded(child: Text(label)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco-Companion (Seed)'),
        backgroundColor: Colors.lightGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Pet'),
            Tab(text: 'Inventory'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Active Pet Detail
          FutureBuilder<PlantPet?>(
            future: _activePetFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              // Tangani kasus di mana tidak ada pet aktif (pet: null dari backend)
              if (snapshot.hasError || !snapshot.hasData || snapshot.data == null || snapshot.data!.id == 'p0') {
                return Center(child: Text('No active pet found. Activate one from Inventory.'));
              }
              final pet = snapshot.data!;
              final isMaxProgress = pet.growthProgress >= 1.0;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUserStatsCard(pet),
                    const SizedBox(height: 30),
                    _buildPetVisual(pet),
                    const SizedBox(height: 30),
                    _buildGrowthProgress(pet, isMaxProgress),
                    const SizedBox(height: 30),
                    _buildBuffsList(pet),
                  ],
                ),
              );
            },
          ),
          
          // Tab 2: Inventory List
          _buildInventoryList(_inventoryFuture),
        ],
      ),
    );
  }
}
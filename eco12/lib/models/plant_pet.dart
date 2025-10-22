// lib/models/plant_pet.dart (Full Code)

// Menggunakan latlong2, bukan google_maps_flutter
import 'package:latlong2/latlong.dart'; 

class PlantPet {
  final String id; // <-- ID pet
  final String name;
  final String type;
  final String rarity;
  final int growthStage;
  final double growthProgress; 
  final int distanceRequired;
  final Map<String, dynamic> buffs;
  final bool isActive; // <-- Status aktif pet

  // Data User yang digabungkan (diperlukan untuk Active Pet tab)
  final int userXP; 
  final int userGP;
  final int userDistanceWalked; 
  final String userRank;

  PlantPet({
    required this.id,
    required this.name,
    required this.type,
    required this.rarity,
    required this.growthStage,
    required this.growthProgress,
    required this.distanceRequired,
    required this.buffs,
    required this.isActive,
    required this.userXP,
    required this.userGP,
    required this.userDistanceWalked,
    required this.userRank,
  });

  factory PlantPet.fromJson(Map<String, dynamic> json) {
    // API /my-pet mengembalikan {pet: {...}, userDistance: X}
    // API /inventory mengembalikan [{petData}, {petData}]
    // Kita harus fleksibel dalam parsing.
    
    final petData = json['pet'] ?? json; // Jika 'pet' ada (dari /my-pet) atau langsung data pet (dari /inventory)
    
    final distance = json['userDistance'] as int? ?? 0;
    final xp = json['userXP'] as int? ?? 0;
    final gp = json['userGP'] as int? ?? 0;
    final rank = json['userRank'] as String? ?? 'Seeder';
    
    final required = petData['distanceRequired'] as int? ?? 1000;
    final progress = distance / required;

    return PlantPet(
      id: petData['_id'] as String? ?? 'p0', 
      name: petData['name'] ?? 'Eco Seedling',
      type: petData['type'] ?? 'Common',
      rarity: petData['rarity'] ?? 'Basic',
      growthStage: petData['growthStage'] ?? 1,
      distanceRequired: required,
      growthProgress: progress > 1.0 ? 1.0 : progress,
      buffs: petData['buffs'] as Map<String, dynamic>? ?? {'XP_Boost': 1.0},
      isActive: petData['isActive'] as bool? ?? false, 
      
      // Data User/Statis
      userXP: xp,
      userGP: gp,
      userDistanceWalked: distance,
      userRank: rank,
    );
  }
}
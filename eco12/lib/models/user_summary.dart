// lib/models/user_summary.dart

class UserSummary {
  final String username; 
  final String? email; 
  final int xp;
  final int gp;
  final String rank;
  
  // Data Leveling yang dihitung oleh API (Backend)
  final int level; 
  final int xpProgress; 
  final int xpRequiredThisLevel; 
  final double progressFraction; 
  
  // Field Profile Tambahan
  final int? distanceWalked;
  final String? motto; 
  final String? avatarId; 

  UserSummary({
    required this.username, 
    this.email,
    required this.xp, 
    required this.gp, 
    required this.rank,
    required this.level,
    required this.xpProgress,
    required this.xpRequiredThisLevel,
    required this.progressFraction,
    this.distanceWalked,
    this.motto,
    this.avatarId,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    // Digunakan untuk endpoint /summary dan /full-profile
    return UserSummary(
      username: json['username'] ?? 'Eco-Warrior',
      email: json['email'], // Hanya ada di /full-profile
      xp: json['XP'] as int? ?? 0,
      gp: json['GP'] as int? ?? 0,
      rank: json['rank'] ?? 'Seeder',
      
      // Data Leveling (diambil langsung dari API)
      level: json['level'] as int? ?? 1,
      xpProgress: json['xpProgress'] as int? ?? 0,
      xpRequiredThisLevel: json['xpRequiredThisLevel'] as int? ?? 1000,
      progressFraction: (json['progressFraction'] as num? ?? 0.0).toDouble(),
      
      // Field Profile Tambahan
      distanceWalked: json['distanceWalked'] as int?,
      motto: json['motto'],
      avatarId: json['avatarId'], // <-- FINAL: Sinkronisasi dengan field avatarId
    );
  }
}
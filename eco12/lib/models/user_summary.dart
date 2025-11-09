// lib/models/user_summary.dart (Full Code - FINAL FIX)

class UserSummary {
  final String username;
  final String? email;
  final int xp;
  final int gp;
  final int diamonds; // <-- Field Diamond
  final String rank;
  final int level; 
  final int xpProgress; 
  final int xpRequiredThisLevel; 
  final double progressFraction; 
  final int? distanceWalked;
  final String? motto;
  final String? avatarId;

  // Static leveling constants
  static const int BASE_XP = 1000;
  static const double MULTIPLIER = 1.75;
  
  // Calculated Leveling Data
  late final int xpForCurrentLevel;
  late final int xpForNextLevel;

  // Private constructor to assign final fields based on calculated values
  UserSummary._internal({
    required this.username, 
    this.email,
    required this.xp, 
    required this.gp, 
    required this.diamonds,
    required this.rank,
    required this.level,
    required this.xpProgress,
    required this.xpRequiredThisLevel,
    required this.progressFraction,
    this.distanceWalked,
    this.motto,
    this.avatarId,
    required this.xpForCurrentLevel,
    required this.xpForNextLevel,
  });

  // --- Leveling Calculation (Static Method) ---
  static Map<String, dynamic> _calculateLevelData(int xp) {
    int currentLevel = 1;
    double cumulativeXP = 0; 
    double levelXPRequired = BASE_XP.toDouble(); 

    while (xp >= cumulativeXP + levelXPRequired) {
      cumulativeXP += levelXPRequired;
      levelXPRequired *= MULTIPLIER;
      currentLevel++;
    }

    int xpRequiredThisLevel = (levelXPRequired - (levelXPRequired / MULTIPLIER)).toInt();
    if (currentLevel == 1) xpRequiredThisLevel = BASE_XP;
    
    int progressXP = xp - cumulativeXP.toInt(); 
    
    int xpRequiredThisLevelCalculated = (BASE_XP * (currentLevel == 1 ? 1 : MULTIPLIER * (currentLevel - 1))).toInt();


    return {
      'level': currentLevel,
      'xpForCurrentLevel': cumulativeXP.toInt(),
      'xpForNextLevel': (cumulativeXP + xpRequiredThisLevel).toInt(),
      'xpProgress': progressXP,
      'xpRequiredThisLevel': xpRequiredThisLevelCalculated,
      'progressFraction': xpRequiredThisLevelCalculated > 0 ? progressXP / xpRequiredThisLevelCalculated : 0.0,
    };
  }
  // ---------------------------------------------------------

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    final int xpValue = json['XP'] as int? ?? 0;
    
    // --- CRITICAL FIX: Ensure parsing uses num (number) then convert to Int ---
    // Mongoose sends greenPoints/diamonds as top-level keys
    
    // GP Parsing (Sudah stabil)
    final int gpValue = json['greenPoints'] as int? ?? (json['GP'] as int? ?? 0); 
    
    // DIAMOND Parsing (FIX: Menggunakan key 'diamonds' dan .toInt() yang aman)
    final int diamondValue = (json['diamonds'] as num? ?? 0).toInt(); 
    
    final calculatedData = _calculateLevelData(xpValue);

    return UserSummary._internal(
      username: json['username'] ?? 'Eco-Warrior',
      email: json['email'],
      xp: xpValue,
      
      gp: gpValue, 
      diamonds: diamondValue, // <-- Menggunakan nilai yang sudah diparsing
      
      rank: json['rank'] ?? 'Seeder',
      distanceWalked: json['distanceWalked'] as int?,
      motto: json['motto'],
      avatarId: json['avatarId'],

      level: calculatedData['level'],
      xpProgress: calculatedData['xpProgress'],
      xpRequiredThisLevel: calculatedData['xpRequiredThisLevel'],
      progressFraction: calculatedData['progressFraction'],
      xpForCurrentLevel: calculatedData['xpForCurrentLevel'],
      xpForNextLevel: calculatedData['xpForNextLevel'],
    );
  }
}
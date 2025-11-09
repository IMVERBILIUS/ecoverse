// lib/models/quest.dart (Full Code - Final Connection)

class Quest {
  final String id;
  final String title;
  final String type; // Daily, Weekly, Event
  final String objectiveType; // criteria (e.g., walk_m, collect_kg)
  final int threshold; 
  final int xpReward;
  final int gpReward;
  final double userProgress; // Progress user (0.0 to 1.0)

  Quest({
    required this.id,
    required this.title,
    required this.type,
    required this.objectiveType,
    required this.threshold,
    required this.xpReward,
    required this.gpReward,
    required this.userProgress,
  });

  // Fungsi BARU: Menghitung progress berdasarkan statistik pengguna
  static double calculateProgress(Quest quest, Map<String, dynamic> userStats) {
    num currentCount = 0; 
    
    // Tentukan nilai currentCount berdasarkan objectiveType
    switch (quest.objectiveType) {
      case 'walk_m':
        currentCount = (userStats['distanceWalked'] as int? ?? 0);
        break;
      case 'collect_kg':
        currentCount = (userStats['totalCollected'] as int? ?? 0); // Data dari submit/deposit
        break;
      case 'events_joined':
        currentCount = (userStats['eventsJoined'] as int? ?? 0);
        break;
      case 'level':
        currentCount = (userStats['currentLevel'] as int? ?? 1);
        break;
      default:
        currentCount = 0;
    }
    
    // Hitung fraksi progress (current / threshold)
    double progress = currentCount / quest.threshold;
    return progress.clamp(0.0, 1.0); // Pastikan nilainya antara 0 dan 1
  }

  // Factory Constructor untuk parsing JSON dari API
  factory Quest.fromJson(Map<String, dynamic> json, Map<String, dynamic> userStats) {
    final quest = Quest(
      id: json['_id'],
      title: json['title'],
      type: json['type'],
      objectiveType: json['criteria'] ?? 'walk_m', // Menggunakan 'criteria' dari backend
      threshold: json['threshold'] ?? 1,
      xpReward: json['gpReward'] ?? 0, 
      gpReward: json['gpReward'] ?? 0, 
      userProgress: 0.0, // Progress default
    );
    
    // Hitung progress saat parsing menggunakan statistik yang diterima
    final progress = calculateProgress(quest, userStats);
    
    // Kembalikan objek Quest yang sudah memiliki progress terhitung
    return Quest(
        id: quest.id,
        title: quest.title,
        type: quest.type,
        objectiveType: quest.objectiveType,
        threshold: quest.threshold,
        xpReward: quest.xpReward,
        gpReward: quest.gpReward,
        userProgress: progress, // <-- Progress yang terhubung
    );
  }
}
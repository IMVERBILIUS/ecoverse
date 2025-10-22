// lib/models/quest.dart
class Quest {
  final String id;
  final String title;
  final String type; // Daily, Weekly, Event
  final String objectiveType;
  final int targetValue;
  final int xpReward;
  final int gpReward;
  final double userProgress; // Progress user (0.0 to 1.0)

  Quest({
    required this.id,
    required this.title,
    required this.type,
    required this.objectiveType,
    required this.targetValue,
    required this.xpReward,
    required this.gpReward,
    required this.userProgress,
  });

  // Contoh factory constructor untuk data dummy/API
  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['_id'],
      title: json['title'],
      type: json['type'],
      objectiveType: json['objectiveType'],
      targetValue: json['targetValue'],
      xpReward: json['xpReward'],
      gpReward: json['gpReward'],
      // User progress harus diambil dari User Document atau API terpisah
      userProgress: 0.5, // Ganti dengan logika API
    );
  }
}
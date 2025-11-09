// lib/models/achievement.dart (Full Code)

class Achievement {
  final String id;
  final String title;
  final String description;
  final String criteria;
  final int threshold;
  final int gpReward;
  final String badgeIcon;
  final double currentProgress; // Progress (0.0 to 1.0)
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.criteria,
    required this.threshold,
    required this.gpReward,
    required this.badgeIcon,
    required this.currentProgress,
    required this.isUnlocked,
  });

  factory Achievement.fromJson(Map<String, dynamic> json, Map<String, dynamic> userStats) {
    // Determine progress based on user stats (SIMULATION)
    double progress = 0.0;
    
    // In a real app, this logic would live on the server!
    switch (json['criteria']) {
      case 'collect_kg':
        progress = (userStats['total_collected'] ?? 0) / json['threshold'];
        break;
      case 'walk_km':
        progress = (userStats['distanceWalked'] ?? 0) / (json['threshold'] * 1000); // Distance in meters
        break;
      case 'events_joined':
        progress = (userStats['events_joined'] ?? 0) / json['threshold'];
        break;
    }
    progress = progress.clamp(0.0, 1.0); // Clamp progress between 0 and 1

    return Achievement(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      criteria: json['criteria'],
      threshold: json['threshold'],
      gpReward: json['gpReward'],
      badgeIcon: json['badgeIcon'],
      currentProgress: progress,
      isUnlocked: progress >= 1.0,
    );
  }
}
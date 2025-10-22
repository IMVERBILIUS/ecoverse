// lib/models/leaderboard_entry.dart (Full Code)

class LeaderboardEntry {
  final String id;
  final String username;
  final String rank;
  final int gp;
  final int xp;
  final String? avatarId;

  LeaderboardEntry({
    required this.id,
    required this.username,
    required this.rank,
    required this.gp,
    required this.xp,
    this.avatarId,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['_id'],
      username: json['username'] ?? 'Anonymous',
      rank: json['currentRank'] ?? 'Seeder',
      gp: json['greenPoints'] ?? 0,
      xp: json['XP'] ?? 0,
      avatarId: json['avatarId'],
    );
  }
}
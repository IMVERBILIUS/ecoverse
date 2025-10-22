// lib/services/leaderboard_service.dart (Full Code)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/leaderboard_entry.dart';
import 'api_service.dart';
import 'auth_service.dart';

class LeaderboardService {
  final AuthService _authService = AuthService();
  static const String _leaderboardUrl = '${ApiService.baseApiUrl}/leaderboards/top-users';

  Future<List<LeaderboardEntry>> fetchLeaderboard({String category = 'GP'}) async {
    final token = await _authService.getToken();
    if (token == null) return [];

    try {
      // Tambahkan category dan limit ke query parameter
      final uri = Uri.parse('$_leaderboardUrl?category=$category&limit=50');
      
      final response = await http.get(
        uri,
        headers: {
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => LeaderboardEntry.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
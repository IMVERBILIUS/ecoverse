// lib/services/quest_service.dart (Full Code - FINAL)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quest.dart';
import 'api_service.dart';
import 'auth_service.dart';

class QuestService {
  final AuthService _authService = AuthService();

  Future<List<Quest>> fetchActiveQuests() async {
    final token = await _authService.getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseApiUrl}/quests/active'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> questJsonList = jsonResponse['quests'] ?? [];
        final Map<String, dynamic> userStats = jsonResponse['userStats'] ?? {}; // <-- Ambil userStats
        
        // Passing userStats saat mapping
        return questJsonList.map((json) => Quest.fromJson(json, userStats)).toList();

      } else {
        print('QuestService: Failed to fetch quests. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('QuestService Network Error: $e');
      return [];
    }
  }
}
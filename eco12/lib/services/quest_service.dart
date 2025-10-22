// lib/services/quest_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quest.dart';
import 'api_service.dart';
import 'auth_service.dart';

class QuestService {
  final AuthService _authService = AuthService();

  // Endpoint API untuk mengambil daftar misi
  static const String _activeQuestsUrl = '${ApiService.baseApiUrl}/quests/active';

  Future<List<Quest>> fetchActiveQuests() async {
    // 1. Dapatkan Token JWT
    final token = await _authService.getToken();
    if (token == null) {
      print('QuestService: Authentication token missing.');
      // Kembalikan list kosong jika user belum login
      return []; 
    }

    try {
      final response = await http.get(
        Uri.parse(_activeQuestsUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token, // Kirim token untuk otentikasi
        },
      );

      if (response.statusCode == 200) {
        // Sukses: Parsing JSON menjadi List<Quest>
        final List<dynamic> jsonList = jsonDecode(response.body);
        
        // PENTING: Untuk MVP, kita simulasikan userProgress di sini.
        // Di versi final, API akan mengirim data progress user yang sudah digabungkan.
        return jsonList.map((json) {
          // Tambahkan data progress dummy sementara
          json['userProgress'] = 0.5; 
          
          return Quest.fromJson(json);
        }).toList();

      } else if (response.statusCode == 401) {
        print('QuestService: Token invalid or expired.');
        // TODO: Implementasi logout paksa jika token invalid
        return [];
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
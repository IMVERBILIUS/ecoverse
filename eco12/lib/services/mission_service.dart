// lib/services/mission_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'auth_service.dart';

class MissionService {
  final AuthService _authService = AuthService();

  /// Submits the deposit data (quantities of sorted trash) to the backend for reward processing.
  Future<Map<String, dynamic>> submitDeposit({
    required String ecoSpotId,
    required Map<String, int> quantities, // Data sorted by the user
  }) async {
    // LANGKAH 1: Dapatkan Token (KEMBALI KE JWT MODE)
    final token = await _authService.getToken(); 
    if (token == null) {
      return {'success': false, 'error': 'Authentication required.', 'msg': 'Authentication required.'};
    }

    try {
      final response = await http.post(
        // PENTING: Panggil endpoint baru
        Uri.parse('${ApiService.baseApiUrl}/missions/submit/deposit'), 
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token, // Kirim token untuk otentikasi
        },
        body: jsonEncode({
          'ecoSpotId': ecoSpotId, 
          'quantities': quantities, // <-- KIRIM DATA SAMPAH TERPISAH
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Sukses
        return {'success': true, 'xp': data['xp'], 'gp': data['gp']};
      } else {
        // Gagal, kirim pesan error dari Express (misalnya: 401 atau 400)
        return {'success': false, 'error': data['msg'] ?? 'Server error during submission.'};
      }
    } catch (e) {
      print('HTTP Mission Service Error: $e');
      return {'success': false, 'error': 'Connection error. Is the server running?'};
    }
  }
}
// lib/services/mission_service.dart (Full Code - FINAL)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'auth_service.dart';

class MissionService {
  final AuthService _authService = AuthService();
  
  // Endpoint URLs
  static const String _depositUrl = '${ApiService.baseApiUrl}/missions/submit/deposit';
  static const String _reportUrl = '${ApiService.baseApiUrl}/missions/report-issue'; // <-- New URL

  // --- FUNGSI SUBMIT REPORT ISSUE (YANG HILANG) ---
  Future<String> submitReport({
    required String ecoSpotId,
    required String reportType,
    required String description,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return 'Authentication required.';

    try {
      final response = await http.post(
        Uri.parse(_reportUrl),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({
          'ecoSpotId': ecoSpotId,
          'reportType': reportType,
          'description': description,
        }),
      );
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['msg'] ?? 'Issue reported successfully.';
      } else {
        return data['msg'] ?? 'Failed to submit report.';
      }
    } catch (e) {
      return 'Network connection error.';
    }
  }


  // --- FUNGSI SUBMIT DEPOSIT (Tetap Sama) ---
  Future<Map<String, dynamic>> submitDeposit({
    required String ecoSpotId,
    required Map<String, int> quantities, 
  }) async {
    final token = await _authService.getToken(); 
    if (token == null) return {'success': false, 'error': 'Authentication required.'};

    try {
      final response = await http.post(
        Uri.parse(_depositUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'ecoSpotId': ecoSpotId, 
          'quantities': quantities, 
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'xp': data['xp'], 'gp': data['gp']};
      } else {
        return {'success': false, 'error': data['msg'] ?? 'Server error during submission.'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network connection error.'};
    }
  }
}
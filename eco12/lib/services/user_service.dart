// lib/services/user_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_summary.dart';
import 'api_service.dart';
import 'auth_service.dart';

class UserService {
  final AuthService _authService = AuthService();
  
  // Base URLs
  static const String _summaryUrl = '${ApiService.baseApiUrl}/user-data/summary';
  static const String _fullProfileUrl = '${ApiService.baseApiUrl}/user-data/full-profile'; 
  static const String _updateProfileUrl = '${ApiService.baseApiUrl}/user-data/profile';
  static const String _updateDistanceUrl = '${ApiService.baseApiUrl}/user-data/update-distance'; 
  
  // New Diamond URLs
  static const String _simulateTopUpUrl = '${ApiService.baseApiUrl}/user-data/simulate-topup'; 
  static const String _convertDiamondUrl = '${ApiService.baseApiUrl}/user-data/convert-diamond'; 

  // Fungsi untuk mengambil data ringkasan pengguna (digunakan MapScreen)
  Future<UserSummary?> fetchUserSummary() async {
    final token = await _authService.getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse(_summaryUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return UserSummary.fromJson(jsonResponse);
      } else {
        print('UserService: Failed to fetch summary. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('UserService Network Error (Summary): $e');
      return null;
    }
  }

  // Fungsi untuk mengambil data profil lengkap (digunakan ProfileScreen)
  Future<UserSummary?> fetchFullProfile() async {
    final token = await _authService.getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse(_fullProfileUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return UserSummary.fromJson(jsonResponse); 
      } else {
        print('UserService: Failed to fetch full profile. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('UserService Network Error (Full Profile): $e');
      return null;
    }
  }

  // --- FUNGSI UPDATE TEXT PROFILE (Termasuk Avatar ID) ---
  Future<bool> updateProfile({
    String? username, 
    String? email, 
    String? motto,
    String? avatarId, 
  }) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final body = jsonEncode({
      'username': username,
      'email': email,
      'motto': motto,
      'avatarId': avatarId, // <-- Mengirim Avatar ID
    });

    try {
      final response = await http.put(
        Uri.parse(_updateProfileUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: body,
      );

      return response.statusCode == 200;

    } catch (e) {
      print('Network Error (Update Profile): $e');
      return false;
    }
  }

  // --- FUNGSI UPDATE JARAK JALAN KAKI ---
  Future<bool> updateDistance(double distanceDelta) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse(_updateDistanceUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'distanceDelta': distanceDelta.toInt(),
        }),
      );

      return response.statusCode == 200;

    } catch (e) {
      print('Network Error (Update Distance): $e');
      return false;
    }
  }

  // --- FUNGSI BARU: SIMULASI TOP UP DIAMOND ---
  Future<String> simulateTopUp(int amount) async {
    final token = await _authService.getToken();
    if (token == null) return 'Authentication required.';

    try {
      final response = await http.post(
        Uri.parse(_simulateTopUpUrl),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({'amount': amount}),
      );
      
      final data = jsonDecode(response.body);
      return response.statusCode == 200 ? data['msg'] : (data['msg'] ?? 'Top-up failed.');
    } catch (e) {
      return 'Network connection error.';
    }
  }

  // --- FUNGSI BARU: KONVERSI DIAMOND KE GP ---
  Future<String> convertDiamond(int amount) async {
    final token = await _authService.getToken();
    if (token == null) return 'Authentication required.';

    try {
      final response = await http.post(
        Uri.parse(_convertDiamondUrl),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({'amount': amount}),
      );
      
      final data = jsonDecode(response.body);
      return response.statusCode == 200 ? data['msg'] : (data['msg'] ?? 'Conversion failed.');
    } catch (e) {
      return 'Network connection error.';
    }
  }
}
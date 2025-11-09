// lib/services/social_service.dart (Full Code)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'auth_service.dart';

class SocialService {
  final AuthService _authService = AuthService();
  static const String _baseUrl = '${ApiService.baseApiUrl}/social';

  // Helper untuk mendapatkan token
  Future<String?> _getToken() => _authService.getToken();

  // 1. Search Users
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final token = await _getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?query=$query'),
        headers: {'x-auth-token': token},
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 2. Send Friend Request
  Future<String> sendRequest(String targetId) async {
    final token = await _getToken();
    if (token == null) return 'Authentication required.';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/request/$targetId'),
        headers: {'x-auth-token': token},
      );
      final data = jsonDecode(response.body);
      return data['msg'] ?? 'Request failed.';
    } catch (e) {
      return 'Network error.';
    }
  }
  
  // 3. Accept Friend Request
  Future<String> acceptRequest(String senderId) async {
    final token = await _getToken();
    if (token == null) return 'Authentication required.';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/accept/$senderId'),
        headers: {'x-auth-token': token},
      );
      final data = jsonDecode(response.body);
      return data['msg'] ?? 'Acceptance failed.';
    } catch (e) {
      return 'Network error.';
    }
  }

  // 4. Get Friends and Requests
  Future<Map<String, dynamic>> getFriendsData() async {
    final token = await _getToken();
    if (token == null) return {'friends': [], 'requests': []};

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/friends'),
        headers: {'x-auth-token': token},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'friends': [], 'requests': []};
    } catch (e) {
      return {'friends': [], 'requests': []};
    }
  }
}
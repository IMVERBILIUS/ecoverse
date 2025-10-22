// lib/services/event_service.dart (Full Code - Final)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/community_event.dart';
import 'api_service.dart';
import 'auth_service.dart';

class EventService {
  final AuthService _authService = AuthService();
  static const String _upcomingUrl = '${ApiService.baseApiUrl}/events/upcoming';
  // Hapus static const String _locationsUrl

  // Helper: Adds padding '=' characters to Base64Url string if needed
  String _addPadding(String input) {
    String output = input;
    int missing = output.length % 4;
    if (missing != 0) {
      output += '=' * (4 - missing);
    }
    return output;
  }

  // Helper to fetch the current User ID from the token
  Future<String?> getUserId() async {
    final token = await _authService.getToken();
    if (token == null) return null;
    
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final String payloadBase64 = parts[1]; 
      final String paddedPayload = _addPadding(payloadBase64); 

      final payload = utf8.decode(base64Url.decode(paddedPayload));
      final Map<String, dynamic> data = jsonDecode(payload);
      return data['user']['id'];
    } catch (e) {
      return null;
    }
  }

  // Fetch upcoming events from API (Full Detail)
  Future<List<CommunityEvent>> fetchUpcomingEvents() async {
    final token = await _authService.getToken();
    final currentUserId = await getUserId();
    if (token == null || currentUserId == null) return [];

    try {
      final response = await http.get(
        Uri.parse(_upcomingUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => CommunityEvent.fromJson(json, currentUserId)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Join a specific event
  Future<String> joinEvent(String eventId) async {
    final token = await _authService.getToken();
    if (token == null) return 'Authentication required.';

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseApiUrl}/events/join/$eventId'),
        headers: {'x-auth-token': token},
      );
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return 'Success: You have joined the event!';
      } else {
        return data['msg'] ?? 'Failed to join event.';
      }

    } catch (e) {
      return 'Network connection error.';
    }
  }

  // FUNGSI BARU: Cancel Join Event
  Future<String> cancelJoinEvent(String eventId) async {
    final token = await _authService.getToken();
    if (token == null) return 'Authentication required.';

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseApiUrl}/events/cancel-join/$eventId'), // <-- URL BARU
        headers: {'x-auth-token': token},
      );
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return 'Success: Registration cancelled.';
      } else {
        return data['msg'] ?? 'Failed to cancel registration.';
      }

    } catch (e) {
      return 'Network connection error.';
    }
  }
}
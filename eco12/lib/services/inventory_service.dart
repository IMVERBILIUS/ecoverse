// lib/services/inventory_service.dart (Full Code - Final)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/achievement.dart';
import '../models/item.dart'; 
import 'api_service.dart';
import 'auth_service.dart';

class InventoryService {
  final AuthService _authService = AuthService();
  static const String _inventoryUrl = '${ApiService.baseApiUrl}/user-data/inventory';
  static const String _shopUrl = '${ApiService.baseApiUrl}/shop/items'; 
  static const String _buyUrl = '${ApiService.baseApiUrl}/shop/buy'; // Base buy URL

  // 1. Fetch User Inventory and Achievements
  Future<Map<String, dynamic>> fetchInventoryAndAchievements() async {
    final token = await _authService.getToken();
    if (token == null) return {'error': 'Unauthorized'};
    
    try {
        final response = await http.get(
        Uri.parse(_inventoryUrl),
        headers: {'x-auth-token': token},
        );

        if (response.statusCode == 200) {
            final jsonResponse = jsonDecode(response.body);
            final List<dynamic> achievementJson = jsonResponse['allAchievements'] ?? [];
            final Map<String, dynamic> userStats = jsonResponse['userStats'] ?? {};

            final List<Achievement> achievements = achievementJson.map(
                (json) => Achievement.fromJson(json, userStats)
            ).toList();
            
            return {
                'generalItems': jsonResponse['generalItems'] ?? [],
                'achievements': achievements,
                'userStats': userStats, // Return stats (including GP)
            };
        } else {
            return {'error': 'Failed to fetch data. Status: ${response.statusCode}'};
        }
    } catch (e) {
        return {'error': 'Network Error. Could not connect to API.'};
    }
  }

  // 2. Fetch Eco-Shop Items (Remains the same)
  Future<List<ShopItem>> fetchShopItems() async {
    final token = await _authService.getToken(); 
    if (token == null) return [];

    try {
        final response = await http.get(
        Uri.parse(_shopUrl),
        headers: {'x-auth-token': token},
        );

        if (response.statusCode == 200) {
            final List<dynamic> jsonList = jsonDecode(response.body);
            return jsonList.map((json) => ShopItem.fromJson(json)).toList();
        } else {
            return [];
        }
    } catch (e) {
        return [];
    }
  }

  // 3. Buy Item Function (NEW)
  Future<String> buyItem(String itemId) async {
    final token = await _authService.getToken();
    if (token == null) return 'Authentication required.';

    try {
        final response = await http.post(
            Uri.parse('$_buyUrl/$itemId'),
            headers: {'x-auth-token': token},
        );
        
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
            return 'Success: ${data['msg']}';
        } else {
            return data['msg'] ?? 'Purchase failed.';
        }
    } catch (e) {
        return 'Network connection error.';
    }
  }
}
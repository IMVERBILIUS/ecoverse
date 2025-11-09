// lib/services/plant_pet_service.dart (Full Code - FINAL FIX)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plant_pet.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'user_service.dart'; // <-- IMPORT UserService untuk fetch full user stats
import '../models/user_summary.dart'; // <-- IMPORT UserSummary

class PlantPetService {
    final AuthService _authService = AuthService();
    final UserService _userService = UserService(); // <-- Inisialisasi UserService
    static const String _petUrl = '${ApiService.baseApiUrl}/pets/my-pet';
    static const String _inventoryUrl = '${ApiService.baseApiUrl}/pets/inventory'; 
    static const String _setActivePetUrl = '${ApiService.baseApiUrl}/pets/set-active'; 
    static const String _evolveUrl = '${ApiService.baseApiUrl}/pets/evolve';

    // Helper untuk menggabungkan data statistik
    Future<Map<String, dynamic>?> _getCombinedPetData(Map<String, dynamic> petJson, UserSummary? summary) async {
        if (summary == null) return null;
        
        // Gabungkan data Pet dengan statistik yang diperlukan untuk kalkulasi
        final Map<String, dynamic> combined = {
            // Data Pet
            'pet': petJson,
            // Data User Stats
            'userDistance': summary.distanceWalked ?? 0,
            'userXP': summary.xp,
            'userGP': summary.gp,
            'userRank': summary.rank,
        };
        return combined;
    }


    Future<PlantPet?> fetchPlantPet() async {
        final token = await _authService.getToken();
        if (token == null) return null;

        try {
            final response = await http.get(
                Uri.parse(_petUrl),
                headers: {
                    'Content-Type': 'application/json',
                    'x-auth-token': token,
                },
            );

            if (response.statusCode == 200) {
                final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
                if (jsonResponse['pet'] == null) return null; 
                
                // Gunakan model dengan data lengkap
                return PlantPet.fromJson(jsonResponse);
            } else {
                return null;
            }
        } catch (e) {
            return null;
        }
    }
    
    // FUNGSI INVENTORY (Diperbaiki untuk mengambil user stats)
    Future<List<PlantPet>> fetchInventory() async {
        final token = await _authService.getToken();
        if (token == null) return [];
        
        // 1. Ambil statistik pengguna yang sedang login
        final userSummary = await _userService.fetchFullProfile();
        if (userSummary == null) return [];

        try {
            final response = await http.get(
                Uri.parse(_inventoryUrl),
                headers: {
                    'x-auth-token': token,
                },
            );

            if (response.statusCode == 200) {
                final List<dynamic> jsonList = jsonDecode(response.body);
                
                // 2. Map data inventory, menggabungkannya dengan current user distance
                return jsonList.map((petData) {
                    final Map<String, dynamic> combinedData = {
                        // Data Pet
                        'pet': petData,
                        // Data User Stats dari Full Profile
                        'userDistance': userSummary.distanceWalked,
                        'userXP': userSummary.xp,
                        'userGP': userSummary.gp,
                        'userRank': userSummary.rank,
                    };
                    return PlantPet.fromJson(combinedData);
                }).toList();
                
            } else {
                return [];
            }
        } catch (e) {
            return [];
        }
    }

    // FUNGSI SET ACTIVE PET (Tetap sama)
    Future<bool> setActivePet(String petId) async {
        final token = await _authService.getToken();
        if (token == null) return false;

        try {
            final response = await http.post(
                Uri.parse(_setActivePetUrl),
                headers: {
                    'Content-Type': 'application/json',
                    'x-auth-token': token,
                },
                body: jsonEncode({'petId': petId}),
            );

            return response.statusCode == 200;

        } catch (e) {
            return false;
        }
    }
    
    // FUNGSI EVOLVE PET
    Future<Map<String, dynamic>> evolvePet(String petId) async {
        final token = await _authService.getToken();
        if (token == null) return {'msg': 'Authentication required.'};

        try {
            final response = await http.post(
                Uri.parse('$_evolveUrl/$petId'),
                headers: {'x-auth-token': token},
            );
            
            final data = jsonDecode(response.body);

            if (response.statusCode == 200) {
                return {'msg': data['msg'], 'newStage': data['newStage']};
            } else {
                return {'msg': data['msg'] ?? 'Evolution failed.'};
            }

        } catch (e) {
            return {'msg': 'Network connection error.'};
        }
    }
}
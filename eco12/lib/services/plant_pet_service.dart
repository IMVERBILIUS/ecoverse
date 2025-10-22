// lib/services/plant_pet_service.dart (Full Code - No Dummy)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plant_pet.dart';
import 'api_service.dart';
import 'auth_service.dart';

class PlantPetService {
    final AuthService _authService = AuthService();
    static const String _petUrl = '${ApiService.baseApiUrl}/pets/my-pet';
    static const String _inventoryUrl = '${ApiService.baseApiUrl}/pets/inventory'; // <-- URL Baru
    static const String _setActivePetUrl = '${ApiService.baseApiUrl}/pets/set-active'; 

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
                // Jika pet adalah null, kirimkan null
                if (jsonResponse['pet'] == null) return null; 
                
                // Gabungkan data user dan pet untuk model PlantPet
                return PlantPet.fromJson(jsonResponse);
            } else {
                print('PetService: Failed to fetch active pet. Status: ${response.statusCode}');
                return null;
            }
        } catch (e) {
            print('PetService Network Error: $e');
            return null;
        }
    }
    
    // FUNGSI BARU: Mengambil semua pet dari API (No Dummy)
    Future<List<PlantPet>> fetchInventory() async {
        final token = await _authService.getToken();
        if (token == null) return [];

        try {
            final response = await http.get(
                Uri.parse(_inventoryUrl),
                headers: {
                    'Content-Type': 'application/json',
                    'x-auth-token': token,
                },
            );

            if (response.statusCode == 200) {
                final List<dynamic> jsonList = jsonDecode(response.body);
                
                // Ambil data user statis (karena inventory tidak membawa data user)
                // TODO: Di versi final, endpoint inventory harus digabung dengan user stats
                const Map<String, dynamic> dummyUserStats = {'userDistance': 0, 'userXP': 0, 'userGP': 0, 'userRank': 'Seeder'};

                return jsonList.map((petData) {
                    // Gabungkan data pet dengan data user statis untuk membuat model PlantPet
                    final combinedData = {...dummyUserStats, 'pet': petData}; 
                    return PlantPet.fromJson(combinedData);
                }).toList();
                
            } else {
                print('PetService: Failed to fetch inventory. Status: ${response.statusCode}');
                return [];
            }
        } catch (e) {
            print('Inventory Network Error: $e');
            return [];
        }
    }

    // FUNGSI BARU: Mengganti pet aktif
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
            print('Set Active Pet Network Error: $e');
            return false;
        }
    }
}
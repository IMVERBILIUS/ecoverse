// lib/services/ecospot_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ecospot.dart';
import 'api_service.dart';

class EcoSpotService {
  Future<List<EcoSpot>> fetchNearbyEcoSpots() async {
    // Panggil endpoint yang telah Anda buat di Express
    final response = await http.get(
      Uri.parse('${ApiService.mapEcoSpotsUrl}/nearby'),
    );

    if (response.statusCode == 200) {
      // Decode JSON array menjadi List<EcoSpot>
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => EcoSpot.fromJson(json)).toList();
    } else {
      // Handle error jika API gagal
      print('Failed to load EcoSpots. Status: ${response.statusCode}');
      return [];
    }
  }
}
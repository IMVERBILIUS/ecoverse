// lib/models/ecospot.dart
import 'package:latlong2/latlong.dart'; // Digunakan untuk koordinat OpenStreetMap

class EcoSpot {
  final String id;
  final String name;
  final String type; // e.g., 'Recycling Station', 'Litter Hotspot'
  final LatLng position; // Posisi GPS (Latitude, Longitude)

  EcoSpot({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
  });

  // Factory constructor untuk membuat objek EcoSpot dari data JSON (dari API Express)
  factory EcoSpot.fromJson(Map<String, dynamic> json) {
    // Catatan: MongoDB GeoJSON menyimpan [Longitude, Latitude]
    final coordinates = json['location']['coordinates'];
    final longitude = coordinates[0];
    final latitude = coordinates[1];

    return EcoSpot(
      id: json['_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      // Menggunakan LatLng dari latlong2
      position: LatLng(latitude, longitude), 
    );
  }
}
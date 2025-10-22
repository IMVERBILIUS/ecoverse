// lib/screens/map_screen.dart (Full Code - Integrasi Pelacakan Jarak)

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 
import 'package:geolocator/geolocator.dart'; 
import 'dart:async'; // <-- Import untuk StreamSubscription
import '../models/ecospot.dart';
import '../services/ecospot_service.dart';
import '../services/user_service.dart'; 
import '../models/user_summary.dart'; 
import 'qr_scanner_screen.dart'; 
import 'profile_screen.dart'; 

// Fungsi helper yang sama dengan di modal dan profile screen
IconData _getIconData(String? id) {
  switch (id) {
    case 'nature': return Icons.nature_people;
    case 'star': return Icons.star;
    case 'leaf': return Icons.eco;
    case 'tree': return Icons.park;
    case 'sun': return Icons.wb_sunny;
    case 'flower': return Icons.local_florist;
    default: return Icons.person;
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Tracking State
  StreamSubscription<Position>? _positionStreamSubscription; // <-- Subskripsi GPS
  Position? _lastKnownPosition;
  final UserService _userService = UserService(); 
  
  // Map/UI State
  LatLng _currentLocation = const LatLng(-6.2088, 106.8456); 
  List<EcoSpot> _ecoSpots = [];
  final EcoSpotService _ecoSpotService = EcoSpotService();
  Future<UserSummary?>? _userSummaryFuture; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMapData();
    _startLocationTracking(); // <-- MULAI TRACKING
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel(); // <-- HENTIKAN TRACKING SAAT KELUAR
    super.dispose();
  }

  // --- LOGIKA PELACAKAN JARAK ---
  void _startLocationTracking() {
    // Konfigurasi stream: jarak minimal 10m, setiap 10 detik
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update setiap 10 meter
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      
      // Update posisi peta secara lokal
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }

      // Hitung jarak dan kirim ke backend
      if (_lastKnownPosition != null) {
        double distance = Geolocator.distanceBetween(
          _lastKnownPosition!.latitude,
          _lastKnownPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        
        // Kirim update jarak ke backend
        if (distance >= 10) { // Kirim ke API hanya jika bergerak > 10m
          _userService.updateDistance(distance);
          _userSummaryFuture = _userService.fetchUserSummary(); // Refresh stats XP/GP
          // print('Distance moved: $distance meters');
        }
      }
      
      _lastKnownPosition = position;
    });
  }
  // --- AKHIR LOGIKA PELACAKAN JARAK ---

  Future<void> _initializeMapData() async {
    setState(() {
      _isLoading = true;
    });
    // Panggil _determinePosition untuk mendapatkan posisi awal
    await _determinePosition(); 
    await _loadEcoSpots();
    _userSummaryFuture = _userService.fetchUserSummary(); 
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _determinePosition() async {
    // ... (Logika izin tetap sama)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Location permissions are denied');
    }
    
    if (permission == LocationPermission.deniedForever) return Future.error('Location permissions are permanently denied.'); 

    Position position = await Geolocator.getCurrentPosition();
    // Atur posisi awal dan lastKnownPosition
    _lastKnownPosition = position;
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _loadEcoSpots() async {
    final spots = await _ecoSpotService.fetchNearbyEcoSpots();
    setState(() {
      _ecoSpots = spots;
    });
  }

  List<Marker> _buildEcoSpotMarkers() {
    return _ecoSpots.map((spot) {
      return Marker(
        point: spot.position, 
        width: 60,
        height: 60,
        child: IconButton(
          icon: Icon(
            spot.type == 'Recycling Station' ? Icons.recycling : Icons.delete,
            color: spot.type == 'Recycling Station' ? Colors.green.shade700 : Colors.red.shade700,
            size: 35,
          ),
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Memulai Misi ${spot.name}. Buka Kamera...'))
            );
            
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QrScannerScreen(missionType: spot.type), 
              ),
            );

            if (result == true) {
              _initializeMapData(); 
            }
          },
        ),
      );
    }).toList();
  }
  
  // Custom Widget: The embedded User Status Bar (Menggunakan Avatar ID)
  Widget _buildUserStatusBar(UserSummary summary) {
    
    final String xpText = '${summary.xpProgress} / ${summary.xpRequiredThisLevel} XP';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        ).then((_) => _initializeMapData()); // Refresh data saat kembali dari Profile
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.only(top: 40, left: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar dan Level
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.teal.shade700, 
                  child: Icon(_getIconData(summary.avatarId), color: Colors.white), // <-- AVATAR ICON DYNAMIC
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      summary.level.toString(), 
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            
            // Nama dan XP Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.username, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                // XP BAR & TEXT
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // XP Progress Bar
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: DecoratedBox( 
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.lightGreen.withOpacity(0.3), 
                                  Colors.lightGreen.shade700, 
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: [summary.progressFraction, summary.progressFraction],
                              ),
                            ),
                            child: LinearProgressIndicator(
                              value: summary.progressFraction, 
                              backgroundColor: Colors.transparent, 
                              color: Colors.transparent, 
                              minHeight: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // XP Text 
                      Text(
                        xpText, 
                        style: const TextStyle(fontSize: 10, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. FlutterMap (Peta)
          FlutterMap(
            options: MapOptions(
              initialCenter: _currentLocation, 
              initialZoom: 16.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ecoverse.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                  ),
                  ..._buildEcoSpotMarkers(),
                ],
              ),
            ],
          ),
          
          // 2. User Status Bar (Di atas Peta)
          FutureBuilder<UserSummary?>(
            future: _userSummaryFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Positioned(
                  top: 0,
                  left: 0,
                  child: SafeArea(
                    child: _buildUserStatusBar(snapshot.data!),
                  ),
                );
              }
              
              // Tampilkan ikon refresh saat data gagal dimuat atau loading
              return Positioned(
                  top: 50,
                  left: 20,
                  child: SafeArea(
                      child: IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.black, size: 30),
                          onPressed: _initializeMapData,
                      )
                  )
              );
            },
          ),
        ],
      ),
    );
  }
}
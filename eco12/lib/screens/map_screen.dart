// lib/screens/map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 
import 'package:geolocator/geolocator.dart'; 
import 'dart:async'; 
import '../models/ecospot.dart';
import '../services/ecospot_service.dart';
import '../services/user_service.dart'; 
import '../models/user_summary.dart'; 
import 'qr_scanner_screen.dart'; 
import 'profile_screen.dart'; 
import '../widgets/ecospot_detail_modal.dart'; 
import '../widgets/report_issue_modal.dart'; 
// import 'package:model_viewer_plus/model_viewer_plus.dart'; // <-- TIDAK DIGUNAKAN LAGI

// Fungsi helper yang sama dengan di modal untuk konsistensi ikon
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
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastKnownPosition;
  final UserService _userService = UserService(); 
  bool _isMoving = false; // <-- STATE BARU untuk Animasi
  
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
    _startLocationTracking(); 
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // --- LOGIKA PELACAKAN JARAK (MENGONTROL ANIMASI) ---
  void _startLocationTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update setiap 10 meter
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }

      if (_lastKnownPosition != null) {
        double distance = Geolocator.distanceBetween(
          _lastKnownPosition!.latitude,
          _lastKnownPosition!.longitude,
          position.latitude,
          position.longitude,
          );
        
        // Cek apakah pergerakan signifikan (untuk mengaktifkan animasi)
        if (distance >= 5) { 
          if (mounted && !_isMoving) { 
              setState(() { _isMoving = true; }); 
          }
          if (distance >= 10) {
              _userService.updateDistance(distance);
              _userSummaryFuture = _userService.fetchUserSummary(); 
          }
        } else {
             if (mounted && _isMoving) {
                 setState(() { _isMoving = false; });
             }
        }
      }
      
      _lastKnownPosition = position;
    });
  }
  // --- AKHIR LOGIKA PELACAKAN JARAK ---


  // FUNGSI UTAMA: Widget Marker Karakter 2D (MENGGUNAKAN IMAGE.ASSET)
  Widget _buildAvatarMarker(String? avatarId) {
      
      // Menggunakan file gambar (GIF untuk bergerak, JPG untuk diam)
      final String imageSrc = _isMoving ? 'assets/walk.gif' : 'assets/stay.jpg';

      return SizedBox(
          width: 80,
          height: 80,
          // Menggunakan Image.asset
          child: Image.asset(
              imageSrc,
              fit: BoxFit.contain,
              // Anda bisa menambahkan key untuk memaksa pembaruan jika ada masalah dengan GIF
              key: ValueKey(imageSrc), 
          ),
      );
  }


  Future<void> _initializeMapData() async {
    setState(() {
      _isLoading = true;
    });
    // Pastikan Anda juga memiliki izin lokasi di AndroidManifest.xml dan Info.plist!
    await _determinePosition(); 
    await _loadEcoSpots();
    _userSummaryFuture = _userService.fetchUserSummary(); 
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Location permissions are denied');
    }
    
    if (permission == LocationPermission.deniedForever) return Future.error('Location permissions are permanently denied.'); 

    Position position = await Geolocator.getCurrentPosition();
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

  // FUNGSI BARU: Menampilkan Report Issue Modal
  void _showReportIssueModal(String ecoSpotId) {
      showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReportIssueModal(ecoSpotId: ecoSpotId),
    ).then((_) {
        _initializeMapData();
    });
  }


  // FUNGSI BARU: Menampilkan Modal Detail EcoSpot dan menangani hasilnya
  void _showEcoSpotDetailModal(EcoSpot spot) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EcoSpotDetailModal(ecoSpot: spot),
    );

    if (result is Map && result['action'] == 'report') {
      _showReportIssueModal(result['ecoSpotId']);
    }
    else if (result == true) {
      _initializeMapData();
    }
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
          onPressed: () => _showEcoSpotDetailModal(spot), 
        ),
      );
    }).toList();
  }
  
  // Custom Widget: The embedded User Status Bar
  Widget _buildUserStatusBar(UserSummary summary) {
    
    final int xpRequired = summary.xpRequiredThisLevel; 
    final String xpText = '${summary.xpProgress} / $xpRequired XP';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        ).then((_) => _initializeMapData());
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
                  child: Icon(_getIconData(summary.avatarId), color: Colors.white), 
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
                  // MARKER AVATAR 2D
                  Marker(
                    point: _currentLocation,
                    width: 80, 
                    height: 80,
                    child: _buildAvatarMarker(null), // Menggunakan Image.asset
                  ),
                  // MARKER ECOSPOTS
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
              
              // Tampilkan ikon refresh saat data gagal dimuat
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
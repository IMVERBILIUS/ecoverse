// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
// Import screens
import 'map_screen.dart';        
import 'qr_scanner_screen.dart'; 
import 'missions_screen.dart';   
import 'plant_pet_screen.dart';  
import 'community_screen.dart';  

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Index halaman yang sedang aktif di Navigation Bar
  // Urutan: [0: Map, 1: Seed, 2: Scanner (Custom Icon), 3: Community, 4: Task]
  int _selectedIndex = 0; // Default ke Maps (index 0)

  // List of Widgets (Screens) yang akan ditampilkan
  final List<Widget> _widgetOptions = <Widget>[
    const MapScreen(),          // 0: Maps
    const PlantPetScreen(),     // 1: Seed/Pet
    const QrScannerPlaceholder(), // 2: Scanner (Placeholder)
    const CommunityScreen(),    // 3: Community Event
    const MissionsScreen(),     // 4: Task/Missions
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Jika user mengklik ikon Scanner (index 2)
      _openScanner();
    } else {
      // Untuk navigasi normal
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Fungsi untuk membuka QR Scanner
  void _openScanner() async {
    // Navigasi ke Scanner Screen
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QrScannerScreen(
          missionType: 'Quick Scan', 
        ), 
      ),
    );

    // Jika scan berhasil (mengembalikan true), refresh data
    if (result == true) {
      // Kembali ke MapScreen (index 0) setelah scan
      setState(() {
        _selectedIndex = 0;
      });
      // TODO: Panggil fungsi refresh data user/peta di MapScreen.
    }
  }

  // Widget Kustom untuk Ikon Scan di Tengah (Circle Button)
  Widget _buildCustomScanIcon() {
    return Container(
      padding: const EdgeInsets.only(bottom: 2.0), // Padding negatif untuk mengangkat
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.teal.shade400, // Warna latar belakang
          shape: BoxShape.circle,
          // BoxShadow bisa ditambahkan untuk efek 3D
        ),
        child: const Icon(
          Icons.qr_code_scanner, 
          size: 28, 
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definisi items yang akan ditampilkan di BottomNavigationBar
    List<BottomNavigationBarItem> items = [
      // 0: MAPS
      const BottomNavigationBarItem(
        icon: Icon(Icons.map, size: 28),
        label: 'Map',
      ),
      // 1: PLANT PETS
      const BottomNavigationBarItem(
        icon: Icon(Icons.eco, size: 28),
        label: 'Seed',
      ),
      // 2: SCANNER (Ikon Kustom)
      BottomNavigationBarItem(
        icon: _buildCustomScanIcon(), // Menggunakan ikon custom
        label: 'Scan',
      ),
      // 3: COMMUNITY
      const BottomNavigationBarItem(
        icon: Icon(Icons.people, size: 28),
        label: 'Community',
      ),
      // 4: TASKS
      const BottomNavigationBarItem(
        icon: Icon(Icons.assignment, size: 28),
        label: 'Task',
      ),
    ];
    
    return Scaffold(
      // FIX OVERFLOW KEYBOARD: Mencegah Scaffold resize saat keyboard muncul
      resizeToAvoidBottomInset: false, 

      // Body
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      
      // HAPUS FloatingActionButton

      // HAPUS BottomAppBar

      bottomNavigationBar: BottomNavigationBar(
        items: items,
        currentIndex: _selectedIndex, 
        selectedItemColor: Colors.teal.shade600,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed, // Tetap gunakan fixed
        onTap: _onItemTapped,
        // Tambahkan padding bawah untuk mengimbangi Safe Area (jika diperlukan)
        // Jika overflow muncul lagi, atur tinggi BottomNavigationBar
        // height: 60.0 + MediaQuery.of(context).padding.bottom
      ),
    );
  }
}

// Widget Placeholder: Digunakan di list _widgetOptions
class QrScannerPlaceholder extends StatelessWidget {
  const QrScannerPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Text('Scanner will open camera'); 
}
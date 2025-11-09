// lib/screens/deposit_form_screen.dart

import 'package:flutter/material.dart';
import '../services/mission_service.dart';
import 'dart:math'; 

class DepositFormScreen extends StatefulWidget {
  final String ecoSpotId;

  const DepositFormScreen({super.key, required this.ecoSpotId});

  @override
  State<DepositFormScreen> createState() => _DepositFormScreenState();
}

class _DepositFormScreenState extends State<DepositFormScreen> {
  final MissionService _missionService = MissionService();
  bool _isLoading = false;
  
  // State BARU untuk Item yang Terdeteksi
  final List<Map<String, dynamic>> _detectedItems = [];
  int _totalSimulatedPoints = 0; // Total poin simulasi

  @override
  void dispose() {
    super.dispose();
  }
  
  // --- LOGIKA SIMULASI PENAMBAHAN ITEM MANUAL (Fokus ke Botol Plastik) ---
  void _addItemManually() {
    // Hanya satu item yang disimulasikan: Plastic Bottle
    const item = {
      'name': 'Plastic Bottle', 
      'points': 5, 
      'icon': Icons.local_drink
    };
    
    setState(() {
      _detectedItems.add({
        'name': item['name'],
        'points': item['points'],
        'icon': item['icon']
      });
      _totalSimulatedPoints += item['points'] as int;
    });
  }
  // ---------------------------------------------
  
  void _confirmDeposit() async {
    if (_detectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item to confirm deposit.')),
      );
      return;
    }
    
    setState(() { _isLoading = true; });

    // Panggil service untuk mengirim data sampah
    // Mengirim TOTAL POINT/XP yang sudah disimulasikan sebagai pengganti QUANTITIES
    final rewardResult = await _missionService.submitDeposit(
      ecoSpotId: widget.ecoSpotId,
      quantities: {'total_points': _totalSimulatedPoints}, // Mengirim total poin
    );
    
    setState(() { _isLoading = false; });

    if (rewardResult['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('DEPOSIT SUCCESS! Gained ${rewardResult['xp']} XP and ${rewardResult['gp']} GP!'),
          backgroundColor: Colors.green,
        )
      );
      // Kembali ke MapScreen dengan hasil 'true'
      Navigator.pop(context, true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rewardResult['error'] ?? 'Deposit failed.'),
          backgroundColor: Colors.red,
        )
      );
    }
  }


  // Widget Bantuan untuk Daftar Item Terdeteksi
  Widget _buildDetectedItemRow(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(item['icon'], size: 24, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Expanded(child: Text(item['name'] as String, style: const TextStyle(fontSize: 16))),
          Text('+${item['points']} Points', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Waste'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            Text(
              'Deposit at Trash Bin: UNKNOWN_BIN',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Text(
              'Simulate adding Plastic Bottles to them.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Bagian Scan / Tambah Item (Memperbaiki BorderStyle)
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                // Border solid untuk tampilan rapi
                border: Border.all(color: Colors.green.shade400, style: BorderStyle.solid, width: 2), 
              ),
              child: Column(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 40, color: Colors.green),
                  const SizedBox(height: 10),
                  const Text('Plastic Bottle Detected', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 15),
                  // Tombol Simulasi Tambah Item
                  ElevatedButton.icon(
                    onPressed: _addItemManually,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Plastic Bottle', style: TextStyle(fontSize: 16, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Daftar Item Terdeteksi
            const Text('Detected Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            
            _detectedItems.isEmpty
                ? const Text('No items added yet.', style: TextStyle(color: Colors.grey))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _detectedItems.map(_buildDetectedItemRow).toList(),
                  ),

            const Divider(height: 30),

            // Total Poin dan Confirm Deposit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Points:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('$_totalSimulatedPoints', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol Konfirmasi
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _confirmDeposit,
              icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('Confirm Deposit', style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
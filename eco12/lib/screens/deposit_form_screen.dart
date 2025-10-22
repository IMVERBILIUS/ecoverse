// lib/screens/deposit_form_screen.dart

import 'package:flutter/material.dart';
import '../services/mission_service.dart';

class DepositFormScreen extends StatefulWidget {
  final String ecoSpotId;
  
  const DepositFormScreen({super.key, required this.ecoSpotId});

  @override
  State<DepositFormScreen> createState() => _DepositFormScreenState();
}

class _DepositFormScreenState extends State<DepositFormScreen> {
  // Gunakan Map untuk melacak jumlah setiap jenis sampah
  final Map<String, int> _trashQuantities = {
    'Plastic Bottle': 0,
    'Paper': 0,
    'Metal Can': 0,
    'Glass': 0,
  };
  bool _isLoading = false;
  final MissionService _missionService = MissionService();

  void _increment(String type) {
    setState(() {
      _trashQuantities[type] = (_trashQuantities[type] ?? 0) + 1;
    });
  }

  void _decrement(String type) {
    setState(() {
      if ((_trashQuantities[type] ?? 0) > 0) {
        _trashQuantities[type] = (_trashQuantities[type] ?? 0) - 1;
      }
    });
  }

  void _submitDeposit() async {
    if (_trashQuantities.values.every((q) => q == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please record at least one item deposited.'))
      );
      return;
    }
    
    setState(() { _isLoading = true; });

    // Panggil service untuk mengirim data sampah
    final rewardResult = await _missionService.submitDeposit(
      ecoSpotId: widget.ecoSpotId,
      quantities: _trashQuantities,
    );
    
    setState(() { _isLoading = false; });

    if (rewardResult['success']) {
      // BERHASIL: Tampilkan hadiah dan tutup form
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SUCCESS! Gained ${rewardResult['xp']} XP and ${rewardResult['gp']} GP!'),
          backgroundColor: Colors.green,
        )
      );
      // Kembali ke MapScreen dengan hasil 'true'
      Navigator.pop(context, true); 
    } else {
      // GAGAL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rewardResult['error'] ?? 'Deposit failed.'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  // Widget untuk menampilkan kontrol hitungan sampah
  Widget _buildCounter(String type) {
    return ListTile(
      title: Text(type),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => _decrement(type),
          ),
          Text(_trashQuantities[type].toString(), style: const TextStyle(fontSize: 18)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _increment(type),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Your Deposit')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Recycling Point: ${widget.ecoSpotId}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView(
                  children: _trashQuantities.keys.map(_buildCounter).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _submitDeposit,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text('Complete Deposit & Get Rewards', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
    );
  }
}
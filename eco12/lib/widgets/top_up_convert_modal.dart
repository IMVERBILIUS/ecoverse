// lib/widgets/top_up_convert_modal.dart

import 'package:flutter/material.dart';
import '../services/user_service.dart';

class TopUpConvertModal extends StatefulWidget {
  final int initialDiamondBalance;
  final int initialGPBalance;
  final Function onTransactionComplete;

  const TopUpConvertModal({
    super.key,
    required this.initialDiamondBalance,
    required this.initialGPBalance,
    required this.onTransactionComplete,
  });

  @override
  State<TopUpConvertModal> createState() => _TopUpConvertModalState();
}

class _TopUpConvertModalState extends State<TopUpConvertModal> {
  final UserService _userService = UserService();
  int _convertAmount = 1; 
  final int GP_RATE = 10; 
  
  final List<Map<String, dynamic>> _topUpOptions = const [
    {'diamonds': 100, 'price': 'Rp 10.000'},
    {'diamonds': 500, 'price': 'Rp 45.000'},
    {'diamonds': 1200, 'price': 'Rp 99.000'},
  ];

  // --- HANDLERS DENGAN FIX STABILITAS (mounted) ---

  void _handleTopUp(int amount) async {
    // 1. Tampilkan loading dialog
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    
    // 2. Lakukan transaksi
    final String resultMessage = await _userService.simulateTopUp(amount);
    
    // 3. FIX: Tutup loading dan modal UTAMA HANYA JIKA WIDGET MASIH ADA
    if (mounted) {
      Navigator.of(context).pop(); // Tutup loading
      Navigator.of(context).pop(); // Tutup modal utama
    }

    // 4. FIX: Tampilkan SnackBar HANYA JIKA WIDGET MASIH ADA
    if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resultMessage), backgroundColor: resultMessage.startsWith('Success') ? Colors.green : Colors.red),
        );
    }
    
    widget.onTransactionComplete(); // Panggil refresh di InventoryScreen
  }

  void _handleConvert() async {
    if (_convertAmount <= 0 || _convertAmount > widget.initialDiamondBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid conversion amount or insufficient Diamonds.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    // 1. Tampilkan loading dialog
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    // 2. Lakukan konversi
    final String resultMessage = await _userService.convertDiamond(_convertAmount);
    
    // 3. FIX: Tutup loading dan modal UTAMA HANYA JIKA WIDGET MASIH ADA
    if (mounted) {
      Navigator.of(context).pop(); // Tutup loading
      Navigator.of(context).pop(); // Tutup modal utama
    }
    
    // 4. FIX: Tampilkan SnackBar HANYA JIKA WIDGET MASIH ADA
    if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resultMessage), backgroundColor: resultMessage.startsWith('Success') ? Colors.green : Colors.red),
        );
    }
    
    widget.onTransactionComplete(); // Panggil refresh di InventoryScreen
  }

  // --- UI BUILDERS ---

  Widget _buildBalanceHeader() {
    // Menggunakan data yang diteruskan (initialDiamondBalance)
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCurrencyDisplay(Icons.diamond, 'Diamonds', widget.initialDiamondBalance, Colors.blue),
          _buildCurrencyDisplay(Icons.monetization_on, 'GP', widget.initialGPBalance, Colors.green),
        ],
      ),
    );
  }

  Widget _buildCurrencyDisplay(IconData icon, String label, int amount, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        Text(amount.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final int maxConvertible = widget.initialDiamondBalance.clamp(0, 100); 

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'EcoVerse Exchange', 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 30),
          
          _buildBalanceHeader(),
          const SizedBox(height: 20),

          // --- Bagian 1: Simulated Top Up ---
          const Text('1. Simulate Top Up (Purchase Diamonds)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: _topUpOptions.map((option) => ListTile(
                title: Text('${option['diamonds']} Diamonds'),
                subtitle: Text('Price: ${option['price']} (Simulated)'),
                trailing: ElevatedButton(
                  onPressed: () => _handleTopUp(option['diamonds'] as int),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white),
                  child: const Text('Top Up'),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 30),

          // --- Bagian 2: Diamond to GP Conversion ---
          const Text('2. Convert Diamond to Green Points (1 : 10)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),

          Card(
            color: Colors.green.shade50,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Convert: $_convertAmount D'),
                      Text('Yields: ${_convertAmount * GP_RATE} GP', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  Slider(
                    value: _convertAmount.toDouble(),
                    min: 1,
                    max: maxConvertible > 0 ? maxConvertible.toDouble() : 1.0,
                    divisions: maxConvertible > 0 ? maxConvertible - 1 : 1, 
                    label: _convertAmount.toString(),
                    onChanged: (double value) {
                      setState(() {
                        _convertAmount = value.toInt();
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: _convertAmount > 0 && _convertAmount <= widget.initialDiamondBalance 
                        ? _handleConvert : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
                    child: const Text('Execute Conversion'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
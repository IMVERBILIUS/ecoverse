// lib/screens/qr_scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'deposit_form_screen.dart'; // <-- New screen for data input

class QrScannerScreen extends StatefulWidget {
  final String missionType; 
  
  const QrScannerScreen({super.key, required this.missionType});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isScanned = false;

  void _handleScanVerification(String qrCodeValue) async {
    // Only process the scan once
    if (_isScanned) return; 

    setState(() {
      _isScanned = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code Verified! Open Deposit Form...'))
    );
    
    // NAVIGATE TO DEPOSIT FORM SCREEN
    // The form screen handles the API call and reward.
    final result = await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => DepositFormScreen(
                ecoSpotId: qrCodeValue, // Pass the scanned ID to the form
            )
        )
    );
    
    // If DepositFormScreen was successful, it returns 'true'. 
    // We pass this result back to MapScreen to trigger a data refresh.
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Eco-Spot QR')),
      body: Stack(
        children: [
          // Widget kamera untuk Mobile Scanner
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
              facing: CameraFacing.back,
            ),
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (!_isScanned && barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _handleScanVerification(barcodes.first.rawValue!);
              }
            },
          ),
          // Overlay UI 
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: _isScanned ? Colors.green : Colors.white, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _isScanned ? 'VERIFIED. LOADING FORM...' : 'SCAN QR CODE\n(${widget.missionType})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, backgroundColor: Colors.black54),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
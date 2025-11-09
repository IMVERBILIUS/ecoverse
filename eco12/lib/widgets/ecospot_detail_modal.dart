// lib/widgets/ecospot_detail_modal.dart

import 'package:flutter/material.dart';
import '../models/ecospot.dart';
import '../screens/qr_scanner_screen.dart'; 

class EcoSpotDetailModal extends StatelessWidget {
  final EcoSpot ecoSpot;

  const EcoSpotDetailModal({super.key, required this.ecoSpot});

  // Define Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color secondaryTeal = Color(0xFF7CA1A6);
  static const Color tertiaryWhite = Color(0xFFFFFFFF);

  // Fungsi untuk memulai misi deposit (Primary Action)
  void _startDepositMission(BuildContext context) async {
    // Navigasi ke QR Scanner
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QrScannerScreen(missionType: ecoSpot.type), 
      ),
    );

    // Kirim sinyal refresh ke MapScreen (jika misi selesai)
    if (result == true && context.mounted) {
        // Pop modal detail dan kirimkan sinyal 'true' (misi berhasil)
        Navigator.of(context).pop(true); 
    } else if (context.mounted) {
        // Hanya tutup modal detail
        Navigator.of(context).pop();
    }
  }

  // Fungsi BARU: Menangani Laporan Masalah (Sends signal back to MapScreen)
  void _handleReportIssue(BuildContext context) {
    // Tutup modal detail dan kirimkan data EcoSpot ID + sinyal 'report' ke MapScreen
    Navigator.of(context).pop({'action': 'report', 'ecoSpotId': ecoSpot.id});
  }

  // Fungsi helper untuk menentukan judul, ikon, dan deskripsi dinamis
  Map<String, dynamic> _getDynamicContent(String type) {
    // Menggunakan shade yang lebih gelap untuk tombol Report jika ingin kontras tanpa Orange/Red
    final Color depositColor = primaryGreen;
    final Color reportColor = secondaryTeal; 

    if (type.contains('Recycling')) {
        return {
            'title': 'Recycling Station',
            'icon': Icons.recycling,
            'color': depositColor,
            'buttonText': 'Start Sorting & Deposit',
            'description': 'Designated zone for sorted recyclable materials (plastic, paper, glass). Requires separation.',
        };
    } else if (type.contains('Litter')) {
        return {
            'title': 'Litter Cleanup Hotspot',
            'icon': Icons.warning_amber,
            'color': Colors.red.shade700, // Tetap gunakan Red untuk potensi bahaya/hotspot
            'buttonText': 'Start Cleanup Mission',
            'description': 'A community-reported area needing cleanup. Your action will earn bonus points.',
        };
    } else {
        return {
            'title': 'General Waste Bin',
            'icon': Icons.delete_outline,
            'color': secondaryTeal,
            'buttonText': 'Deposit General Waste',
            'description': 'Standard public trash bin. Suitable for non-recyclable or mixed waste.',
        };
    }
  }

  // Fungsi helper untuk menentukan aset gambar dinamis
  String _getAssetPath(String type) {
    if (type.contains('Recycling')) {
        return 'assets/recycle_placeholder.jpg';
    } else if (type.contains('Litter')) {
        return 'assets/litter_placeholder.jpg'; 
    } else {
        return 'assets/trashbin_placeholder.jpg';
    }
  }


  @override
  Widget build(BuildContext context) {
    final double distanceKm = 0.64; 
    final content = _getDynamicContent(ecoSpot.type);
    final assetPath = _getAssetPath(ecoSpot.type);
    
    // Warna untuk tombol Report (Menggunakan Secondary Teal yang lembut)
    final Color reportButtonColor = secondaryTeal; 

    return Container(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20), 
      decoration: BoxDecoration(
        color: tertiaryWhite, // Warna background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Visual 
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: content['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(assetPath), 
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close, color: tertiaryWhite, shadows: [Shadow(blurRadius: 5, color: Colors.black.withOpacity(0.5))]),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(height: 15),

          // Title dan Jarak
          Text(
            content['title'], 
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.directions_walk, size: 16, color: primaryGreen), // Warna Primary
              const SizedBox(width: 5),
              Text('${distanceKm.toStringAsFixed(2)} km away', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 15),
          
          // Detail Deskripsi
          Text(
            'Jl. Merdeka No. 1, Jakarta Pusat', 
            style: TextStyle(fontSize: 14, color: secondaryTeal), // Warna Secondary
          ),
          const SizedBox(height: 5),
          Text(
            content['description'], 
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 25),

          // Tombol Aksi

          // TOMBOL 1 (Report Issue) - Menggunakan Warna Secondary
          ElevatedButton.icon(
            onPressed: () => _handleReportIssue(context),
            icon: const Icon(Icons.report_problem_outlined, color: tertiaryWhite),
            label: const Text('Report Issue', style: TextStyle(fontSize: 16, color: tertiaryWhite)),
            style: ElevatedButton.styleFrom(
              backgroundColor: reportButtonColor, // <-- WARNA SECONDARY
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Friendly corner
              elevation: 3,
            ),
          ),
          const SizedBox(height: 10),
          
          // TOMBOL 2 (Deposit Waste - Primary Action)
          OutlinedButton.icon(
            onPressed: () => _startDepositMission(context), 
            icon: Icon(content['icon'], color: content['color']),
            label: Text(content['buttonText'], style: TextStyle(fontSize: 16, color: content['color'])),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: content['color']), 
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
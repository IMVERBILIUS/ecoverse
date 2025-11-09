// lib/widgets/report_issue_modal.dart (Full Code - Final Design)

import 'package:flutter/material.dart';
import '../services/mission_service.dart';

class ReportIssueModal extends StatefulWidget {
  final String ecoSpotId;

  const ReportIssueModal({super.key, required this.ecoSpotId});

  @override
  State<ReportIssueModal> createState() => _ReportIssueModalState();
}

class _ReportIssueModalState extends State<ReportIssueModal> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Full Bin';
  bool _isSending = false;
  final MissionService _missionService = MissionService();

  // Define Colors (Updated Palette)
  final Color primaryColor = const Color(0xFF4CAF50); // Main Green
  final Color secondaryColor = const Color(0xFF7CA1A6); // Muted Teal

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });

      final resultMessage = await _missionService.submitReport(
        ecoSpotId: widget.ecoSpotId,
        reportType: _selectedType,
        description: _descriptionController.text,
      );

      // Setelah selesai, tutup modal dan tampilkan SnackBar
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultMessage), backgroundColor: resultMessage.startsWith('Issue reported') ? primaryColor : Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Styling for input fields (Less rounded)
    const OutlineInputBorder inputBorder = OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)), // Kurangi kelengkungan
        borderSide: BorderSide(color: Color(0xFFDDDDDD))
    );

    return Padding(
      padding: EdgeInsets.only(
        top: 30,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Report EcoSpot Issue', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: secondaryColor)),
            const Divider(color: Color(0xFFDDDDDD), height: 30),
            
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1. Type of Issue:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                        border: inputBorder,
                        focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: secondaryColor, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5)
                    ),
                    items: ['Full Bin', 'Damaged Spot', 'Excessive Litter'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  const Text('2. Detailed Complaint:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'E.g., Trash has been overflowing for two days.',
                      border: inputBorder,
                      focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: secondaryColor, width: 2)),
                    ),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty ? 'Complaint cannot be empty' : null,
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: _isSending ? null : _submitReport,
                    icon: _isSending 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Icon(Icons.send, color: Colors.white),
                    label: Text(_isSending ? 'Sending...' : 'Submit Report', style: const TextStyle(fontSize: 18, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, // Warna Hijau Primary
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Kurangi kelengkungan tombol
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
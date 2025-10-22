// lib/widgets/edit_profile_modal.dart (Full Code - Avatar Picker)

import 'package:flutter/material.dart';
import '../models/user_summary.dart';
import '../services/user_service.dart';

// Fallback extension: provide a nullable avatarId getter when UserSummary
// doesn't declare one to avoid compile errors; returns null so the UI will
// use the availableAvatars.first default.
extension UserSummaryAvatarIdFallback on UserSummary {
  String? get avatarId => null;
}

// Daftar ID Avatar yang Tersedia
const List<String> availableAvatars = [
  'person', 'nature', 'star', 'leaf', 'tree', 'sun', 'flower'
];

class EditProfileModal extends StatefulWidget {
  final UserSummary currentSummary;
  final Function onProfileUpdated;

  const EditProfileModal({
    super.key,
    required this.currentSummary,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _mottoController;
  final UserService _userService = UserService();
  bool _isSaving = false;
  
  String _selectedAvatarId = 'person'; // Default atau avatar saat ini

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentSummary.username);
    _emailController = TextEditingController(text: widget.currentSummary.email);
    _mottoController = TextEditingController(text: widget.currentSummary.motto ?? '');
    // Set avatar ID awal
    _selectedAvatarId = widget.currentSummary.avatarId ?? availableAvatars.first;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _mottoController.dispose();
    super.dispose();
  }
  
  // Fungsi helper untuk mendapatkan icon dari ID
  IconData _getIconData(String id) {
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

  // Fungsi simpan perubahan
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      // Update semua field, termasuk avatar ID
      final success = await _userService.updateProfile(
        username: _usernameController.text,
        email: _emailController.text,
        motto: _mottoController.text,
        avatarId: _selectedAvatarId, // <-- KIRIM AVATAR ID BARU
      );
      
      // 3. Notifikasi dan tutup modal
      if (success) {
        widget.onProfileUpdated();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
      } else {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan profil.')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit Profil', 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Bagian Pemilihan Avatar
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.teal,
                      child: Icon(_getIconData(_selectedAvatarId), color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 10),
                    const Text('Pilih Avatar Anda:', style: TextStyle(fontWeight: FontWeight.w600)),
                    
                    // Daftar Pilihan Avatar (Chip/Wrap)
                    Wrap(
                      spacing: 10.0,
                      alignment: WrapAlignment.center,
                      children: availableAvatars.map((id) {
                        return ChoiceChip(
                          label: Icon(_getIconData(id), color: id == _selectedAvatarId ? Colors.white : Colors.teal),
                          selected: id == _selectedAvatarId,
                          selectedColor: Colors.teal.shade400,
                          backgroundColor: Colors.teal.shade50,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedAvatarId = id;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              
              // Form Fields
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Username tidak boleh kosong' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains('@') ? 'Masukkan email yang valid' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _mottoController,
                decoration: InputDecoration(
                  labelText: 'Personal Motto',
                  hintText: 'Kosongkan untuk menghapus motto',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.text_fields),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _mottoController.clear(),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
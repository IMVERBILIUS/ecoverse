// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // Simpan token ke Shared Preferences untuk menjaga sesi
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Aksi Registrasi
  Future<bool> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiService.registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Registrasi berhasil, simpan token yang dikembalikan server
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      return true;
    } else {
      // Gagal registrasi (misalnya, email sudah ada)
      print('Registration failed: ${response.body}');
      return false;
    }
  }

  // Aksi Login
Future<bool> login(String email, String password) async {
    final response = await http.post(
      // PASTIKAN PEMANGGILAN INI BENAR:
      Uri.parse(ApiService.loginUrl), 
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Login berhasil, simpan token
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      return true;
    } else {
      // Gagal login (misalnya, kredensial salah)
      print('Login failed: ${response.body}');
      return false;
    }
  }

  // Mendapatkan token untuk permintaan yang membutuhkan otentikasi (misalnya: mengambil data user)
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
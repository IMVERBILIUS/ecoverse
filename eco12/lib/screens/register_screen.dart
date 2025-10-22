// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// import 'map_screen.dart'; // Akan digunakan setelah register berhasil

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleRegister() async {
    setState(() { _isLoading = true; });
    
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    bool success = await _authService.register(username, email, password);
    
    setState(() { _isLoading = false; });

    if (success) {
      // REGISTRASI BERHASIL
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Logging in...'))
      );
      // Pindahkan ke Map Screen (ganti dengan navigasi yang benar)
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => const MapScreen()), 
      // );

    } else {
      // Gagal (misalnya, email sudah digunakan)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Failed. Check your input.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register for Ecoverse')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleRegister,
                    child: const Text('Register & Start Game'),
                  ),
          ],
        ),
      ),
    );
  }
}
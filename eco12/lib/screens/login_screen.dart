import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_screen.dart'; // <-- PENTING: Import MainScreen yang baru

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final dynamic loginResult = await _authService.login(email, password);
    late final bool success;
    late final String message;
    if (loginResult is Map<String, dynamic>) {
      success = loginResult['success'] == true;
      message = loginResult['msg'] ?? 'An unknown error occurred.';
    } else if (loginResult is bool) {
      success = loginResult;
      message = success ? 'Login successful' : 'Invalid email or password.';
    } else {
      success = false;
      message = 'An unknown error occurred.';
    }

    if (success) {
      // LOGIN BERHASIL: Navigasi ke MainScreen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful! Welcome to Ecoverse.')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()), 
      );
    } else {
      // LOGIN GAGAL: Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $message')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ecoverse Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Welcome Back, Eco-Warrior!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
              const SizedBox(height: 20),
              // Tambahkan tombol Register atau link di sini jika ada
            ],
          ),
        ),
      ),
    );
  }
}
// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_screen.dart'; 

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

  // Define Colors
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color secondaryTeal = const Color(0xFF7CA1A6);

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
    // Gunakan Scaffold tanpa AppBar untuk tampilan fullscreen
    return Scaffold(
      backgroundColor: primaryGreen, // Warna latar belakang Primary
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 10, // Elevasi tinggi untuk efek menonjol
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Sudut membulat modern
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Logo/Ikon Kustom
                  Icon(Icons.eco_rounded, size: 60, color: primaryGreen),
                  const SizedBox(height: 10),
                  
                  // Judul
                  Text(
                    'Welcome Back, Eco-Warrior!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to continue your green mission.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryTeal),
                  ),
                  const SizedBox(height: 30),

                  // Field Email
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'user@ecoverse.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: secondaryTeal),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryGreen, width: 2),
                      ),
                      prefixIcon: Icon(Icons.email, color: secondaryTeal),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  
                  // Field Password
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryGreen, width: 2),
                      ),
                      prefixIcon: Icon(Icons.lock, color: secondaryTeal),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 40),

                  // Tombol Login
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                  const SizedBox(height: 20),
                  
                  // Tombol Register
                  TextButton(
                    onPressed: () {
                      // TODO: Navigasi ke Registration Screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Registration flow goes here.')),
                      );
                    },
                    child: Text(
                      'New to Ecoverse? Register Here',
                      style: TextStyle(color: secondaryTeal, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
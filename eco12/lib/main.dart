// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const EcoverseApp());
}

class EcoverseApp extends StatelessWidget {
  const EcoverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecoverse',
      theme: ThemeData(
        primarySwatch: Colors.green, // Tema hijau sesuai Ecoverse
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Set halaman awal ke LoginScreen
    );
  }
}
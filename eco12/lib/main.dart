// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

// PASTIKAN BARIS INI ADA AGAR PLATFORM VIEW (ModelViewer/WebView) TERINISIALISASI DENGAN BENAR
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EcoverseApp());
}

class EcoverseApp extends StatelessWidget {
  const EcoverseApp({super.key});

  // Define Colors based on user request
  static const Color primaryGreen = Color(0xFF4CAF50); // Primary: #4CAF50 (Main Green)
  static const Color secondaryTeal = Color(0xFF7CA1A6); // Secondary: #7CA1A6 (Muted Teal/Blue-Green)
  static const Color tertiaryWhite = Color(0xFFFFFFFF); // Tertiary/Background: #FFFFFF

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECOVERSE',
      // Apply the new, user-friendly theme
      theme: ThemeData(
        // 1. Color Scheme (Setting global colors)
        colorScheme: ColorScheme.light(
          primary: primaryGreen,
          secondary: secondaryTeal,
          background: tertiaryWhite,
          surface: tertiaryWhite,
          error: Colors.red.shade700,
        ),
        
        // 2. Base Properties
        useMaterial3: true,
        
        // 3. AppBar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: primaryGreen,
          foregroundColor: tertiaryWhite,
          elevation: 0, 
          centerTitle: true,
        ),
        
        // 4. Global Button Style
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: tertiaryWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), 
            ),
            elevation: 3,
          ),
        ),

        // 5. Primary Color Replacement 
        primarySwatch: MaterialColor(primaryGreen.value, {
          50: primaryGreen.withOpacity(0.1),
          100: primaryGreen.withOpacity(0.2),
          500: primaryGreen,
          700: primaryGreen.withOpacity(0.7),
          900: primaryGreen.withOpacity(0.9),
        }),
      ),
      home: const LoginScreen(), // Set halaman awal ke LoginScreen
    );
  }
}
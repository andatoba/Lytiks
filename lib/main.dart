import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const LytiksApp());
}

class LytiksApp extends StatelessWidget {
  const LytiksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lytiks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: const Color(0xFF004B63), // Nuevo color azul oscuro
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004B63),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF004B63),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF004B63),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF004B63), width: 2),
          ),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

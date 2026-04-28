import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/agrotecban_login.dart';

void main() {
  // Inicializar sqflite_ffi solo para plataformas desktop (NO Web)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const AgrotecbanApp());
}

class AgrotecbanApp extends StatelessWidget {
  const AgrotecbanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agrotecban',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
      routes: {
        '/login': (context) => AgrotecbanLogin(),
      },
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF00903E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00903E),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF00903E),
          secondary: const Color(0xFFFFDF00),
          tertiary: const Color(0xFF0B3D25),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00903E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00903E),
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
            borderSide: const BorderSide(color: Color(0xFF00903E), width: 2),
          ),
        ),
        useMaterial3: true,
      ),
      home: AgrotecbanLogin(),
    );
  }
}

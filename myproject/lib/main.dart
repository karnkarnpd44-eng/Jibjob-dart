// main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'splash_screen.dart'; // ✅ ดึงหน้า SplashScreen มาเป็นหน้าเริ่มต้น

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('th', '')],

      // Theme + Font
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),

      // ✅ กำหนดหน้าแรกของแอปเป็น SplashScreen
      home: const SplashScreen(),
    );
  }
}

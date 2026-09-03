// main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:myproject/%E0%B8%AB%E0%B8%99%E0%B9%89%E0%B8%B2login/loginwith.dart'; // ✅ หน้า Login

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
      theme: ThemeData(textTheme: GoogleFonts.kanitTextTheme()),

      // ✅ หน้าแรกของแอป (รูปแรก)
      home: const JibJobLoginPage(),
    );
  }
}

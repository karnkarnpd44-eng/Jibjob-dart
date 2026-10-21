// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 1. นำเข้า Firebase Core และไฟล์คอนฟิกที่เพิ่งสร้างเสร็จ
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'splash_screen.dart';

void main() async {
  // 2. สั่งให้ Flutter Engine พร้อมทำงานก่อนเริ่มเรียกเซอร์วิส
  WidgetsFlutterBinding.ensureInitialized();

  // 3. เริ่มต้นเชื่อมต่อ Firebase กับโปรเจกต์ JIBJob
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('th', '')],
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}

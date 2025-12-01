// main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // สำหรับฟอนต์ภาษาไทย (Kanit)
import 'package:flutter_localizations/flutter_localizations.dart'; // สำหรับ Localization
import 'package:myproject/logincreate1.dart'; // import หน้าแรกของแอป
// import 'package:myproject/l10n/app_localizations.dart'; // ยกเลิกการคอมเมนต์เมื่อสร้างไฟล์ ARB แล้ว

void main() {
  runApp(const CreateAccountApp());
}

class CreateAccountApp extends StatelessWidget {
  const CreateAccountApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 1. การตั้งค่ารองรับภาษาไทย (Localization)
      localizationsDelegates: const [
        // AppLocalizations.delegate, // ยกเลิกการคอมเมนต์เมื่อสร้างไฟล์ ARB แล้ว
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // ภาษาอังกฤษ
        Locale('th', ''), // ภาษาไทย
      ],

      // 2. การตั้งค่าธีมและฟอนต์สำหรับภาษาไทย
      theme: ThemeData(
        // ใช้ฟอนต์ Kanit เพื่อให้แสดงผลภาษาไทยได้สวยงามและถูกต้อง
        textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
        // ตั้งค่าสีอื่นๆ ของธีมตามต้องการ
      ),

      // 3. กำหนดหน้าแรกของแอป
      home: CreateAccountPage1(), // กำหนดให้หน้า CreateAccountPage1 เป็นหน้าแรก
    );
  }
}

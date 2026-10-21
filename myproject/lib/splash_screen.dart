import 'package:flutter/material.dart';
import 'หน้าlogin/loginwith.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // เริ่มต้นที่ 1 ทันที เพื่อให้แสดงโลโก้แรกคู่กับพื้นหลังทันทีที่เปิดแอป
  int _activeLogoStep = 1;

  @override
  void initState() {
    super.initState();
    _runSplashSequence();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // โหลดรูปที่ 2 ล่วงหน้าไว้ในแรม เพื่อให้ตอนสลับเฟดไม่กระตุก
    precacheImage(const AssetImage('assets/logo2.png'), context);
  }

  void _runSplashSequence() async {
    // -----------------------------------------------------------------
    // จังหวะที่ 1 (ภาพที่ 2): แสดงโลโก้แรก + พื้นหลัง ค้างไว้ 2 วินาที
    // -----------------------------------------------------------------
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    // -----------------------------------------------------------------
    // สลับเป็นภาพที่ 3: โลโก้แรกเลือนออก โลโก้ที่สองเลือนเข้ามาแทน
    // -----------------------------------------------------------------
    setState(() {
      _activeLogoStep = 2;
    });

    // -----------------------------------------------------------------
    // จังหวะที่ 2 (ภาพที่ 3): แสดงโลโก้ JibJob เต็มตัว ค้างไว้อีก 2 วินาที
    // -----------------------------------------------------------------
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    // -----------------------------------------------------------------
    // เลือนหน้าจอแบบ Smooth Fade Transition ไปยังหน้าเข้าสู่ระบบ
    // -----------------------------------------------------------------
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const JibJobLoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // -----------------------------------------------------------
          // ส่วนที่ 1: ภาพพื้นหลัง Doodle แสดงผลทันทีตั้งแต่เริ่ม ไม่ต้องรอเงื่อนไขใดๆ
          // -----------------------------------------------------------
          Opacity(
            opacity: 0.35, // ปรับความคมชัด/จางของพื้นหลังได้ตามต้องการ
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),

          // -----------------------------------------------------------
          // ส่วนที่ 2: โลโก้ตรงกลางที่เฟดสลับกัน 2 จังหวะ
          // -----------------------------------------------------------
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // --- โลโก้ที่ 1 (สัญลักษณ์ไอคอนวงกลม): ติดทันทีตั้งแต่เปิดแอป ---
                AnimatedOpacity(
                  opacity: _activeLogoStep == 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  child: Image.asset(
                    'assets/logoicon.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.sync,
                      size: 90,
                      color: Color(0xFF00AEEF),
                    ),
                  ),
                ),

                // --- โลโก้ที่ 2 (โลโก้ JibJob เต็มตัว): เฟดเข้ามาในจังหวะที่ 2 ---
                AnimatedOpacity(
                  opacity: _activeLogoStep == 2 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  child: Image.asset(
                    'assets/logo2.png',
                    width: 500,
                    height: 260,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'JibJob',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F2B48),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

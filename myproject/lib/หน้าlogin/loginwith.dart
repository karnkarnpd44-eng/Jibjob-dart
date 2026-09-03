import 'package:flutter/material.dart';
import 'package:myproject/%E0%B8%AB%E0%B8%99%E0%B9%89%E0%B8%B2login/condition.dart';

class JibJobLoginPage extends StatelessWidget {
  const JibJobLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryButtonColor = const Color(0xFF1A3766);
    const double buttonHeight = 50.0;
    const double buttonRadius = 10.0;
    const TextStyle buttonTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เข้าสู่ระบบ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildLogoSection(),

              const SizedBox(height: 50),

              // ปุ่มเข้าสู่ระบบ
              ElevatedButton(
                onPressed: () {
                  // ใส่ Logic การเข้าสู่ระบบตรงนี้
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryButtonColor,
                  minimumSize: const Size.fromHeight(buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonRadius),
                  ),
                ),
                child: Text(
                  'เข้าสู่ระบบ',
                  style: buttonTextStyle.copyWith(color: Colors.white),
                ),
              ),

              const SizedBox(height: 15),

              // ปุ่มสร้างบัญชี (แก้ไขให้นำทางไปหน้าเงื่อนไขก่อน)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // เปลี่ยนเป็นชื่อ Class ของหน้าเงื่อนไขที่คุณสร้างไว้
                      builder: (context) => const TermsOfServicePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryButtonColor,
                  minimumSize: const Size.fromHeight(buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonRadius),
                  ),
                ),
                child: Text(
                  'สร้างบัญชี',
                  style: buttonTextStyle.copyWith(color: Colors.white),
                ),
              ),

              const SizedBox(height: 30),

              _buildSocialLoginButton(
                iconPath: 'assets/google.png',
                text: 'เข้าสู่ระบบผ่าน Google',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Image.asset(
          'assets/logo2.png',
          height: 150,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              'JIBJOB',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A3766),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required String iconPath,
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 1,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 22,
            height: 22,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.login, size: 22),
          ),
          const SizedBox(width: 15),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

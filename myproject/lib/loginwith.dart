// loginwith.dart
import 'package:flutter/material.dart';
// ต้อง import ไฟล์หน้าสร้างบัญชีเพื่อให้ Navigator รู้จักคลาส CreateAccountPage1
import 'package:myproject/logincreate1.dart';

class JibJobLoginPage extends StatelessWidget {
  const JibJobLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // กำหนดสีหลักสำหรับปุ่ม
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
              // 1. ส่วนของโลโก้
              _buildLogoSection(context),

              const SizedBox(height: 50),

              // 2. ปุ่ม "เข้าสู่ระบบ"
              ElevatedButton(
                onPressed: () {
                  // TODO: เพิ่ม logic เข้าสู่ระบบ
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

              // 3. ปุ่ม "สร้างบัญชี" (แก้ไขจุดนี้เพื่อให้กดไปหน้า 2 ได้)
              ElevatedButton(
                onPressed: () {
                  // ใช้ Navigator เพื่อเปิดหน้า CreateAccountPage1
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAccountPage1(),
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

              // 4. ปุ่ม Social Login ต่างๆ
              _buildSocialLoginButton(
                iconPath: 'assets/google.png',
                text: 'เข้าสู่ระบบผ่าน Google',
                onPressed: () {},
              ),
              const SizedBox(height: 15),
              _buildSocialLoginButton(
                iconPath: 'assets/facebook.png',
                text: 'เข้าสู่ระบบผ่าน Facebook',
                onPressed: () {},
              ),
              const SizedBox(height: 15),
              _buildSocialLoginButton(
                iconPath: 'assets/line.png',
                text: 'เข้าสู่ระบบผ่าน Line',
                onPressed: () {},
              ),
              const SizedBox(height: 15),
              _buildSocialLoginButton(
                iconPath: 'assets/thaid.png',
                text: 'เข้าสู่ระบบผ่าน ThaID',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ป้องกัน error ถ้ายังไม่มีไฟล์รูปภาพ ให้เช็คชื่อไฟล์ assets ให้ตรงกันด้วยครับ
          Image.asset(
            'assets/jibjob.png',
            height: 120,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'JibJob Logo',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A3766),
                ),
              );
            },
          ),
        ],
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
        children: [
          // ป้องกัน error ถ้าไม่มีไฟล์ไอคอน
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

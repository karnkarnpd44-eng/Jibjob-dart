import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JibJob App',
      theme: ThemeData(
        // กำหนดสีหลักของแอปตามรูป (เช่น สีน้ำเงินเข้มสำหรับปุ่ม)
        primarySwatch: Colors.blue,
        // กำหนดพื้นหลังหลักของ Scaffold เป็นสีม่วงอ่อนๆ (ตามขอบนอกของรูป)
        scaffoldBackgroundColor: const Color(0xFFF0F0FF), // สีม่วงอ่อน
      ),
      home: const JibJobLoginPage(),
    );
  }
}

class JibJobLoginPage extends StatelessWidget {
  const JibJobLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // กำหนดสีหลักสำหรับปุ่ม
    final Color primaryButtonColor = const Color(
      0xFF1A3766,
    ); // สีน้ำเงินเข้มสำหรับปุ่มหลัก
    const double buttonHeight = 50.0;
    const double buttonRadius = 10.0;
    const TextStyle buttonTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      // AppBar สามารถใช้สำหรับแสดงข้อความ "เข้าสู่ระบบ" ด้านบน
      appBar: AppBar(
        title: const Text(
          'เข้าสู่ระบบ',
          style: TextStyle(
            color: Colors.black, // สีของข้อความใน AppBar
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white, // พื้นหลังของ AppBar เป็นสีขาว
        elevation: 0, // ลบเงา
        centerTitle: true,
      ),
      // ใช้ SingleChildScrollView เพื่อให้เลื่อนได้หากหน้าจอมีขนาดเล็ก
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 1. ส่วนของโลโก้ JibJob และพื้นหลังรูปวาด
              _buildLogoSection(context),

              const SizedBox(height: 50),

              // 2. ปุ่ม "เข้าสู่ระบบ" หลัก
              ElevatedButton(
                onPressed: () {
                  // TODO: เพิ่ม logic เมื่อกดปุ่มเข้าสู่ระบบ
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryButtonColor, // สีน้ำเงินเข้ม
                  minimumSize: const Size.fromHeight(buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonRadius),
                  ),
                ),
                child: Text(
                  'เข้าสู่ระบบ',
                  style: buttonTextStyle.copyWith(
                    color: Colors.white,
                  ), // ข้อความสีขาว
                ),
              ),

              const SizedBox(height: 15),

              // 3. ปุ่ม "สร้างบัญชี" หลัก
              ElevatedButton(
                onPressed: () {
                  // TODO: เพิ่ม logic เมื่อกดปุ่มสร้างบัญชี
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryButtonColor, // สีน้ำเงินเข้ม
                  minimumSize: const Size.fromHeight(buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonRadius),
                  ),
                ),
                child: Text(
                  'สร้างบัญชี',
                  style: buttonTextStyle.copyWith(
                    color: Colors.white,
                  ), // ข้อความสีขาว
                ),
              ),

              const SizedBox(height: 30),

              // 4. ปุ่มเข้าสู่ระบบผ่าน Social Media / ThaiID
              _buildSocialLoginButton(
                iconPath: 'assets/google_logo.png', // สมมติว่ามีรูปโลโก้ Google
                text: 'เข้าสู่ระบบผ่าน Google',
                onPressed: () {},
              ),
              const SizedBox(height: 15),
              _buildSocialLoginButton(
                iconPath: 'assets/apple_logo.png', // สมมติว่ามีรูปโลโก้ Apple
                text: 'เข้าสู่ระบบผ่าน Apple',
                onPressed: () {},
              ),
              const SizedBox(height: 15),
              _buildSocialLoginButton(
                iconPath: 'assets/line_logo.png', // สมมติว่ามีรูปโลโก้ Line
                text: 'เข้าสู่ระบบผ่าน Line',
                onPressed: () {},
              ),
              const SizedBox(height: 15),
              _buildSocialLoginButton(
                iconPath: 'assets/thaiid_logo.png', // สมมติว่ามีรูปโลโก้ ThaiID
                text: 'เข้าสู่ระบบผ่าน ThaiID',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget สำหรับส่วนโลโก้และพื้นหลังรูปวาด
  Widget _buildLogoSection(BuildContext context) {
    // ส่วนนี้ควรใช้ Image.asset หรือ CustomPaint สำหรับรูปวาดพื้นหลัง
    // ในโค้ดตัวอย่างนี้จะใช้เพียง Container และ Text สำหรับจำลองตำแหน่งโลโก้
    return Container(
      alignment: Alignment.center,
      height: 250, // กำหนดความสูงสำหรับส่วนนี้
      // *******
      // NOTE: ส่วนนี้จะแทนที่ด้วยรูปวาดพื้นหลังและโลโก้ JibJob จริงๆ
      // *******
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // แสดงโลโก้
          Image.asset('assets/jibjob.png', height: 120),
          // หรือใช้ Text แทนโลโก้ ถ้าหาไฟล์ไม่เจอ
          // const Text(
          //   'JibJob',
          //   style: TextStyle(
          //     fontSize: 50,
          //     fontWeight: FontWeight.bold,
          //     color: primaryButtonColor,
          //   ),
          // ),
        ],
      ),
    );
  }

  // Widget สำหรับปุ่ม Social Login
  Widget _buildSocialLoginButton({
    required String iconPath,
    required String text,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white, // พื้นหลังสีขาว
        side: const BorderSide(color: Colors.grey, width: 0.5), // ขอบสีเทาอ่อน
        minimumSize: const Size.fromHeight(50.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // แทนที่ด้วย Image.asset(iconPath, height: 24)
          // ในโค้ดตัวอย่างจะใช้ Icon แทน
          const Icon(
            Icons.star,
            color: Colors.black,
            size: 24,
          ), // ใช้ Icon ชั่วคราว
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

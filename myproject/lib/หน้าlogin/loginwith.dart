import 'package:flutter/material.dart';
import 'package:myproject/%E0%B8%AB%E0%B8%99%E0%B9%89%E0%B8%B2login/condition.dart';
import '../หน้าหลักjibber/home.dart';

class JibJobLoginPage extends StatelessWidget {
  const JibJobLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryButtonColor = Color(0xFF0F2B48);
    const double buttonHeight = 52.0;
    const double buttonRadius = 10.0;
    const TextStyle buttonTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'เข้าสู่ระบบ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // -------------------------------------------------------------
          // 1. ภาพพื้นหลังจาง ๆ ด้านหลังปุ่มกด (Background Doodle)
          // -------------------------------------------------------------
          Positioned.fill(
            child: Opacity(
              opacity: 0.9, // ปรับความชัดของภาพ
              child: Image.asset(
                'assets/background.jpg', // ตรวจสอบชื่อและนามสกุลไฟล์ให้ตรง
                fit: BoxFit.cover,
              ),
            ),
          ),

          // -------------------------------------------------------------
          // 2. เนื้อหาหลัก โลโก้ และ ปุ่มกด
          // -------------------------------------------------------------
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28.0,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildLogoSection(),

                    const SizedBox(height: 60),

                    // ปุ่มเข้าสู่ระบบ (กดแล้วเปิดตัวเลือก เข้าผ่านรหัส หรือ OTP)
                    ElevatedButton(
                      onPressed: () => _showLoginBottomSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryButtonColor,
                        minimumSize: const Size.fromHeight(buttonHeight),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonRadius),
                        ),
                      ),
                      child: Text(
                        'เข้าสู่ระบบ',
                        style: buttonTextStyle.copyWith(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ปุ่มสร้างบัญชี (นำทางไปหน้าเงื่อนไข)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsOfServicePage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryButtonColor,
                        minimumSize: const Size.fromHeight(buttonHeight),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonRadius),
                        ),
                      ),
                      child: Text(
                        'สร้างบัญชี',
                        style: buttonTextStyle.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ส่วนแสดงโลโก้
  Widget _buildLogoSection() {
    return Center(
      child: Image.asset(
        'assets/logo2.png',
        height: 160,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Text(
            'JIBJOB',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F2B48),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // หน้าต่าง BottomSheet สำหรับเลือกล็อกอิน (รหัสผ่าน vs OTP)
  // ---------------------------------------------------------------------------
  void _showLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _LoginBottomSheetContent(),
    );
  }
}

// Stateful Widget จัดการโหมดล็อกอิน (รหัสผ่าน / OTP)
class _LoginBottomSheetContent extends StatefulWidget {
  const _LoginBottomSheetContent();

  @override
  State<_LoginBottomSheetContent> createState() =>
      _LoginBottomSheetContentState();
}

class _LoginBottomSheetContentState extends State<_LoginBottomSheetContent> {
  int _selectedTab = 0; // 0 = รหัสผ่าน, 1 = รหัส OTP
  bool _obscurePassword = true;
  bool _otpSent = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: bottomInset + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'เลือกวิธีเข้าสู่ระบบ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),

            // แถบสลับโหมด: รหัสผ่าน vs OTP
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? const Color(0xFF0F2B48)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'เข้าด้วยรหัสผ่าน',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedTab == 0
                                ? Colors.white
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? const Color(0xFF0F2B48)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'เข้าด้วยรหัส OTP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedTab == 1
                                ? Colors.white
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // -------------------------------------------------------------
            // แบบฟอร์ม 1: เข้าด้วยรหัสผ่าน
            // -------------------------------------------------------------
            if (_selectedTab == 0) ...[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'เบอร์โทรศัพท์ หรือ อีเมล',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF0F2B48),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF0F2B48),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // สลับไปใช้ OTP เพื่อกู้คืนรหัสผ่านได้
                    setState(() => _selectedTab = 1);
                  },
                  child: const Text(
                    'ลืมรหัสผ่าน? ใช้ OTP แทน',
                    style: TextStyle(color: Color(0xFF00AEEF)),
                  ),
                ),
              ),
            ],

            // -------------------------------------------------------------
            // แบบฟอร์ม 2: เข้าด้วย OTP
            // -------------------------------------------------------------
            if (_selectedTab == 1) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'หมายเลขโทรศัพท์',
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: Color(0xFF0F2B48),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AEEF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_phoneController.text.trim().isNotEmpty) {
                        setState(() => _otpSent = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ส่งรหัส OTP ไปยังเบอร์ของคุณแล้ว'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'ขอ OTP',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'รหัส OTP (6 หลัก)',
                  prefixIcon: const Icon(
                    Icons.security,
                    color: Color(0xFF0F2B48),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 14),

            // ปุ่มยืนยันเข้าสู่ระบบ
            ElevatedButton(
              onPressed: () {
                // ตัวอย่าง: เข้าสู่ระบบสำเร็จแล้วนำทางไปยัง HomeScreen
                Navigator.pop(context); // ปิด BottomSheet
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F2B48),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'เข้าสู่ระบบ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

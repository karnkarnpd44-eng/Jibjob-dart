// lib/หน้าlogin/loginwith.dart
import 'package:flutter/material.dart';
import 'package:myproject/%E0%B8%AB%E0%B8%99%E0%B9%89%E0%B8%B2login/condition.dart';
import '../หน้าหลักjibber/home.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          // 1. ภาพพื้นหลังจาง ๆ ด้านหลังปุ่มกด
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Image.asset(
                'assets/background.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          // 2. เนื้อหาหลัก โลโก้ และ ปุ่มกด
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

                    // ปุ่มเข้าสู่ระบบ
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

                    // ปุ่มสร้างบัญชี
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

  void _showLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _LoginBottomSheetContent(),
    );
  }
}

// -----------------------------------------------------------------------------
// คลาสจัดการ BottomSheet สำหรับเข้าสู่ระบบผ่านรหัสผ่าน หรือ OTP จริง
// -----------------------------------------------------------------------------
class _LoginBottomSheetContent extends StatefulWidget {
  const _LoginBottomSheetContent();

  @override
  State<_LoginBottomSheetContent> createState() =>
      _LoginBottomSheetContentState();
}

class _LoginBottomSheetContentState extends State<_LoginBottomSheetContent> {
  int _selectedTab = 1; // ตั้งค่าเริ่มต้นให้เปิดแท็บ OTP ก่อน
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _verificationId;

  final AuthService _authService = AuthService();

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

  // ฟังก์ชันขอส่งรหัส OTP ไปยัง Firebase
  void _handleSendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกหมายเลขโทรศัพท์')));
      return;
    }

    setState(() => _isLoading = true);

    await _authService.sendOTP(
      phoneNumber: phone,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ส่งรหัส OTP สำเร็จแล้ว กรุณากรอกรหัส 6 หลัก'),
            backgroundColor: Color(0xFF00AEEF),
          ),
        );
      },
      onError: (errorMessage) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $errorMessage'),
            backgroundColor: Colors.redAccent,
          ),
        );
      },
    );
  }

  // ฟังก์ชันตรวจสอบ OTP และเข้าสู่ระบบ
  void _handleVerifyAndLogin() async {
    final otpCode = _otpController.text.trim();
    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกรหัส OTP ให้ครบ 6 หลัก')),
      );
      return;
    }

    // ดึง verificationId จากตัวแปรหน้าจอ หรือจาก AuthService โดยตรง
    final currentVerifyId = _verificationId ?? AuthService.verifyId;

    if (currentVerifyId == null || currentVerifyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากดปุ่ม "ขอ OTP" สีฟ้าให้ระบบส่งรหัสก่อน'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential? credential = await _authService.verifyOTP(
        smsCode: otpCode,
        verificationId: currentVerifyId,
      );

      if (credential?.user != null) {
        final uid = credential!.user!.uid;
        bool exists = await _authService.checkUserExists(uid);

        if (!mounted) return;
        Navigator.pop(context); // ปิด BottomSheet

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ยืนยันตัวตนสำเร็จ กำลังเข้าสู่หน้าหลัก...'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );

        // นำทางเข้าสู่หน้าหลัก
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('รหัส OTP ไม่ถูกต้อง: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            // แท็บ 0: เข้าด้วยรหัสผ่าน
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
                  onPressed: () => setState(() => _selectedTab = 1),
                  child: const Text(
                    'ลืมรหัสผ่าน? ใช้ OTP แทน',
                    style: TextStyle(color: Color(0xFF00AEEF)),
                  ),
                ),
              ),
            ],

            // -------------------------------------------------------------
            // แท็บ 1: เข้าด้วย OTP[cite: 4, 26, 40]
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
                        hintText: 'เช่น 0812345678',
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
                    onPressed: _isLoading ? null : _handleSendOTP,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
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
              onPressed: _isLoading
                  ? null
                  : (_selectedTab == 1
                        ? _handleVerifyAndLogin
                        : () {
                            // กรณีล็อกอินด้วยรหัสผ่าน นำทางเข้าหน้าหลัก
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          }),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F2B48),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
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

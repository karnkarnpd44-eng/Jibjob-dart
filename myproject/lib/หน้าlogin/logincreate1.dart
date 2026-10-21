import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../หน้าหลักjibber/home.dart';
import '../services/auth_service.dart'; // หรือ import '../auth_service.dart'; ตามตำแหน่งที่วางไว้

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // เซอร์วิสสำหรับติดต่อ Firebase
  final AuthService _authService = AuthService();

  // สถานะการทำงานหลังบ้าน
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _isSavingData = false;
  bool _isOtpVerified = false; // ตรวจสอบว่ายืนยัน OTP ผ่านหรือยัง
  String? _verificationId;
  DateTime? _selectedBirthDate;

  // Controllers สำหรับ Step 1
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  // Controllers สำหรับ Step 2
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedGender = 'ชาย';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // ตรวจสอบความสมบูรณ์ของ Step 1 ก่อนไปต่อ
    if (_nameController.text.trim().isEmpty) {
      _showWarningSnackBar('กรุณากรอกชื่อ-นามสกุล');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showWarningSnackBar('กรุณากรอกหมายเลขโทรศัพท์');
      return;
    }
    if (!_isOtpVerified) {
      _showWarningSnackBar('กรุณากดยืนยันรหัส OTP ให้สำเร็จก่อนไปขั้นตอนถัดไป');
      return;
    }

    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _prevPage() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _showWarningSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF0F4C81),
      ),
    );
  }

  // ===========================================================================
  // ฟังก์ชันส่งรหัส OTP (Firebase Auth)
  // ===========================================================================
  void _handleSendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showWarningSnackBar('กรุณากรอกเบอร์โทรศัพท์ก่อนกดขอ OTP');
      return;
    }

    setState(() => _isSendingOtp = true);

    await _authService.sendOTP(
      phoneNumber: phone,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _isSendingOtp = false;
        });
        _showWarningSnackBar('ส่งรหัส OTP สำเร็จแล้ว');
      },
      onError: (errorMessage) {
        if (!mounted) return;
        setState(() => _isSendingOtp = false);
        _showWarningSnackBar('เกิดข้อผิดพลาด: $errorMessage', isError: true);
      },
    );
  }

  // ===========================================================================
  // ฟังก์ชันยืนยันรหัส OTP
  // ===========================================================================
  void _handleVerifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showWarningSnackBar('กรุณากรอกรหัส OTP ให้ครบ 6 หลัก');
      return;
    }

    final currentVerifyId = _verificationId ?? AuthService.verifyId;
    if (currentVerifyId == null || currentVerifyId.isEmpty) {
      _showWarningSnackBar('กรุณากดปุ่ม "ส่งรหัส OTP" ก่อน', isError: true);
      return;
    }

    setState(() => _isVerifyingOtp = true);

    try {
      UserCredential? credential = await _authService.verifyOTP(
        smsCode: otp,
        verificationId: currentVerifyId,
      );

      if (credential?.user != null) {
        if (!mounted) return;
        setState(() {
          _isOtpVerified = true;
          _isVerifyingOtp = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ยืนยันรหัส OTP ถูกต้องเรียบร้อย'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifyingOtp = false);
      _showWarningSnackBar(
        'รหัส OTP ไม่ถูกต้อง: ${e.toString()}',
        isError: true,
      );
    }
  }

  // ===========================================================================
  // ฟังก์ชันบันทึกข้อมูลผู้ใช้ลง Cloud Firestore (Users Collection)
  // ===========================================================================
  void _handleCompleteRegistration() async {
    final ageText = _ageController.text
        .replaceAll(RegExp(r'[^0-9]'), '')
        .trim();
    final int age = int.tryParse(ageText) ?? 0;

    // เงื่อนไขตรวจสอบอายุขั้นต่ำ 20 ปีบริบูรณ์ตามเอกสารโครงการ
    if (age < 20) {
      _showWarningSnackBar(
        'ขออภัย ผู้ใช้งานต้องมีอายุ 20 ปีบริบูรณ์ขึ้นไป',
        isError: true,
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      _showWarningSnackBar('กรุณากรอกที่อยู่ของคุณ');
      return;
    }

    setState(() => _isSavingData = true);

    try {
      final user = _authService.currentUser;
      final uid = user?.uid ?? DateTime.now().millisecondsSinceEpoch.toString();

      // บันทึกข้อมูลลง Firestore ตาราง Users ตามโครงสร้าง Data Dictionary
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'user_id': uid,
        'full_name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'employer', // ค่าเริ่มต้นสำหรับฝั่งผู้ว่าจ้าง
        'gender': _selectedGender,
        'address': _addressController.text.trim(),
        'birth_date': _selectedBirthDate != null
            ? Timestamp.fromDate(_selectedBirthDate!)
            : null,
        'age': age,
        'rating_score': 0.0,
        'total_reviews': 0,
        'is_active': true,
        'profile_image_url': '',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('สร้างบัญชีสำเร็จเรียบร้อย!'),
          backgroundColor: Color(0xFF0F4C81),
          duration: Duration(seconds: 1),
        ),
      );

      // นำทางเข้าสู่หน้าหลัก HomeScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showWarningSnackBar(
        'เกิดข้อผิดพลาดในการบันทึกข้อมูล: $e',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSavingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // ควบคุมการเลื่อนผ่านปุ่มเท่านั้น
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [_buildStep1Page(), _buildStep2Page()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFEDF6FB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00AEEF).withOpacity(0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Image.asset(
              'assets/logo2.1.png',
              width: 58,
              height: 58,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.all_inclusive_rounded,
                size: 44,
                color: Color(0xFF00AEEF),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'สร้างบัญชี',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F4C81),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentPage == 0 ? 32 : 12,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == 0
                      ? const Color(0xFF0F4C81)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentPage == 1 ? 32 : 12,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == 1
                      ? const Color(0xFF0F4C81)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Page() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel('ชื่อ-นามสกุล'),
          _buildInputField(
            controller: _nameController,
            hintText: 'สมชาย ใจดี',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 14),

          _buildInputLabel('อีเมล'),
          _buildInputField(
            controller: _emailController,
            hintText: 'example@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),

          _buildInputLabel('รหัสผ่าน'),
          _buildInputField(
            controller: _passwordController,
            hintText: '•••• •••• ••••',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 14),

          _buildInputLabel('เบอร์โทรศัพท์'),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _phoneController,
                  hintText: 'เช่น 0812345678',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 10),
              _buildYellowActionButton(
                label: _isSendingOtp ? 'กำลังส่ง...' : 'ส่งรหัส OTP',
                onPressed: _isSendingOtp ? () {} : _handleSendOTP,
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _otpController,
                  hintText: 'กรอกรหัส OTP (6 หลัก)',
                  prefixIcon: Icons.security_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              _buildYellowActionButton(
                label: _isOtpVerified
                    ? 'ยืนยันแล้ว'
                    : (_isVerifyingOtp ? 'ตรวจ...' : 'ยืนยัน OTP'),
                onPressed: (_isVerifyingOtp || _isOtpVerified)
                    ? () {}
                    : _handleVerifyOTP,
              ),
            ],
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C81),
                elevation: 2,
                shadowColor: const Color(0xFF0F4C81).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ถัดไป (ข้อมูลส่วนตัว)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStep2Page() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel('ที่อยู่'),
          _buildInputField(
            controller: _addressController,
            hintText: 'บ้านเลขที่, ถนน, แขวง/ตำบล, เขต/อำเภอ, จังหวัด',
            prefixIcon: Icons.location_on_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          _buildInputLabel('เพศ'),
          Row(
            children: [
              _buildGenderChip('ชาย'),
              const SizedBox(width: 8),
              _buildGenderChip('หญิง'),
              const SizedBox(width: 8),
              _buildGenderChip('LGBTQ+'),
            ],
          ),
          const SizedBox(height: 16),

          _buildInputLabel('วัน/เดือน/ปีเกิด'),
          _buildInputField(
            controller: _dobController,
            hintText: 'วว/ดด/ปปปป',
            prefixIcon: Icons.calendar_today_outlined,
            readOnly: true,
            suffixIcon: const Icon(
              Icons.calendar_month,
              color: Color(0xFF0F4C81),
            ),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                _selectedBirthDate = picked;
                int calculatedAge = DateTime.now().year - picked.year;
                if (DateTime.now().month < picked.month ||
                    (DateTime.now().month == picked.month &&
                        DateTime.now().day < picked.day)) {
                  calculatedAge--;
                }

                setState(() {
                  _dobController.text =
                      '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year + 543}';
                  _ageController.text = '$calculatedAge ปี';
                });
              }
            },
          ),
          const SizedBox(height: 16),

          _buildInputLabel('อายุ (ต้อง 20 ปีขึ้นไป)'),
          _buildInputField(
            controller: _ageController,
            hintText: 'เช่น 25 ปี',
            prefixIcon: Icons.cake_outlined,
            readOnly: true,
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSavingData ? null : _handleCompleteRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C81),
                elevation: 2,
                shadowColor: const Color(0xFF0F4C81).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSavingData
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'สร้างบัญชี',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          Center(
            child: TextButton.icon(
              onPressed: _prevPage,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.grey,
                size: 18,
              ),
              label: const Text(
                'ย้อนกลับไปแก้ไขข้อมูลบัญชี',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: readOnly,
        maxLines: maxLines,
        onTap: onTap,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: const Color(0xFF0F4C81), size: 20)
              : null,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00AEEF), width: 1.6),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildYellowActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF000),
          foregroundColor: Colors.black87,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE2D800), width: 1),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderChip(String gender) {
    final bool isSelected = _selectedGender == gender;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = gender),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F4C81) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0F4C81)
                  : Colors.grey.shade300,
              width: 1.2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0xFF0F4C81).withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                gender,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

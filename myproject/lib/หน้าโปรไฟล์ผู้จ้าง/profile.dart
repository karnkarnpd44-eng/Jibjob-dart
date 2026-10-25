// lib/หน้าโปรไฟล์ผู้จ้าง/profile.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../หน้าหลักjibber/home.dart';
import '../หน้าแจ้งเตือน/notification_list.dart';
import '../หน้างานของฉัน/my_jobs.dart';
import '../หน้าข้อความ/chat_list.dart';
import '../ฝั่งผู้รับจ้าง JOBBER/หน้าการรับงาน/jobber_home.dart';
import '../../admin_chat.dart';
import '../services/media_service.dart'; // หรือ import '../media_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userBio;
  final double rating;
  final String? activeJobTitle;
  final String? activeJobberName;
  final double? activeWageAmount;
  final bool isCompleted;

  const ProfileScreen({
    Key? key,
    this.userName = 'ผู้ใช้งาน',
    this.userBio = 'ช่องแนะนำตัว',
    this.rating = 0.0,
    this.activeJobTitle,
    this.activeJobberName,
    this.activeWageAmount,
    this.isCompleted = false,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _currentView = 'main';

  // ข้อมูลโปรไฟล์จริงจาก Firestore
  late String _currentName;
  late String _currentBio;
  double _currentRating = 0.0;
  String _profileImageUrl = '';
  List<String> _userImages = [];
  final int _maxImages = 5;

  bool _isLoadingUserData = true;
  bool _isSavingProfile = false;
  bool _isUploadingMedia = false;

  final MediaService _mediaService = MediaService();

  late TextEditingController _nameEditController;
  late TextEditingController _bioEditController;

  // Controllers สำหรับหน้าเปลี่ยนรหัสผ่าน
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isUsingOtp = false;
  bool _otpVerified = false;
  bool _obscureOldPass = true;
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;

  bool _isEmployer = true;
  bool _notiEnabled = true;

  late List<Map<String, dynamic>> _paymentHistory;
  late List<Map<String, dynamic>> _jobHistory;

  @override
  void initState() {
    super.initState();
    _currentName = widget.userName;
    _currentBio = widget.userBio;
    _currentRating = widget.rating;

    _nameEditController = TextEditingController(text: _currentName);
    _bioEditController = TextEditingController(
      text: _currentBio == 'ช่องแนะนำตัว' ? '' : _currentBio,
    );

    _paymentHistory = [
      if (widget.activeJobTitle != null && widget.activeWageAmount != null)
        {
          'title': 'งาน${widget.activeJobTitle}',
          'jobber': 'Jobber : ${widget.activeJobberName ?? "กิตติพงษ์"}',
          'status': 'สถานะ : สำเร็จ',
          'time': 'เมื่อสักครู่',
          'amount': widget.activeWageAmount!,
        },
      {
        'title': 'งานคนพาหมาไปเดินเล่น',
        'jobber': 'Jobber : กิตติพงษ์',
        'status': 'สถานะ : สำเร็จ',
        'time': '5 นาทีที่ผ่านมา',
        'amount': 300.0,
      },
    ];

    _jobHistory = [
      if (widget.activeJobTitle != null)
        {
          'title': 'งาน "${widget.activeJobTitle}"',
          'status': 'สถานะ : สำเร็จ',
          'time': 'เมื่อสักครู่',
        },
      {
        'title': 'งาน "คนพาหมาไปเดินเล่น"',
        'status': 'สถานะ : สำเร็จ',
        'time': '5 นาทีที่ผ่านมา',
      },
      {
        'title': 'งาน "ฝากซื้อของ"',
        'status': 'สถานะ : สำเร็จ',
        'time': '1 วัน',
      },
      {
        'title': 'งาน "คนช่วยถือของ"',
        'status': 'สถานะ : ยกเลิก',
        'time': '9/11/68',
      },
    ];

    _loadUserData();
  }

  // ===========================================================================
  // ดึงข้อมูลจริงจาก Cloud Firestore
  // ===========================================================================
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          final data = doc.data()!;
          setState(() {
            _currentName = data['full_name'] ?? widget.userName;
            _currentBio =
                (data['bio'] != null && data['bio'].toString().isNotEmpty)
                ? data['bio']
                : 'ช่องแนะนำตัว';

            if (data['rating_score'] != null) {
              _currentRating = (data['rating_score'] as num).toDouble();
            }

            _profileImageUrl = data['profile_image_url'] ?? '';

            if (data['portfolio_images'] != null) {
              _userImages = List<String>.from(data['portfolio_images']);
            }

            _phoneController.text =
                data['phone_number'] ?? user.phoneNumber ?? '';
            _nameEditController.text = _currentName;
            _bioEditController.text = _currentBio == 'ช่องแนะนำตัว'
                ? ''
                : _currentBio;
            _isLoadingUserData = false;
          });
        }
      } catch (e) {
        debugPrint('>>> เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้: $e');
        if (mounted) setState(() => _isLoadingUserData = false);
      }
    } else {
      if (mounted) setState(() => _isLoadingUserData = false);
    }
  }

  // ===========================================================================
  // Dialog เลือกถ่ายรูป หรือเลือกจากคลังภาพ
  // ===========================================================================
  void _showImagePickerChoice({
    required Function(ImageSource source) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF0F4C81)),
              title: const Text(
                'ถ่ายภาพสด (Camera)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                onSelected(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF00AEEF),
              ),
              title: const Text(
                'เลือกจากคลังภาพ (Gallery)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                onSelected(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // อัปโหลดรูปโปรไฟล์
  void _handleUploadProfileImage(ImageSource source) async {
    setState(() => _isUploadingMedia = true);
    try {
      final url = await _mediaService.uploadProfileImage(source: source);
      if (url != null && mounted) {
        setState(() {
          _profileImageUrl = url;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อัปเดตรูปโปรไฟล์สำเร็จเรียบร้อย'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('อัปโหลดรูปโปรไฟล์ล้มเหลว: $e')));
    } finally {
      if (mounted) setState(() => _isUploadingMedia = false);
    }
  }

  // อัปโหลดรูปผลงาน
  void _handleUploadPortfolioImage(ImageSource source) async {
    if (_userImages.length >= _maxImages) return;

    setState(() => _isUploadingMedia = true);
    try {
      final url = await _mediaService.uploadPortfolioImage(source: source);
      if (url != null && mounted) {
        setState(() {
          _userImages.add(url);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เพิ่มรูปภาพผลงานที่ ${_userImages.length} สำเร็จ'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('อัปโหลดรูปผลงานล้มเหลว: $e')));
    } finally {
      if (mounted) setState(() => _isUploadingMedia = false);
    }
  }

  // บันทึกชื่อและคำแนะนำตัว
  Future<void> _saveProfileData() async {
    final newName = _nameEditController.text.trim();
    final newBio = _bioEditController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกชื่อของคุณ')));
      return;
    }

    setState(() => _isSavingProfile = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'full_name': newName,
              'bio': newBio,
              'updated_at': FieldValue.serverTimestamp(),
            });
      }

      if (!mounted) return;

      setState(() {
        _currentName = newName;
        _currentBio = newBio.isNotEmpty ? newBio : 'ช่องแนะนำตัว';
        _currentView = 'main';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกข้อมูลโปรไฟล์เรียบร้อยแล้ว'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึก: $e')));
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  @override
  void dispose() {
    _nameEditController.dispose();
    _bioEditController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: _currentView != 'main'
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  setState(() {
                    if (_currentView == 'change_password') {
                      _currentView = 'settings';
                    } else if (_currentView == 'edit_profile') {
                      _currentView = 'settings';
                    } else {
                      _currentView = 'main';
                    }
                  });
                },
              )
            : null,
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoadingUserData && _currentView == 'main'
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0F4C81)),
              )
            : _buildCurrentViewBody(),
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  String _getAppBarTitle() {
    switch (_currentView) {
      case 'payments':
        return 'การชำระเงิน';
      case 'history':
        return 'ประวัติการจ้างงาน';
      case 'settings':
        return 'การตั้งค่า';
      case 'edit_profile':
        return 'แก้ไขโปรไฟล์';
      case 'change_password':
        return 'ความปลอดภัยและรหัสผ่าน';
      default:
        return 'โปรไฟล์';
    }
  }

  Widget _buildCurrentViewBody() {
    switch (_currentView) {
      case 'payments':
        return _buildPaymentsView();
      case 'history':
        return _buildHistoryView();
      case 'settings':
        return _buildSettingsView();
      case 'edit_profile':
        return _buildEditProfileView();
      case 'change_password':
        return _buildChangePasswordView();
      default:
        return _buildMainProfileView();
    }
  }

  // ===========================================================================
  // 1. หน้าโปรไฟล์หลัก
  // ===========================================================================
  Widget _buildMainProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF002244),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isEmployer = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _isEmployer ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'ผู้จ้าง',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isEmployer
                              ? const Color(0xFF002244)
                              : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _isEmployer = false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JobberHomeScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: !_isEmployer ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'ผู้รับจ้าง',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: !_isEmployer
                              ? const Color(0xFF002244)
                              : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // แสดงรูปโปรไฟล์จริง
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0F4C81),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _profileImageUrl.isNotEmpty
                              ? NetworkImage(_profileImageUrl)
                              : null,
                          child: _profileImageUrl.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4AC4F3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_currentRating > 0 ? _currentRating.toStringAsFixed(1) : "0.0"} คะแนน/รีวิว',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      _currentName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _nameEditController.text = _currentName;
                          _bioEditController.text =
                              _currentBio == 'ช่องแนะนำตัว' ? '' : _currentBio;
                          _currentView = 'edit_profile';
                        });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              _currentBio,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.edit_note,
                            color: Colors.black54,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

          _buildMenuTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'การชำระเงิน',
            onTap: () => setState(() => _currentView = 'payments'),
          ),
          const SizedBox(height: 16),
          _buildMenuTile(
            icon: Icons.business_center_outlined,
            title: 'ประวัติการจ้างงาน',
            onTap: () => setState(() => _currentView = 'history'),
          ),
          const SizedBox(height: 16),
          _buildMenuTile(
            icon: Icons.settings_outlined,
            title: 'การตั้งค่า',
            onTap: () => setState(() => _currentView = 'settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. หน้าย่อย: แก้ไขโปรไฟล์ (อัปโหลดรูปโปรไฟล์ & รูปผลงานจริงขึ้น Storage)
  // ===========================================================================
  Widget _buildEditProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0F4C81),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _profileImageUrl.isNotEmpty
                        ? NetworkImage(_profileImageUrl)
                        : null,
                    child: _isUploadingMedia
                        ? const CircularProgressIndicator(
                            color: Color(0xFF0F4C81),
                          )
                        : (_profileImageUrl.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 55,
                                  color: Colors.grey,
                                )
                              : null),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _isUploadingMedia
                        ? null
                        : () {
                            _showImagePickerChoice(
                              onSelected: (source) =>
                                  _handleUploadProfileImage(source),
                            );
                          },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4AC4F3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // รายการรูปภาพผลงาน 5 ภาพ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'รูปภาพผลงาน',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '(${_userImages.length}/$_maxImages ภาพ)',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _maxImages,
            itemBuilder: (context, index) {
              final bool hasImage = index < _userImages.length;

              if (hasImage) {
                final imageUrl = _userImages[index];
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFFE8F5FD),
                        border: Border.all(
                          color: const Color(0xFF4AC4F3),
                          width: 1.5,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () async {
                          await _mediaService.deletePortfolioImage(imageUrl);
                          setState(() {
                            _userImages.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return InkWell(
                onTap: _isUploadingMedia
                    ? null
                    : () {
                        if (_userImages.length < _maxImages) {
                          _showImagePickerChoice(
                            onSelected: (source) =>
                                _handleUploadPortfolioImage(source),
                          );
                        }
                      },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black26,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.black45,
                      size: 24,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          const Text(
            'ชื่อที่แสดง',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameEditController,
            decoration: InputDecoration(
              hintText: 'กรอกชื่อของคุณ',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF4AC4F3),
                  width: 1.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ข้อความแนะนำตัวสั้นๆ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'สูงสุด 100 ตัวอักษร',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bioEditController,
            maxLength: 100,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'เขียนแนะนำตัวเองสั้นๆ เพื่อให้คู่สนทนารู้จักคุณมากขึ้น...',
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF4AC4F3),
                  width: 1.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSavingProfile ? null : _saveProfileData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4AC4F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSavingProfile
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'บันทึกข้อมูล',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. หน้าย่อย: การชำระเงิน
  // ===========================================================================
  Widget _buildPaymentsView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _paymentHistory.length,
      itemBuilder: (context, index) {
        final item = _paymentHistory[index];
        final double amount = item['amount'] as double;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF4AC4F3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    '฿${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item['jobber'],
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                item['status'],
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['time'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 4. หน้าย่อย: ประวัติการจ้างงาน
  // ===========================================================================
  Widget _buildHistoryView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _jobHistory.length,
      itemBuilder: (context, index) {
        final item = _jobHistory[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF4AC4F3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['status'],
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['time'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 5. หน้าย่อย: การตั้งค่า
  // ===========================================================================
  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        _buildSettingOption(
          icon: Icons.person_outline,
          title: 'แก้ไขข้อมูลส่วนตัว',
          subtitle: 'แก้ไขชื่อ, รูปโปรไฟล์ และข้อความแนะนำตัว',
          onTap: () {
            setState(() {
              _nameEditController.text = _currentName;
              _bioEditController.text = _currentBio == 'ช่องแนะนำตัว'
                  ? ''
                  : _currentBio;
              _currentView = 'edit_profile';
            });
          },
        ),
        const Divider(height: 20),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(
            Icons.notifications_none,
            color: Colors.black87,
          ),
          title: const Text(
            'การแจ้งเตือน',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: const Text(
            'แจ้งเตือนสถานะงานและข้อความใหม่',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          value: _notiEnabled,
          activeColor: const Color(0xFF4AC4F3),
          onChanged: (val) {
            setState(() => _notiEnabled = val);
          },
        ),
        const Divider(height: 20),
        _buildSettingOption(
          icon: Icons.lock_outline,
          title: 'ความปลอดภัยและรหัสผ่าน',
          subtitle: 'เปลี่ยนรหัสผ่านเข้าใช้งาน',
          onTap: () {
            setState(() {
              _oldPasswordController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
              _otpController.clear();
              _isUsingOtp = false;
              _otpVerified = false;
              _currentView = 'change_password';
            });
          },
        ),
        const Divider(height: 20),
        _buildSettingOption(
          icon: Icons.headset_mic_outlined,
          title: 'ศูนย์ช่วยเหลือและฝ่ายบริการลูกค้า',
          subtitle: 'รายงานปัญหาการใช้งาน',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const AdminChatScreen(userRole: 'ผู้ว่าจ้าง'),
              ),
            );
          },
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text(
              'ออกจากระบบ',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 6. หน้าย่อย: เปลี่ยนรหัสผ่าน
  // ===========================================================================
  Widget _buildChangePasswordView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF6FB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF00AEEF).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF0F4C81),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isUsingOtp
                        ? 'ยืนยันตัวตนด้วยรหัส OTP ผ่านเบอร์โทรศัพท์เพื่อตั้งรหัสผ่านใหม่'
                        : 'กรุณากรอกรหัสผ่านเดิมเพื่อความปลอดภัยก่อนตั้งรหัสผ่านใหม่',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (!_isUsingOtp) ...[
            const Text(
              'รหัสผ่านเดิม',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _oldPasswordController,
              obscureText: _obscureOldPass,
              decoration: InputDecoration(
                hintText: 'กรอกรหัสผ่านเดิมของคุณ',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF0F4C81),
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOldPass ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureOldPass = !_obscureOldPass),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 4),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isUsingOtp = true;
                    _otpVerified = false;
                  });
                },
                child: const Text(
                  'ลืมรหัสผ่านเดิม? ใช้รหัส OTP แทน',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00AEEF),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],

          if (_isUsingOtp) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ยืนยันเบอร์โทรศัพท์',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isUsingOtp = false),
                  child: const Text(
                    'กลับไปใช้รหัสเดิม',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        color: Color(0xFF0F4C81),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF000),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'ส่งรหัส OTP ไปยังเบอร์โทรศัพท์ของคุณแล้ว',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'ส่ง OTP',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'กรอกรหัส OTP 6 หลัก',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(
                        Icons.security,
                        color: Color(0xFF0F4C81),
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _otpVerified
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF0F4C81),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_otpController.text.trim().isNotEmpty) {
                      setState(() => _otpVerified = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'ยืนยันรหัส OTP ถูกต้อง ปลดล็อกตั้งรหัสผ่านใหม่แล้ว',
                          ),
                          backgroundColor: Color(0xFF22C55E),
                        ),
                      );
                    }
                  },
                  child: Text(
                    _otpVerified ? 'ยืนยันแล้ว' : 'ตรวจสอบ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
          ],

          const Text(
            'รหัสผ่านใหม่',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _newPasswordController,
            obscureText: _obscureNewPass,
            enabled: !_isUsingOtp || _otpVerified,
            decoration: InputDecoration(
              hintText: 'อย่างน้อย 8 ตัวอักษร',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: const Icon(
                Icons.lock_reset,
                color: Color(0xFF0F4C81),
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPass ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureNewPass = !_obscureNewPass),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'ยืนยันรหัสผ่านใหม่',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPass,
            enabled: !_isUsingOtp || _otpVerified,
            decoration: InputDecoration(
              hintText: 'กรอกรหัสผ่านใหม่อีกครั้งให้ตรงกัน',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF0F4C81),
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPass ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirmPass = !_obscureConfirmPass),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final newPass = _newPasswordController.text.trim();
                final confirmPass = _confirmPasswordController.text.trim();

                if (!_isUsingOtp &&
                    _oldPasswordController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('กรุณากรอกรหัสผ่านเดิม หรือเลือกใช้ OTP'),
                    ),
                  );
                  return;
                }
                if (_isUsingOtp && !_otpVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('กรุณายืนยันรหัส OTP ให้ถูกต้องก่อน'),
                    ),
                  );
                  return;
                }
                if (newPass.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'รหัสผ่านใหม่ต้องมีความยาวอย่างน้อย 6-8 ตัวอักษร',
                      ),
                    ),
                  );
                  return;
                }
                if (newPass != confirmPass) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'รหัสผ่านใหม่และการยืนยันรหัสผ่านไม่ตรงกัน',
                      ),
                    ),
                  );
                  return;
                }

                setState(() => _currentView = 'settings');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('เปลี่ยนรหัสผ่านใหม่สำเร็จเรียบร้อยแล้ว'),
                    backgroundColor: Color(0xFF22C55E),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002244),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'บันทึกรหัสผ่านใหม่',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.black38,
      ),
      onTap: onTap,
    );
  }

  // ===========================================================================
  // 7. แถบเมนูล่าง
  // ===========================================================================
  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 80,
      color: const Color(0xFF002244),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'หน้าแรก',
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
          _buildNavItem(
            icon: Icons.notifications,
            label: 'แจ้งเตือน',
            hasBadge: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationListScreen(),
                ),
              );
            },
          ),
          _buildNavItem(
            icon: Icons.work,
            label: 'งานของฉัน',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyJobsScreen()),
              );
            },
          ),
          _buildNavItem(
            icon: Icons.chat,
            label: 'ข้อความ',
            hasBadge: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListScreen()),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6BB82D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_circle, color: Colors.white, size: 26),
                Text(
                  'โปรไฟล์',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool hasBadge = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              if (hasBadge)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

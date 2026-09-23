import 'package:flutter/material.dart';
import '../home.dart';
import '../หน้าแจ้งเตือน/notification_list.dart';
import '../หน้างานของฉัน/my_jobs.dart';
import '../หน้าข้อความ/chat_list.dart';

class ProfileScreen extends StatefulWidget {
  // ===========================================================================
  // [BACKEND HOOKS]
  // ข้อมูลจริงของผู้ใช้ ปัจจุบันรับผ่าน Constructor และมี Default สำหรับ Mockup
  // ในอนาคตเชื่อมต่อ: FirebaseAuth.instance.currentUser หรือ Users Collection
  // ===========================================================================
  final String userName;
  final String userBio;
  final double rating;
  final String? activeJobTitle;
  final String? activeJobberName;
  final double? activeWageAmount;
  final bool isCompleted;

  const ProfileScreen({
    Key? key,
    this.userName = 'ดนัย',
    this.userBio = 'ช่องแนะนำตัว',
    this.rating = 4.5,
    this.activeJobTitle,
    this.activeJobberName,
    this.activeWageAmount,
    this.isCompleted = false,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // มุมมองย่อย: 'main', 'payments', 'history', 'settings'
  String _currentView = 'main';

  // สวิตช์สลับ ผู้จ้าง / ผู้รับจ้าง (ค่าเริ่มต้น: ผู้จ้าง)
  bool _isEmployer = true;

  // การตั้งค่าแจ้งเตือน
  bool _notiEnabled = true;

  late List<Map<String, dynamic>> _paymentHistory;
  late List<Map<String, dynamic>> _jobHistory;

  @override
  void initState() {
    super.initState();

    // ===========================================================================
    // [DATA INTEGRATION]
    // รวมงานจริงที่ส่งต่อมาจากหน้างาน/การจ่ายเงิน เข้ากับรายการประวัติ
    // ===========================================================================
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
                    _currentView = 'main';
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
      body: SafeArea(child: _buildCurrentViewBody()),
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
      default:
        return _buildMainProfileView();
    }
  }

  // ===========================================================================
  // 1. หน้าโปรไฟล์หลัก (Profile Main View)
  // ===========================================================================
  Widget _buildMainProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนหัว: สวิตช์สลับ ผู้จ้าง / ผู้รับจ้าง
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
                    onTap: () => setState(() => _isEmployer = false),
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

          // ข้อมูลโปรไฟล์ส่วนตัว
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
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          ),
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
                    '${widget.rating} คะแนน/รีวิว',
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
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          widget.userBio,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.edit_note,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // รายการเมนู
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
  // 2. หน้าย่อย: การชำระเงิน (Payments View)
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
                  const Text(
                    'รายละเอียด',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      decoration: TextDecoration.underline,
                    ),
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
  // 3. หน้าย่อย: ประวัติการจ้างงาน (Job History View)
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
                  const Text(
                    'รายละเอียด',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      decoration: TextDecoration.underline,
                    ),
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
  // 4. หน้าย่อย: การตั้งค่าที่จำเป็น (Settings View)
  // ===========================================================================
  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // แก้ไขโปรไฟล์
        _buildSettingOption(
          icon: Icons.person_outline,
          title: 'แก้ไขข้อมูลส่วนตัว',
          subtitle: 'ชื่อ, เบอร์โทรศัพท์, ที่อยู่เริ่มต้น',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('เปิดหน้าจอแก้ไขข้อมูลส่วนตัว...')),
            );
          },
        ),
        const Divider(height: 20),

        // แจ้งเตือน
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

        // ความปลอดภัย
        _buildSettingOption(
          icon: Icons.lock_outline,
          title: 'ความปลอดภัยและรหัสผ่าน',
          subtitle: 'เปลี่ยนรหัสผ่านเข้าใช้งาน',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('เปิดหน้าเปลี่ยนรหัสผ่าน...')),
            );
          },
        ),
        const Divider(height: 20),

        // ติดต่อฝ่ายบริการลูกค้า
        _buildSettingOption(
          icon: Icons.headset_mic_outlined,
          title: 'ศูนย์ช่วยเหลือและฝ่ายบริการลูกค้า',
          subtitle: 'รายงานปัญหาการใช้งาน',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('กำลังติดต่อศูนย์บริการ JibJob...')),
            );
          },
        ),
        const SizedBox(height: 36),

        // ปุ่มออกจากระบบ
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              // ===============================================================
              // [BACKEND: SignOut Auth Token]
              // FirebaseAuth.instance.signOut();
              // ===============================================================
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
  // 5. แถบเมนูล่าง (Bottom Navigation Bar)
  // ===========================================================================
  Widget _buildCustomBottomNavBar() {
    return Container(
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
          // ปุ่มโปรไฟล์ (ไฮไลต์สีเขียว)
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

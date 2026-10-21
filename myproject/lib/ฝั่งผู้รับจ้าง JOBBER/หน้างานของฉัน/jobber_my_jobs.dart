import 'package:flutter/material.dart';
import '../หน้าการรับงาน/jobber_home.dart';
import '../หน้าข้อความ/jobber_messages.dart';
import '../หน้าโปรไฟล์ผู้รับจ้าง/jobber_profile.dart';
import '../หน้าการรับงาน/jobber_tracking.dart';

class JobberMyJobsScreen extends StatefulWidget {
  final Map<String, dynamic>? inProgressJob;
  final Map<String, dynamic>? completedJob;
  final int initialIndex;

  const JobberMyJobsScreen({
    Key? key,
    this.inProgressJob,
    this.completedJob,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<JobberMyJobsScreen> createState() => _JobberMyJobsScreenState();
}

class _JobberMyJobsScreenState extends State<JobberMyJobsScreen> {
  late int _selectedTabIndex;
  final Color _activeTabColor = const Color.fromARGB(255, 93, 183, 184);

  List<Map<String, dynamic>> _inProgressJobs = [
    {
      'id': 'job_001',
      'title': 'คนพาหมาไปเดินเล่น',
      'wage': '300 ฿',
      'wageDetail': '300 บาท',
      'distance': 'ห่างจากคุณ 1.5 กม.',
      'timeAgo': 'กำลังดำเนินการ',
      'jobType': 'คนพาหมาไปเดินเล่น',
      'date': '12 พ.ย. 2568',
      'location': '123/45 หมู่บ้าน สุขใจ ลาดพร้าว80',
      'timeRange': '16:30-17:30 น.',
    },
  ];

  final List<Map<String, dynamic>> _waitingJobs = [
    {
      'id': 'job_002',
      'title': 'ฉันหาคนพาหมาไปเดินเล่น',
      'wage': '300 ฿',
      'distance': 'ห่างจากคุณ 1.5 กม.',
      'timeAgo': '2 นาที ที่ผ่านมา',
      'jobType': 'คนพาหมาไปเดินเล่น',
      'date': '12 พ.ย. 2568',
      'location': '123/45 หมู่บ้าน สุขใจ ลาดพร้าว80',
      'timeRange': '16:30-17:30 น.',
      'wageDetail': '300 บาท',
    },
  ];

  List<Map<String, dynamic>> _completedJobs = [];

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialIndex;

    if (widget.inProgressJob != null) {
      _inProgressJobs.insert(0, widget.inProgressJob!);
    }
    if (widget.completedJob != null) {
      _completedJobs.insert(0, widget.completedJob!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Text(
                'งานของฉัน',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildTabButton(index: 0, label: 'กำลังทำอยู่'),
                  const SizedBox(width: 8),
                  _buildTabButton(index: 1, label: 'รอการตอบรับ'),
                  const SizedBox(width: 8),
                  _buildTabButton(index: 2, label: 'สำเร็จแล้ว'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildTabButton({required int index, required String label}) {
    final bool isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? _activeTabColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? _activeTabColor : Colors.grey.shade300,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    List<Map<String, dynamic>> currentList;

    if (_selectedTabIndex == 0) {
      currentList = _inProgressJobs;
    } else if (_selectedTabIndex == 1) {
      currentList = _waitingJobs;
    } else {
      currentList = _completedJobs;
    }

    if (currentList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/empty_bird.png',
              width: 95,
              height: 95,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.flutter_dash,
                size: 85,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ยังไม่มีงานเลย..',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: currentList.length,
      itemBuilder: (context, index) {
        final job = currentList[index];
        return GestureDetector(
          onTap: () {
            if (_selectedTabIndex == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobberTrackingScreen(job: job),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'งานใหม่',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      job['timeAgo'] ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  job['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${job['wage']} ${job['distance']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      if (_selectedTabIndex == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                JobberTrackingScreen(job: job),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('เปิดดูรายละเอียด "${job['title']}"'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'รายละเอียดงาน',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // โครงสร้าง Bottom Navigation Bar ตามภาพต้นแบบที่ 2 เป๊ะๆ
  // ===========================================================================
  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 80,
      color: const Color(0xFF00AEEF),
      // ปรับ padding ด้านบนเพื่อดันกลุ่มปุ่มและกล่องเขียวให้ร่นลงมา ไม่ชิดขอบบน
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 4, // <--- เพิ่มระยะเว้นจากขอบบน (ลองปรับ 8 - 12 ตามความพอดี)
        bottom: 4,
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment
              .center, // จัดให้อยู่กึ่งกลางแนวตั้งของพื้นที่ที่เหลือ
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'หน้าแรก',
              isSelected: false,
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JobberHomeScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
            _buildNavItem(
              icon: Icons.work,
              label: 'งานของฉัน',
              isSelected: true,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.chat,
              label: 'ข้อความ',
              hasBadge: true,
              isSelected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JobberMessagesScreen(),
                  ),
                );
              },
            ),
            _buildNavItem(
              icon: Icons.account_circle,
              label: 'โปรไฟล์',
              isSelected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JobberProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 71,
        height: 55,
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFF8DC63F),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 26),
                if (hasBadge && !isSelected)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

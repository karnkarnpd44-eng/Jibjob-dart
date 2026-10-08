// lib/หน้างานของฉัน/my_jobs.dart
import 'package:flutter/material.dart';
import '../home.dart';
import '../หน้าข้อความ/chat_list.dart';
import '../หน้าแจ้งเตือน/notification_list.dart';
import '../หน้าโปรไฟล์ผู้จ้าง/profile.dart';
import '../หน้าการสร้างงาน/jobber_working.dart'; // ✅ นำเข้าหน้า JobberWorkingScreen

class MyJobsScreen extends StatefulWidget {
  final String? activeJobTitle;
  final String? activeJobDate;
  final String? initialTab; // 'ongoing', 'waiting', 'completed'
  final bool isCancelled;

  const MyJobsScreen({
    Key? key,
    this.activeJobTitle,
    this.activeJobDate,
    this.initialTab = 'ongoing',
    this.isCancelled = false,
  }) : super(key: key);

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  late int _selectedTabIndex;
  late List<Map<String, dynamic>> _ongoingJobs;
  late List<Map<String, dynamic>> _waitingJobs;
  late List<Map<String, dynamic>> _completedJobs;

  @override
  void initState() {
    super.initState();

    // 1. ตั้งค่าแท็บเริ่มต้นตามที่ถูกส่งมา
    if (widget.isCancelled || widget.initialTab == 'waiting') {
      _selectedTabIndex = 1; // แท็บ "รอการตอบรับ / งานที่ยกเลิก"
    } else if (widget.initialTab == 'completed') {
      _selectedTabIndex = 2; // แท็บ "สำเร็จแล้ว"
    } else {
      _selectedTabIndex = 0; // แท็บ "กำลังทำอยู่"
    }

    // 2. งานที่กำลังทำอยู่
    _ongoingJobs = [
      if (!widget.isCancelled &&
          widget.initialTab != 'completed' &&
          widget.activeJobTitle != null)
        {
          'title': widget.activeJobTitle!,
          'time': widget.activeJobDate ?? '12/11/2568',
          'hasClockIcon': true,
        }
      else
        {
          'title': 'คนพาหมาไปเดินเล่น',
          'time': '12/11/2568',
          'hasClockIcon': true,
        },
    ];

    // 3. งานรอตอบรับ / งานที่ถูกยกเลิก (ดันงานที่เพิ่งยกเลิกขึ้นบนสุด)
    _waitingJobs = [
      if (widget.isCancelled && widget.activeJobTitle != null)
        {
          'title': 'คุณถูกกดยกเลิกงาน "${widget.activeJobTitle}" แล้ว',
          'time': 'เมื่อสักครู่',
        },
      {
        'title': 'คุณถูกกดยกเลิกงาน "คนช่วยถือของ" แล้ว',
        'time': '5 นาทีที่ผ่านมา',
      },
      {
        'title':
            'มีคนรับงาน "${widget.activeJobTitle ?? "พาหมาไปเดินเล่นแล้ว"}" แล้ว',
        'time': '2 ชั่วโมง ที่แล้ว',
      },
    ];

    // 4. งานที่สำเร็จแล้ว (ดันงานที่เพิ่งจบงานขึ้นบนสุด)
    _completedJobs = [
      if (widget.initialTab == 'completed' && widget.activeJobTitle != null)
        {
          'title': 'งาน "${widget.activeJobTitle}" สำเร็จ!',
          'time': 'เมื่อสักครู่',
        },
      {'title': 'งาน "ฝากซื้อของ" สำเร็จ!', 'time': '1 วัน'},
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
        title: const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text(
            'งานของฉัน',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildTabSelector(),
            const SizedBox(height: 20),
            Expanded(child: _buildSelectedTabContent()),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildTabButton(title: 'กำลังทำอยู่', index: 0),
          const SizedBox(width: 8),
          _buildTabButton(title: 'รอการตอบรับ', index: 1),
          const SizedBox(width: 8),
          _buildTabButton(title: 'สำเร็จแล้ว', index: 2),
        ],
      ),
    );
  }

  Widget _buildTabButton({required String title, required int index}) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: SizedBox(
        height: 42,
        child: ElevatedButton(
          onPressed: () => setState(() => _selectedTabIndex = index),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? const Color(0xFF4AC4F3)
                : Colors.white,
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            elevation: 0,
            side: const BorderSide(color: Color(0xFF4AC4F3), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
              color: isSelected ? Colors.black : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    List<Map<String, dynamic>> currentList;
    if (_selectedTabIndex == 0) {
      currentList = _ongoingJobs;
    } else if (_selectedTabIndex == 1) {
      currentList = _waitingJobs;
    } else {
      currentList = _completedJobs;
    }

    if (currentList.isEmpty) {
      return const Center(
        child: Text(
          'ไม่มีรายการงานในสถานะนี้',
          style: TextStyle(color: Colors.black45, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: currentList.length,
      itemBuilder: (context, index) {
        final job = currentList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF4AC4F3), width: 1.5),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              // ✅ เมื่ออยู่ในแท็บ "กำลังทำอยู่" ให้เปิดไปยังหน้า jobber_working.dart
              if (_selectedTabIndex == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobberWorkingScreen(
                      jobberName: 'สมชาย สายลุย',
                      rating: '4.8',
                      jobTitle: job['title']?.toString() ?? 'คนพาหมาไปเดินเล่น',
                      jobDate: job['time']?.toString() ?? '12/11/2568',
                      workTimeRange: '16:30-17:30',
                      wageAmount: 100.0,
                      feeAmount: 0.0,
                    ),
                  ),
                );
              }
            }, // ปิด onTap
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          job['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (job['hasClockIcon'] == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF4AC4F3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Color(0xFF00A3E0),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['time'],
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6BB82D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.work, color: Colors.white, size: 26),
                Text(
                  'งานของฉัน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
          _buildNavItem(
            icon: Icons.account_circle,
            label: 'โปรไฟล์',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
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

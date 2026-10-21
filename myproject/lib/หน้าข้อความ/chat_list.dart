import 'package:flutter/material.dart';
import '../หน้าหลักjibber/home.dart';
import 'chat_room.dart'; // import หน้าห้องแชท
import '../หน้าแจ้งเตือน/notification_list.dart';
import '../หน้างานของฉัน/my_jobs.dart';
import '../หน้าโปรไฟล์ผู้จ้าง/profile.dart';

class ChatListScreen extends StatefulWidget {
  final String jobberName;

  const ChatListScreen({Key? key, this.jobberName = 'กิตติพงษ์'})
    : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'กิตติพงษ์',
      'lastMessage': 'กำลังไปครับ!',
      'time': 'เมื่อสักครู่',
      'avatar': null,
    },
    {
      'name': 'สมชาย สายลุย',
      'lastMessage': 'ถึงแล้วครับ รออยู่หน้าหมู่บ้าน',
      'time': '12:30',
      'avatar': null,
    },
    {
      'name': 'วิภาดา รักสัตว์',
      'lastMessage': 'น้องหมาเรียบร้อยดีแล้วนะคะ ขอบคุณค่ะ',
      'time': 'เมื่อวาน',
      'avatar': null,
    },
  ];

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
            'ข้อความ',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: _chats.length,
          itemBuilder: (context, index) {
            final chat = _chats[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4AC4F3), width: 1.5),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoomScreen(
                        jobberName: chat['name']?.toString() ?? 'Jobber',
                        initialMessage:
                            chat['lastMessage']?.toString() ?? 'สวัสดีครับ',
                        initialTime: chat['time']?.toString() ?? 'เมื่อสักครู่',
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0F4C81),
                            width: 1.8,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: chat['avatar'] != null
                              ? AssetImage(chat['avatar'].toString())
                              : null,
                          child: chat['avatar'] == null
                              ? const Icon(
                                  Icons.person,
                                  size: 38,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chat['name']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  chat['lastMessage']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  chat['time']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: buildCustomBottomNavBar(context),
    );
  }

  Widget buildCustomBottomNavBar(BuildContext context) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6BB82D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat, color: Colors.white, size: 26),
                Text(
                  'ข้อความ',
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

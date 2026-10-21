import 'package:flutter/material.dart';
import '../หน้าการรับงาน/jobber_home.dart';
import '../หน้างานของฉัน/jobber_my_jobs.dart';
import '../หน้าโปรไฟล์ผู้รับจ้าง/jobber_profile.dart';

class JobberMessagesScreen extends StatefulWidget {
  final Map<String, dynamic>? job;

  const JobberMessagesScreen({Key? key, this.job}) : super(key: key);

  @override
  State<JobberMessagesScreen> createState() => _JobberMessagesScreenState();
}

class _JobberMessagesScreenState extends State<JobberMessagesScreen> {
  late List<Map<String, dynamic>> _chatRooms;

  @override
  void initState() {
    super.initState();
    _chatRooms = [
      {
        'id': 'room_01',
        'name': widget.job?['employerName'] ?? 'ดนัย',
        'avatar': 'assets/employer_avatar.png',
        'lastMessage': 'ส่งเมื่อ 1 นาทีที่ผ่านมา',
        'job':
            widget.job ??
            {
              'jobType': 'คนพาหมาไปเดินเล่น',
              'employerName': 'ดนัย',
              'wage': '100 ฿',
              'location': '123/45 หมู่บ้าน สุขใจ ลาดพร้าว80',
              'timeRange': '16:30-17:30 น.',
            },
      },
    ];
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
                'ข้อความ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                itemCount: _chatRooms.length,
                itemBuilder: (context, index) {
                  final room = _chatRooms[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF86D5F2),
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: Image.asset(
                            room['avatar'],
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      ),
                      title: Text(
                        room['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        room['lastMessage'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobberChatRoomScreen(
                              employerName: room['name'],
                              job: room['job'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
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
              isSelected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JobberMyJobsScreen(),
                  ),
                );
              },
            ),
            _buildNavItem(
              icon: Icons.chat,
              label: 'ข้อความ',
              hasBadge: false,
              isSelected: true,
              onTap: () {},
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

class JobberChatRoomScreen extends StatefulWidget {
  final String employerName;
  final Map<String, dynamic> job;

  const JobberChatRoomScreen({
    Key? key,
    required this.employerName,
    required this.job,
  }) : super(key: key);

  @override
  State<JobberChatRoomScreen> createState() => _JobberChatRoomScreenState();
}

class _JobberChatRoomScreenState extends State<JobberChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'employer',
      'text': 'สวัสดีครับ มาถึงบริเวณหน้าหมู่บ้านแล้วหรือยังครับ?',
      'time': '16:25',
    },
    {
      'sender': 'jobber',
      'text': 'สวัสดีครับ กำลังเลี้ยวเข้าซอยหน้าหมู่บ้านครับผม',
      'time': '16:26',
    },
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'jobber',
        'text': text,
        'time':
            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      });
    });

    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.job['jobType'] ?? widget.job['title'] ?? 'ข้อความ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final bool isMe = msg['sender'] == 'jobber';

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF86D5F2) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft: Radius.circular(isMe ? 14 : 2),
                        bottomRight: Radius.circular(isMe ? 2 : 14),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          msg['time'],
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'พิมพ์ข้อความ...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F3F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF00AEEF),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

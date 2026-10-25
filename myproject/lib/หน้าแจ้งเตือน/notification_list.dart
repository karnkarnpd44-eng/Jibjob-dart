// lib/หน้าแจ้งเตือน/notification_list.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../หน้าหลักjibber/home.dart';
import '../หน้าข้อความ/chat_list.dart';
import '../หน้าการสร้างงาน/jobber_arrived.dart';
import '../หน้างานของฉัน/my_jobs.dart';
import '../หน้าโปรไฟล์ผู้จ้าง/profile.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({Key? key}) : super(key: key);

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // ลบแจ้งเตือนออกจากสถานะ (สามารถเก็บสถานะการซ่อนไว้ใน Local หรือลบจริง)
  final Set<String> _dismissedIds = {};

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
            'แจ้งเตือน',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: currentUserId == null
            ? const Center(child: Text('กรุณาเข้าสู่ระบบก่อนใช้งาน'))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('jobs')
                    .where('employer_id', isEqualTo: currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4AC4F3),
                      ),
                    );
                  }

                  // รายการแจ้งเตือนเริ่มต้น ( Mockup ตามที่คุณต้องการให้อยู่ถาวร )
                  final List<Map<String, dynamic>> notifications = [
                    {
                      'id': 'welcome_msg',
                      'title':
                          'ยินดีต้อนรับสู่ JibJob!\nเริ่มโพสต์งานแรกของคุณได้เลย',
                      'description': '',
                      'time': '',
                      'icon': Icons.volunteer_activism,
                      'iconColor': const Color(0xFFE040FB),
                      'actionText': null,
                      'isUnread': false,
                    },
                  ];

                  if (snapshot.hasData) {
                    final docs = snapshot.data!.docs;

                    for (var doc in docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final jobId = doc.id;
                      if (_dismissedIds.contains(jobId))
                        continue; // ข้ามอันที่ถูกปัดลบไปแล้ว

                      final status = data['status'] ?? '';
                      final jobTitle = data['title'] ?? 'งานบริการ';
                      final jobberName = data['jobber_name'] ?? 'Jobber';
                      final rating = '4.8';
                      final date = data['job_date'] ?? '12/11/2568';
                      final timeRange =
                          data['work_time_range'] ?? '16:30-17:30';
                      final wage = (data['reward_amount'] is num)
                          ? (data['reward_amount'] as num).toDouble()
                          : 100.0;
                      final applicantIds =
                          (data['applicant_ids'] as List?) ?? [];

                      // 1. แจ้งเตือน: Jobber มาถึงแล้ว
                      if (status == 'jobber_arrived') {
                        notifications.add({
                          'id': jobId,
                          'title': 'Jobber มาถึงแล้ว!',
                          'description':
                              '$jobberName เดินทางมาถึงจุดนัดหมายแล้ว',
                          'time': 'เมื่อสักครู่',
                          'icon': Icons.notifications_active,
                          'iconColor': const Color(0xFFE53935),
                          'actionText': 'ตรวจสอบ',
                          'isUnread': true,
                          'onTapAction': () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobberArrivedScreen(
                                  jobId: jobId,
                                  jobberName: jobberName,
                                  rating: rating,
                                  jobTitle: jobTitle,
                                  jobDate: date,
                                  workTimeRange: timeRange,
                                  wageAmount: wage,
                                  feeAmount: 0.0,
                                ),
                              ),
                            );
                          },
                        });
                      }
                      // 2. แจ้งเตือน: จ่ายเงินสำเร็จ / งานเสร็จสิ้น
                      else if (status == 'completed') {
                        notifications.add({
                          'id': jobId,
                          'title': 'จ่ายเงินสำเร็จ!',
                          'description':
                              'คุณจ่ายเงินสำหรับงาน "$jobTitle" และงานเสร็จสิ้นแล้ว',
                          'time': 'เมื่อสักครู่',
                          'icon': Icons.payments_outlined,
                          'iconColor': const Color(0xFF7CD94C),
                          'actionText': null,
                          'isUnread': false,
                        });
                      }
                      // 3. แจ้งเตือน: มีคนรับงานแล้ว
                      else if (applicantIds.isNotEmpty && status == 'pending') {
                        notifications.add({
                          'id': jobId,
                          'title': 'มีคนรับงาน "$jobTitle" แล้ว',
                          'description': 'มีผู้สมัคร ${applicantIds.length} คน',
                          'time': 'เร็วๆ นี้',
                          'icon': Icons.celebration,
                          'iconColor': const Color(0xFF4AC4F3),
                          'actionText': null,
                          'isUnread': true,
                        });
                      }
                      // 4. แจ้งเตือน: งานถูกยกเลิก
                      else if (status == 'cancelled') {
                        notifications.add({
                          'id': jobId,
                          'title': 'คุณถูกกดยกเลิกงาน "$jobTitle" แล้ว',
                          'description': '',
                          'time': 'เมื่อสักครู่',
                          'icon': Icons.sentiment_dissatisfied,
                          'iconColor': const Color(0xFFFF9E44),
                          'actionText': null,
                          'isUnread': false,
                        });
                      }
                    }
                  }

                  if (notifications.isEmpty) {
                    return const Center(
                      child: Text(
                        'ไม่มีรายการแจ้งเตือน',
                        style: TextStyle(color: Colors.black45, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      final bool isUnread = item['isUnread'] == true;
                      final String uniqueKey = item['id'] ?? index.toString();

                      // ห่อหุ้มด้วย Dismissible เพื่อให้สไลด์ซ้ายเพื่อลบการ์ดแจ้งเตือนได้
                      return Dismissible(
                        key: Key(uniqueKey),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'ลบแจ้งเตือน',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            _dismissedIds.add(uniqueKey);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ลบการแจ้งเตือนเรียบร้อยแล้ว'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: item['onTapAction'] as VoidCallback?,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isUnread
                                  ? const Color(0xFFF0F9FF)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isUnread
                                    ? const Color(0xFF00A3E0)
                                    : const Color(0xFF4AC4F3),
                                width: isUnread ? 2.0 : 1.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isUnread)
                                  Container(
                                    margin: const EdgeInsets.only(
                                      top: 10,
                                      right: 8,
                                    ),
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    item['icon'] as IconData,
                                    size: 28,
                                    color: item['iconColor'] as Color,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isUnread
                                              ? FontWeight.w900
                                              : FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      if (item['description']
                                          .toString()
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item['description'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                      if (item['time']
                                          .toString()
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item['time'],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            if (item['actionText'] != null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFD0E884,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  item['actionText'],
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6BB82D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications, color: Colors.white, size: 26),
                Text(
                  'แจ้งเตือน',
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

// lib/หน้าแจ้งเตือน/notification_list.dart
import 'package:flutter/material.dart';
import '../home.dart';
import '../หน้าข้อความ/chat_list.dart';
import '../หน้าการสร้างงาน/jobber_arrived.dart';

class NotificationListScreen extends StatefulWidget {
  // รับข้อมูล Jobber และข้อมูลงานจริงที่เกี่ยวข้อง
  final String latestJobberName;
  final String latestRating;
  final String jobTitle;
  final String jobDate;
  final String workTimeRange;
  final double wageAmount;
  final double feeAmount;
  final bool hasNewArrival;

  const NotificationListScreen({
    Key? key,
    this.latestJobberName = 'สมชาย',
    this.latestRating = '4.8',
    this.jobTitle = 'คนพาหมาไปเดินเล่น',
    this.jobDate = '12/11/2568',
    this.workTimeRange = '16:30-17:30',
    this.wageAmount = 100.0,
    this.feeAmount = 0.0,
    this.hasNewArrival = true,
  }) : super(key: key);

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      {
        'title': 'Jobber มาถึงแล้ว!',
        'description': '${widget.latestJobberName} เดินทางมาถึงจุดนัดหมายแล้ว',
        'time': 'เมื่อสักครู่',
        'icon': Icons.notifications_active,
        'iconColor': const Color(0xFFE53935),
        'actionText': 'ตรวจสอบ',
        'isUnread': widget.hasNewArrival,
        'isArrivalEvent': true,
      },
      {
        'title': 'จ่ายเงินสำเร็จ!',
        'description': 'คุณจ่ายเงินสำหรับงาน "${widget.jobTitle}" แล้ว',
        'time': '1 นาทีที่แล้ว',
        'icon': Icons.payments_outlined,
        'iconColor': const Color(0xFF7CD94C),
        'actionText': null,
        'isUnread': false,
        'isArrivalEvent': false,
      },
      {
        'title': 'คุณถูกกดยกเลิกงาน "คนช่วยถือของ" แล้ว',
        'description': '',
        'time': '5 นาทีที่ผ่านมา',
        'icon': Icons.sentiment_dissatisfied,
        'iconColor': const Color(0xFFFF9E44),
        'actionText': null,
        'isUnread': false,
        'isArrivalEvent': false,
      },
      {
        'title': 'มีคนรับงาน "${widget.jobTitle}" แล้ว',
        'description': '',
        'time': '2 ชั่วโมง ที่แล้ว',
        'icon': Icons.celebration,
        'iconColor': const Color(0xFF4AC4F3),
        'actionText': null,
        'isUnread': false,
        'isArrivalEvent': false,
      },
      {
        'title': 'เริ่มเลย! ยุ่งอยู่หรือเปล่า? หาคนช่วยสิ',
        'description': '',
        'time': '',
        'icon': Icons.bolt,
        'iconColor': const Color(0xFF5B7FFF),
        'actionText': null,
        'isUnread': false,
        'isArrivalEvent': false,
      },
      {
        'title': 'ยินดีต้อนรับสู่ JibJob!\nเริ่มโพสต์งานแรกของคุณได้เลย',
        'description': '',
        'time': '',
        'icon': Icons.volunteer_activism,
        'iconColor': const Color(0xFFE040FB),
        'actionText': null,
        'isUnread': false,
        'isArrivalEvent': false,
      },
    ];
  }

  // ส่งก้อนข้อมูลจริงเข้า JobberArrivedScreen ครบทุกพารามิเตอร์
  void _openJobberArrivedScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobberArrivedScreen(
          jobberName: widget.latestJobberName,
          rating: widget.latestRating,
          jobTitle: widget.jobTitle,
          jobDate: widget.jobDate,
          workTimeRange: widget.workTimeRange,
          wageAmount: widget.wageAmount,
          feeAmount: widget.feeAmount,
        ),
      ),
    );
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
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final item = _notifications[index];
            final bool isUnread = item['isUnread'] == true;

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (item['isArrivalEvent'] == true) {
                  setState(() => item['isUnread'] = false);
                  _openJobberArrivedScreen();
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isUnread ? const Color(0xFFF0F9FF) : Colors.white,
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
                        margin: const EdgeInsets.only(top: 10, right: 8),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          if (item['description'].toString().isNotEmpty) ...[
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
                          if (item['time'].toString().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['time'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (item['actionText'] != null)
                                  InkWell(
                                    onTap: () {
                                      setState(() => item['isUnread'] = false);
                                      _openJobberArrivedScreen();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD0E884),
                                        borderRadius: BorderRadius.circular(8),
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
            );
          },
        ),
      ),
      bottomNavigationBar: buildCustomBottomNavBar(context),
    );
  }

  Widget buildCustomBottomNavBar(BuildContext context) {
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
          _buildNavItem(icon: Icons.work, label: 'งานของฉัน'),
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
          _buildNavItem(icon: Icons.account_circle, label: 'โปรไฟล์'),
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

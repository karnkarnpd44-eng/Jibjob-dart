// lib/หน้าหลักjibber/home.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../หน้าการสร้างงาน/post_job.dart';
import '../หน้าการสร้างงาน/waiting_jobber.dart';
import '../หน้างานของฉัน/my_jobs.dart';
import '../หน้าข้อความ/chat_list.dart';
import '../หน้าแจ้งเตือน/notification_list.dart';
import '../หน้าโปรไฟล์ผู้จ้าง/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ------------------ APP BAR ------------------
  PreferredSizeWidget buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset('assets/jibjob.png', height: 42),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black26, width: 1.2),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'วันนี้มีอะไรให้ช่วยมั้ยครับ?',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.black38),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ------------------ BODY ------------------
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          buildCallJobberButton(context),
          const SizedBox(height: 12),
          buildSectionTitle("งานแนะนำ"),
          buildRecommendedCategories(),
          const SizedBox(height: 12),
          // 💡 ปุ่มทางลัดงานที่กำลังรอให้ช่วย (เชื่อมต่อ Firestore Realtime อัตโนมัติ)
          buildWaitingJobberButton(context),
          const SizedBox(height: 12),
          buildSectionTitle("ข่าวสาร.."),
          buildNewsSection(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // ------------------ CALL JOBBER BUTTON ------------------
  Widget buildCallJobberButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PostJobScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5AB6C3),
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.black87, width: 2.5),
            ),
          ),
          child: const Text(
            'เรียก Jobber',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------ RECOMMENDED CATEGORIES ------------------
  Widget buildRecommendedCategories() {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: const [
          LargeCategoryCard(
            text: 'งานบ้านและชีวิตประจำวัน',
            color: Color(0xFFFFF275),
            image: 'assets/im1.png',
          ),
          LargeCategoryCard(
            text: 'ฝากซื้อ รับ-ส่งของ',
            color: Color(0xFFFFC5C5),
            image: 'assets/im2.png',
          ),
          LargeCategoryCard(
            text: 'ดูแลสัตว์เลี้ยง',
            color: Color(0xFF98A6FF),
            image: 'assets/im3.png',
          ),
          LargeCategoryCard(
            text: 'ติวหนังสือ/การบ้าน',
            color: Color(0xFFFFEFB0),
            image: 'assets/im4.png',
          ),
          LargeCategoryCard(
            text: 'จัดกิจกรรม/เซอร์ไพรส์',
            color: Color(0xFFFFD6E8),
            image: 'assets/im5.png',
          ),
          LargeCategoryCard(
            text: 'งานออนไลน์',
            color: Color(0xFFDCCBFF),
            image: 'assets/im6.png',
          ),
          LargeCategoryCard(
            text: 'งานช่างเบื้องต้น',
            color: Color(0xFFFFEFB0),
            image: 'assets/im7.png',
          ),
          LargeCategoryCard(
            text: 'พิเศษ',
            color: Color(0xFFFFD6E8),
            image: 'assets/im8.png',
          ),
          LargeCategoryCard(
            text: 'อื่นๆ',
            color: Color(0xFFDCCBFF),
            image: 'assets/im9.png',
          ),
        ],
      ),
    );
  }

  // ------------------ WAITING JOBBER BUTTON (FIRESTORE REALTIME) ------------------
  Widget buildWaitingJobberButton(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      // ดึงงานสถานะ 'pending' ที่เป็นของผู้ว่าจ้างคนนี้
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('employer_id', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        // หากไม่มีงานค้างรอรับ ให้ซ่อนปุ่มและหัวข้อนี้ไปเลย
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        // ดึงข้อมูลจริงของงานล่าสุดที่สร้าง
        final latestJobDoc = snapshot.data!.docs.first;
        final jobData = latestJobDoc.data() as Map<String, dynamic>;

        final String jobId = latestJobDoc.id;
        final String title = jobData['title'] ?? 'ไม่มีระบุชื่องาน';
        final String desc =
            jobData['description'] ?? 'ไม่มีรายละเอียดเพิ่มเติม';
        final String address =
            jobData['address'] ?? '123/45 หมู่บ้านสุขใจ ลาดพร้าว80';
        final String date = jobData['job_date'] ?? '12/11/2568';
        final String timeRange = jobData['work_time_range'] ?? '16:30-17:30';
        final double wage = (jobData['reward_amount'] is num)
            ? (jobData['reward_amount'] as num).toDouble()
            : 100.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionTitle("งานที่กำลังรอให้ช่วย"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // ส่งข้อมูลจริงทั้งหมดไปยัง WaitingJobberScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WaitingJobberScreen(
                          jobId: jobId,
                          jobTitle: title,
                          jobDesc: desc,
                          jobAddress: address,
                          jobDate: date,
                          workTimeRange: timeRange,
                          wageAmount: wage,
                          feeAmount: 0.0,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF00AEEF,
                    ), // สีฟ้าตามภาพที่ 1
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: Colors.black87, width: 1.5),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'รอ Jobber รับงาน ($title)...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------ NEWS SECTION ------------------
  Widget buildNewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5E5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black54, width: 1.2),
        ),
        child: const Center(
          child: Text(
            '•••',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------ TITLE ------------------
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
    );
  }

  // ------------------ BOTTOM NAVBAR ------------------
  Widget buildCustomBottomNavBar() {
    return Container(
      color: const Color(0xFF002244),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6BB82D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, color: Colors.white, size: 28),
                Text(
                  'หน้าแรก',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: buildBody(context),
      bottomNavigationBar: buildCustomBottomNavBar(),
    );
  }
}

// ------------------ LARGE CATEGORY CARD ------------------
class LargeCategoryCard extends StatelessWidget {
  final String text;
  final Color color;
  final String image;

  const LargeCategoryCard({
    Key? key,
    required this.text,
    required this.color,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black87, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 38, fit: BoxFit.contain),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

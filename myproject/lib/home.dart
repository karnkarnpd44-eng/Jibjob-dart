// home.dart
import 'package:flutter/material.dart';
import 'หน้าการสร้างงาน/post_job.dart';
import 'หน้าการสร้างงาน/waiting_jobber.dart';
import 'หน้าข้อความ/chat_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: buildBody(context),
      bottomNavigationBar: buildCustomBottomNavBar(),
    );
  }

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
          buildSectionTitle("งานที่กำลังรอให้ช่วย"),
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
            backgroundColor: const Color(0xFF5AB6C3), // สีฟ้าอมเขียวสว่างตามภาพ
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
            color: Color(0xFFFFF275), // สีเหลือง
            image: 'assets/im1.png',
          ),
          LargeCategoryCard(
            text: 'ฝากซื้อ รับ-ส่งของ',
            color: Color(0xFFFFC5C5), // สีชมพู
            image: 'assets/im2.png',
          ),
          LargeCategoryCard(
            text: 'ดูแลสัตว์เลี้ยง',
            color: Color(0xFF98A6FF), // สีฟ้าม่วง
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

  // ------------------ WAITING JOBBER BUTTON ------------------
  Widget buildWaitingJobberButton(BuildContext context) {
    return Padding(
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WaitingJobberScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A3E0), // สีฟ้าสด
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Colors.black87, width: 1.5),
            ),
            elevation: 0,
          ),
          child: const Row(
            children: [
              Text(
                'รอ Jobber รับงาน...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, size: 22, color: Colors.black87),
            ],
          ),
        ),
      ),
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
          color: const Color(0xFFE5E5E5), // พื้นหลังสีเทาอ่อนตามภาพ
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

  // ------------------ BOTTOM NAVBAR (CUSTOM UI) ------------------
  Widget buildCustomBottomNavBar() {
    return Container(
      color: const Color(0xFF002244), // สีกรมท่าเข้ม
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // หน้าแรก (แถบไฮไลต์สีเขียวมน)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6BB82D), // สีเขียวตองอ่อน
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

          // แจ้งเตือน (มี Badge สีแดง)
          _buildNavItem(
            icon: Icons.notifications,
            label: 'แจ้งเตือน',
            hasBadge: true,
          ),

          // งานของฉัน
          _buildNavItem(icon: Icons.work, label: 'งานของฉัน'),

          // ข้อความ (มี Badge สีแดง เชื่อมไปยัง ChatListScreen)
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

          // โปรไฟล์
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

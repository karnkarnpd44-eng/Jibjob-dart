// home.dart

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  //หน้ารอ jobber รับงาน-----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(context), // 💡 แก้ไข: ต้องส่ง context เข้าไป
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  // ------------------ APP BAR ------------------
  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset('assets/jibjob.png', height: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color.fromARGB(255, 47, 11, 230),
                ),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'วันนี้มีอะไรให้ช่วยครับ?',
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
    );
  }

  // ------------------ BODY ------------------
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildModeSelector(),
          buildCallJobberButton(),
          buildCategorySection(),
          // เมื่อ buildBody รับ context แล้ว การเรียกใช้ตรงนี้จะถูกต้อง
          buildSectionTitle("งานที่กำลังรอให้ช่วย"),
          buildWaitingJobberButton(context),
        ],
      ),
    );
  }

  // ------------------ MODE SELECTOR ------------------
  Widget buildModeSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5AB6E3),
                foregroundColor: Colors.white,
              ),
              child: const Text('วันนี้ฉันเป็น'),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF011966),
              foregroundColor: Colors.white,
            ),
            child: const Text('Jibber'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              side: const BorderSide(color: Colors.black12),
            ),
            child: const Text('Jobber'),
          ),
        ],
      ),
    );
  }

  // ------------------ CALL JOBBER BUTTON ------------------
  Widget buildCallJobberButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5AB6E3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.black, width: 2.0), // ขอบดำ
            ),
          ),
          child: const Text('เรียก Jobber', style: TextStyle(fontSize: 25)),
        ),
      ),
    );
  }

  // ------------------ CATEGORY SECTION ------------------
  Widget buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle("หมวดหมู่ทั้งหมด"),
        SizedBox(
          height: 100,

          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, top: 8),
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            clipBehavior: Clip.none,
            cacheExtent: 300,
            children: const [
              CategoryButton(
                text: 'แนะนำ',
                color: Color(0xFFDCCBFF),
                icon: Icons.star,
              ),
              CategoryButton(
                text: 'งานบ้านและชีวิตประจำวัน',
                color: Color(0xFFFFEFB0),
                image: 'assets/im1.png',
              ),
              CategoryButton(
                text: 'ฝากซื้อ/รับ-ส่งของ',
                color: Color(0xFFFFD6E8),
                image: 'assets/im2.png',
              ),
              CategoryButton(
                text: 'ดูแลสัตว์เลี้ยง',
                color: Color(0xFFDCCBFF),
                image: 'assets/im3.png',
              ),
              CategoryButton(
                text: 'ติวหนังสือ/การบ้าน',
                color: Color(0xFFFFEFB0),
                image: 'assets/im4.png',
              ),
              CategoryButton(
                text: 'จัดกิจกรรม/เซอร์ไพรส์',
                color: Color(0xFFFFD6E8),
                image: 'assets/im5.png',
              ),
              CategoryButton(
                text: 'งานออนไลน์',
                color: Color(0xFFDCCBFF),
                image: 'assets/im6.png',
              ),
              CategoryButton(
                text: 'งานช่างเบื้องต้น',
                color: Color(0xFFFFEFB0),
                image: 'assets/im7.png',
              ),
              CategoryButton(
                text: 'พิเศษ',
                color: Color(0xFFFFD6E8),
                image: 'assets/im8.png',
              ),
              CategoryButton(
                text: 'อื่นๆ',
                color: Color(0xFFDCCBFF),
                image: 'assets/im9.png',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------ WAITING JOBBER BUTTON ------------------
  Widget buildWaitingJobberButton(BuildContext context) {
    return Padding(
      // Padding รอบตัวปุ่ม (ขอบซ้ายขวา)
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // 💡 ลบ SizedBox(width: double.infinity) ออก เพราะ ElevatedButton จะยืดเต็มความกว้างใน Padding
      child: ElevatedButton(
        // 💡 ฟังก์ชันนำทางไปหน้าจอชั่วคราว
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // 💡 ใช้ Placeholder() ชั่วคราว
              builder: (context) =>
                  const Placeholder(), //ใส่ชื่อคลาสที่จัะไปตรงนี้
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5AB6E3), // สีฟ้า
          foregroundColor: Colors.white,

          // 💡 แก้ไข: เพิ่มความสูง (vertical: 20 -> 28)
          // 💡 แก้ไข: เพิ่มระยะห่างแนวนอนภายในปุ่ม (horizontal: 20) เพื่อไม่ให้ข้อความติดขอบ
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Colors.black, width: 2.0), // ขอบดำ
          ),
        ),
        child: const Row(
          children: [
            // 💡 แก้ไขขนาดฟอนต์ (fontSize: 18 -> 22)
            Text('รอ Jobber รับงาน...', style: TextStyle(fontSize: 18)),
            Icon(Icons.arrow_forward_ios), // ลูกศรชี้ขวา
          ],
        ),
      ),
    );
  }

  // ------------------ TITLE ------------------
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ------------------ BOTTOM NAV ------------------
  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color.fromARGB(255, 33, 3, 232),
      unselectedItemColor: const Color.fromARGB(255, 108, 106, 106),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าแรก'),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'แจ้งเตือน',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'งานของฉัน'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'ข้อความ'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
      ],
    );
  }
}

// ------------------ CATEGORY BUTTON ------------------
class CategoryButton extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final String? image;

  const CategoryButton({
    Key? key,
    required this.text,
    required this.color,
    this.icon,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null)
              Image.asset(image!, height: 28)
            else if (icon != null)
              Icon(icon, size: 28),

            const SizedBox(height: 6),

            Text(
              text,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

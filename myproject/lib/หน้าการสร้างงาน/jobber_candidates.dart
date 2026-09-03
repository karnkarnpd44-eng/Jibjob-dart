import 'package:flutter/material.dart';
import 'jobber_tracking.dart';

class JobberCandidatesScreen extends StatelessWidget {
  const JobberCandidatesScreen({Key? key}) : super(key: key);

  // ข้อมูลจำลอง Jobber ที่กดสนใจงานเข้ามา (รัศมีไม่เกิน 5 กม.)
  final List<Map<String, dynamic>> candidates = const [
    {
      'name': 'กิตติพงษ์',
      'rating': '4.5',
      'distance': '1.5 กม.',
      'avatar': 'assets/pim1.jpg',
    },
    {
      'name': 'อาทิตยา',
      'rating': '4.0',
      'distance': '2.0 กม.',
      'avatar': 'assets/pim2.jpg',
    },
    {
      'name': 'สมชาย',
      'rating': '4.8',
      'distance': '0.8 กม.',
      'avatar': 'assets/pim3.jpg',
    },
    {
      'name': 'วิภาดา',
      'rating': '4.9',
      'distance': '3.2 กม.',
      'avatar': 'assets/pim4.jpg',
    },
    {
      'name': 'ณัฐวุฒิ',
      'rating': '4.2',
      'distance': '4.1 กม.',
      'avatar': 'assets/pim5.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ชื่องาน
              const Text(
                'พาหมาไปเดินเล่น',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),

              // การ์ดข้อมูลงานด้านบน
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4AC4F3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '12 พ.ย. 2568   16:30 - 17:30',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 20),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '123/45 หมู่บ้าน สุขใจ ลาดพร้าว80',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          color: Colors.green,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '100 บาท',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Color(0xFF4AC4F3),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'รอ Jobber ตอบรับ (เหลือเวลา 45 นาที)',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // กล่องรายการ Jobber ที่สามารถเลื่อน Scroll ดูได้
              Container(
                height: 220, // ปรับความสูงของรายการเลื่อน
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black26, width: 1.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: candidates.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.black12,
                    ),
                    itemBuilder: (context, index) {
                      final item = candidates[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            // รูป Avatar Jobber
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.grey[200],
                              child: const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // ข้อมูลชื่อ คะแนน ระยะทาง
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item['rating']} ( ${item['distance']} )',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'ดูโปรไฟล์',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // ปุ่มเลือกสีเขียวสด
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () {
                                  // 💡 นำทางไปหน้าสถานะ Jobber กำลังมา
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          JobberTrackingScreen(
                                            jobberName: item['name'],
                                            rating: item['rating'],
                                            distance: item['distance'],
                                          ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF99E22B),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                ),
                                child: const Text(
                                  'เลือก',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ปุ่มต่อเวลาเปิดรับงาน
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.hourglass_empty,
                    color: Colors.black87,
                  ),
                  label: const Text(
                    'ต่อเวลาเปิดรับงาน (เพิ่มอีก 1 ชั่วโมง)',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF4AC4F3),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ปุ่มยกเลิกงาน (สีแดงส้ม)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel, color: Color(0xFF006666)),
                  label: const Text(
                    'ยกเลิกงาน',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A7A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // แถบแจ้งเตือนด้านล่าง
              const Divider(thickness: 1, color: Colors.black26),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: 16,
                    color: Colors.black54,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'เมื่อมี Jobber กดรับงานระบบจะแจ้งเตือนทันที',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

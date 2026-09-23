// lib/หน้าการสร้างงาน/jobber_arrived.dart
import 'package:flutter/material.dart';
import '../หน้าข้อความ/chat_room.dart';
import 'jobber_working.dart';

class JobberArrivedScreen extends StatelessWidget {
  // บังคับรับค่าจริงทุกตัว ไม่ใช้ค่าคงที่ Default อีกต่อไป
  final String jobberName;
  final String rating;
  final String jobTitle;
  final String jobDate;
  final String workTimeRange;
  final double wageAmount;
  final double feeAmount;

  const JobberArrivedScreen({
    Key? key,
    required this.jobberName,
    required this.rating,
    required this.jobTitle,
    required this.jobDate,
    required this.workTimeRange,
    required this.wageAmount,
    required this.feeAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jobber ถึงแล้ว!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // การ์ดแสดงสถานะ Jobber ถึงจุดนัดหมายแล้ว
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                decoration: BoxDecoration(
                  color: const Color(0xFF65C1BF),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  children: [
                    // ส่วนหัวการ์ด: แสดงรูปโปรไฟล์ ชื่อ และคะแนนรีวิว
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 34,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              jobberName, // 💡 แสดงชื่อคนที่เลือกไว้จริง
                              style: const TextStyle(
                                fontSize: 18,
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
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rating, // 💡 แสดงคะแนนรีวิวที่ส่งต่อมา
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'ดูโปรไฟล์',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ข้อความแจ้งเตือนสถานะ
                    const Text(
                      'Jobber ถึงจุดนัดหมายแล้ว!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ภาพประกอบ Jobber ขี่มอเตอร์ไซค์
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/jobber_arrived.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.two_wheeler,
                                size: 80,
                                color: Colors.white70,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ปุ่มที่ 1: ไปที่แชทเพื่อตรวจสอบ (เปิดห้องแชทของ Jobber คนนี้ทันที)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatRoomScreen(jobberName: jobberName),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD0E884),
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                              color: Colors.black26,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'ไปที่แชทเพื่อตรวจสอบ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ปุ่มที่ 2: เริ่มงานได้เลย! (ส่งต่อก้อนข้อมูลจริงเข้า JobberWorkingScreen ครบถ้วน)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobberWorkingScreen(
                                jobberName: jobberName,
                                rating: rating,
                                jobTitle: jobTitle,
                                jobDate: jobDate,
                                workTimeRange: workTimeRange,
                                wageAmount: wageAmount,
                                feeAmount: feeAmount,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9A800),
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                              color: Colors.black38,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'เริ่มงานได้เลย!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// [SIMULATION - ลบส่วนนี้เมื่อต่อ Backend จริง]
import 'dart:async';
import 'package:flutter/material.dart';
import 'jobber_arrived.dart';

class JobberTrackingScreen extends StatefulWidget {
  final String jobberName;
  final String rating;
  final String distance;

  const JobberTrackingScreen({
    Key? key,
    this.jobberName = 'กิตติพงษ์',
    this.rating = '4.5',
    this.distance = '1.5 กม.',
  }) : super(key: key);

  @override
  State<JobberTrackingScreen> createState() => _JobberTrackingScreenState();
}

class _JobberTrackingScreenState extends State<JobberTrackingScreen> {
  // ===========================================================================
  // [SIMULATION - ลบส่วนนี้เมื่อต่อ Backend จริง]
  // ตัวแปรจับเวลาสำหรับจำลองการเดินทาง 10 วินาที
  // ===========================================================================
  Timer? _trackingSimulationTimer;

  @override
  void initState() {
    super.initState();

    // ===========================================================================
    // [SIMULATION - ลบส่วนนี้เมื่อต่อ Backend จริง]
    // จำลอง Jobber เดินทาง 10 วินาที แล้วสลับหน้าจอไปที่ JobberArrivedScreen อัตโนมัติ
    // เมื่อต่อหลังบ้านจริง: ให้แทนที่จุดนี้ด้วย Firestore Listener ตรวจสอบสถานะงาน (status == 'jobber_arrived')
    // ===========================================================================
    _trackingSimulationTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => JobberArrivedScreen(
              jobberName: widget.jobberName,
              rating: widget.rating,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    // ===========================================================================
    // [SIMULATION - ลบส่วนนี้เมื่อต่อ Backend จริง]
    // ยกเลิก Timer เมื่อผู้ใช้ออกจากหน้าจอนี้ก่อนครบ 10 วินาที
    // ===========================================================================
    _trackingSimulationTimer?.cancel();

    super.dispose();
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'สถานะงาน Jobber กำลังมา...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF65C1BF),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              widget.jobberName,
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
                                  widget.rating,
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
                    const SizedBox(height: 16),

                    const Row(
                      children: [
                        Text(
                          'เวลาที่จะถึง',
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '5 นาที',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'ระยะทาง',
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                        const SizedBox(width: 24),
                        Text(
                          widget.distance,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'รายละเอียดงาน',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '12 พ.ย. 2568   16:30 - 17:30',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '123/45 หมู่บ้าน สุขใจ ลาดพร้าว80',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.payments_outlined,
                                color: Colors.green,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                '100 บาท',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
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
                                  fontSize: 12,
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

                    // แผนที่จำลอง
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          Positioned(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_pin,
                                    color: Color(0xFF6A1B9A),
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'ตำแหน่ง Jobber กำลังเดินทาง',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.black45,
                          size: 20,
                        ),
                        label: const Text(
                          'ยกเลิกงาน',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD3D7DC),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

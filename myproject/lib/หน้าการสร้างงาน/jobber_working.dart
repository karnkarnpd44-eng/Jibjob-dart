// [SIMULATION - ลบส่วนนี้เมื่อต่อ Backend จริง]
import 'dart:async';
import 'package:flutter/material.dart';
import '../หน้าข้อความ/chat_list.dart';

class JobberWorkingScreen extends StatefulWidget {
  final String jobberName;
  final String rating;
  final String jobCategory;

  const JobberWorkingScreen({
    Key? key,
    this.jobberName = 'กิตติพงษ์',
    this.rating = '4.5',
    this.jobCategory = 'ดูแลสัตว์เลี้ยงชั่วคราว',
  }) : super(key: key);

  @override
  State<JobberWorkingScreen> createState() => _JobberWorkingScreenState();
}

class _JobberWorkingScreenState extends State<JobberWorkingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _bounceAnimation;

  // ===========================================================================
  // [SIMULATION - ลบส่วนนี้เมื่อต่อ Backend จริง]
  // ตัวแปรจำลอง: ฝั่ง Jobber กดยืนยันส่งมอบงานเข้ามาแล้ว (ค่าเริ่มต้นคือยังไม่เสร็จ)
  // ===========================================================================
  Timer? _jobberFinishSimulationTimer;
  bool _isJobFinishedByJobber =
      false; // false = กำลังทำงาน, true = Jobber กดยืนยันเสร็จงานแล้ว

  @override
  void initState() {
    super.initState();

    // แอนิเมชันให้รูปการ์ตูนขยับลอยขึ้นลงเบาๆ จำลองการปฏิบัติงาน
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // ===========================================================================
    // [SIMULATION - ลบส่วนนี้เมื่อต่อ Backend จริง]
    // จำลองสถานการณ์: รอ 10 วินาที เสมือน Jobber กดส่งมอบงานจากเครื่องของตนเอง
    // ---------------------------------------------------------------------------
    // เมื่อต่อหลังบ้านจริง (Firebase Firestore):
    // ให้เปลี่ยนเป็น StreamSubscription ดักฟังการอัปเดตเอกสารในคอลเลกชัน Jobs
    // FirebaseFirestore.instance.collection('Jobs').doc(widget.jobId)
    //   .snapshots().listen((snapshot) {
    //     if (snapshot.data()?['status'] == 'completed_by_jobber' && mounted) {
    //       setState(() => _isJobFinishedByJobber = true);
    //     }
    //   });
    // ===========================================================================
    _jobberFinishSimulationTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isJobFinishedByJobber = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jobber ส่งมอบงานแล้ว โปรดตรวจสอบและยืนยันการจบงาน'),
            backgroundColor: Color(0xFF01224F),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    // ===========================================================================
    // [SIMULATION - ลบส่วนนี้เมื่อต่อ Backend จริง]
    // ยกเลิก Timer เมื่อออกจากหน้าจอ
    // ===========================================================================
    _jobberFinishSimulationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF65C1BF), // สีพื้นหลังฟ้าอมเขียวหลัก
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // หัวข้อด้านบน
              const Text(
                'Jobber กำลังทำงาน',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 18),

              // การ์ดโปรไฟล์ Jobber
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
                          const Icon(Icons.star, color: Colors.amber, size: 18),
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
              const SizedBox(height: 36),

              // กล่องแสดงสถานะและ Progress การทำงาน
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ชื่องาน และการ์ตูนเคลื่อนไหว
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _bounceAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _bounceAnimation.value),
                              child: SizedBox(
                                width: 85,
                                height: 85,
                                child: Image.asset(
                                  'assets/walking_dog.png', // เปลี่ยนเป็น Path รูปภาพของคุณ
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.directions_walk,
                                          size: 48,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.jobCategory,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Progress กราฟิก: เริ่มงาน ---> จบงาน
                    Column(
                      children: [
                        Row(
                          children: [
                            // วงกลมเริ่มงาน (ติ๊กถูกสีเขียว)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6BB82D),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            // เส้นประเชื่อมตรงกลาง
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final boxWidth = constraints.constrainWidth();
                                  const dashWidth = 5.0;
                                  const dashSpace = 4.0;
                                  final dashCount =
                                      (boxWidth / (dashWidth + dashSpace))
                                          .floor();
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(dashCount, (_) {
                                      return const SizedBox(
                                        width: dashWidth,
                                        height: 2,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            ),
                            // วงกลมจบงาน (สลับเป็นติ๊กถูกสีเขียวเมื่อ Jobber ส่งมอบงานแล้ว)
                            _isJobFinishedByJobber
                                ? Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF6BB82D),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )
                                : Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF75A6C2),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'เริ่มงาน',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'จบงาน',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ปุ่มแชท
              Center(
                child: SizedBox(
                  width: 220,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatListScreen(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('เปิดห้องสนทนา In-App Chat...'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFD0E884,
                      ), // สีเขียวตองอ่อน
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black26, width: 1),
                      ),
                    ),
                    child: const Text(
                      'แชท',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),

              // ปุ่มยืนยันการจบงาน (จะแสดงขึ้นมาเมื่อ Jobber กดยืนยันส่งมอบงานเข้ามาแล้วเท่านั้น)
              if (_isJobFinishedByJobber) ...[
                const SizedBox(height: 14),
                Center(
                  child: SizedBox(
                    width: 220,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        // โฟลว์ถัดไป: ไปหน้าชำระเงิน (เงินสด/QR Code) และหน้าให้คะแนนรีวิว
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'ยืนยันจบงานสำเร็จ เข้าสู่การชำระเงิน',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFF9A800,
                        ), // สีส้มเหลืองตาม Mockup
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Colors.black26,
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'ยืนยันการจบงาน',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

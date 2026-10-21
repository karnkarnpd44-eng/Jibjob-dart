import 'dart:async';
import 'package:flutter/material.dart';
import 'jobber_in_progress.dart';
import '../หน้างานของฉัน/jobber_my_jobs.dart';

class JobberWorkConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobberWorkConfirmationScreen({Key? key, required this.job})
    : super(key: key);

  @override
  State<JobberWorkConfirmationScreen> createState() =>
      _JobberWorkConfirmationScreenState();
}

class _JobberWorkConfirmationScreenState
    extends State<JobberWorkConfirmationScreen>
    with TickerProviderStateMixin {
  // สถานะ: 'waiting_employer' (รอผู้จ้างอนุมัติ), 'approved' (ผู้จ้างอนุมัติแล้ว)
  String _status = 'waiting_employer';
  Timer? _timer;

  // Animation Controllers สำหรับการสั่นของรถและควันไอเสีย
  late AnimationController _bikeVibrationController;
  late AnimationController _smokeController;

  @override
  void initState() {
    super.initState();

    // 1. แอนิเมชันตัวรถสั่นเบาๆ ขณะติดเครื่องจอดรอ (Vibration loop)
    _bikeVibrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    )..repeat(reverse: true);

    // 2. แอนิเมชันควันพวยพุ่งออกจากท่อไอเสีย (Smoke loop)
    _smokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // จำลองสถานการณ์ 10 วินาที เมื่อครบเวลาระบบจะเปลี่ยนเป็นหน้า "ผู้จ้างอนุมัติเริ่มงาน!"
    _timer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _status = 'approved';
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bikeVibrationController.dispose();
    _smokeController.dispose();
    super.dispose();
  }

  // ฟังก์ชันกดย้อนกลับแล้วพาไปหน้า "งานของฉัน" ในหมวด "กำลังทำอยู่"
  void _navigateToMyJobsInProgress() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            JobberMyJobsScreen(inProgressJob: widget.job, initialIndex: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_status == 'waiting_employer') {
      return _buildWaitingEmployerView();
    }
    return _buildEmployerApprovedView();
  }

  // ===========================================================================
  // หน้าที่ 1: ถึงแล้ว! (รอผู้จ้างยืนยันเริ่มงาน - แสดง 10 วินาทีแรก)
  // ===========================================================================
  Widget _buildWaitingEmployerView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed:
              _navigateToMyJobsInProgress, // กดย้อนกลับไปหน้างานของฉัน (กำลังทำอยู่)
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              child: Text(
                'ถึงแล้ว!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // การ์ดพื้นหลังสีเขียวมิ้นต์ โค้งมนพร้อมมิติเงา
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 93, 183, 184),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ส่วนโปรไฟล์ผู้จ้าง
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/employer_avatar.png',
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.person,
                                        size: 34,
                                        color: Colors.black54,
                                      ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF5CB85C),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.job['employerName'] ?? 'ดนัย',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Row(
                              children: [
                                Icon(Icons.star, size: 14, color: Colors.amber),
                                SizedBox(width: 4),
                                Text(
                                  '4.5 ดูโปรไฟล์',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'ถึงจุดนัดหมายแล้ว!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =========================================================
                    // ส่วนภาพเคลื่อนไหว: รถจอดสั่น + ควันพุ่งออกจากท่อไอเสีย
                    // =========================================================
                    Expanded(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _bikeVibrationController,
                            _smokeController,
                          ]),
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // ตัวรถมอเตอร์ไซค์พร้อมการสั่นเบาๆ (Engine Idling)
                                Transform.translate(
                                  offset: Offset(
                                    0,
                                    _bikeVibrationController.value * 1.8,
                                  ),
                                  child: Image.asset(
                                    'assets/jobber_arrived.png',
                                    height: 190,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.two_wheeler,
                                              size: 110,
                                              color: Colors.black87,
                                            ),
                                  ),
                                ),

                                // ละอองควันไอเสียลูกที่ 1
                                Positioned(
                                  left: 38 - (_smokeController.value * 28),
                                  bottom: 46 + (_smokeController.value * 18),
                                  child: Opacity(
                                    opacity: (1.0 - _smokeController.value)
                                        .clamp(0.0, 1.0),
                                    child: Transform.scale(
                                      scale:
                                          0.5 + (_smokeController.value * 0.9),
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.85),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // ละอองควันไอเสียลูกที่ 2 (เหลื่อมจังหวะให้พวยพุ่งต่อเนื่อง)
                                Positioned(
                                  left:
                                      32 -
                                      (((_smokeController.value + 0.5) % 1.0) *
                                          32),
                                  bottom:
                                      48 +
                                      (((_smokeController.value + 0.5) % 1.0) *
                                          22),
                                  child: Opacity(
                                    opacity:
                                        (1.0 -
                                                ((_smokeController.value +
                                                        0.5) %
                                                    1.0))
                                            .clamp(0.0, 1.0),
                                    child: Transform.scale(
                                      scale:
                                          0.6 +
                                          (((_smokeController.value + 0.5) %
                                                  1.0) *
                                              1.0),
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.75),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ปุ่มสถานะจำลอง (กำลังรอผู้จ้างยืนยันเริ่มงาน)
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD3E782),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Color(0xFF2E4B00),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'ผู้จ้างกำลังยืนยันเริ่มงาน...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E4B00),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // หน้าที่ 2: ผู้จ้างอนุมัติเริ่มงาน! (กดยืนยันเริ่มงานทั้งสองฝ่าย)
  // ===========================================================================
  Widget _buildEmployerApprovedView() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _status = 'waiting_employer';
            });
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                'ผู้จ้างอนุมัติเริ่มงาน!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 20),

              // กล่องรายละเอียดงาน (รับค่าแบบ Dynamic)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00AEEF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'รายละเอียด',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildApprovedInfoRow(
                      'งาน',
                      widget.job['jobType'] ?? widget.job['title'] ?? '-',
                    ),
                    _buildApprovedInfoRow('วันที่', widget.job['date'] ?? '-'),
                    _buildApprovedInfoRow(
                      'สถานที่',
                      widget.job['location'] ?? '-',
                    ),
                    _buildApprovedInfoRow(
                      'ช่วงเวลาทำงาน',
                      widget.job['timeRange'] ?? '-',
                    ),
                    _buildApprovedInfoRow(
                      'ค่าจ้าง',
                      '${widget.job['wageDetail'] ?? widget.job['wage'] ?? '-'}',
                    ),
                    const SizedBox(height: 20),

                    // ปุ่ม "เริ่มงาน!"
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  JobberInProgressScreen(job: widget.job),
                            ),
                          );
                        },
                        child: const Text(
                          'เริ่มงาน!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovedInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              '$title :',
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

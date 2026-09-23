// lib/หน้าการสร้างงาน/jobber_working.dart
import 'package:flutter/material.dart';
import '../หน้าข้อความ/chat_room.dart';
import '../หน้าจบงานและรีวิว/payment_summary.dart';

class JobberWorkingScreen extends StatefulWidget {
  final String jobberName;
  final String rating;
  final String jobTitle;
  final String jobDate;
  final String workTimeRange;
  final double wageAmount;
  final double feeAmount;

  const JobberWorkingScreen({
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
  State<JobberWorkingScreen> createState() => _JobberWorkingScreenState();
}

class _JobberWorkingScreenState extends State<JobberWorkingScreen> {
  // ===========================================================================
  // [SYSTEM LOGIC - TWO-WAY CONFIRMATION]
  // _isJobberCompleted: สถานะว่า Jobber กดส่งมอบงานแล้วหรือยัง
  // _isJibberApproved:  สถานะว่า Jibber ตรวจสอบและกดยืนยันจบงานแล้ว
  // ===========================================================================
  bool _isJobberCompleted = false;
  bool _isJibberApproved = false;

  @override
  Widget build(BuildContext context) {
    // 1. ถ้า Jibber กดยืนยันจบงานแล้ว -> แสดงหน้า JOB COMPLETE!
    if (_isJibberApproved) {
      return _buildJobCompleteView();
    }

    // 2. หน้าจอติดตามงานปกติของฝั่ง Jibber
    return Scaffold(
      backgroundColor: const Color(0xFF65C1BF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // ปุ่มจำลองการส่งมอบงานจากฝั่ง Jobber
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isJobberCompleted = !_isJobberCompleted;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isJobberCompleted
                        ? '${widget.jobberName} กดส่งมอบงานเรียบร้อยแล้ว!'
                        : 'รีเซ็ตสถานะเป็น: Jobber ยังทำงานไม่เสร็จ',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(
              _isJobberCompleted ? Icons.check_circle : Icons.toggle_off,
              color: _isJobberCompleted
                  ? const Color(0xFF6BB82D)
                  : Colors.black54,
            ),
            label: Text(
              _isJobberCompleted ? 'Jobber ส่งงานแล้ว' : 'จำลอง Jobber จบงาน',
              style: TextStyle(
                color: _isJobberCompleted ? Colors.white : Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jobber กำลังทำงาน',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // ข้อมูล Jobber คนที่เลือกปฏิบัติงาน
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        size: 46,
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
              const SizedBox(height: 24),

              // การ์ดแสดงสถานะงาน (ดึง widget.jobTitle แสดงผลจริง)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/im3.png',
                          height: 50,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.work_outline,
                                size: 44,
                                color: Color(0xFF5AB6C3),
                              ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            widget.jobTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Color(0xFF6BB82D),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: _isJobberCompleted
                                ? const Color(0xFF6BB82D)
                                : Colors.black26,
                          ),
                        ),
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: _isJobberCompleted
                              ? const Color(0xFF6BB82D)
                              : Colors.grey[300],
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: _isJobberCompleted
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'เริ่มงาน',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        Text(
                          _isJobberCompleted
                              ? 'Jobber ส่งมอบงานแล้ว'
                              : 'รอส่งมอบงาน',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isJobberCompleted
                                ? const Color(0xFF2E7D32)
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // ปุ่มแชท
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatRoomScreen(jobberName: widget.jobberName),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0E884),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Colors.black38, width: 1),
                    ),
                  ),
                  child: const Text(
                    'แชท',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ปุ่มยืนยันการจบงาน (กดได้เมื่อ Jobber ส่งมอบงานแล้วเท่านั้น)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isJobberCompleted
                      ? () {
                          setState(() {
                            _isJibberApproved = true;
                          });
                        }
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'กรุณารอผู้รับจ้าง (Jobber) กดส่งมอบงานก่อน จึงจะกดยืนยันได้',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isJobberCompleted
                        ? const Color(0xFFF9A800)
                        : Colors.grey[400],
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: _isJobberCompleted
                            ? Colors.black45
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    _isJobberCompleted
                        ? 'ยืนยันการจบงาน'
                        : 'รอ Jobber ส่งมอบงาน...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isJobberCompleted
                          ? Colors.black87
                          : Colors.white70,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // หน้าจอ: JOB COMPLETE! (แสดงหลังยืนยันจบงาน)
  Widget _buildJobCompleteView() {
    return Scaffold(
      backgroundColor: const Color(0xFF65C1BF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                'assets/complete.png',
                height: 240,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.celebration,
                  size: 130,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'JOB COMPLETE!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // ส่งก้อนข้อมูลจริงไปยังหน้าสรุปค่าใช้จ่ายและรีวิว
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentSummaryScreen(
                          jobTitle: widget.jobTitle,
                          jobDate: widget.jobDate,
                          completedTime:
                              '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')} น.',
                          workTimeRange: widget.workTimeRange,
                          wageAmount: widget.wageAmount,
                          feeAmount: widget.feeAmount,
                          jobberName: widget.jobberName,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Colors.black26, width: 1),
                    ),
                  ),
                  child: const Text(
                    'จ่ายเงินแล้ว!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

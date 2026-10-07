// lib/หน้าการสร้างงาน/jobber_candidates.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../หน้างานของฉัน/my_jobs.dart';
import 'jobber_tracking.dart';

class JobberCandidatesScreen extends StatefulWidget {
  final String jobTitle;
  final String jobDate;
  final String workTimeRange;
  final double wageAmount;
  final double feeAmount;
  final int initialRemainingSeconds;

  const JobberCandidatesScreen({
    Key? key,
    required this.jobTitle,
    required this.jobDate,
    required this.workTimeRange,
    required this.wageAmount,
    this.feeAmount = 0.0,
    this.initialRemainingSeconds = 3600,
  }) : super(key: key);

  @override
  State<JobberCandidatesScreen> createState() => _JobberCandidatesScreenState();
}

class _JobberCandidatesScreenState extends State<JobberCandidatesScreen> {
  Timer? _countdownTimer;
  late int _remainingSeconds;

  // ข้อมูล Jobber แต่ละคน พร้อมข้อความแนะนำตัวและรูป 5 รูป
  final List<Map<String, dynamic>> _candidates = [
    {
      'name': 'สมชาย สายลุย',
      'rating': '4.9',
      'distance': '1.2 กม.',
      'bio':
          'รักสัตว์ เลี้ยงสุนัขพันธุ์ใหญ่มาตลอด 5 ปี ใจเย็น แข็งแรง พาวิ่งออกกำลังกายได้สบายครับ',
      'images': [
        'assets/sample1.png',
        'assets/sample2.png',
        'assets/sample3.png',
        'assets/sample4.png',
        'assets/sample5.png',
      ],
    },
    {
      'name': 'วิภาดา รักสัตว์',
      'rating': '4.8',
      'distance': '2.5 กม.',
      'bio':
          'มีประสบการณ์ดูแลสุนัขและแมว เป็นมิตร ตรงต่อเวลา อัปเดตรูปและพิกัดให้ตลอดเวลาการจ้างงานค่ะ',
      'images': [
        'assets/sample1.png',
        'assets/sample2.png',
        'assets/sample3.png',
        'assets/sample4.png',
        'assets/sample5.png',
      ],
    },
    {
      'name': 'กิตติพงษ์ ตรงเวลา',
      'rating': '5.0',
      'distance': '3.1 กม.',
      'bio':
          'ทำงานด้วยความรับผิดชอบ ซื่อสัตย์ ตรงต่อเวลา พร้อมเริ่มงานตามเวลาที่กำหนดทันทีครับ',
      'images': [
        'assets/sample1.png',
        'assets/sample2.png',
        'assets/sample3.png',
        'assets/sample4.png',
        'assets/sample5.png',
      ],
    },
  ];

  Map<String, dynamic>? _viewingCandidate;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialRemainingSeconds;
    _startCountdown();
  }

  // ตัวนับถอยหลังวินาทีต่อวินาที
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _showTimeoutDialog();
      }
    });
  }

  String _formatRemainingTime(int totalSeconds) {
    if (totalSeconds <= 0) return '0 วินาที';
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours ชม. $minutes นาที $seconds วิ';
    } else if (minutes > 0) {
      return '$minutes นาที $seconds วิ';
    } else {
      return '$seconds วินาที';
    }
  }

  // ฟังก์ชันกดต่อเวลาเปิดรับงาน (+1 ชม.)
  void _extendTime() {
    setState(() {
      _remainingSeconds += 3600;
    });
    _startCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ต่อเวลาเปิดรับงานเพิ่มอีก 1 ชั่วโมง (คงเหลือ ${_formatRemainingTime(_remainingSeconds)})',
        ),
        backgroundColor: const Color(0xFF00A3E0),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // จำลองหมดเวลา
  void _simulateTimeout() {
    _countdownTimer?.cancel();
    setState(() {
      _remainingSeconds = 0;
    });
    _showTimeoutDialog();
  }

  // Pop-up แจ้งหมดเวลา
  void _showTimeoutDialog() {
    _countdownTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF275),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 3.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_off_outlined,
                color: Colors.redAccent,
                size: 54,
              ),
              const SizedBox(height: 10),
              const Text(
                'หมดเวลาเปิดรับงานแล้ว!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ยังไม่มี Jobber รับงานในช่วงเวลาที่กำหนด\nคุณต้องการรอต่อ หรือยกเลิกงานนี้?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyJobsScreen(
                                activeJobTitle: widget.jobTitle,
                                activeJobDate: widget.jobDate,
                                isCancelled: true,
                              ),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4D4D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'ยกเลิกงาน',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _extendTime();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF98D819),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'รอต่อ (+1 ชม.)',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pop-up ยืนยันการยกเลิกงาน
  void _showCancelConfirmationDialog() {
    _countdownTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC6C6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 3.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'คุณต้องการยกเลิกงานจริงๆหรอ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Image.asset(
                        'assets/cancel_person.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.sentiment_dissatisfied,
                              size: 60,
                              color: Colors.black54,
                            ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 78,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyJobsScreen(
                                activeJobTitle: widget.jobTitle,
                                activeJobDate: widget.jobDate,
                                isCancelled: true,
                              ),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'ใช่',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 78,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _startCountdown();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF99E22B),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'ไม่ใช่',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewingCandidate != null) {
      return _buildProfileDetailScreen(_viewingCandidate!);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: _simulateTimeout,
              child: Row(
                children: const [
                  Icon(Icons.timer_outlined, color: Colors.orange, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'จำลองหมดเวลา',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.jobTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // การ์ดแสดงรายละเอียดงาน
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4AC4F3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.jobDate}   ${widget.workTimeRange}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        SizedBox(width: 6),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.money, color: Colors.green, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.wageAmount.toStringAsFixed(0)} บาท',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Color(0xFF4AC4F3),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'รอ Jobber ตอบรับ (เหลือเวลา ${_formatRemainingTime(_remainingSeconds)})',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // รายชื่อผู้สมัคร
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12, width: 1.2),
                ),
                child: Column(
                  children: _candidates.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final candidate = entry.value;
                    final bool isLast = idx == _candidates.length - 1;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Row(
                            children: [
                              // กดรูปโปรไฟล์
                              InkWell(
                                onTap: () => setState(
                                  () => _viewingCandidate = candidate,
                                ),
                                borderRadius: BorderRadius.circular(28),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 36,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // รายละเอียดชื่อ + ดาว + ปุ่ม "ดูโปรไฟล์" สีฟ้า
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      candidate['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
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
                                          '${candidate['rating']} ( ${candidate['distance']} )',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // 🌟 ปุ่มดูโปรไฟล์สีฟ้า
                                    InkWell(
                                      onTap: () => setState(
                                        () => _viewingCandidate = candidate,
                                      ),
                                      child: const Text(
                                        'ดูโปรไฟล์',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF00A3E0),
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ปุ่มเลือกทำงาน
                              ElevatedButton(
                                onPressed: () => _selectJobber(candidate),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8CD837),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text(
                                  'เลือก',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: Colors.black12,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // ปุ่มต่อเวลา
              OutlinedButton.icon(
                onPressed: _extendTime,
                icon: const Icon(Icons.hourglass_empty, color: Colors.black87),
                label: const Text(
                  'ต่อเวลาเปิดรับงาน (เพิ่มอีก 1 ชั่วโมง)',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  side: const BorderSide(color: Color(0xFF4AC4F3), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ปุ่มยกเลิกงาน
              ElevatedButton.icon(
                onPressed: _showCancelConfirmationDialog,
                icon: const Icon(Icons.cancel, color: Color(0xFF005B60)),
                label: const Text(
                  'ยกเลิกงาน',
                  style: TextStyle(
                    color: Color(0xFF005B60),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: const Color(0xFFFF7A7A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.notifications_none,
                    size: 16,
                    color: Colors.black45,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'เมื่อมี Jobber กดรับงานระบบจะแจ้งเตือนทันที',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // หน้าแสดงข้อมูลโปรไฟล์
  Widget _buildProfileDetailScreen(Map<String, dynamic> candidate) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => setState(() => _viewingCandidate = null),
        ),
        title: Text(
          'โปรไฟล์ ${candidate['name']}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 48,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
                              '${candidate['rating']} คะแนนรีวิว',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'อยู่ห่างจากคุณ ${candidate['distance']}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'ข้อความแนะนำตัว',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  candidate['bio'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'รูปภาพ / ผลงาน (5 ภาพ)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5FD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF4AC4F3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.image,
                          color: Color(0xFF0F4C81),
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'รูป ${index + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF0F4C81),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _viewingCandidate = null);
                    _selectJobber(candidate);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8CD837),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'เลือก ${candidate['name']} ทำงานนี้',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  // ส่งข้อมูลไปยังหน้า jobber_tracking.dart
  void _selectJobber(Map<String, dynamic> candidate) {
    _countdownTimer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => JobberTrackingScreen(
          jobberName: candidate['name']?.toString() ?? 'กิตติพงษ์',
          rating: candidate['rating']?.toString() ?? '4.5',
          distance:
              candidate['distance']?.toString() ??
              '1.5 กม.', // ✅ เพิ่มบรรทัดนี้เข้ามาให้ครบตามที่ JobberTrackingScreen ต้องการ
          jobTitle: widget.jobTitle,
          jobDate: widget.jobDate,
          workTimeRange: widget.workTimeRange,
          wageAmount: widget.wageAmount,
          feeAmount: widget.feeAmount,
        ),
      ),
    );
  }
}

// lib/หน้าการสร้างงาน/waiting_jobber.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../หน้างานของฉัน/my_jobs.dart';
import 'jobber_candidates.dart';
import 'edit_job.dart';

class WaitingJobberScreen extends StatefulWidget {
  final String? jobId;
  final String jobTitle;
  final String jobDesc;
  final String jobAddress;
  final String jobDate;
  final String workTimeRange;
  final double wageAmount;
  final double feeAmount;
  final int initialRemainingSeconds;

  const WaitingJobberScreen({
    Key? key,
    this.jobId,
    required this.jobTitle,
    this.jobDesc = 'ไม่มีรายละเอียดเพิ่มเติม',
    this.jobAddress = '123/45 หมู่บ้านสุขใจ ลาดพร้าว80',
    required this.jobDate,
    required this.workTimeRange,
    required this.wageAmount,
    this.feeAmount = 0.0,
    this.initialRemainingSeconds = 3600, // เริ่มต้น 1 ชั่วโมง (3600 วินาที)
  }) : super(key: key);

  @override
  State<WaitingJobberScreen> createState() => _WaitingJobberScreenState();
}

class _WaitingJobberScreenState extends State<WaitingJobberScreen> {
  Timer? _countdownTimer;
  StreamSubscription<DocumentSnapshot>? _jobSubscription;
  late int _remainingSeconds;

  late String _currentTitle;
  late String _currentDesc;
  late String _currentAddress;
  late String _currentDate;
  late String _currentTime;
  late double _currentWage;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.jobTitle;
    _currentDesc = widget.jobDesc;
    _currentAddress = widget.jobAddress;
    _currentDate = widget.jobDate;
    _currentTime = widget.workTimeRange;
    _currentWage = widget.wageAmount;
    _remainingSeconds = widget.initialRemainingSeconds;

    _startCountdown();
    _listenToJobApplicants(); // 💡 ฟัง Firestore จริง แทนการนับเวลา 10 วิ
  }

  // ===========================================================================
  // ดักฟังข้อมูล Firestore แบบ Realtime (ตรวจจับเมื่อมีคนกดรับงาน)
  // ===========================================================================
  void _listenToJobApplicants() {
    if (widget.jobId == null || widget.jobId!.isEmpty) return;

    _jobSubscription?.cancel();
    _jobSubscription = FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobId)
        .snapshots()
        .listen((snapshot) {
          if (!mounted || !snapshot.exists) return;

          final data = snapshot.data();
          if (data != null && data['applicant_ids'] != null) {
            final List applicants = List.from(data['applicant_ids']);
            // ถ้ามีคนกดรับงานแล้ว ให้สลับไปหน้าคัดเลือกผู้สมัครทันที
            if (applicants.isNotEmpty) {
              _countdownTimer?.cancel();
              _jobSubscription?.cancel();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => JobberCandidatesScreen(
                    jobId: widget.jobId,
                    jobTitle: _currentTitle,
                    jobDate: _currentDate,
                    workTimeRange: _currentTime,
                    wageAmount: _currentWage,
                    feeAmount: widget.feeAmount,
                    initialRemainingSeconds: _remainingSeconds,
                  ),
                ),
              );
            }
          }
        });
  }

  // อัปเดตสถานะยกเลิกงานใน Firestore
  Future<void> _updateJobCancelledInFirestore() async {
    try {
      if (widget.jobId != null && widget.jobId!.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.jobId)
            .update({
              'status': 'cancelled',
              'cancelled_at': FieldValue.serverTimestamp(),
              'updated_at': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('>>> เกิดข้อผิดพลาดในการยกเลิกงาน Firestore: $e');
    }
  }

  // อัปเดตการต่อเวลาใน Firestore
  Future<void> _updateJobExtendedInFirestore() async {
    try {
      if (widget.jobId != null && widget.jobId!.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.jobId)
            .update({
              'extended_at': FieldValue.serverTimestamp(),
              'updated_at': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('>>> เกิดข้อผิดพลาดในการต่อเวลา Firestore: $e');
    }
  }

  // ตัวนับถอยหลังทีละ 1 วินาที
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

  // กดต่อเวลา +1 ชั่วโมง
  void _extendTime() {
    setState(() {
      _remainingSeconds += 3600;
    });
    _startCountdown();
    _updateJobExtendedInFirestore();

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

  // Pop-up เมื่อหมดเวลาเปิดรับงาน
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
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _updateJobCancelledInFirestore();
                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyJobsScreen(
                                activeJobTitle: _currentTitle,
                                activeJobDate: _currentDate,
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
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await _updateJobCancelledInFirestore();
                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyJobsScreen(
                                activeJobTitle: _currentTitle,
                                activeJobDate: _currentDate,
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

  Future<void> _openEditScreen() async {
    _countdownTimer?.cancel();

    final updatedData = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditJobScreen(
          initialData: {
            'title': _currentTitle,
            'desc': _currentDesc,
            'address': _currentAddress,
            'date': _currentDate,
            'time': _currentTime,
            'price': _currentWage.toStringAsFixed(0),
            'payment': 'เงินสด/โอน',
          },
        ),
      ),
    );

    if (updatedData != null && mounted) {
      setState(() {
        _currentTitle = updatedData['title'] ?? _currentTitle;
        _currentDesc = updatedData['desc'] ?? _currentDesc;
        _currentAddress = updatedData['address'] ?? _currentAddress;
        _currentDate = updatedData['date'] ?? _currentDate;
        _currentTime = updatedData['time'] ?? _currentTime;
        if (updatedData['price'] != null) {
          _currentWage = double.tryParse(updatedData['price']!) ?? _currentWage;
        }
      });
    }

    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _jobSubscription?.cancel();
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),

              // การ์ดแสดงรายละเอียดงาน
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
                    Text(
                      '$_currentDate   $_currentTime',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _currentAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Text(
                        '${_currentWage.toStringAsFixed(0)} บาท',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
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
              const SizedBox(height: 16),

              // ===============================================================
              // กล่องแสดงสถานะรอ Jobber (ปรับให้เด็กนั่งชิดขอบล่างของกรอบสีฟ้า)
              // ===============================================================
              Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias, // ให้รูปภาพตัดขอบมนพอดีกรอบ
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4AC4F3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.end, // 💡 วางชิดติดขอบล่าง
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Image.asset(
                          'assets/WaitingJobber.jpg',
                          fit: BoxFit.contain,
                          alignment:
                              Alignment.bottomCenter, // 💡 ตัวเด็กชิดติดขอบล่าง
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person_outline,
                              size: 50,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 30.0,
                          right: 16.0,
                          top: 20.0,
                        ),
                        child: Text(
                          'ตอนนี้ยังไม่มี Jobber\nเข้ามารับงาน...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ปุ่มแก้ไขรายละเอียดงาน
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _openEditScreen,
                  icon: const Icon(Icons.edit_outlined, color: Colors.black87),
                  label: const Text(
                    'แก้ไขรายละเอียดงาน',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF275),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.black87, width: 1.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ปุ่มต่อเวลาเปิดรับงาน
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _extendTime,
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

              // ปุ่มยกเลิกงาน
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _showCancelConfirmationDialog,
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

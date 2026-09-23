// lib/หน้าการสร้างงาน/waiting_jobber.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../home.dart';
import 'jobber_candidates.dart';
import 'edit_job.dart';

class WaitingJobberScreen extends StatefulWidget {
  // บังคับรับค่าจริงทุกตัวจากหน้าสร้างงาน ไม่มีค่าคงที่ตัวอย่าง
  final String jobTitle;
  final String jobDesc;
  final String jobAddress;
  final String jobDate;
  final String workTimeRange;
  final double wageAmount;
  final double feeAmount;

  const WaitingJobberScreen({
    Key? key,
    required this.jobTitle,
    this.jobDesc = 'ไม่มีรายละเอียดเพิ่มเติม',
    this.jobAddress = 'พิกัดงานที่ระบุ',
    required this.jobDate,
    required this.workTimeRange,
    required this.wageAmount,
    this.feeAmount = 0.0,
  }) : super(key: key);

  @override
  State<WaitingJobberScreen> createState() => _WaitingJobberScreenState();
}

class _WaitingJobberScreenState extends State<WaitingJobberScreen> {
  Timer? _simulationTimer;

  // ตัวแปรภายใน State เพื่อให้รองรับการแก้ไขข้อมูลงานได้แบบไดนามิก
  late String _currentTitle;
  late String _currentDesc;
  late String _currentAddress;
  late String _currentDate;
  late String _currentTime;
  late double _currentWage;

  @override
  void initState() {
    super.initState();
    // นำค่าจริงที่ส่งมาจาก Constructor ใส่เข้า State
    _currentTitle = widget.jobTitle;
    _currentDesc = widget.jobDesc;
    _currentAddress = widget.jobAddress;
    _currentDate = widget.jobDate;
    _currentTime = widget.workTimeRange;
    _currentWage = widget.wageAmount;

    _startTimer();
  }

  void _startTimer() {
    _simulationTimer?.cancel();
    // จำลองเมื่อผ่านไป 10 วินาที -> มี Jobber สมัครเข้ามา แล้วส่งข้อมูลชุดนี้ไปหน้าคัดเลือก
    _simulationTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => JobberCandidatesScreen(
              jobTitle: _currentTitle,
              jobDate: _currentDate,
              workTimeRange: _currentTime,
              wageAmount: _currentWage,
              feeAmount: widget.feeAmount,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  // Pop-up ยืนยันการยกเลิกงาน
  void _showCancelConfirmationDialog() {
    _simulationTimer?.cancel();

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
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.sentiment_dissatisfied,
                                size: 60,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Spacer(),
                    // ปุ่ม "ใช่"
                    SizedBox(
                      width: 78,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ยกเลิกงานเรียบร้อยแล้ว'),
                              backgroundColor: Colors.black87,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'ใช่',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ปุ่ม "ไม่ใช่"
                    SizedBox(
                      width: 78,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _startTimer();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF99E22B),
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'ไม่ใช่',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
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
    _simulationTimer?.cancel();

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

    _startTimer();
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
                _currentTitle, // 💡 ชื่องานจริง
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),

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

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4AC4F3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Image.asset(
                        'assets/WaitingJobber.jpg',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'ต่อเวลาเปิดรับงานเพิ่มอีก 1 ชั่วโมงแล้ว',
                        ),
                      ),
                    );
                  },
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

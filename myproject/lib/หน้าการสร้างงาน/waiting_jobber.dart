// [SIMULATION - ลบส่วนนี้เมื่อต่อ Backend จริง]
import 'dart:async';
import 'package:flutter/material.dart';
import '../home.dart'; // ✅ ถูกต้อง
import 'jobber_candidates.dart';
import 'edit_job.dart';

class WaitingJobberScreen extends StatefulWidget {
  const WaitingJobberScreen({Key? key}) : super(key: key);

  @override
  State<WaitingJobberScreen> createState() => _WaitingJobberScreenState();
}

class _WaitingJobberScreenState extends State<WaitingJobberScreen> {
  String _jobTitle = 'พาหมาไปเดินเล่น';
  String _jobDesc = 'น้องหมา 2 ตัว ตัวผู้กับตัวเมีย';
  String _jobAddress = '123/45 หมู่บ้าน สุขใจ ลาดพร้าว80';
  String _jobDate = '12 พ.ย. 2568';
  String _jobTime = '16:30 - 17:30';
  String _jobPrice = '300 บาท';
  String _jobPayment = 'QR Code';

  // ===========================================================================
  // [SIMULATION - ลบส่วนนี้เมื่อต่อ Backend จริง]
  // ===========================================================================
  Timer? _simulationTimer;

  void _startTimer() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const JobberCandidatesScreen(),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  // Pop-up ยืนยันการยกเลิกงาน
  void _showCancelConfirmationDialog() {
    _simulationTimer?.cancel(); // หยุดนับเวลาระหว่างเปิด Pop-up

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
              color: const Color(0xFFFFC6C6), // สีชมพูพาสเทลตามรูป
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
                    // ช่องใส่รูปภาพคนขอร้อง
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Image.asset(
                        'assets/cancel_person.png', // เปลี่ยนเป็นชื่อไฟล์รูปภาพของคุณ
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.sentiment_dissatisfied,
                              size: 60,
                              color: Colors.black54,
                            ),
                          );
                        },
                      ),
                    ),
                    const Spacer(),
                    // ปุ่ม "ใช่" (สีแดง)
                    SizedBox(
                      width: 78,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext); // ปิด Dialog
                          // ล้าง Route ย้อนกลับไปหน้าแรก และสแตนบายรองานใหม่
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
                          backgroundColor: const Color(0xFFFF3B30), // สีแดงสด
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
                    // ปุ่ม "ไม่ใช่" (สีเขียวตองอ่อน)
                    SizedBox(
                      width: 78,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext); // ปิด Dialog
                          _startTimer(); // นับเวลาต่อ
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF99E22B,
                          ), // สีเขียวตองอ่อน
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
            'title': _jobTitle,
            'desc': _jobDesc,
            'address': _jobAddress,
            'date': _jobDate,
            'time': _jobTime,
            'price': _jobPrice,
            'payment': _jobPayment,
          },
        ),
      ),
    );

    if (updatedData != null && mounted) {
      setState(() {
        _jobTitle = updatedData['title'] ?? _jobTitle;
        _jobDesc = updatedData['desc'] ?? _jobDesc;
        _jobAddress = updatedData['address'] ?? _jobAddress;
        _jobDate = updatedData['date'] ?? _jobDate;
        _jobTime = updatedData['time'] ?? _jobTime;
        _jobPrice = updatedData['price'] ?? _jobPrice;
        _jobPayment = updatedData['payment'] ?? _jobPayment;
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
                _jobTitle,
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
                      '$_jobDate   $_jobTime',
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
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _jobAddress,
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
                        _jobPrice.contains('บาท')
                            ? _jobPrice
                            : '$_jobPrice บาท',
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

              // ปุ่มยกเลิกงาน (เรียก Pop-up)
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'jobber_work_confirmation.dart';
import '../หน้าข้อความ/jobber_messages.dart';
import '../หน้างานของฉัน/jobber_my_jobs.dart';

class JobberTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobberTrackingScreen({Key? key, required this.job}) : super(key: key);

  @override
  State<JobberTrackingScreen> createState() => _JobberTrackingScreenState();
}

class _JobberTrackingScreenState extends State<JobberTrackingScreen> {
  bool _isViewingMap = false;

  // ===========================================================================
  // 💡 ฟังก์ชันอัปเดตสถานะ "ถึงแล้ว" ลง Firestore จริง
  // ===========================================================================
  Future<void> _updateJobAsArrived(String jobId) async {
    if (jobId.isEmpty) {
      _navigateToConfirmation();
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
        'status': 'jobber_arrived',
        'arrived_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ส่งการแจ้งเตือนไปยังผู้จ้างแล้ว: "Jobber มาถึงแล้ว"'),
          backgroundColor: Color(0xFF00AEEF),
        ),
      );

      _navigateToConfirmation();
    } catch (e) {
      debugPrint('>>> อัปเดตสถานะถึงแล้วไม่สำเร็จ: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ===========================================================================
  // 💡 ฟังก์ชันแสดง Popup ยืนยันการยกเลิกงาน
  // ===========================================================================
  void _showCancelConfirmationDialog(String jobId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'ยืนยันการยกเลิก',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'คุณต้องการจะยกเลิกงานจริงๆ หรอ?',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'ไม่ยกเลิก',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _cancelJobInFirestore(jobId);
              },
              child: const Text(
                'ยืนยันยกเลิก',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 💡 ฟังก์ชันอัปเดตสถานะเป็น cancelled ใน Firestore
  // ===========================================================================
  Future<void> _cancelJobInFirestore(String jobId) async {
    if (jobId.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
        'status': 'cancelled',
        'cancelled_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('คุณได้ยกเลิกงานนี้เรียบร้อยแล้ว'),
          backgroundColor: Colors.redAccent,
        ),
      );

      // กลับไปหน้า "งานของฉัน"
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const JobberMyJobsScreen(initialIndex: 0),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('>>> ยกเลิกงานไม่สำเร็จ: $e');
    }
  }

  void _navigateToConfirmation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobberWorkConfirmationScreen(job: widget.job),
      ),
    );
  }

  // ===========================================================================
  // 💡 ฟังก์ชันสร้าง/เปิดห้องแชทอัตโนมัติ Realtime ลงใน Firestore chats collection
  // ===========================================================================
  Future<void> _openChatRoom(
    Map<String, dynamic> liveJobData,
    String jobId,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final employerId =
        liveJobData['employer_id'] ?? widget.job['employer_id'] ?? '';
    final employerName =
        liveJobData['employer_name'] ??
        liveJobData['employerName'] ??
        widget.job['employerName'] ??
        'ผู้ว่าจ้าง';

    if (employerId.isEmpty && jobId.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              JobberChatRoomScreen(employerName: employerName, job: widget.job),
        ),
      );
      return;
    }

    try {
      final chatQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('job_id', isEqualTo: jobId)
          .get();

      String chatId = '';
      if (chatQuery.docs.isNotEmpty) {
        chatId = chatQuery.docs.first.id;
      } else {
        final newChatRef = await FirebaseFirestore.instance
            .collection('chats')
            .add({
              'job_id': jobId,
              'job_title': liveJobData['title'] ?? widget.job['title'] ?? 'งาน',
              'participants': [currentUser.uid, employerId],
              'employer_id': employerId,
              'jobber_id': currentUser.uid,
              'last_message': 'เริ่มสนทนา',
              'updated_at': FieldValue.serverTimestamp(),
            });
        chatId = newChatRef.id;
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobberChatRoomScreen(
            employerName: employerName,
            job: widget.job,
            chatId: chatId,
          ),
        ),
      );
    } catch (e) {
      debugPrint('>>> เปิดห้องแชทไม่สำเร็จ: $e');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              JobberChatRoomScreen(employerName: employerName, job: widget.job),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobId = widget.job['id']?.toString() ?? '';

    return StreamBuilder<DocumentSnapshot>(
      stream: jobId.isNotEmpty
          ? FirebaseFirestore.instance.collection('jobs').doc(jobId).snapshots()
          : const Stream.empty(),
      builder: (context, snapshot) {
        final Map<String, dynamic> liveData =
            snapshot.hasData && snapshot.data!.exists
            ? (snapshot.data!.data() as Map<String, dynamic>)
            : widget.job;

        if (_isViewingMap) {
          return _buildTrackingMapView(liveData, jobId);
        }
        return _buildTrackingDetailView(liveData, jobId);
      },
    );
  }

  // ===========================================================================
  // 1. หน้ารายละเอียดการเดินทาง
  // ===========================================================================
  Widget _buildTrackingDetailView(Map<String, dynamic> liveData, String jobId) {
    final title = liveData['title'] ?? liveData['jobType'] ?? '-';
    final date = liveData['job_date'] ?? liveData['date'] ?? '-';
    final location = liveData['address'] ?? liveData['location'] ?? '-';
    final timeRange =
        liveData['work_time_range'] ?? liveData['timeRange'] ?? '-';
    final reward =
        liveData['reward_amount']?.toString() ??
        liveData['wageDetail'] ??
        liveData['wage'] ??
        '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const JobberMyJobsScreen(initialIndex: 0),
              ),
            );
          },
        ),
        title: const Text(
          'รายละเอียดงาน',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                      blurRadius: 16,
                      offset: const Offset(0, 4),
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
                    _buildInfoRow('งาน', title),
                    _buildInfoRow('วันที่', date),
                    _buildInfoRow('สถานที่', location),
                    _buildInfoRow('ช่วงเวลาทำงาน', timeRange),
                    _buildInfoRow('ค่าจ้าง', '$reward บาท'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.map_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'เปิดแผนที่',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isViewingMap = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.chat_bubble_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'แชท',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AEEF),
                      elevation: 1,
                      shadowColor: const Color(0xFF00AEEF).withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _openChatRoom(liveData, jobId),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5CB85C),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF5CB85C,
                                ).withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        Container(
                          width: 2.5,
                          height: 48,
                          color: const Color(0xFFCBD5E1),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF94A3B8),
                              width: 2.5,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF94A3B8),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 5),
                        Text(
                          'เดินทาง',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 56),
                        Text(
                          'ถึงที่นัดหมาย',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // ปุ่ม "ถึงแล้ว"
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF90D925),
                    foregroundColor: const Color(0xFF1B3800),
                    elevation: 1,
                    shadowColor: const Color(0xFF90D925).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _updateJobAsArrived(jobId),
                  child: const Text(
                    'ถึงแล้ว',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 💡 เพิ่มปุ่มยกเลิกงานแบบไม่มีกล่อง (มีแค่ตัวหนังสือ) อยู่ใต้ปุ่มถึงแล้ว
              TextButton(
                onPressed: () => _showCancelConfirmationDialog(jobId),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'ยกเลิกงาน',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
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

  // ===========================================================================
  // 2. หน้าแผนที่
  // ===========================================================================
  Widget _buildTrackingMapView(Map<String, dynamic> liveData, String jobId) {
    final location =
        liveData['address'] ?? liveData['location'] ?? 'จุดนัดหมาย';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            setState(() {
              _isViewingMap = false;
            });
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size.infinite,
                          painter: MapGridPainter(),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Icon(
                                Icons.location_on,
                                size: 48,
                                color: Color(0xFF6B52AE),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF90D925),
                    foregroundColor: const Color(0xFF1B3800),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _updateJobAsArrived(jobId),
                  child: const Text(
                    'ถึงแล้ว',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _showCancelConfirmationDialog(jobId),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'ยกเลิกงาน',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 45) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double i = 0; i < size.height; i += 45) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }

    final routePaint = Paint()
      ..color = const Color(0xFF7B88D6)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width, size.height * 0.52)
      ..lineTo(size.width * 0.85, size.height * 0.52)
      ..lineTo(size.width * 0.80, size.height * 0.58)
      ..lineTo(size.width * 0.53, size.height * 0.58)
      ..lineTo(size.width * 0.50, size.height * 0.50);

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

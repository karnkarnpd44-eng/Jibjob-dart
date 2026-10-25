import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'jobber_tracking.dart';
import '../หน้างานของฉัน/jobber_my_jobs.dart';
import '../หน้าข้อความ/jobber_messages.dart';
import '../หน้าโปรไฟล์ผู้รับจ้าง/jobber_profile.dart';

class JobberHomeScreen extends StatefulWidget {
  const JobberHomeScreen({Key? key}) : super(key: key);

  @override
  State<JobberHomeScreen> createState() => _JobberHomeScreenState();
}

class _JobberHomeScreenState extends State<JobberHomeScreen> {
  bool _dontShowToday = false;
  Map<String, dynamic>? _selectedJob;

  void _showRiskWarningDialog(Map<String, dynamic> job) {
    if (_dontShowToday) {
      _onConfirmAcceptJob(job);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9A83E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black, width: 2.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/Warning.png',
                          width: 85,
                          height: 85,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.campaign,
                                size: 75,
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'การแจ้งเตือน',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'ความเสี่ยง!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'งานบางประเภทอาจเกี่ยวข้องกับพื้นที่ส่วนตัว หรือสถานที่จำกัดการเข้าถึง\n'
                      'โปรดพิจารณารายละเอียดงานและข้อตกลงระหว่างกันอย่างรอบคอบ\n'
                      'JibJob ทำหน้าที่เป็นแพลตฟอร์มตัวกลางเท่านั้น มิได้เป็นผู้รับรองความปลอดภัยของงาน',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF4848),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text(
                                'ยกเลิก',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF90D925),
                                foregroundColor: const Color(0xFF1B3800),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                _onConfirmAcceptJob(job);
                              },
                              child: const Text(
                                'เข้าใจแล้ว',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B3800),
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
            );
          },
        );
      },
    );
  }

  // กดสมัครรับงาน (สถานะเริ่มต้นเป็น pending)
  void _onConfirmAcceptJob(Map<String, dynamic> job) async {
    final jobId = job['id']?.toString() ?? '';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && jobId.isNotEmpty) {
        await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
          'applicant_ids': FieldValue.arrayUnion([user.uid]),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('>>> เกิดข้อผิดพลาดในการกดรับงาน Firestore: $e');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ส่งคำขอรับงาน "${job['title']}" แล้ว กำลังรอผู้จ้างคัดเลือก...',
        ),
        backgroundColor: const Color(0xFFF9A83E),
      ),
    );
  }

  // 💡 เมื่อกดปุ่ม "เดินทาง" -> อัปเดตสถานะเป็น accepted งานจะหายจากหน้าแรก และย้ายไปหน้า "งานของฉัน" ทันที
  Future<void> _startTraveling(
    String jobId,
    Map<String, dynamic> jobData,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
        'status': 'accepted',
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // พาไปหน้าติดตามงาน
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobberTrackingScreen(
            job: {
              'id': jobId,
              'title': jobData['title'],
              'date': jobData['job_date'] ?? 'วันนี้',
              'timeRange': jobData['work_time_range'] ?? 'ตามตกลง',
              'wageDetail': '${jobData['reward_amount']} บาท',
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('>>> อัปเดตสถานะเดินทางไม่สำเร็จ: $e');
    }
  }

  // ยกเลิกงานฝั่ง Jobber
  Future<void> _cancelJobByJobber(String jobId) async {
    try {
      if (_selectedJob != null) {
        setState(() {
          _selectedJob = null;
        });
      }

      await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
        'status': 'cancelled',
        'cancelled_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('คุณได้ยกเลิกการรับงานนี้แล้ว'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('>>> ยกเลิกงานไม่สำเร็จ: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedJob != null) {
      return _buildJobDetailView(_selectedJob!);
    }
    return _buildJobListView();
  }

  Widget _buildJobListView() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/jibjob.png',
                    height: 42,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.all_inclusive,
                      color: Color(0xFF00A3E0),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'วันนี้มีอะไรให้ช่วยมั้ยครับ?',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.search,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // 💡 ดึงข้อมูลทั้งหมดจาก collection 'jobs' มากรองใน Dart เพื่อความยืดหยุ่นสูงสุด
                stream: FirebaseFirestore.instance
                    .collection('jobs')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00A3E0),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'ยังไม่มีประกาศงานในขณะนี้',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  // 💡 📌 จุดที่แก้ไข: กรองงานเพื่อให้งานใหม่ (pending) และงานที่เกี่ยวข้องแสดงผลที่หน้าแรก
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'pending';
                    final assignedJobberId = data['jobber_id'] ?? '';

                    // 1. เป็นงานใหม่สถานะ pending ทั่วไปที่เปิดรับสมัคร ให้แสดงทันที
                    if (status == 'pending') return true;

                    // 2. เป็นงานที่ผู้จ้างเลือกเราแล้ว (matched หรือ accepted ก่อนกดเดินทาง) และเป็นของเราจริง ๆ
                    if ((status == 'matched' || status == 'accepted') &&
                        assignedJobberId == currentUserId) {
                      return true;
                    }

                    // 3. งานที่ถูกยกเลิก
                    if (status == 'cancelled') return true;

                    return false;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Text(
                        'ยังไม่มีประกาศงานในขณะนี้',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final String jobId = doc.id;
                      final String title = data['title'] ?? 'งานที่ประกาศ';
                      final double reward = (data['reward_amount'] is num)
                          ? (data['reward_amount'] as num).toDouble()
                          : 100.0;
                      final String status = data['status'] ?? 'pending';
                      final List applicants =
                          (data['applicant_ids'] as List?) ?? [];
                      final String assignedJobberId = data['jobber_id'] ?? '';

                      final bool hasApplied = applicants.contains(
                        currentUserId,
                      );
                      final bool isMatchedForMe =
                          (status == 'matched' || status == 'accepted') &&
                          assignedJobberId == currentUserId;

                      final bool isTakenByOther =
                          (status == 'accepted' || status == 'matched') &&
                          assignedJobberId != currentUserId;
                      final bool isCancelled = status == 'cancelled';

                      Color borderColor = Colors.grey.shade300;
                      if (isMatchedForMe) borderColor = const Color(0xFF00AEEF);
                      if (isTakenByOther || isCancelled)
                        borderColor = Colors.red.shade300;

                      final Widget cardWidget = Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor,
                            width: isMatchedForMe ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isMatchedForMe) ...[
                                  const Text(
                                    '🎉',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'คุณถูกเลือกให้รับงาน!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ] else if (isTakenByOther) ...[
                                  const Text(
                                    '❌',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'งานนี้ได้ผู้รับจ้างคนอื่นแล้ว',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ] else if (isCancelled) ...[
                                  const Text(
                                    '⚠️',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'งานนี้ถูกยกเลิกแล้ว',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ] else ...[
                                  const Icon(
                                    Icons.notifications_none,
                                    size: 22,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'งานใหม่',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                Text(
                                  'เมื่อสักครู่',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 28.0),
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Padding(
                              padding: const EdgeInsets.only(left: 28.0),
                              child: Text(
                                '${reward.toStringAsFixed(0)} ฿   ห่างจากคุณ 1.2 กม.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedJob = {
                                        'id': jobId,
                                        'title': title,
                                        'wage':
                                            '${reward.toStringAsFixed(0)} ฿',
                                        'distance': 'ห่างจากคุณ 1.2 กม.',
                                        'timeAgo': 'เมื่อสักครู่',
                                        'jobType': title,
                                        'date': data['job_date'] ?? 'วันนี้',
                                        'location':
                                            data['address'] ??
                                            'พื้นที่ใกล้เคียง',
                                        'timeRange':
                                            data['work_time_range'] ??
                                            'ตามตกลง',
                                        'wageDetail':
                                            '${reward.toStringAsFixed(0)} บาท',
                                        'status': status,
                                        'jobber_id': assignedJobberId,
                                      };
                                    });
                                  },
                                  child: const Text(
                                    'รายละเอียดงาน',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _buildRealtimeActionButton(
                                  jobId: jobId,
                                  jobData: data,
                                  hasApplied: hasApplied,
                                  isMatchedForMe: isMatchedForMe,
                                  isTakenByOther: isTakenByOther,
                                  isCancelled: isCancelled,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );

                      if (isTakenByOther || isCancelled) {
                        return Dismissible(
                          key: Key(jobId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'ลบการ์ดนี้',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onDismissed: (direction) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ลบการ์ดเรียบร้อยแล้ว'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: cardWidget,
                        );
                      }

                      return cardWidget;
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildRealtimeActionButton({
    required String jobId,
    required Map<String, dynamic> jobData,
    required bool hasApplied,
    required bool isMatchedForMe,
    required bool isTakenByOther,
    required bool isCancelled,
  }) {
    // 💡 เมื่อผู้จ้างเลือกเราแล้ว (matched) -> แสดงปุ่ม "ยกเลิก" และ "เดินทาง" ที่หน้าแรกค้างไว้
    if (isMatchedForMe) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 28,
            child: ElevatedButton(
              onPressed: () => _cancelJobByJobber(jobId),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4848),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            height: 28,
            child: ElevatedButton(
              onPressed: () => _startTraveling(jobId, jobData),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8DC63F),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: const Text(
                'เดินทาง',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (isTakenByOther || isCancelled) {
      return SizedBox(
        height: 28,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            disabledBackgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 0,
          ),
          child: const Text(
            'สิ้นสุดแล้ว',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (hasApplied) {
      return SizedBox(
        height: 28,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF9A83E),
            disabledBackgroundColor: const Color(0xFFF9A83E),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 0,
          ),
          child: const Text(
            'กำลังรอ..',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 28,
      child: ElevatedButton(
        onPressed: () => _showRiskWarningDialog({
          'id': jobId,
          'title': jobData['title'],
          'wage': '${jobData['reward_amount']} ฿',
          'distance': 'ห่างจากคุณ 1.2 กม.',
          'timeAgo': 'เมื่อสักครู่',
          'jobType': jobData['title'],
          'date': jobData['job_date'] ?? 'วันนี้',
          'location': jobData['address'] ?? 'พื้นที่ใกล้เคียง',
          'timeRange': jobData['work_time_range'] ?? 'ตามตกลง',
          'wageDetail': '${jobData['reward_amount']} บาท',
        }),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00AEEF),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
        child: const Text(
          'รับงาน',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildJobDetailView(Map<String, dynamic> job) {
    final String jobId = job['id'];
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .snapshots(),
      builder: (context, snapshot) {
        String status = job['status'];
        String assignedJobber = job['jobber_id'] ?? '';
        List applicants = [];

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          status = data['status'] ?? 'pending';
          assignedJobber = data['jobber_id'] ?? '';
          applicants = data['applicant_ids'] ?? [];
        }

        final bool hasApplied = applicants.contains(currentUserId);
        final bool isMatchedForMe =
            status == 'matched' && assignedJobber == currentUserId;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
              onPressed: () => setState(() => _selectedJob = null),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Opacity(
                    opacity: 0.15,
                    child: Image.asset(
                      'assets/im1.png',
                      height: 110,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.work_outline,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'รายละเอียดงาน',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'รายละเอียด',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow('งาน', ': ${job['jobType']}'),
                        const SizedBox(height: 6),
                        _buildDetailRow('วันที่', ': ${job['date']}'),
                        const SizedBox(height: 6),
                        _buildDetailRow('สถานที่', ': ${job['location']}'),
                        const SizedBox(height: 6),
                        _buildDetailRow(
                          'ช่วงเวลาทำงาน',
                          ': ${job['timeRange']}',
                        ),
                        const SizedBox(height: 6),
                        _buildDetailRow('ค่าจ้าง', ': ${job['wageDetail']}'),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: isMatchedForMe
                        ? Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF4848),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () => _cancelJobByJobber(jobId),
                                  child: const Text(
                                    'ยกเลิก',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8DC63F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () => _startTraveling(jobId, job),
                                  child: const Text(
                                    'เดินทาง',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : hasApplied
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF9A83E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            onPressed: null,
                            child: const Text(
                              'กำลังรอการคัดเลือก...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00AEEF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => _showRiskWarningDialog(job),
                            child: const Text(
                              'รับงานนี้เลย',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 80,
      color: const Color(0xFF00AEEF),
      padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'หน้าแรก',
              isSelected: true,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.work,
              label: 'งานของฉัน',
              isSelected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const JobberMyJobsScreen(initialIndex: 0),
                  ),
                );
              },
            ),
            _buildNavItem(
              icon: Icons.chat,
              label: 'ข้อความ',
              hasBadge: true,
              isSelected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JobberMessagesScreen(),
                  ),
                );
              },
            ),
            _buildNavItem(
              icon: Icons.account_circle,
              label: 'โปรไฟล์',
              isSelected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JobberProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 71,
        height: 55,
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFF8DC63F),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 26),
                if (hasBadge && !isSelected)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

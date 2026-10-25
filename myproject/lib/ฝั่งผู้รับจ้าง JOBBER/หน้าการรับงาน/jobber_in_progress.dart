import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'jobber_home.dart';
import '../หน้าข้อความ/jobber_messages.dart';
import '../หน้างานของฉัน/jobber_my_jobs.dart';

class JobberInProgressScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobberInProgressScreen({Key? key, required this.job}) : super(key: key);

  @override
  State<JobberInProgressScreen> createState() => _JobberInProgressScreenState();
}

class _JobberInProgressScreenState extends State<JobberInProgressScreen> {
  int _currentStepIndex = 1;
  Timer? _paymentCheckTimer;
  bool _showReportButton = false;

  @override
  void dispose() {
    _paymentCheckTimer?.cancel();
    super.dispose();
  }

  IconData _getJobIcon(String jobTitle) {
    final title = jobTitle.toLowerCase();
    if (title.contains('หมา') ||
        title.contains('แมว') ||
        title.contains('สัตว์') ||
        title.contains('เดินเล่น')) {
      return Icons.pets;
    } else if (title.contains('ทำความสะอาด') ||
        title.contains('บ้าน') ||
        title.contains('กวาด')) {
      return Icons.cleaning_services_rounded;
    } else if (title.contains('สอน') ||
        title.contains('ติว') ||
        title.contains('เรียน')) {
      return Icons.school_rounded;
    } else if (title.contains('ส่ง') || title.contains('ของ')) {
      return Icons.delivery_dining_rounded;
    }
    return Icons.work_outline_rounded;
  }

  Future<void> _completeJobByJobber() async {
    final jobId = widget.job['id']?.toString() ?? '';
    if (jobId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
          'status': 'jobber_completed',
          'jobber_completed_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('>>> อัปเดตสถานะจบงานฝั่ง Jobber ไม่สำเร็จ: $e');
      }
    }

    if (!mounted) return;
    setState(() {
      _currentStepIndex = 2;
      _startPaymentConfirmationTimer();
    });
  }

  void _startPaymentConfirmationTimer() {
    _paymentCheckTimer?.cancel();
    _paymentCheckTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _currentStepIndex == 2) {
        _showPaymentConfirmDialog();
      }
    });
  }

  void _showPaymentConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 54,
                  color: Color(0xFF00AEEF),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ตรวจสอบการชำระเงิน',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'คุณได้รับเงินจากผู้จ้างแล้วหรือยัง?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.red.shade400,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          setState(() {
                            _showReportButton = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'คุณสามารถกดรายงานปัญหา หรือติดต่อแอดมินได้ทันที',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        },
                        child: Text(
                          'ยังไม่ได้รับ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF28DE5B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _paymentCheckTimer?.cancel();
                          setState(() {
                            _currentStepIndex = 3;
                          });
                        },
                        child: const Text(
                          'ได้รับแล้ว',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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

  void _showReportBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'รายงานปัญหา',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'กรุณาเลือกปัญหาที่คุณพบเจอ เพื่อให้ทีมงานเข้าตรวจสอบ:',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                _buildReportOption(
                  bottomSheetContext,
                  'ผู้จ้างปฏิเสธการจ่ายเงิน',
                ),
                _buildReportOption(
                  bottomSheetContext,
                  'ได้รับเงินไม่ตรงตามจำนวนที่ตกลงไว้',
                ),
                _buildReportOption(
                  bottomSheetContext,
                  'ไม่สามารถติดต่อผู้จ้างได้หลังจากทำงานเสร็จ',
                ),
                _buildReportOption(
                  bottomSheetContext,
                  'ผู้จ้างมีพฤติกรรมไม่เหมาะสม / คุกคาม',
                ),
                const Divider(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.support_agent, color: Colors.white),
                    label: const Text(
                      'ติดต่อแอดมิน (Help Center)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AEEF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      _openAdminChat();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAdminChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminChatScreen(userRole: 'ผู้รับจ้าง'),
      ),
    );
  }

  Widget _buildReportOption(BuildContext context, String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: const Icon(
        Icons.report_problem_outlined,
        color: Colors.redAccent,
        size: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ส่งรายงาน "$title" เรียบร้อยแล้ว แอดมินจะติดต่อกลับโดยเร็วที่สุด',
            ),
            backgroundColor: Colors.black87,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobId = widget.job['id']?.toString() ?? '';

    return StreamBuilder<DocumentSnapshot>(
      stream: jobId.isNotEmpty
          ? FirebaseFirestore.instance.collection('jobs').doc(jobId).snapshots()
          : const Stream.empty(),
      builder: (context, snapshot) {
        final liveJobData = snapshot.hasData && snapshot.data!.exists
            ? (snapshot.data!.data() as Map<String, dynamic>)
            : widget.job;

        final employerId = liveJobData['employer_id'] ?? '';

        if (employerId.isNotEmpty) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(employerId)
                .get(),
            builder: (context, userSnap) {
              String employerName =
                  liveJobData['employer_name'] ??
                  liveJobData['employerName'] ??
                  widget.job['employerName'] ??
                  'ผู้ว่าจ้าง';
              double bayesianRating = 0.0;
              int reviewCount = 0;

              if (userSnap.hasData && userSnap.data!.exists) {
                final uData = userSnap.data!.data() as Map<String, dynamic>?;
                if (uData != null) {
                  employerName =
                      uData['full_name'] ?? uData['name'] ?? employerName;
                  if (uData['bayesian_rating'] != null) {
                    bayesianRating = (uData['bayesian_rating'] as num)
                        .toDouble();
                  } else if (uData['rating'] != null) {
                    bayesianRating = (uData['rating'] as num).toDouble();
                  }
                  reviewCount = uData['review_count'] ?? 0;
                }
              }
              return _buildScreenContent(
                liveJobData,
                employerName,
                bayesianRating,
                reviewCount,
              );
            },
          );
        }

        final fallbackName =
            liveJobData['employer_name'] ??
            liveJobData['employerName'] ??
            widget.job['employerName'] ??
            'ผู้ว่าจ้าง';
        return _buildScreenContent(liveJobData, fallbackName, 0.0, 0);
      },
    );
  }

  Widget _buildScreenContent(
    Map<String, dynamic> jobData,
    String employerName,
    double rating,
    int reviewCount,
  ) {
    if (_currentStepIndex == 1) {
      return _buildWorkingView(jobData, employerName, rating, reviewCount);
    } else if (_currentStepIndex == 2) {
      return _buildJobCompleteView();
    } else {
      return _buildPaymentSuccessView();
    }
  }

  Widget _buildWorkingView(
    Map<String, dynamic> jobData,
    String employerName,
    double rating,
    int reviewCount,
  ) {
    final title =
        jobData['jobType'] ??
        jobData['title'] ??
        widget.job['jobType'] ??
        widget.job['title'] ??
        'งานบริการ';
    final date = jobData['date'] ?? jobData['job_date'] ?? '-';
    final location = jobData['location'] ?? jobData['address'] ?? '-';
    final timeRange = jobData['timeRange'] ?? jobData['work_time_range'] ?? '-';
    final wage =
        jobData['wageDetail'] ??
        jobData['wage'] ??
        jobData['reward_amount']?.toString() ??
        '-';

    final dynamicIcon = _getJobIcon(title);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 140, 220, 249),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
              size: 18,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const JobberMyJobsScreen(initialIndex: 0),
                ),
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jobber กำลังทำงาน',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xFFF1F5F9),
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employerName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFF59E0B),
                                size: 18,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${rating.toStringAsFixed(1)} คะแนนรีวิว',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'รายละเอียด',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow('งาน', title),
                    _buildDetailRow('วันที่', date),
                    _buildDetailRow('สถานที่', location),
                    _buildDetailRow('ช่วงเวลาทำงาน', timeRange),
                    _buildDetailRow('ค่าจ้าง', '$wage บาท'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          dynamicIcon,
                          size: 22,
                          color: const Color(0xFF0F172A),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6BB82D),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6BB82D).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6BB82D),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6BB82D),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6BB82D).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'เริ่มงาน',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'กำลังทำ',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'จบงาน',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobberChatRoomScreen(
                          employerName: employerName,
                          job: jobData,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                  label: const Text(
                    'แชท',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0E884),
                    foregroundColor: const Color(0xFF1B3800),
                    elevation: 1,
                    shadowColor: const Color(0xFFD0E884).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: Color(0xFFB4D255),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9A800),
                    foregroundColor: Colors.black87,
                    elevation: 2,
                    shadowColor: const Color(0xFFF9A800).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _completeJobByJobber,
                  child: const Text(
                    'จบงาน',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              '$label :',
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

  Widget _buildJobCompleteView() {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 140, 220, 249),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                'assets/complete.png',
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.celebration,
                  size: 100,
                  color: Color(0xFFF9A83E),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'JOB COMPLETE!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Color(0xFF1F384C),
                ),
              ),
              const Spacer(),
              if (_showReportButton) ...[
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.report_problem, color: Colors.red),
                    label: const Text(
                      'รายงานปัญหา / ยังไม่ได้รับเงิน',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      backgroundColor: Colors.white.withOpacity(0.85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _showReportBottomSheet,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // 💡 ปุ่มแบบสไลด์ (Slide to Confirm) สำหรับฝั่งผู้รับจ้าง
              SlideToConfirmButton(
                onSubmitted: () {
                  _paymentCheckTimer?.cancel();
                  setState(() {
                    _currentStepIndex = 3;
                  });
                },
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSuccessView() {
    final String wageStr =
        widget.job['wageDetail'] ?? widget.job['wage'] ?? '100 บาท';
    final String cleanNumber = wageStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final double amount = double.tryParse(cleanNumber) ?? 100.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFEE65A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: Color(0xFF5CB85C),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 14),
              const Text(
                'ได้รับเงินสำเร็จ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'รายละเอียด',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'งาน : ${widget.job['jobType'] ?? widget.job['title']}',
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    Text(
                      'วัน : ${widget.job['date'] ?? '12 พ.ย. 2568'}',
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const Text(
                      'เวลา : 18:00 น.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                    Text(
                      'ช่วงเวลาทำงาน : ${widget.job['timeRange'] ?? '16:30-17:30 น.'}',
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    Text(
                      'ค่าจ้าง : ${widget.job['wageDetail'] ?? widget.job['wage']}',
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'การจ่ายเงิน',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ค่าจ้าง', style: TextStyle(fontSize: 13)),
                        Text(
                          '฿${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ค่าธรรมเนียม', style: TextStyle(fontSize: 13)),
                        Text(
                          '฿0',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'รวม',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '฿${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.report_problem_outlined,
                    color: Colors.black54,
                    size: 18,
                  ),
                  label: const Text(
                    'รายงานปัญหา / ติดต่อแอดมิน',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _showReportBottomSheet,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF90D925),
                    foregroundColor: const Color(0xFF1B3800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const JobberMyJobsScreen(initialIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'สำเร็จแล้ว',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Widget ปุ่มสไลด์แบบเปลี่ยนสีเข้ม-อ่อน สำหรับฝั่งผู้รับจ้าง
// =============================================================================
class SlideToConfirmButton extends StatefulWidget {
  final VoidCallback onSubmitted;

  const SlideToConfirmButton({Key? key, required this.onSubmitted})
    : super(key: key);

  @override
  State<SlideToConfirmButton> createState() => _SlideToConfirmButtonState();
}

class _SlideToConfirmButtonState extends State<SlideToConfirmButton> {
  double _dragPosition = 0.0;
  bool _isSubmitted = false;

  @override
  Widget build(BuildContext context) {
    const double containerHeight = 56.0;
    const double sliderButtonSize = 48.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDragExtent =
            constraints.maxWidth - sliderButtonSize - 6;
        final double progress = maxDragExtent > 0
            ? (_dragPosition / maxDragExtent).clamp(0.0, 1.0)
            : 0.0;
        final Color currentBackgroundColor = Color.lerp(
          const Color.fromARGB(255, 215, 246, 226), // เขียวจางตอนเริ่มต้น
          const Color(0xFF16A34A), // เขียวเข้มตอนสไลด์
          progress,
        )!;

        return Container(
          height: containerHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: currentBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black26, width: 1),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Center(
                child: Text(
                  _isSubmitted ? 'ได้รับเงินสำเร็จ!' : 'ได้รับเงินแล้ว ➔',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: progress > 0.5 ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Positioned(
                left: 3 + _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isSubmitted) return;
                    setState(() {
                      _dragPosition += details.delta.dx;
                      if (_dragPosition < 0) {
                        _dragPosition = 0;
                      } else if (_dragPosition > maxDragExtent) {
                        _dragPosition = maxDragExtent;
                      }
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isSubmitted) return;
                    if (_dragPosition >= maxDragExtent * 0.85) {
                      setState(() {
                        _dragPosition = maxDragExtent;
                        _isSubmitted = true;
                      });
                      widget.onSubmitted();
                    } else {
                      setState(() {
                        _dragPosition = 0.0;
                      });
                    }
                  },
                  child: Container(
                    height: sliderButtonSize,
                    width: sliderButtonSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF16A34A),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// หน้าห้องแชตฝ่ายบริการลูกค้า (Admin Chat Screen)
// =============================================================================
class AdminChatScreen extends StatefulWidget {
  final String userRole;

  const AdminChatScreen({Key? key, this.userRole = 'ผู้รับจ้าง'})
    : super(key: key);

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      {
        'sender': 'admin',
        'text':
            'สวัสดีครับ ยินดีต้อนรับสู่ศูนย์บริการลูกค้า JibJob 🎧\n'
            'เจ้าหน้าที่พร้อมให้ความช่วยเหลือ (${widget.userRole}) แล้วครับ\n'
            'ไม่ทราบว่ามีปัญหาเกี่ยวกับการจ้างงาน การชำระเงิน หรือการใช้งานระบบด้านใด สามารถพิมพ์แจ้งรายละเอียดไว้ได้เลยครับ',
        'time':
            '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
      },
    ];
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({'sender': 'user', 'text': text, 'time': timeStr});
    });

    _msgController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00AEEF).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.headset_mic_rounded,
                color: Color(0xFF00AEEF),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'ฝ่ายบริการลูกค้า JibJob',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'พร้อมให้บริการตลอด 24 ชม.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final bool isUser = msg['sender'] == 'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF00AEEF) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 2),
                        bottomRight: Radius.circular(isUser ? 2 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: TextStyle(
                            fontSize: 14,
                            color: isUser ? Colors.white : Colors.black87,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'],
                          style: TextStyle(
                            fontSize: 10,
                            color: isUser
                                ? Colors.white70
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'พิมพ์ข้อความถึงเจ้าหน้าที่...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF00AEEF),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

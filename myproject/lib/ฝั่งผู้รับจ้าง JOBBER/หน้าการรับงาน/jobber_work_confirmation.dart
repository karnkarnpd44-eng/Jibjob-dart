import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late AnimationController _bikeVibrationController;
  late AnimationController _smokeController;

  @override
  void initState() {
    super.initState();

    _bikeVibrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    )..repeat(reverse: true);

    _smokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _bikeVibrationController.dispose();
    _smokeController.dispose();
    super.dispose();
  }

  void _navigateToMyJobsInProgress() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const JobberMyJobsScreen(initialIndex: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobId = widget.job['id']?.toString() ?? '';

    // 💡 ใช้ StreamBuilder ฟังสถานะจริงจาก Firestore แบบเรียลไทม์
    return StreamBuilder<DocumentSnapshot>(
      stream: jobId.isNotEmpty
          ? FirebaseFirestore.instance.collection('jobs').doc(jobId).snapshots()
          : const Stream.empty(),
      builder: (context, snapshot) {
        final Map<String, dynamic> jobData =
            snapshot.hasData && snapshot.data!.exists
            ? (snapshot.data!.data() as Map<String, dynamic>)
            : widget.job;

        final String status = jobData['status'] ?? 'jobber_arrived';

        final String employerName =
            jobData['employer_name'] ??
            jobData['employerName'] ??
            widget.job['employerName'] ??
            'ผู้ว่าจ้าง';

        // 💡 ถ้ารัฐสถานะใน Firestore เป็น 'working' แปลว่าผู้จ้างกดปุ่ม "เริ่มงานได้เลย!" แล้ว ให้เปลี่ยนเป็นหน้าอนุมัติทันที
        if (status == 'working') {
          return _buildEmployerApprovedView(jobData, employerName);
        }

        // ถ้ายังไม่ใช่ ให้ค้างหน้าจอรอผู้จ้างยืนยัน
        return _buildWaitingEmployerView(jobData, employerName);
      },
    );
  }

  // ===========================================================================
  // หน้าที่ 1: ถึงแล้ว! (รอผู้จ้างกดเริ่มงาน)
  // ===========================================================================
  Widget _buildWaitingEmployerView(
    Map<String, dynamic> jobData,
    String employerName,
  ) {
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
          onPressed: _navigateToMyJobsInProgress,
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
                              employerName,
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
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD3E782),
                        borderRadius: BorderRadius.circular(14),
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
  // หน้าที่ 2: ผู้จ้างอนุมัติเริ่มงาน!
  // ===========================================================================
  Widget _buildEmployerApprovedView(
    Map<String, dynamic> jobData,
    String employerName,
  ) {
    final title = jobData['title'] ?? jobData['jobType'] ?? '-';
    final date = jobData['job_date'] ?? jobData['date'] ?? '-';
    final location = jobData['address'] ?? jobData['location'] ?? '-';
    final timeRange = jobData['work_time_range'] ?? jobData['timeRange'] ?? '-';
    final reward =
        jobData['reward_amount']?.toString() ??
        jobData['wageDetail'] ??
        jobData['wage'] ??
        '-';

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
          onPressed: _navigateToMyJobsInProgress,
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
                    _buildApprovedInfoRow('งาน', title),
                    _buildApprovedInfoRow('วันที่', date),
                    _buildApprovedInfoRow('สถานที่', location),
                    _buildApprovedInfoRow('ช่วงเวลาทำงาน', timeRange),
                    _buildApprovedInfoRow('ค่าจ้าง', '$reward บาท'),
                    const SizedBox(height: 20),
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
                                  JobberInProgressScreen(job: jobData),
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

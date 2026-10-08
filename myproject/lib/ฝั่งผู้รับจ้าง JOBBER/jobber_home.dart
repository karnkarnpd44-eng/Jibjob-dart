import 'dart:async';
import 'package:flutter/material.dart';
import 'jobber_tracking.dart';

class JobberHomeScreen extends StatefulWidget {
  const JobberHomeScreen({Key? key}) : super(key: key);

  @override
  State<JobberHomeScreen> createState() => _JobberHomeScreenState();
}

class _JobberHomeScreenState extends State<JobberHomeScreen> {
  bool _hasJobs = false; // นับเวลา 10 วินาทีเพื่อโหลดงาน
  Timer? _timer;

  // จัดการสถานะ "วันนี้ไม่แสดงหน้านี้อีก"
  bool _dontShowToday = false;

  // เก็บข้อมูลงานที่เลือกดูรายละเอียด (ถ้าเป็น null แปลว่าอยู่หน้าหลัก)
  Map<String, dynamic>? _selectedJob;

  // เก็บ ID ของงานที่เราเพิ่งกดรับล่าสุด เพื่อให้อัปเดตผลลัพธ์ตรงกับงานจริง
  String? _waitingJobId;

  // รายการงาน พร้อมฟิลด์ 'id' และ 'status'
  final List<Map<String, dynamic>> _jobList = [
    {
      'id': 'job_001',
      'title': 'ฉันต้องการคนช่วยถือของ',
      'wage': '95 ฿',
      'distance': 'ห่างจากคุณ 1 กม.',
      'timeAgo': 'เมื่อสักครู่',
      'jobType': 'คนช่วยถือของ',
      'date': '12 พ.ย. 2568',
      'location': '123/45 หมู่บ้าน สุขใจ ลาดพร้าว80',
      'timeRange': '16:30-17:30 น.',
      'wageDetail': '95 บาท',
      'status': 'initial', // สถานะ: initial, waiting, accepted, rejected
    },
    {
      'id': 'job_002',
      'title': 'ฉันหาคนพาหมาไปเดินเล่น',
      'wage': '100 ฿',
      'distance': 'ห่างจากคุณ 1.5 กม.',
      'timeAgo': '2 นาที ที่ผ่านมา',
      'jobType': 'คนพาหมาไปเดินเล่น',
      'date': '12 พ.ย. 2568',
      'location': '123/45 หมู่บ้าน สุขใจ ลาดพร้าว80',
      'timeRange': '16:30-17:30 น.',
      'wageDetail': '300 บาท',
      'status': 'initial',
    },
  ];

  @override
  void initState() {
    super.initState();
    // จำลองการรอ 10 วินาทีแรก จะเป็นหน้าว่างพร้อมข้อความจางๆ
    _timer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _hasJobs = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ===========================================================================
  // ป๊อปอัปแจ้งเตือนความเสี่ยง (ถอดแบบจากฝั่งสร้างงานของผู้จ้าง)
  // ===========================================================================
  void _showRiskWarningDialog(Map<String, dynamic> job) {
    if (_dontShowToday) {
      _onConfirmAcceptJob(job);
      return;
    }

    bool localDontShow = false;

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
                                if (localDontShow) {
                                  setState(() {
                                    _dontShowToday = true;
                                  });
                                }
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
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              localDontShow = !localDontShow;
                            });
                          },
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: localDontShow
                                  ? Colors.black
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: localDontShow
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              localDontShow = !localDontShow;
                            });
                          },
                          child: const Text(
                            'วันนี้ไม่แสดงหน้านี้อีก',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
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

  // ===========================================================================
  // เมื่อกดยืนยันรับงาน -> อัปเดตสถานะของงานตัวที่กดจริง
  // ===========================================================================
  void _onConfirmAcceptJob(Map<String, dynamic> job) {
    setState(() {
      job['status'] = 'waiting';
      _waitingJobId = job['id']; // จำ ID ของงานที่เพิ่งกดรับไว้
      if (_selectedJob != null) {
        _selectedJob = null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ส่งคำขอรับงาน "${job['title']}" แล้ว กำลังรอผู้จ้างคัดเลือก...',
        ),
        backgroundColor: const Color(0xFFF9A83E),
      ),
    );
  }

  // ฟังก์ชันอัปเดตสถานะงานตาม ID จริง (ใช้ได้ทั้งระบบจำลอง และ Firebase ในอนาคต)
  void _updateJobStatusByTarget(String targetStatus) {
    if (_waitingJobId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากดรับงานใดงานหนึ่งก่อน เพื่อจำลองผลตอบรับ'),
          backgroundColor: Colors.black87,
        ),
      );
      return;
    }

    setState(() {
      final targetJob = _jobList.firstWhere(
        (job) => job['id'] == _waitingJobId,
        orElse: () => {},
      );

      if (targetJob.isNotEmpty) {
        targetJob['status'] = targetStatus;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedJob != null) {
      return _buildJobDetailView(_selectedJob!);
    }
    return _buildJobListView();
  }

  // ================= 1. หน้าหลัก (รายการงานว่าง) =================
  Widget _buildJobListView() {
    final sortedJobs = List<Map<String, dynamic>>.from(_jobList);
    sortedJobs.sort((a, b) {
      if (a['status'] == 'accepted') return -1;
      if (b['status'] == 'accepted') return 1;
      return 0;
    });

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
              child: !_hasJobs
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'ยังไม่มีงานบริเวณใกล้เคียง',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: sortedJobs.length,
                      itemBuilder: (context, index) {
                        final job = sortedJobs[index];
                        final String status = job['status'] ?? 'initial';
                        final bool isAccepted = status == 'accepted';
                        final bool isRejected = status == 'rejected';

                        final Widget cardWidget = Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAccepted
                                  ? const Color(0xFF00AEEF)
                                  : isRejected
                                  ? Colors.red.shade300
                                  : Colors.grey.shade300,
                              width: isAccepted ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isAccepted) ...[
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
                                    job['timeAgo'],
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
                                  job['title'],
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
                                  '${job['wage']} ${job['distance']}',
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
                                        _selectedJob = job;
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
                                  _buildActionButton(job, status),
                                ],
                              ),
                            ],
                          ),
                        );

                        // ปัดซ้ายเพื่อลบเฉพาะงานที่สถานะเป็น rejected
                        if (isRejected) {
                          return Dismissible(
                            key: Key(job['id'].toString()),
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
                                    'ลบงานนี้',
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
                              setState(() {
                                _jobList.removeWhere(
                                  (item) => item['id'] == job['id'],
                                );
                                if (_waitingJobId == job['id']) {
                                  _waitingJobId = null;
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'ลบ "${job['title']}" ออกจากรายการแล้ว',
                                  ),
                                  backgroundColor: Colors.black87,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: cardWidget,
                          );
                        }

                        return cardWidget;
                      },
                    ),
            ),

            // =================================================================
            // แผงปุ่มจำลองสถานการณ์ (ทำงานกับงานที่กดรับจริง ไม่ Fix ค่า)
            // =================================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'จำลองผล:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateJobStatusByTarget('accepted');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8DC63F),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 28),
                    ),
                    child: const Text(
                      'ผู้จ้างเลือกเรา',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateJobStatusByTarget('rejected');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 28),
                    ),
                    child: const Text(
                      'เลือกคนอื่น',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        for (var job in _jobList) {
                          job['status'] = 'initial';
                        }
                        _waitingJobId = null;
                      });
                    },
                    child: const Text(
                      'รีเซ็ต',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(color: Color(0xFF00AEEF)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomItem(
              icon: Icons.home,
              label: 'หน้าแรก',
              isSelected: true,
            ),
            _buildBottomItem(
              icon: Icons.work,
              label: 'งานของฉัน',
              isSelected: false,
            ),
            _buildBottomItem(
              icon: Icons.chat_bubble_outline,
              label: 'ข้อความ',
              isSelected: false,
              hasBadge: true,
            ),
            _buildBottomItem(
              icon: Icons.person_outline,
              label: 'โปรไฟล์',
              isSelected: false,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ปุ่มแอ็กชันการ์ดงาน (สลับ สี + ข้อความ ตามสถานะของงานแต่ละตัว)
  // ===========================================================================
  Widget _buildActionButton(Map<String, dynamic> job, String status) {
    if (status == 'waiting') {
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
    } else if (status == 'accepted') {
      return SizedBox(
        height: 28,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobberTrackingScreen(job: job),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8DC63F),
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
      );
    } else if (status == 'rejected') {
      return SizedBox(
        height: 28,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4848),
            disabledBackgroundColor: const Color(0xFFFF4848),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 0,
          ),
          child: const Text(
            'ล้มเหลว',
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
        onPressed: () {
          _showRiskWarningDialog(job);
        },
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

  // ================= 2. หน้ารายละเอียดงาน (12.1) =================
  Widget _buildJobDetailView(Map<String, dynamic> job) {
    final String status = job['status'] ?? 'initial';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            setState(() {
              _selectedJob = null;
            });
          },
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
                    _buildDetailRow('ช่วงเวลาทำงาน', ': ${job['timeRange']}'),
                    const SizedBox(height: 6),
                    _buildDetailRow('ค่าจ้าง', ': ${job['wageDetail']}'),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: status == 'waiting'
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
                    : status == 'accepted'
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8DC63F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  JobberTrackingScreen(job: job),
                            ),
                          );
                        },
                        child: const Text(
                          'เดินทางไปทำงานนี้',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8DC63F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          _showRiskWarningDialog(job);
                        },
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

  Widget _buildBottomItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    bool hasBadge = false,
  }) {
    return Container(
      padding: isSelected
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
          : EdgeInsets.zero,
      decoration: isSelected
          ? BoxDecoration(
              color: const Color(0xFF8DC63F),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              if (hasBadge)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

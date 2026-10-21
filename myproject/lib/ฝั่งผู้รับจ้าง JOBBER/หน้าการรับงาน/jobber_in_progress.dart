import 'dart:async';
import 'package:flutter/material.dart';
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
  // 1 = กำลังทำงาน..., 2 = JOB COMPLETE!, 3 = ได้รับเงินสำเร็จ
  int _currentStepIndex = 1;
  Timer? _paymentCheckTimer;
  bool _showReportButton =
      false; // แสดงปุ่มรายงานปัญหาเมื่อตอบว่ายังไม่ได้รับเงิน

  @override
  void dispose() {
    _paymentCheckTimer?.cancel();
    super.dispose();
  }

  // ===========================================================================
  // เริ่มนับเวลา 10 วินาที เพื่อแสดงป๊อปอัปถามเรื่องเงิน
  // ===========================================================================
  void _startPaymentConfirmationTimer() {
    _paymentCheckTimer?.cancel();
    _paymentCheckTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _currentStepIndex == 2) {
        _showPaymentConfirmDialog();
      }
    });
  }

  // ===========================================================================
  // ป๊อปอัปถาม "คุณได้รับเงินแล้วหรือยัง"
  // ===========================================================================
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
                    // ปุ่ม 1: ยังไม่ได้รับ
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
                            _showReportButton = true; // เปิดปุ่มรายงานบนหน้าจอ
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
                    // ปุ่ม 2: ได้รับแล้ว
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
                          setState(() {
                            _currentStepIndex = 3; // ไปหน้ารายละเอียดการจบงาน
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

  // ===========================================================================
  // หน้าต่างเมนูรายงานปัญหา (Modal Bottom Sheet)
  // ===========================================================================
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

                // ปุ่มติดต่อแอดมิน -> เปิดเข้าหน้า AdminChatScreen โดยตรง
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
                      Navigator.pop(bottomSheetContext); // ปิด BottomSheet
                      _openAdminChat(); // เปิดหน้าแชตแอดมิน
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

  // ฟังก์ชันเปิดหน้าห้องแชตแอดมินสำหรับผู้รับจ้าง
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
    if (_currentStepIndex == 1) {
      return _buildWorkingView();
    } else if (_currentStepIndex == 2) {
      return _buildJobCompleteView();
    } else {
      return _buildPaymentSuccessView();
    }
  }

  // ===========================================================================
  // ภาพที่ 1: กำลังทำงาน...
  // ===========================================================================
  Widget _buildWorkingView() {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 134, 219, 242),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'กำลังทำงาน...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/employer_avatar.png',
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.black54,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        '4.5 ดูโปรไฟล์',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade400, width: 1.2),
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
                      'วันที่ : ${widget.job['date'] ?? '-'}',
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    Text(
                      'สถานที่ : ${widget.job['location'] ?? '-'}',
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    Text(
                      'ช่วงเวลาทำงาน : ${widget.job['timeRange'] ?? '-'}',
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
                  border: Border.all(color: Colors.grey.shade400, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pets, size: 24, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(
                          widget.job['jobType'] ?? 'ดูแลสัตว์เลี้ยงชั่วคราว',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStepItem(
                          icon: Icons.check,
                          label: 'เริ่มงาน',
                          isActive: true,
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        _buildStepItem(
                          icon: Icons.check,
                          label: 'กำลังทำ',
                          isActive: true,
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        _buildStepItem(
                          icon: null,
                          label: 'จบงาน',
                          isActive: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ปุ่มแชท
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4E677),
                    foregroundColor: const Color(0xFF2E4B00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobberChatRoomScreen(
                          employerName: widget.job['employerName'] ?? 'ดนัย',
                          job: widget.job,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'แชท',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9A83E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentStepIndex = 2; // พาไปหน้าที่ 2 JOB COMPLETE!
                      _startPaymentConfirmationTimer(); // เริ่มจับเวลา 10 วิเพื่อถามเรื่องเงิน
                    });
                  },
                  child: const Text(
                    'จบงาน',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ภาพที่ 2: JOB COMPLETE! (พร้อมป๊อปอัป 10 วิ และปุ่มรายงานปัญหา)
  // ===========================================================================
  Widget _buildJobCompleteView() {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 134, 219, 242),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                'assets/complete.png',
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Column(
                  children: const [
                    Icon(
                      Icons.celebration,
                      size: 100,
                      color: Color(0xFFF9A83E),
                    ),
                    SizedBox(height: 12),
                  ],
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

              // แสดงปุ่มรายงานปัญหา หากผู้ใช้เลือก "ยังไม่ได้รับ" ในป๊อปอัป
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

              // ปุ่มได้รับเงินแล้ว!
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28DE5B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    _paymentCheckTimer?.cancel();
                    setState(() {
                      _currentStepIndex = 3;
                    });
                  },
                  child: const Text(
                    'ได้รับเงินแล้ว!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ภาพที่ 3: ได้รับเงินสำเร็จ (พร้อมปุ่มรายงานปัญหา และปุ่มกลับหน้าแรก)
  // ===========================================================================
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
        automaticallyImplyLeading:
            false, // บังคับไม่ให้ระบบดึงปุ่มย้อนกลับมาแสดงอัตโนมัติ
        leading:
            const SizedBox.shrink(), // ใส่ Widget ว่างทับตำแหน่งปุ่มย้อนกลับ
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

              // การ์ดรายละเอียด
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

              // การ์ดสรุปการเงิน
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

              // ปุ่มรายงานปัญหา (ในหน้ารายละเอียดจบงาน)
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

              // ปุ่มกลับหน้าแรก
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
                        builder: (context) => JobberMyJobsScreen(
                          completedJob: {
                            'id': widget.job['id'] ?? 'job_latest',
                            'title':
                                widget.job['jobType'] ??
                                widget.job['title'] ??
                                'งานที่รับมอบหมาย',
                            'wage':
                                widget.job['wageDetail'] ??
                                widget.job['wage'] ??
                                '300 ฿',
                            'distance': 'งานสำเร็จแล้ว',
                            'timeAgo': 'เมื่อสักครู่',
                          },
                          initialIndex: 2, // 2 = เปิดแท็บ "สำเร็จแล้ว" ทันที
                        ),
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

  Widget _buildStepItem({
    required IconData? icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF5CB85C) : Colors.transparent,
            shape: BoxShape.circle,
            border: isActive
                ? null
                : Border.all(color: Colors.grey.shade400, width: 2),
          ),
          child: icon != null
              ? Icon(icon, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? Colors.black87 : Colors.grey.shade500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
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

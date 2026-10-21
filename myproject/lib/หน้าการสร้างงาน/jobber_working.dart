// lib/หน้าการสร้างงาน/jobber_working.dart
import 'package:flutter/material.dart';
import '../หน้าข้อความ/chat_room.dart';
import '../หน้าจบงานและรีวิว/payment_summary.dart';

class JobberWorkingScreen extends StatefulWidget {
  final String jobberName;
  final String rating;
  final String jobTitle;
  final String jobDate;
  final String workTimeRange;
  final double wageAmount;
  final double feeAmount;

  const JobberWorkingScreen({
    Key? key,
    required this.jobberName,
    required this.rating,
    required this.jobTitle,
    required this.jobDate,
    required this.workTimeRange,
    required this.wageAmount,
    required this.feeAmount,
  }) : super(key: key);

  @override
  State<JobberWorkingScreen> createState() => _JobberWorkingScreenState();
}

class _JobberWorkingScreenState extends State<JobberWorkingScreen> {
  // ===========================================================================
  // [SYSTEM LOGIC - TWO-WAY CONFIRMATION]
  // _isJobberCompleted: สถานะว่า Jobber กดส่งมอบงานแล้วหรือยัง
  // _isJibberApproved:  สถานะว่า Jibber ตรวจสอบและกดยืนยันจบงานแล้ว
  // ===========================================================================
  bool _isJobberCompleted = false;
  bool _isJibberApproved = false;

  // ===========================================================================
  // BottomSheet รายงานปัญหา (กดเลือกหัวข้อ หรือ กดคุยกับแอดมิน)
  // ===========================================================================
  void _showReportBottomSheet() {
    final List<String> employerIssues = [
      'ผู้รับจ้างทำงานไม่เสร็จตามที่ตกลงไว้',
      'งานไม่ตรงตามรายละเอียดที่ระบุ',
      'ไม่สามารถติดต่อผู้รับจ้างได้ในระหว่างงาน',
      'ผู้รับจ้างมีพฤติกรรมไม่เหมาะสม / คุกคาม',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFC),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: SafeArea(
            top: false,
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
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(sheetContext),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'กรุณาเลือกปัญหาที่คุณพบเจอ เพื่อให้ทีมงานเข้าตรวจสอบ:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),

                ...employerIssues.map(
                  (issue) => InkWell(
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'ส่งรายงาน "$issue" แล้ว เจ้าหน้าที่จะเข้าตรวจสอบโดยเร็ว',
                          ),
                          backgroundColor: Colors.black87,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFFF5252),
                            size: 24,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              issue,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                const Divider(color: Color(0xFFE2E8F0), thickness: 1),
                const SizedBox(height: 16),

                // ปุ่ม ติดต่อแอดมิน -> เปิดเข้าหน้าห้องแชตแอดมินทันที
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _openAdminChat();
                    },
                    icon: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
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
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // เปิดเข้าสู่หน้าแชตของแอดมินจริง
  // ===========================================================================
  void _openAdminChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminChatScreen(userRole: 'ผู้ว่าจ้าง'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isJibberApproved) {
      return _buildJobCompleteView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF65C1BF),
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isJobberCompleted = !_isJobberCompleted;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isJobberCompleted
                            ? '${widget.jobberName} กดส่งมอบงานเรียบร้อยแล้ว!'
                            : 'รีเซ็ตสถานะเป็น: Jobber ยังทำงานไม่เสร็จ',
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.black87,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _isJobberCompleted
                        ? Colors.white
                        : Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isJobberCompleted
                          ? const Color(0xFF6BB82D)
                          : Colors.black12,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isJobberCompleted
                            ? Icons.check_circle_rounded
                            : Icons.toggle_off_rounded,
                        color: _isJobberCompleted
                            ? const Color(0xFF6BB82D)
                            : Colors.black54,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isJobberCompleted
                            ? 'Jobber ส่งงานแล้ว'
                            : 'จำลอง Jobber จบงาน',
                        style: TextStyle(
                          color: _isJobberCompleted
                              ? const Color(0xFF2E7D32)
                              : Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Jobber กำลังทำงาน',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),

              // การ์ดโปรไฟล์ Jobber
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
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFFF1F5F9),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Color(0xFF94A3B8),
                              ),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.jobberName,
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
                              widget.rating,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'ดูโปรไฟล์',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // การ์ดแสดงสถานะงาน
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Image.asset(
                            'assets/im3.png',
                            height: 38,
                            width: 38,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.work_outline_rounded,
                                  size: 32,
                                  color: Color(0xFF0284C7),
                                ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Flexible(
                          child: Text(
                            widget.jobTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

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
                              color: _isJobberCompleted
                                  ? const Color(0xFF6BB82D)
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: _isJobberCompleted
                                ? const Color(0xFF6BB82D)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isJobberCompleted
                                  ? const Color(0xFF6BB82D)
                                  : const Color(0xFFCBD5E1),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: _isJobberCompleted
                                ? Colors.white
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'เริ่มงาน',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          _isJobberCompleted
                              ? 'Jobber ส่งมอบงานแล้ว'
                              : 'รอส่งมอบงาน',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: _isJobberCompleted
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ปุ่มแชท
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatRoomScreen(jobberName: widget.jobberName),
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

              // ปุ่มยืนยันการจบงาน
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isJobberCompleted
                      ? () {
                          setState(() {
                            _isJibberApproved = true;
                          });
                        }
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'กรุณารอผู้รับจ้าง (Jobber) กดส่งมอบงานก่อน จึงจะกดยืนยันได้',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isJobberCompleted
                        ? const Color(0xFFF9A800)
                        : const Color(0xFFCBD5E1),
                    foregroundColor: _isJobberCompleted
                        ? Colors.black87
                        : const Color(0xFF64748B),
                    elevation: _isJobberCompleted ? 2 : 0,
                    shadowColor: const Color(0xFFF9A800).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_isJobberCompleted) ...[
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        _isJobberCompleted
                            ? 'ยืนยันการจบงาน'
                            : 'รอ Jobber ส่งมอบงาน...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isJobberCompleted
                              ? Colors.black87
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // หน้าจอ: JOB COMPLETE! (แสดงหลังยืนยันจบงาน)
  // ===========================================================================
  Widget _buildJobCompleteView() {
    return Scaffold(
      backgroundColor: const Color(0xFF65C1BF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                'assets/complete.png',
                height: 240,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.celebration,
                  size: 130,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'JOB COMPLETE!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),

              // ===============================================================
              // ปุ่มรายงานปัญหา (กดแล้วเปิด BottomSheet ตามภาพ)
              // ===============================================================
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _showReportBottomSheet,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0xFFFF5252),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.warning_rounded,
                        color: Color(0xFFFF5252),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'รายงานปัญหา / ติดต่อแอดมิน',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF5252),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ===============================================================
              // ปุ่มจ่ายเงินแล้ว!
              // ===============================================================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentSummaryScreen(
                          jobTitle: widget.jobTitle,
                          jobDate: widget.jobDate,
                          completedTime:
                              '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')} น.',
                          workTimeRange: widget.workTimeRange,
                          wageAmount: widget.wageAmount,
                          feeAmount: widget.feeAmount,
                          jobberName: widget.jobberName,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Colors.black26, width: 1),
                    ),
                  ),
                  child: const Text(
                    'จ่ายเงินแล้ว!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// หน้าห้องแชตฝ่ายบริการลูกค้า (Admin Chat Screen)
// =============================================================================
class AdminChatScreen extends StatefulWidget {
  final String userRole;

  const AdminChatScreen({Key? key, this.userRole = 'ผู้ว่าจ้าง'})
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

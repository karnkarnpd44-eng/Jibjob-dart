import 'package:flutter/material.dart';
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
  // ควบคุมการสลับระหว่างหน้ารายละเอียด กับ หน้าเปิดแผนที่เต็มจอ
  bool _isViewingMap = false;

  @override
  Widget build(BuildContext context) {
    if (_isViewingMap) {
      return _buildTrackingMapView();
    }
    return _buildTrackingDetailView();
  }

  // ===========================================================================
  // 1. หน้ารายละเอียดการเดินทาง (UI โมเดิร์น + ปุ่มแชทเข้าห้องตรง)
  // ===========================================================================
  Widget _buildTrackingDetailView() {
    final employerName = widget.job['employerName'] ?? 'ผู้ว่าจ้าง';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // พื้นหลังสีเทาอ่อน สบายตา
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
            // เมื่อกดย้อนกลับจากหน้าติดตามงาน ให้พาไปหน้างานของฉัน ในแท็บ "กำลังทำอยู่"
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => JobberMyJobsScreen(
                  inProgressJob: widget.job,
                  initialIndex: 0,
                ),
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

              // กล่องรายละเอียดงาน (การ์ดมิติใหม่ นุ่มนวล ดูมีระดับ)
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
                    _buildInfoRow(
                      'งาน',
                      widget.job['jobType'] ?? widget.job['title'] ?? '-',
                    ),
                    _buildInfoRow('วันที่', widget.job['date'] ?? '-'),
                    _buildInfoRow('สถานที่', widget.job['location'] ?? '-'),
                    _buildInfoRow(
                      'ช่วงเวลาทำงาน',
                      widget.job['timeRange'] ?? '-',
                    ),
                    _buildInfoRow(
                      'ค่าจ้าง',
                      '${widget.job['wageDetail'] ?? widget.job['wage'] ?? '-'}',
                    ),
                    const SizedBox(height: 16),

                    // ปุ่มเปิดแผนที่ (ปุ่มสีฟ้า สไตล์โมเดิร์น)
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
                            _isViewingMap =
                                true; // สลับเป็นหน้าแผนที่ Google Maps เต็มจอ
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ปุ่มแชท -> กดแล้วส่งตรงเข้าสู่ห้องแชทของงานนั้นทันที
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
                    onPressed: () {
                      // ส่งตรงเข้า JobberChatRoomScreen ของผู้จ้างคนนั้นทันที
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobberChatRoomScreen(
                            employerName: employerName,
                            job: widget.job,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ไทม์ไลน์สถานะการเดินทาง (Timeline Indicator ดีไซน์สวยงาม)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        // จุดที่ 1: กำลังเดินทาง (สำเร็จ / เช็คแล้ว)
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
                        // เส้นเชื่อม
                        Container(
                          width: 2.5,
                          height: 48,
                          color: const Color(0xFFCBD5E1),
                        ),
                        // จุดที่ 2: ถึงที่นัดหมาย (รอดำเนินการ)
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

              // ปุ่ม "ถึงแล้ว" (ปุ่มใหญ่ สีเขียวมะนาว เด่นชัด)
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'ส่งการแจ้งเตือนไปยังผู้จ้างแล้ว: "Jobber มาถึงแล้ว"',
                        ),
                        backgroundColor: Color(0xFF00AEEF),
                      ),
                    );

                    // นำทางไปยังหน้ายืนยันเริ่มงาน
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            JobberWorkConfirmationScreen(job: widget.job),
                      ),
                    );
                  },
                  child: const Text(
                    'ถึงแล้ว',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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

  // ตัวช่วยแสดงแถวข้อมูลในกล่องรายละเอียด
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
  // 2. หน้าแผนที่ Google Maps (คงเดิมและจัดขอบมนให้เนียนขึ้น)
  // ===========================================================================
  Widget _buildTrackingMapView() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            setState(() {
              _isViewingMap = false; // ย้อนกลับมาหน้ารายละเอียดการเดินทาง
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
                        // ตารางจำลองแผนที่
                        CustomPaint(
                          size: Size.infinite,
                          painter: MapGridPainter(),
                        ),
                        // หมุดปลายทางพร้อมแสดงชื่อสถานที่จริงของงานนั้น
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
                                  widget.job['location'] ?? 'จุดนัดหมาย',
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

              // ปุ่ม "ถึงแล้ว" ในหน้าแผนที่
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'คุณถึงที่หมายแล้ว! ส่งการแจ้งเตือนไปยังผู้จ้างเรียบร้อย',
                        ),
                        backgroundColor: Color(0xFF90D925),
                      ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            JobberWorkConfirmationScreen(job: widget.job),
                      ),
                    );
                  },
                  child: const Text(
                    'ถึงแล้ว',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
}

// ตัววาดเส้นทางจำลองแผนที่
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

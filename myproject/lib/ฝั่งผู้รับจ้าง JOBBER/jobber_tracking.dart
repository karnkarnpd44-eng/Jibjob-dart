import 'package:flutter/material.dart';

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
  // 1. หน้ารายละเอียดการเดินทาง (ภาพซ้าย)
  // ===========================================================================
  Widget _buildTrackingDetailView() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 6),
              const Text(
                'รายละเอียดงาน',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // กล่องรายละเอียดงาน (ดึงค่า Dynamic ตามงานที่ส่งเข้ามา)
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
                    const SizedBox(height: 14),

                    // ปุ่มเปิดแผนที่
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          setState(() {
                            _isViewingMap =
                                true; // สลับเป็นหน้าแผนที่ Google Maps เต็มจอ
                          });
                        },
                        child: const Text(
                          'เปิดแผนที่',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ปุ่มแชท
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 90,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AEEF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('เปิดห้องแชทกับผู้จ้าง...'),
                        ),
                      );
                    },
                    child: const Text(
                      'แชท',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ไทม์ไลน์สถานะการเดินทาง (Timeline Indicator)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5CB85C),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 48,
                          color: Colors.grey.shade400,
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade500,
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          'เดินทาง',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 46),
                        Text(
                          'ถึงที่นัดหมาย',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'คุณถึงที่หมายแล้ว! ส่งการแจ้งเตือนไปยังผู้จ้างเรียบร้อย',
                        ),
                        backgroundColor: Color(0xFF90D925),
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

  // ===========================================================================
  // 2. หน้าแผนที่ Google Maps (ภาพขวา)
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
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        // ตารางจำลองแผนที่ (พร้อมต่อยอดใส่ GoogleMap วิดเจ็ตจริง)
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
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.job['location'] ?? 'จุดนัดหมาย',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
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

              // ปุ่ม "ถึงแล้ว"
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'คุณถึงที่หมายแล้ว! ส่งการแจ้งเตือนไปยังผู้จ้างเรียบร้อย',
                        ),
                        backgroundColor: Color(0xFF90D925),
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

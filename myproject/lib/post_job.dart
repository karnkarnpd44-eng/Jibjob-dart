import 'package:flutter/material.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({Key? key}) : super(key: key);

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final TextEditingController _titleController = TextEditingController(
    text: 'คนพาหมาไปเดินเล่น',
  );
  final TextEditingController _descController = TextEditingController(
    text: 'น้องหมา 2 ตัว ตัวผู้กับตัวเมีย',
  );
  final TextEditingController _addressController = TextEditingController(
    text: '123/45 หมู่บ้านสุขใจ ลาดพร้าว80',
  );
  final TextEditingController _dateController = TextEditingController(
    text: '12/11/2568',
  );
  final TextEditingController _timeController = TextEditingController(
    text: '16:30-17:30',
  );
  final TextEditingController _priceController = TextEditingController(
    text: '100 บาท',
  );

  // ตัวเลือกการชำระเงินตามเอกสาร: เงินสด หรือ QR Code ส่วนตัว
  String _paymentMethod = 'QR Code';

  // สไตล์กรอบ Input สีฟ้าขอบมนตาม Mockup
  final OutlineInputBorder _blueInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFF4AC4F3), width: 1.5),
  );

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Warning Pop-up แจ้งเตือนข้อตกลงเรื่องความเสี่ยงตามบทที่ 1 และ 3
  // Warning Pop-up แจ้งเตือนข้อตกลงเรื่องความเสี่ยง
  void _showWarningPopup() {
    bool doNotShowAgain = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBB040), // สีพื้นหลังส้มอมเหลืองตามภาพ
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black,
                    width: 3.5,
                  ), // ขอบสีดำหนา
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- แถบส่วนหัว: รูปภาพและข้อความหัวข้อ ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 💡 ช่องใส่รูปภาพตามขนาดและระยะในภาพ
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: Image.asset(
                            'assets/Warning.png', // <-- ใส่ Path รูปภาพของคุณตรงนี้
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // แสดงกล่องจำลองระหว่างที่ยังไม่ได้ใส่ไฟล์รูป
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.black26,
                                    strokeAlign: BorderSide.strokeAlignInside,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 40,
                                    color: Colors.black38,
                                  ),
                                ),
                              );
                            },
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
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'ความเสี่ยง!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // --- เนื้อหารายละเอียดข้อความแจ้งเตือน ---
                    const Text(
                      'งานบางประเภทอาจเกี่ยวข้องกับพื้นที่ส่วนตัว\n'
                      'หรือสถานที่จำกัดการเข้าถึง\n'
                      'โปรดพิจารณารายละเอียดงานและข้อตกลง\n'
                      'ระหว่างกันอย่างรอบคอบ\n'
                      'JibJobทำหน้าที่เป็นแพลตฟอร์มตัวกลาง\n'
                      'เท่านั้นมิได้เป็นผู้รับรองความปลอดภัย\n'
                      'ของงาน',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // --- ปุ่มยกเลิก และ เข้าใจแล้ว ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ปุ่มยกเลิก (สีแดง)
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFFF4D4D,
                                ), // สีแดงอมส้ม
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'ยกเลิก',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // ปุ่มเข้าใจแล้ว (สีเขียวตองอ่อน)
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(dialogContext); // ปิด Dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'บันทึกงานสำเร็จ เริ่มค้นหาผู้รับจ้างในรัศมี 5กิโลเมตร...',
                                    ),
                                    backgroundColor: Color(0xFF01224F),
                                  ),
                                );
                                Navigator.pop(context); // ย้อนกลับหน้าแรก
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF99E22B,
                                ), // สีเขียวตองอ่อน
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'เข้าใจแล้ว',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // --- Checkbox: วันนี้ไม่แสดงหน้านี้อีก ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              doNotShowAgain = !doNotShowAgain;
                            });
                          },
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: doNotShowAgain
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.black,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'วันนี้ไม่แสดงหน้านี้อีก',
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
            );
          },
        );
      },
    );
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
              const Text(
                'เรียก Jobber',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // ================= ส่วนที่ 1: รายละเอียดงาน =================
              const Text(
                'รายละเอียดงาน',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'ฉันหา',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  enabledBorder: _blueInputBorder,
                  focusedBorder: _blueInputBorder,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'รายละเอียดงาน',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  enabledBorder: _blueInputBorder,
                  focusedBorder: _blueInputBorder,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ================= ส่วนที่ 2: สถานที่และเวลา =================
              const Text(
                'สถานที่และเวลา',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // แผนที่จำลองฝั่งซ้าย
                  Container(
                    width: 100,
                    height: 105,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                        const Icon(
                          Icons.location_on,
                          size: 32,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ช่องที่อยู่ และ ช่องวัน/เวลา ฝั่งขวา
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: _addressController,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            enabledBorder: _blueInputBorder,
                            focusedBorder: _blueInputBorder,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextField(
                                controller: _dateController,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  enabledBorder: _blueInputBorder,
                                  focusedBorder: _blueInputBorder,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                '|',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 6,
                              child: TextField(
                                controller: _timeController,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  enabledBorder: _blueInputBorder,
                                  focusedBorder: _blueInputBorder,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ================= ส่วนที่ 3: ค่าจ้างและการชำระเงิน =================
              const Text(
                'ค่าจ้างและการชำระเงิน',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF4AC4F3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // กล่องใส่ค่าจ้าง
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ค่าจ้างรวม',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 38,
                                child: TextField(
                                  controller: _priceController,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    enabledBorder: _blueInputBorder,
                                    focusedBorder: _blueInputBorder,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Radio Button เลือกวิธีชำระ
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _buildPaymentOption('เงินสดหลังจบงาน'),
                              _buildPaymentOption('QR Code'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'เงื่อนไขการคำนวณค่าจ้าง',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ================= ปุ่มกดยืนยันด้านล่าง =================
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF4AC4F3),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'บันทึกเป็นฉบับร่าง',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _showWarningPopup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF01224F,
                          ), // สีน้ำเงินเข้ม
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'เรียก Jobber ทันที!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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

  // วิดเจ็ตตัวเลือก Radio Button การชำระเงิน
  Widget _buildPaymentOption(String title) {
    return InkWell(
      onTap: () => setState(() => _paymentMethod = title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Radio<String>(
                value: title,
                groupValue: _paymentMethod,
                activeColor: const Color(0xFF01224F),
                onChanged: (val) {
                  if (val != null) setState(() => _paymentMethod = val);
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

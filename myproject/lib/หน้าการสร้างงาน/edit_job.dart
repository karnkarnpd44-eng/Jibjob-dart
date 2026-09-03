import 'package:flutter/material.dart';

class EditJobScreen extends StatefulWidget {
  final Map<String, String> initialData;

  const EditJobScreen({Key? key, required this.initialData}) : super(key: key);

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _addressController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _priceController;

  String _paymentMethod = 'QR Code';

  final OutlineInputBorder _blueInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFF4AC4F3), width: 1.5),
  );

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData['title']);
    _descController = TextEditingController(text: widget.initialData['desc']);
    _addressController = TextEditingController(
      text: widget.initialData['address'],
    );
    _dateController = TextEditingController(text: widget.initialData['date']);
    _timeController = TextEditingController(text: widget.initialData['time']);
    _priceController = TextEditingController(text: widget.initialData['price']);
    _paymentMethod = widget.initialData['payment'] ?? 'QR Code';
  }

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

              // ส่วนที่ 1: รายละเอียดงาน
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

              // ส่วนที่ 2: สถานที่และเวลา
              const Text(
                'สถานที่และเวลา',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

              // ส่วนที่ 3: ค่าจ้างและการชำระเงิน
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          const SizedBox(height: 4),
                          const Text(
                            'ค่าจ้างขั้นต่ำ 100 บาท',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
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
              ),
              const SizedBox(height: 36),

              // ปุ่มยืนยันการแก้ไขปุ่มเดียวเดี่ยวๆ ตามภาพ
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // ส่งค่าที่อัปเดตแล้วกลับไปยังหน้าที่เรียก
                    Navigator.pop(context, {
                      'title': _titleController.text,
                      'desc': _descController.text,
                      'address': _addressController.text,
                      'date': _dateController.text,
                      'time': _timeController.text,
                      'price': _priceController.text,
                      'payment': _paymentMethod,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF01224F,
                    ), // สีน้ำเงินเข้มตามภาพ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'ยืนยันการแก้ไข',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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

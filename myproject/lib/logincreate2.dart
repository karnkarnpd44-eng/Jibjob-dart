import 'package:flutter/material.dart';
import 'package:myproject/logincreate1.dart';
import 'package:myproject/home.dart';

void main() {
  runApp(CreateAccountPage2());
}

class CreateAccountPage2 extends StatefulWidget {
  //StatefulWidget คือประกาศว่าคลาสนี้เป็นคลาสที่มีสถานะเปลี่ยนแปลงได้
  @override
  _CreateAccountPage2State createState() => _CreateAccountPage2State(); //ส่วนนี้สำคัญมาก มันทำหน้าที่สร้างและเชื่อมต่อเข้ากับ widget2
}

Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CreateAccountPage2(),
  );
}

DateTime? _selectedDate; // สำหรับเก็บค่าวันที่ผู้ใช้เลือก
int? _age; // สำหรับเก็บค่าอายุที่คำนวณได้

class _CreateAccountPage2State extends State<CreateAccountPage2> {
  //บันทัดนี้ส่ือว่า คำสั่งทั้งหมดที่สั่งจะถูกใช้ได้ในไฟล์นี้เท่านั้น
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? _selectedGender;
  //String ใช้ตัวนี้เพื่อ ปุ่มไหนที่ยังไม่กดจะเป็นปุ่มว่าง
  //selectedGender ใช้เพื่อเก็บค่าที่ผู้ใช้ได้กดเลือกไว้
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ส่วนหัว (โลโก้ + พื้นหลังสี)
              Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 237, 244, 248),
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo2.1.png', // รูปจากเครื่อง
                      width: 150,
                      height: 166,
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // ฟอร์มสมัครสมาชิก
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .stretch, // ✅ ทำให้ข้อความกินพื้นที่เต็มบรรทัด
                  children: [
                    Text(
                      "สร้างบัญชี",
                      textAlign: TextAlign.center, // ✅ จัดข้อความกึ่งกลาง
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    Container(height: 2, width: 150, color: Colors.blue[900]),
                    SizedBox(height: 20),

                    // Address
                    Text("ที่อยู่"),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: 20),

                    // Gender
                    Text("เพศ"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Radio<String>(
                              value: "ชาย",
                              groupValue:
                                  _selectedGender, //selectedGender ใช้เพื่อเก็บค่าที่ผู้ใช้ได้กดเลือกไว้
                              onChanged: (String? value) {
                                // String ใช้ตัวนี้เพื่อ ปุ่มไหนที่ยังไม่กดจะเป็นปุ่มว่าง
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                              activeColor: Colors.blue[900],
                            ),
                            Text("ชาย"),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: "หญิง",
                              groupValue:
                                  _selectedGender, //selectedGender ใช้เพื่อเก็บค่าที่ผู้ใช้ได้กดเลือกไว้
                              onChanged: (String? value) {
                                // String ใช้ตัวนี้เพื่อ ปุ่มไหนที่ยังไม่กดจะเป็นปุ่มว่าง
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                              activeColor: Colors.blue[900],
                            ),
                            Text("หญิง"),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: "LGBTQ+",
                              groupValue:
                                  _selectedGender, //selectedGender ใช้เพื่อเก็บค่าที่ผู้ใช้ได้กดเลือกไว้
                              onChanged: (String? value) {
                                // String ใช้ตัวนี้เพื่อ ปุ่มไหนที่ยังไม่กดจะเป็นปุ่มว่าง
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                              activeColor: Colors.blue[900],
                            ),
                            Text("LGBTQ+"),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),

                    // Date of Birth
                    Text("วัน/เดือน/ปีเกิด"),
                    TextFormField(
                      readOnly: true, // ทำให้ผู้ใช้ไม่สามารถพิมพ์เองได้
                      decoration: InputDecoration(
                        hintText:
                            _selectedDate ==
                                null // หากยังไม่ได้เลือกวัน จะแสดงข้อความ **** **** ****
                            ? "**** **** ****"
                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}", // แสดงวันที่ที่เลือก
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                        ), // เพิ่มไอคอนปฏิทินด้านขวา
                      ),
                      onTap: () async {
                        // เมื่อผู้ใช้แตะที่ช่องนี้ จะแสดงปฏิทินขึ้นมา
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != _selectedDate) {
                          setState(() {
                            _selectedDate = picked;
                            // คำนวณอายุอัตโนมัติเมื่อเลือกวันเกิด
                            _age = DateTime.now().year - _selectedDate!.year;
                            // ตรวจสอบว่าวันเกิดในปีปัจจุบันผ่านไปหรือยัง
                            if (DateTime.now().month < _selectedDate!.month ||
                                (DateTime.now().month == _selectedDate!.month &&
                                    DateTime.now().day < _selectedDate!.day)) {
                              _age = _age! - 1;
                            }
                          });
                        }
                      },
                    ),
                    SizedBox(height: 15),

                    // Age
                    Text("อายุ"),
                    TextFormField(
                      readOnly: true, // ทำให้ผู้ใช้ไม่สามารถพิมพ์เองได้
                      decoration: InputDecoration(
                        hintText:
                            _age ==
                                null // หากยังไม่ได้เลือกวัน จะแสดงข้อความ **** **** ****
                            ? "**** **** ****"
                            : _age.toString(), // แสดงอายุที่คำนวณได้
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),

                    // ปุ่ม สร้างเชื่อมหน้าโฮมกับหน้า2
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.blue[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "สร้าง",
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // ปุ่ม Navigation (Back & Next)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CreateAccountPage1(), // เปลี่ยน YourNextPage() เป็นชื่อ Widget ของหน้าถัดไป
                          ),
                        ); // TODO: Back action
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// logincreate1.dart

import 'package:flutter/material.dart';
import 'package:myproject/logincreate2.dart'; // import หน้า 2 สำหรับปุ่ม Next

// import 'package:myproject/l10n/app_localizations.dart'; // ยกเลิกการคอมเมนต์เมื่อตั้งค่า l10n เสร็จสิ้น

// เปลี่ยนเป็น StatefulWidget เพื่อจัดการข้อมูลที่ผู้ใช้พิมพ์
class CreateAccountPage1 extends StatefulWidget {
  const CreateAccountPage1({Key? key}) : super(key: key);

  @override
  _CreateAccountPage1State createState() => _CreateAccountPage1State();
}

class _CreateAccountPage1State extends State<CreateAccountPage1> {
  // สร้าง Controller สำหรับเก็บข้อมูล
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController =
      TextEditingController(); // เพิ่ม Controller สำหรับ OTP

  @override
  Widget build(BuildContext context) {
    // หากต้องการใช้การแปลภาษาไทยผ่าน l10n ให้ยกเลิกคอมเมนต์บรรทัดนี้
    // final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ส่วนหัว (โลโก้ + พื้นหลังสี)
              Container(
                width: double.infinity,
                // ใช้สีพื้นหลัง
                color: const Color.fromARGB(255, 237, 244, 248),
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    // ตรวจสอบว่ามีไฟล์ 'assets/logo1.png' อยู่จริง
                    Image.asset('assets/logo2.1.png', width: 150, height: 166),
                    const SizedBox(height: 5),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // หัวข้อ สร้างบัญชี
              Text(
                "สร้างบัญชี", // เปลี่ยนเป็นภาษาไทย
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              // ขีดเส้นใต้
              Container(
                height: 2,
                width: 150, // ปรับความกว้างตามภาพด้านซ้าย (ประมาณ)
                color: Colors.blue[900],
                margin: const EdgeInsets.only(
                  top: 5,
                  bottom: 20,
                ), // เพิ่มระยะห่าง
              ),
              // const SizedBox(height: 20), // ไม่ต้องใช้เพราะใช้ margin แทน

              // ชื่อ-นามสกุล
              const Text("ชื่อ-นามสกุล"), // เปลี่ยนเป็นภาษาไทย
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  hintText: "Segun Phillips",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // ปรับรัศมีขอบ
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // อีเมล
              const Text("อีเมล"), // เปลี่ยนเป็นภาษาไทย
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "segunphilips@gmail.com",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // รหัสผ่าน
              const Text("รหัสผ่าน"), // เปลี่ยนเป็นภาษาไทย
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "**** **** ****",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // เบอร์โทร
              const Text("เบอร์โทร"), // เปลี่ยนเป็นภาษาไทย
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "**** **** ****",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // ปุ่ม ส่งรหัส OTP
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Logic สำหรับส่ง OTP
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                        255,
                        253,
                        253,
                        4,
                      ), // สีพื้นหลัง
                      foregroundColor: Colors.black, // สีตัวอักษร
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.grey), // ขอบเทา
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                    ),
                    child: const Text("ส่งรหัส OTP"),
                  ),
                ],
              ),
              const SizedBox(height: 10), // เพิ่มช่องว่าง
              // OTP
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "OTP",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // ปุ่ม ยืนยัน OTP
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Logic สำหรับยืนยัน OTP
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                        255,
                        253,
                        253,
                        4,
                      ), // สีพื้นหลัง
                      foregroundColor: Colors.black, // สีตัวอักษร
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.grey), // ขอบเทา
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                    ),
                    child: const Text("ยืนยัน OTP"),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // ปุ่ม สร้าง
              ElevatedButton(
                onPressed: () {
                  // TODO: เพิ่ม logic การสร้างบัญชี
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF99ABBC),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "สร้าง", // เปลี่ยนเป็นภาษาไทย
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),

              // ปุ่ม Navigation (ลูกศรย้อนกลับ & จุดชี้หน้า & ปุ่มถัดไป)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ลูกศรย้อนกลับ
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      // Navigator.pop(context); // หากต้องการย้อนกลับหน้าเดิม
                    },
                  ),
                  // ปุ่ม ถัดไป
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateAccountPage2(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "ถัดไป", // เปลี่ยนเป็นภาษาไทย
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
}

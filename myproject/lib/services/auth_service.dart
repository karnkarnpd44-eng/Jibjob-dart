import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String? verifyId;

  AuthService() {
    // ปิด SafetyNet/reCAPTCHA บน Emulator เมื่ออยู่ในโหมด Debug เพื่อให้ส่ง OTP ได้อย่างราบรื่น
    if (kDebugMode) {
      _auth.setSettings(appVerificationDisabledForTesting: true);
    }
  }

  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // 1. ฟังก์ชันส่งรหัส OTP (Phone Auth)
  // ---------------------------------------------------------------------------
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
  }) async {
    try {
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-]'), '').trim();
      String formattedPhone = cleanPhone;
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '+66${formattedPhone.substring(1)}';
      } else if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+66$formattedPhone';
      }

      debugPrint(">>> กำลังส่ง OTP ไปที่เบอร์: $formattedPhone");

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint(">>> ตรวจพบ SMS อัตโนมัติ: กำลังล็อกอิน...");
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint(">>> Firebase Error [${e.code}]: ${e.message}");
          onError(e.message ?? e.code);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint(">>> ส่ง OTP สำเร็จ! verificationId คือ: $verificationId");
          verifyId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verifyId = verificationId;
        },
      );
    } catch (e) {
      debugPrint(">>> ข้อผิดพลาดทั่วไป: $e");
      onError(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 2. ฟังก์ชันตรวจสอบรหัส OTP และเข้าสู่ระบบ
  // ---------------------------------------------------------------------------
  Future<UserCredential?> verifyOTP({
    required String smsCode,
    String? verificationId,
  }) async {
    try {
      final String id = verificationId ?? verifyId ?? '';
      debugPrint(">>> ตรวจสอบ OTP ด้วย verificationId: $id | Code: $smsCode");

      if (id.isEmpty) {
        throw Exception('กรุณากดปุ่ม "ขอ OTP" ก่อนกดยืนยันเข้าสู่ระบบ');
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: id,
        smsCode: smsCode.trim(),
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      debugPrint(">>> ยืนยัน OTP สำเร็จ! UID: ${userCredential.user?.uid}");
      return userCredential;
    } catch (e) {
      debugPrint(">>> ยืนยัน OTP ล้มเหลว: $e");
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. ฟังก์ชันเข้าสู่ระบบด้วย อีเมล/เบอร์โทรศัพท์ + รหัสผ่านจริง
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    try {
      final cleanIdentifier = identifier.trim();
      QuerySnapshot query;

      // ตรวจสอบว่าเป็น Email หรือเบอร์โทรศัพท์
      if (cleanIdentifier.contains('@')) {
        query = await _firestore
            .collection('users')
            .where('email', isEqualTo: cleanIdentifier)
            .limit(1)
            .get();
      } else {
        String cleanPhone = cleanIdentifier.replaceAll(RegExp(r'[\s\-]'), '');
        query = await _firestore
            .collection('users')
            .where('phone_number', isEqualTo: cleanPhone)
            .limit(1)
            .get();
      }

      if (query.docs.isEmpty) {
        throw Exception('ไม่พบบัญชีผู้ใช้งานนี้ในระบบ');
      }

      final userData = query.docs.first.data() as Map<String, dynamic>;

      // ตรวจสอบรหัสผ่านที่บันทึกไว้ในฐานข้อมูล
      final storedPassword =
          userData['password'] ?? userData['password_hash'] ?? '';
      if (storedPassword != password.trim()) {
        throw Exception('รหัสผ่านไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง');
      }

      return userData;
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 4. ตรวจสอบว่าเคยมีข้อมูลใน Firestore หรือยัง
  // ---------------------------------------------------------------------------
  Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint(">>> ตรวจสอบ users ล้มเหลว: $e");
      return false;
    }
  }

  // ออกจากระบบ
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

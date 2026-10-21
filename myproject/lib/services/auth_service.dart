import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String? verifyId;

  AuthService() {
    // ปิด SafetyNet/Play Integrity บน Emulator เพื่อให้ใช้เบอร์ทดสอบได้ทันที
    if (kDebugMode) {
      _auth.setSettings(appVerificationDisabledForTesting: true);
    }
  }

  User? get currentUser => _auth.currentUser;

  // ส่ง OTP
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
  }) async {
    try {
      String clean = phoneNumber.replaceAll(RegExp(r'[\s\-]'), '').trim();
      String formatted = clean;
      if (formatted.startsWith('0')) {
        formatted = '+66${formatted.substring(1)}';
      } else if (!formatted.startsWith('+')) {
        formatted = '+66$formatted';
      }

      debugPrint(">>> กำลังส่ง OTP ไปที่เบอร์: $formatted");

      await _auth.verifyPhoneNumber(
        phoneNumber: formatted,
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

  // ตรวจสอบ OTP
  Future<UserCredential?> verifyOTP({
    required String smsCode,
    String? verificationId,
  }) async {
    try {
      final String id = verificationId ?? verifyId ?? '';
      debugPrint(">>> ตรวจสอบ OTP ด้วย verificationId: $id | Code: $smsCode");

      if (id.isEmpty) {
        throw Exception('ไม่พบ verificationId กรุณากดปุ่ม "ขอ OTP" ก่อน');
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: id,
        smsCode: smsCode.trim(),
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      debugPrint(">>> ล็อกอินสำเร็จ! UID: ${userCredential.user?.uid}");
      return userCredential;
    } catch (e) {
      debugPrint(">>> ยืนยัน OTP ล้มเหลว: $e");
      rethrow;
    }
  }

  // ตรวจสอบว่าเคยมีข้อมูลในตาราง users หรือยัง
  Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint(">>> ตรวจสอบ users ล้มเหลว: $e");
      return false;
    }
  }
}

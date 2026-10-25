import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MediaService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // ---------------------------------------------------------------------------
  // ฟังก์ชันพื้นฐาน: ถ่ายรูปจากกล้องสด หรือ เลือกจากคลังภาพ
  // ---------------------------------------------------------------------------
  Future<XFile?> pickOrCaptureImage({required ImageSource source}) async {
    try {
      return await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80, // บีบอัดไฟล์ไม่ให้เกิน 5 MB ตามข้อกำหนดโครงการ
      );
    } catch (e) {
      debugPrint('>>> เกิดข้อผิดพลาดในการเปิดกล้อง/คลังภาพ: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 1. จัดการรูปโปรไฟล์หลัก (Profile Image)
  // ---------------------------------------------------------------------------
  Future<String?> uploadProfileImage({required ImageSource source}) async {
    final XFile? file = await pickOrCaptureImage(source: source);
    if (file == null) return null;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('ผู้ใช้ยังไม่ได้เข้าสู่ระบบ');

    final Uint8List bytes = await file.readAsBytes();
    final String path = 'profile_images/${user.uid}.jpg';

    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final String downloadUrl = await uploadTask.ref.getDownloadURL();

    // บันทึก URL ลงใน Firestore ตาราง users
    await _firestore.collection('users').doc(user.uid).update({
      'profile_image_url': downloadUrl,
      'updated_at': FieldValue.serverTimestamp(),
    });

    return downloadUrl;
  }

  // ---------------------------------------------------------------------------
  // 2. จัดการรูปผลงาน 5 รูป (Portfolios)
  // ---------------------------------------------------------------------------
  Future<String?> uploadPortfolioImage({required ImageSource source}) async {
    final XFile? file = await pickOrCaptureImage(source: source);
    if (file == null) return null;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('ผู้ใช้ยังไม่ได้เข้าสู่ระบบ');

    final Uint8List bytes = await file.readAsBytes();
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String path = 'portfolios/${user.uid}/$fileName';

    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final String downloadUrl = await uploadTask.ref.getDownloadURL();

    // เพิ่ม URL เข้าลิสต์ portfolio_images ใน users collection
    await _firestore.collection('users').doc(user.uid).update({
      'portfolio_images': FieldValue.arrayUnion([downloadUrl]),
      'updated_at': FieldValue.serverTimestamp(),
    });

    return downloadUrl;
  }

  // ลบรูปผลงานออกจาก Storage และ Firestore
  Future<void> deletePortfolioImage(String imageUrl) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'portfolio_images': FieldValue.arrayRemove([imageUrl]),
        'updated_at': FieldValue.serverTimestamp(),
      });

      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('>>> ลบรูปผลงานผิดพลาด: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 3. จัดการรูปภาพในห้องแชต (Chat Attachment) - ถ่ายรูปหรือส่งรูปให้คู่สนทนา
  // ---------------------------------------------------------------------------
  Future<String?> uploadChatImage({
    required String jobId,
    required ImageSource source,
  }) async {
    final XFile? file = await pickOrCaptureImage(source: source);
    if (file == null) return null;

    final Uint8List bytes = await file.readAsBytes();
    final String fileName = 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String path = 'chat_attachments/$jobId/$fileName';

    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  // ---------------------------------------------------------------------------
  // 4. จัดการรูปสลิปหลักฐานการชำระเงิน (Payment Slip)
  // ---------------------------------------------------------------------------
  Future<String?> uploadPaymentSlip({
    required String jobId,
    required ImageSource source,
  }) async {
    final XFile? file = await pickOrCaptureImage(source: source);
    if (file == null) return null;

    final Uint8List bytes = await file.readAsBytes();
    final String fileName = 'slip_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String path = 'payment_slips/$jobId/$fileName';

    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }
}

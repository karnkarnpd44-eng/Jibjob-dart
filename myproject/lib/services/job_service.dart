import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------------------------------------------------------------------
  // 1. ฟังก์ชันสร้างประกาศงานใหม่ (Create Job)
  // ---------------------------------------------------------------------------
  Future<String> createJob({
    required String title,
    required String description,
    required String category,
    required double rewardAmount,
    required String locationName,
    double locationLat = 13.7563, // พิกัดเริ่มต้น (กรุงเทพฯ/พื้นที่ปฏิบัติงาน)
    double locationLng = 100.5018,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('ผู้ใช้ยังไม่ได้เข้าสู่ระบบ');

      // ดึงชื่อของผู้จ้างเพื่อเก็บไปพร้อมกับประกาศงาน
      String employerName = 'ผู้ว่าจ้าง';
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        employerName = userDoc.data()!['full_name'] ?? 'ผู้ว่าจ้าง';
      }

      // สร้าง Document Reference ใหม่ใน 'jobs'
      final jobRef = _firestore.collection('jobs').doc();

      final jobData = {
        'job_id': jobRef.id,
        'employer_id': user.uid,
        'employer_name': employerName,
        'title': title.trim(),
        'description': description.trim(),
        'category': category,
        'reward_amount': rewardAmount,
        'location_name': locationName.trim(),
        'location_lat': locationLat,
        'location_lng': locationLng,
        'radius_match': 5.0, // รัศมีการจับคู่ 5 กิโลเมตรตามข้อกำหนด
        'status':
            'pending', // สถานะ: pending (รอผู้รับจ้าง), accepted, completed, cancelled
        'jobber_id': null,
        'jobber_name': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await jobRef.set(jobData);
      debugPrint('>>> ประกาศงานสำเร็จ รหัสงาน: ${jobRef.id}');
      return jobRef.id;
    } catch (e) {
      debugPrint('>>> เกิดข้อผิดพลาดในการสร้างงาน: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. ดึงรายการงานที่รอคนรับงานทั้งหมด (สำหรับฝั่ง Jobber หน้าแรก)
  // ---------------------------------------------------------------------------
  Stream<QuerySnapshot> getAvailableJobsStream() {
    return _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'pending')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  // ---------------------------------------------------------------------------
  // 3. ดึงรายการงานของผู้ว่าจ้างคนปัจจุบัน (สำหรับหน้า "งานของฉัน")
  // ---------------------------------------------------------------------------
  Stream<QuerySnapshot> getEmployerJobsStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('jobs')
        .where('employer_id', isEqualTo: uid)
        .orderBy('created_at', descending: true)
        .snapshots();
  }
}

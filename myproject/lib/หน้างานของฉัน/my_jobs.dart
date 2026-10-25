// lib/หน้างานของฉัน/my_jobs.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../หน้าหลักjibber/home.dart';
import '../หน้าข้อความ/chat_list.dart';
import '../หน้าแจ้งเตือน/notification_list.dart';
import '../หน้าโปรไฟล์ผู้จ้าง/profile.dart';
import '../หน้าการสร้างงาน/jobber_working.dart';
import '../หน้าการสร้างงาน/jobber_candidates.dart';
import '../หน้าการสร้างงาน/jibber_tracking.dart';

class MyJobsScreen extends StatefulWidget {
  final String? activeJobTitle;
  final String? activeJobDate;
  final String? initialTab; // 'ongoing', 'waiting', 'completed'
  final bool isCancelled;

  const MyJobsScreen({
    Key? key,
    this.activeJobTitle,
    this.activeJobDate,
    this.initialTab = 'waiting',
    this.isCancelled = false,
  }) : super(key: key);

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  late int _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    if (widget.isCancelled || widget.initialTab == 'waiting') {
      _selectedTabIndex = 1; // แท็บ "รอการตอบรับ"
    } else if (widget.initialTab == 'completed') {
      _selectedTabIndex = 2; // แท็บ "สำเร็จแล้ว"
    } else {
      _selectedTabIndex = 0; // แท็บ "กำลังทำอยู่"
    }
  }

  // ฟังก์ชันลบงานจาก Firestore เมื่อปัดการ์ด
  Future<void> _deleteJobFromFirestore(String jobId) async {
    try {
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).delete();
    } catch (e) {
      debugPrint('>>> ลบงานไม่สำเร็จ: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text(
            'งานของฉัน',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildTabSelector(),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: currentUserId != null
                    ? FirebaseFirestore.instance
                          .collection('jobs')
                          .where('employer_id', isEqualTo: currentUserId)
                          .snapshots()
                    : const Stream.empty(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4AC4F3),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'ไม่มีรายการงานในระบบ',
                        style: TextStyle(color: Colors.black45, fontSize: 16),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  // 1. หมวด "กำลังทำอยู่" (รวม working, in_progress)
                  final ongoingDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? '';
                    return status == 'working' || status == 'in_progress';
                  }).toList();

                  // 2. หมวด "รอการตอบรับ"
                  final waitingDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? '';
                    return status == 'pending' ||
                        status == 'accepted' ||
                        status == 'jobber_arrived' ||
                        status == 'cancelled';
                  }).toList();

                  waitingDocs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aStatus = aData['status'] ?? '';
                    final bStatus = bData['status'] ?? '';

                    if (aStatus == 'cancelled' && bStatus != 'cancelled')
                      return 1;
                    if (bStatus == 'cancelled' && aStatus != 'cancelled')
                      return -1;
                    return 0;
                  });

                  // 3. หมวด "สำเร็จแล้ว" (รองรับทั้ง jobber_completed และ completed)
                  final completedDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? '';
                    return status == 'completed' ||
                        status == 'jobber_completed';
                  }).toList();

                  if (_selectedTabIndex == 0) {
                    return _buildJobList(ongoingDocs, tabType: 'ongoing');
                  } else if (_selectedTabIndex == 1) {
                    return _buildJobList(waitingDocs, tabType: 'waiting');
                  } else {
                    return _buildJobList(completedDocs, tabType: 'completed');
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildTabButton(title: 'กำลังทำอยู่', index: 0),
          const SizedBox(width: 8),
          _buildTabButton(title: 'รอการตอบรับ', index: 1),
          const SizedBox(width: 8),
          _buildTabButton(title: 'สำเร็จแล้ว', index: 2),
        ],
      ),
    );
  }

  Widget _buildTabButton({required String title, required int index}) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: SizedBox(
        height: 42,
        child: ElevatedButton(
          onPressed: () => setState(() => _selectedTabIndex = index),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? const Color(0xFF4AC4F3)
                : Colors.white,
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            elevation: 0,
            side: const BorderSide(color: Color(0xFF4AC4F3), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
              color: isSelected ? Colors.black : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobList(
    List<QueryDocumentSnapshot> jobDocs, {
    required String tabType,
  }) {
    if (jobDocs.isEmpty) {
      return const Center(
        child: Text(
          'ไม่มีรายการงานในสถานะนี้',
          style: TextStyle(color: Colors.black45, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: jobDocs.length,
      itemBuilder: (context, index) {
        final doc = jobDocs[index];
        final job = doc.data() as Map<String, dynamic>;
        final String jobId = doc.id;
        final String title = job['title'] ?? 'ไม่มีระบุชื่องาน';
        final String date = job['job_date'] ?? '12/11/2568';
        final String timeRange = job['work_time_range'] ?? '16:30-17:30';
        final double wage = (job['reward_amount'] is num)
            ? (job['reward_amount'] as num).toDouble()
            : 100.0;
        final String status = job['status'] ?? 'pending';
        final List applicantIds = (job['applicant_ids'] as List?) ?? [];

        final bool isCancelled = status == 'cancelled';
        final bool isAccepted =
            status == 'accepted' || status == 'jobber_arrived';
        final bool hasApplicants =
            applicantIds.isNotEmpty && !isAccepted && !isCancelled;

        String displayTitle = title;
        String statusSubtitle = '';

        if (tabType == 'waiting') {
          if (isCancelled) {
            displayTitle = 'คุณยกเลิกงาน "$title" แล้ว';
          } else if (status == 'jobber_arrived') {
            displayTitle = 'Jobber ถึงจุดนัดหมายแล้ว!';
          } else if (isAccepted) {
            displayTitle = 'เลือกผู้รับจ้างแล้ว (รอเริ่มงาน)';
          } else if (hasApplicants) {
            displayTitle =
                'มีคนรับงาน "$title" แล้ว (${applicantIds.length} คน)';
          }
        } else if (tabType == 'completed') {
          if (status == 'jobber_completed') {
            statusSubtitle = 'Jobber ส่งมอบงานแล้ว (รอคุณตรวจสอบ)';
          } else if (status == 'completed') {
            // 💡 ถ้าจ่ายเงินและจบงานแล้ว ให้แสดงคำว่า "เสร็จสิ้น" เป็นสีเขียว
            statusSubtitle = 'เสร็จสิ้น';
          }
        }

        // โครงสร้างการ์ดงาน
        final Widget cardWidget = Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCancelled
                  ? const Color(0xFF4AC4F3)
                  : (hasApplicants ||
                        isAccepted ||
                        status == 'jobber_completed' ||
                        status == 'completed')
                  ? const Color(0xFF8CD837)
                  : const Color(0xFF4AC4F3),
              width: 1.5,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              if (isCancelled) return;

              if (tabType == 'ongoing' || tabType == 'completed') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobberWorkingScreen(
                      jobId: jobId,
                      jobberName: job['jobber_name'] ?? 'สมชาย สายลุย',
                      rating: '4.8',
                      jobTitle: title,
                      jobDate: date,
                      workTimeRange: timeRange,
                      wageAmount: wage,
                      feeAmount: 0.0,
                    ),
                  ),
                );
              } else if (tabType == 'waiting' && isAccepted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobberTrackingScreen(
                      jobId: jobId,
                      jobberName: job['jobber_name'] ?? 'กิตติพงษ์',
                      rating: '4.8',
                      distance: '1.5 กม.',
                      jobTitle: title,
                      jobDate: date,
                      workTimeRange: timeRange,
                      wageAmount: wage,
                      feeAmount: 0.0,
                    ),
                  ),
                );
              } else if (tabType == 'waiting' && hasApplicants) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobberCandidatesScreen(
                      jobId: jobId,
                      jobTitle: title,
                      jobDate: date,
                      workTimeRange: timeRange,
                      wageAmount: wage,
                      feeAmount: 0.0,
                    ),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (statusSubtitle.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                statusSubtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: status == 'completed'
                                      ? const Color(
                                          0xFF2E7D32,
                                        ) // 💡 สีเขียวสำหรับคำว่า "เสร็จสิ้น"
                                      : const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$date   $timeRange',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      if (!isCancelled) ...[
                        if (tabType == 'completed')
                          // 💡 แสดงปุ่มเฉพาะตอนที่ยังไม่ได้กดจบงาน (สถานะ jobber_completed) ถ้าเสร็จแล้ว (completed) จะซ่อนปุ่ม
                          if (status == 'jobber_completed')
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JobberWorkingScreen(
                                      jobId: jobId,
                                      jobberName:
                                          job['jobber_name'] ?? 'สมชาย สายลุย',
                                      rating: '4.8',
                                      jobTitle: title,
                                      jobDate: date,
                                      workTimeRange: timeRange,
                                      wageAmount: wage,
                                      feeAmount: 0.0,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF9A800),
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                minimumSize: const Size(0, 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'ตรวจสอบการจบงาน',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else if (tabType == 'waiting' && isAccepted)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JobberTrackingScreen(
                                      jobId: jobId,
                                      jobberName:
                                          job['jobber_name'] ?? 'กิตติพงษ์',
                                      rating: '4.8',
                                      distance: '1.5 กม.',
                                      jobTitle: title,
                                      jobDate: date,
                                      workTimeRange: timeRange,
                                      wageAmount: wage,
                                      feeAmount: 0.0,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00A3E0),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                minimumSize: const Size(0, 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                status == 'jobber_arrived'
                                    ? 'Jobber ถึงแล้ว'
                                    : 'ติดตาม Jobber',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else if (tabType == 'waiting' && hasApplicants)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        JobberCandidatesScreen(
                                          jobId: jobId,
                                          jobTitle: title,
                                          jobDate: date,
                                          workTimeRange: timeRange,
                                          wageAmount: wage,
                                          feeAmount: 0.0,
                                        ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8CD837),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                minimumSize: const Size(0, 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'ดูผู้สมัคร',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        return Dismissible(
          key: Key(jobId),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.centerRight,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_outline, color: Colors.white, size: 24),
                SizedBox(width: 6),
                Text(
                  'ลบการ์ดนี้',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (direction) {
            _deleteJobFromFirestore(jobId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ลบรายการงานเรียบร้อยแล้ว'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: cardWidget,
        );
      },
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 80,
      color: const Color(0xFF002244),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'หน้าแรก',
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
          _buildNavItem(
            icon: Icons.notifications,
            label: 'แจ้งเตือน',
            hasBadge: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationListScreen(),
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6BB82D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.work, color: Colors.white, size: 26),
                Text(
                  'งานของฉัน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildNavItem(
            icon: Icons.chat,
            label: 'ข้อความ',
            hasBadge: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListScreen()),
              );
            },
          ),
          _buildNavItem(
            icon: Icons.account_circle,
            label: 'โปรไฟล์',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool hasBadge = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              if (hasBadge)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../หน้าการรับงาน/jobber_home.dart';
import '../หน้าข้อความ/jobber_messages.dart';
import '../หน้าโปรไฟล์ผู้รับจ้าง/jobber_profile.dart';
import '../หน้าการรับงาน/jobber_tracking.dart';
import '../หน้าการรับงาน/jobber_in_progress.dart';

class JobberMyJobsScreen extends StatefulWidget {
  final int initialIndex;

  const JobberMyJobsScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<JobberMyJobsScreen> createState() => _JobberMyJobsScreenState();
}

class _JobberMyJobsScreenState extends State<JobberMyJobsScreen> {
  late int _selectedTabIndex;
  final Color _activeTabColor = const Color.fromARGB(255, 93, 183, 184);
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialIndex == 1
        ? 0
        : (widget.initialIndex > 1 ? 1 : widget.initialIndex);
  }

  void _showJobDetailsBottomSheet(Map<String, dynamic> jobData, String wage) {
    final title = jobData['title'] ?? 'งานบริการ';
    final date = jobData['job_date'] ?? jobData['date'] ?? 'วันนี้';
    final location =
        jobData['address'] ?? jobData['location'] ?? 'พื้นที่ใกล้เคียง';
    final timeRange =
        jobData['work_time_range'] ?? jobData['timeRange'] ?? 'ตามตกลง';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'รายละเอียดงาน',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('งาน', ': $title'),
                    const SizedBox(height: 8),
                    _buildDetailRow('วันที่', ': $date'),
                    const SizedBox(height: 8),
                    _buildDetailRow('สถานที่', ': $location'),
                    const SizedBox(height: 8),
                    _buildDetailRow('ช่วงเวลาทำงาน', ': $timeRange'),
                    const SizedBox(height: 8),
                    _buildDetailRow('ค่าจ้าง', ': $wage บาท'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AEEF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'ปิด',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13.5, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Text(
                'งานของฉัน',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildTabButton(index: 0, label: 'กำลังทำอยู่'),
                  const SizedBox(width: 8),
                  _buildTabButton(index: 1, label: 'สำเร็จแล้ว'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: currentUserId == null
                  ? const Center(child: Text('กรุณาเข้าสู่ระบบก่อนใช้งาน'))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('jobs')
                          .where('jobber_id', isEqualTo: currentUserId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF00AEEF),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildEmptyView();
                        }

                        final docs = snapshot.data!.docs;

                        final ongoingDocs = docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final status = data['status'] ?? '';
                          return status == 'accepted' ||
                              status == 'jobber_arrived' ||
                              status == 'working';
                        }).toList();

                        final completedDocs = docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final status = data['status'] ?? '';
                          return status == 'completed' ||
                              status == 'jobber_completed' ||
                              status == 'success' ||
                              status == 'finished';
                        }).toList();

                        List<QueryDocumentSnapshot> currentList;
                        if (_selectedTabIndex == 0) {
                          currentList = ongoingDocs;
                        } else {
                          currentList = completedDocs;
                        }

                        if (currentList.isEmpty) {
                          return _buildEmptyView();
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: currentList.length,
                          itemBuilder: (context, index) {
                            final doc = currentList[index];
                            final jobData = doc.data() as Map<String, dynamic>;
                            final jobId = doc.id;
                            final title = jobData['title'] ?? 'งานบริการ';
                            final wage =
                                jobData['reward_amount']?.toString() ?? '100';
                            final status = jobData['status'] ?? '';

                            String statusText = 'ถึงจุดนัดหมายแล้ว';
                            Color statusColor = Colors.orange;

                            if (_selectedTabIndex == 1 ||
                                status == 'completed' ||
                                status == 'jobber_completed') {
                              statusText = 'เสร็จสิ้น';
                              statusColor = Colors.green;
                            } else if (status == 'working') {
                              statusText = 'ผู้จ้างอนุมัติเริ่มงานแล้ว';
                              statusColor = Colors.green;
                            } else if (status == 'accepted') {
                              statusText = 'คุณถูกเลือกให้รับงานแล้ว!';
                              statusColor = Colors.orange;
                            }

                            final cardWidget = Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF86D5F2),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        statusText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'ค่าจ้าง: $wage ฿',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (_selectedTabIndex == 0) ...[
                                        if (status == 'working') ...[
                                          ElevatedButton(
                                            onPressed: () =>
                                                _showJobDetailsBottomSheet(
                                                  jobData,
                                                  wage,
                                                ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              elevation: 0,
                                              minimumSize: const Size(0, 32),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'รายละเอียดงาน',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => JobberInProgressScreen(
                                                    job: {
                                                      'id': jobId,
                                                      'title': title,
                                                      'date':
                                                          jobData['job_date'] ??
                                                          'วันนี้',
                                                      'timeRange':
                                                          jobData['work_time_range'] ??
                                                          'ตามตกลง',
                                                      'wageDetail': '$wage บาท',
                                                      'location':
                                                          jobData['address'] ??
                                                          jobData['location'] ??
                                                          '-',
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF00AEEF,
                                              ),
                                              elevation: 0,
                                              minimumSize: const Size(0, 32),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'สถานะงาน',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ] else ...[
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => JobberTrackingScreen(
                                                    job: {
                                                      'id': jobId,
                                                      'title': title,
                                                      'date':
                                                          jobData['job_date'] ??
                                                          'วันนี้',
                                                      'timeRange':
                                                          jobData['work_time_range'] ??
                                                          'ตามตกลง',
                                                      'wageDetail': '$wage บาท',
                                                      'location':
                                                          jobData['address'] ??
                                                          jobData['location'] ??
                                                          '-',
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF00AEEF,
                                              ),
                                              elevation: 0,
                                              minimumSize: const Size(0, 32),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'ไปหน้าติดตามงาน',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            );

                            return Dismissible(
                              key: Key(jobId),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.centerRight,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
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
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('ลบการ์ดเรียบร้อยแล้ว'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: cardWidget,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flutter_dash, size: 85, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'ยังไม่มีงานเลย..',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({required int index, required String label}) {
    final bool isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? _activeTabColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? _activeTabColor : Colors.grey.shade300,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 80,
      color: const Color(0xFF00AEEF),
      padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'หน้าแรก',
              isSelected: false,
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JobberHomeScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
            _buildNavItem(
              icon: Icons.work,
              label: 'งานของฉัน',
              isSelected: true,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.chat,
              label: 'ข้อความ',
              isSelected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JobberMessagesScreen(),
                  ),
                );
              },
            ),
            _buildNavItem(
              icon: Icons.account_circle,
              label: 'โปรไฟล์',
              isSelected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JobberProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 71,
        height: 55,
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFF8DC63F),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

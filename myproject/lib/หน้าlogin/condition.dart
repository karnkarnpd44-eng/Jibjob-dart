import 'package:flutter/material.dart';
// นำเข้าไฟล์หน้าสมัครสมาชิก (ตรวจสอบ path ให้ตรงกับที่ตั้งไฟล์ RegisterScreen ของคุณ)
import 'logincreate1.dart';

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  bool _hasReadToBottom = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'ข้อกำหนดและเงื่อนไข',
          style: TextStyle(
            color: Color(0xFF0F4C81),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                // เมื่อเลื่อนถึงช่วง 40px ก่อนล่างสุด ให้ปลดล็อกปุ่มยอมรับ
                if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 40) {
                  if (!_hasReadToBottom) {
                    setState(() {
                      _hasReadToBottom = true;
                    });
                  }
                }
                return true;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // การ์ดหัวข้อหลัก
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF6FB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00AEEF).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                color: Color(0xFF0F4C81),
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'ข้อตกลงการใช้บริการ JibJob',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F4C81),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'เอกสารฉบับนี้เป็นเงื่อนไขการใช้บริการของแอปพลิเคชัน JibJob ซึ่งเป็นแพลตฟอร์มตัวกลางสำหรับเชื่อมต่อระหว่างผู้ว่าจ้าง (Jibber) และผู้รับจ้าง (Jobber) โปรดเลื่อนอ่านข้อกำหนดจนสิ้นสุดเพื่อดำเนินการต่อ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader('1. คำจำกัดความ'),
                    _buildSectionBody(
                      '• แอปพลิเคชัน: แอป JibJob รวมถึงระบบเว็บไซต์ หรือบริการที่เกี่ยวข้อง\n'
                      '• Jibber: ผู้ที่ประกาศจ้างงานผ่านระบบแอปพลิเคชัน\n'
                      '• Jobber: ผู้ที่รับงานจาก Jibber ผ่านระบบแอปพลิเคชัน\n'
                      '• งาน: ภารกิจหรือบริการที่ Jibber และ Jobber ตกลงร่วมกันผ่านแอป',
                    ),

                    _buildSectionHeader('2. ลักษณะของบริการ'),
                    _buildSectionBody(
                      'JibJob ทำหน้าที่เป็น "แพลตฟอร์มตัวกลาง" สำหรับประกาศงาน การค้นหา การสื่อสาร และการจัดการสถานะงานเท่านั้น JibJob ไม่ใช่นายจ้าง ไม่ใช่ลูกจ้าง และไม่เป็นคู่สัญญาโดยตรงระหว่างผู้ใช้ การตกลงจ้างงาน เงื่อนไข ค่าตอบแทน เป็นความรับผิดชอบร่วมกันของทั้งสองฝ่าย',
                    ),

                    _buildSectionHeader('3. ข้อตกลงทั่วไป'),
                    _buildSectionBody(
                      'เงื่อนไขและข้อตกลงฉบับนี้มีผลบังคับใช้ระหว่างท่านกับผู้พัฒนาตลอดระยะเวลาการใช้งานแพลตฟอร์ม เมื่อท่านยอมรับข้อตกลง ถือว่าท่านยอมรับที่จะปฏิบัติตามกฎระเบียบและนโยบายความเป็นส่วนตัว หากพบการกระทำที่ฝ่าฝืนกฎหมายหรือขัดต่อศีลธรรมอันดี ทางระบบขอสงวนสิทธิ์ในการระงับการให้บริการทันที',
                    ),

                    _buildSectionHeader('4. การสมัครและบัญชีผู้ใช้'),
                    _buildSectionBody(
                      '• ผู้สมัครใช้งานจะต้องเป็นบุคคลที่มีอายุครบ 20 ปีบริบูรณ์ขึ้นไป\n'
                      '• ผู้ใช้ต้องให้ข้อมูลที่เป็นความจริง ถูกต้อง และเป็นปัจจุบัน\n'
                      '• ผู้ใช้ต้องรับผิดชอบต่อความปลอดภัยและการใช้งานบัญชีของตนเองทั้งหมด\n'
                      '• ข้อมูลจากบัตรประจำตัวประชาชนจะใช้เพื่อวัตถุประสงค์ในการยืนยันอายุและความปลอดภัยของชุมชนผู้ใช้งานเท่านั้น\n'
                      '• ระบบขอสงวนสิทธิ์ในการระงับบัญชีทันทีหากตรวจพบข้อมูลเท็จหรือการทุจริต',
                    ),

                    _buildSectionHeader('5. การประกาศงานและการรับงาน'),
                    _buildSectionBody(
                      '• Jibber ต้องระบุรายละเอียดงานให้ครบถ้วน ชัดเจน ตรงตามความเป็นจริง\n'
                      '• งานที่ประกาศต้องไม่ขัดต่อกฎหมายและศีลธรรมอันดี\n'
                      '• Jobber มีสิทธิ์พิจารณาเลือกรับงานตามความสมัครใจและความถนัด\n'
                      '• สำหรับงานในพื้นที่ส่วนตัว ระบบจะมีข้อความแจ้งเตือนความเสี่ยง (Risk Warning) โดย Jobber ต้องกดยอมรับความเสี่ยงก่อนยืนยันรับงาน\n'
                      '• ความสัมพันธ์ระหว่างผู้ใช้เป็นสัญญาบริการอิสระ ไม่ก่อให้เกิดสถานะลูกจ้างตามกฎหมายแรงงาน',
                    ),

                    _buildSectionHeader('6. การติดต่อระหว่างผู้ใช้'),
                    _buildSectionBody(
                      '1. จัดให้มีระบบห้องแชทภายในแอปเพื่ออำนวยความสะดวกในการติดต่อ\n'
                      '2. ผู้ใช้ตกลงสื่อสารด้วยถ้อยคำสุภาพ ไม่ข่มขู่ คุกคาม หรือสร้างความเดือดร้อน\n'
                      '3. ห้ามใช้ช่องทางสื่อสารเพื่อหลอกลวง ชักชวนทำกิจกรรมผิดกฎหมาย\n'
                      '4. การแลกเปลี่ยนข้อมูลส่วนบุคคลภายนอกระบบ เป็นความรับผิดชอบและความสมัครใจของผู้ใช้เอง',
                    ),

                    _buildSectionHeader('7. ค่าจ้างและการชำระเงิน'),
                    _buildSectionBody(
                      '• อัตราค่าจ้างเป็นการตกลงร่วมกันโดยตรงระหว่าง Jibber และ Jobber\n'
                      '• การชำระเงินเป็นการจ่ายโดยตรงระหว่างผู้ใช้ (เงินสด หรือ โอนบัญชีส่วนบุคคล) เงินค่าจ้างไม่ผ่านระบบตัวกลางของ JibJob\n'
                      '• หากเกิดข้อพิพาทเรื่องการจ่ายเงินไม่ครบ ล่าช้า หรือไม่ชำระเงิน ผู้ใช้ต้องดำเนินการเจรจาแก้ไขร่วมกันโดยตรง',
                    ),

                    _buildSectionHeader('8. การยกเลิกงานและการรายงาน (Report)'),
                    _buildSectionBody(
                      '1. สามารถยกเลิกงานได้ก่อนเริ่มงานตามขั้นตอนของระบบพร้อมระบุเหตุผล\n'
                      '2. กรณีเกิดปัญหา การโกง หรือทิ้งงาน ผู้ใช้สามารถกดปุ่ม "รายงานปัญหา (Report)" พร้อมแนบหลักฐานเพื่อให้ทีมงานตรวจสอบ\n'
                      '3. ระบบจะบันทึกประวัติพฤติกรรมเพื่อใช้ประเมินความน่าเชื่อถือ และอาจระงับบัญชีผู้กระทำผิดถาวร',
                    ),

                    _buildSectionHeader('9. ความปลอดภัยและระบบเซ็นเซอร์'),
                    _buildSectionBody(
                      '• ติดตามตำแหน่ง GPS เฉพาะช่วงที่สถานะงานดำเนินอยู่เท่านั้น เพื่อรักษาความเป็นส่วนตัว\n'
                      '• ระบบตรวจจับเหตุฉุกเฉินผ่านเซ็นเซอร์แรงกระแทก หากเกิดเหตุผิดปกติจะแจ้งเตือนและส่งพิกัดช่วยเหลือตามขั้นตอน\n'
                      '• มีระบบแจ้งเตือนความเสี่ยงสำหรับงานในสถานที่ส่วนบุคคล',
                    ),

                    _buildSectionHeader(
                      '10. นโยบายคุ้มครองข้อมูลส่วนบุคคล (PDPA)',
                    ),
                    _buildSectionBody(
                      'JibJob ให้ความสำคัญต่อการรักษาความปลอดภัยของข้อมูลส่วนบุคคลตาม พ.ร.บ. คุ้มครองข้อมูลส่วนบุคคล พ.ศ. 2562 (PDPA) ข้อมูลของท่านจะถูกจัดเก็บอย่างปลอดภัยและใช้เพื่อการยืนยันตัวตนและการให้บริการเท่านั้น จะไม่มีการเปิดเผยต่อบุคคลภายนอกโดยปราศจากความยินยอม',
                    ),

                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.grey.shade400,
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '--- สิ้นสุดข้อกำหนดการใช้บริการ ---',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // แถบปุ่มล่างสุด (จะปลดล็อกเมื่อเลื่อนจนสุด หรือแสดงคำแนะนำให้อ่านต่อ)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: _hasReadToBottom
                  ? Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF0F4C81),
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'ไม่ยอมรับ',
                                style: TextStyle(
                                  color: Color(0xFF0F4C81),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
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
                              onPressed: () {
                                // เชื่อมต่อไปยังหน้าสร้างบัญชี (RegisterScreen)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F4C81),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'ยอมรับ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // ช่วยเลื่อนหน้าจอลงไปล่างสุดทันที
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_downward_rounded,
                          size: 18,
                          color: Colors.grey,
                        ),
                        label: const Text(
                          'โปรดเลื่อนลงเพื่ออ่านเงื่อนไขให้ครบถ้วน',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 6.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F4C81),
        ),
      ),
    );
  }

  Widget _buildSectionBody(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 13.5,
          color: Colors.blueGrey.shade800,
          height: 1.5,
        ),
      ),
    );
  }
}

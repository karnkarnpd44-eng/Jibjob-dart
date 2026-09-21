import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  // ===========================================================================
  // [BACKEND HOOKS]
  // รับข้อมูลคู่สนทนาจริงมาจากหน้าที่เรียก เพื่อความต่อเนื่องของข้อมูล
  // ในอนาคตสามารถเพิ่ม: final String chatId; final String currentUserId;
  // ===========================================================================
  final String jobberName;

  const ChatRoomScreen({Key? key, required this.jobberName}) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ===========================================================================
  // [MOCKUP DATA - พร้อมแทนที่ด้วย Firestore StreamBuilder ในอนาคต]
  // โครงสร้างตรงตามคอลเลกชัน Chats: sender, text, timestamp, type
  // ===========================================================================
  final List<Map<String, dynamic>> _messages = [
    {'sender': 'jobber', 'text': 'กำลังไปครับ!', 'time': '16:35'},
  ];

  // ฟังก์ชันจำลองการส่งข้อความ
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'user', // ผู้ว่าจ้าง (Jibber) เป็นคนส่ง
        'text': text,
        'time': '16:36',
      });
    });

    _messageController.clear();

    // เลื่อนหน้าจอลงล่างสุดอัตโนมัติเมื่อมีข้อความใหม่
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // ===========================================================================
    // [TODO: FUTURE BACKEND]
    // FirebaseFirestore.instance.collection('chats').doc(widget.chatId)
    //   .collection('messages').add({
    //     'sender_id': currentUserId,
    //     'text': text,
    //     'created_at': FieldValue.serverTimestamp(),
    //   });
    // ===========================================================================
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, color: Colors.grey, size: 24),
            ),
            const SizedBox(width: 10),
            Text(
              widget
                  .jobberName, // 💡 แสดงชื่อ Jobber ที่ส่งมาจากหน้าที่แล้วจริง
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // พื้นที่แสดงประวัติข้อความแชท
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final bool isUser = msg['sender'] == 'user';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              // ฝั่ง Jobber เป็นสีกรมท่าเข้มตามภาพ Mockup, ฝั่งผู้ใช้เป็นสีฟ้าอ่อน
                              color: isUser
                                  ? const Color(0xFF4AC4F3)
                                  : const Color(0xFF022B52),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg['text'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // แถบกรอกข้อความและปุ่มถ่ายรูปด้านล่าง
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.black54, width: 1.2),
                ),
                child: Row(
                  children: [
                    // ปุ่มรูปกล้อง (เตรียมไว้ต่อ Image Picker / Firebase Storage)
                    IconButton(
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        size: 26,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('เปิดกล้อง/คลังภาพสำหรับส่งรูป...'),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'ส่งข้อความ',
                          hintStyle: TextStyle(
                            color: Colors.black38,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 6),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    // ปุ่มไอคอนส่งข้อความสีดำ
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.black87,
                        size: 24,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

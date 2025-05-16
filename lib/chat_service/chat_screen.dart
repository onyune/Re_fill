import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isOwner = false;
  List<String> _members = []; //전체 참여자 UID 목록
  String? _selectedUid; // 선택된 UID
  String? _ownerId;
  String? _menagerId;

  @override
  void initState(){
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("포그라운드 메시지 수신: ${message.notification?.title}");
    });

    _checkIfOwner();
    _loadMembers();

  }
  void _checkIfOwner() async{
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance.collection('chatRooms').doc('defaultRoom').get();
    final ownerId = doc['ownerId'];
    final managerId = doc['managerId']; // 부방장 가져오기
    setState(() {
      _isOwner = user?.uid == ownerId;
      _ownerId = ownerId;
      _menagerId = managerId;
    });
  }
  String _getUserRole(String uid){
    if (uid == _ownerId) return"[점주]";
    if (uid == _menagerId) return"[매니저]";
    return "[직원]";
  }
  Future<void> _loadMembers()async{
    final doc = await FirebaseFirestore.instance.collection('chatRooms').doc('defaultRoom').get();

    final List<dynamic> members = doc['members'];
    setState(() {
      _members = members.cast<String>();
    });
    }


  Future<void> _assignManager(String selectedUid) async{
    await FirebaseFirestore.instance.collection('chatRooms').doc('defaultRoom').update({'managerId' : selectedUid});
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc('defaultRoom')
        .collection('messages')
        .add({'senderId': user.uid, 'text': text, 'timestamp': FieldValue.serverTimestamp()});

    _messageController.clear();

  }

  @override
  Widget build(BuildContext context) {
    const mainBlue = Color(0xFF2563EB);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '채팅',
          style: TextStyle(
            color: Color(0xFF2563EB), // mainBlue 직접 넣기
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent, // 파란색 띠 제거
        elevation: 0, // 그림자 제거
        centerTitle: false, // 왼쪽 정렬
        iconTheme: const IconThemeData(color: Color(0xFF2563EB)), // 아이콘도 파란색
      ),
      body: Column(
        children: [
          // 점주만 볼 수 있는 부방장 지정 버튼
          if (_isOwner)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedUid,
                      hint: const Text("부방장 선택"),
                      isExpanded: true,
                      items: _members.map((uid) {
                        return DropdownMenuItem<String>(
                          value: uid,
                          child: Text(uid),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUid = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _selectedUid == null
                        ? null
                        : () {
                      _assignManager(_selectedUid!);
                    },
                    child: const Text("지정"),
                  ),
                ],
              ),
            ),


          // 채팅 메시지 출력 영역
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatRooms')
                  .doc('defaultRoom')
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      '아직 메시지가 없습니다.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;
                final currentUser = FirebaseAuth.instance.currentUser;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final message = messageData['text'] ?? '';
                    final senderId = messageData['senderId'];
                    final isMe = currentUser?.uid == senderId;
                    final roleTag = _getUserRole(senderId);

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? mainBlue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "$roleTag $message" ,

                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          // 입력창
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: mainBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

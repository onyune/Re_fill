import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
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
  List<String> _members = [];
  String? _ownerId;
  String? _storeId;

  // 🔹 사용자 정보 캐시: uid -> {'name': 전유진, 'role': owner}
  Map<String, Map<String, dynamic>> _userInfoCache = {};

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("포그라운드 메시지 수신: ${message.notification?.title}");
    });

    _loadUserStoreId();
  }

  void _loadUserStoreId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];

    setState(() {
      _storeId = storeId;
    });

    _loadChatRoomInfo(storeId);
    _loadMembers(storeId);
  }

  Future<void> _loadChatRoomInfo(String storeId) async {
    final doc = await FirebaseFirestore.instance.collection('chatRooms').doc(storeId).get();
    final ownerId = doc['ownerId'];

    setState(() {
      _ownerId = ownerId;
    });
  }

  Future<void> _loadMembers(String storeId) async {
    final doc = await FirebaseFirestore.instance.collection('chatRooms').doc(storeId).get();
    final List<dynamic> members = doc['members'];
    setState(() {
      _members = members.cast<String>();
    });

    for (final uid in members) {
      await _loadUserInfo(uid);
    }
  }

  Future<void> _loadUserInfo(String uid) async {
    if (_userInfoCache.containsKey(uid)) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _userInfoCache[uid] = {
        'name': data['name'] ?? '알 수 없음',
        'role': data['role'] ?? 'staff',
      };
      setState(() {});
    }
  }
  // 채팅창 이름별 이모지
  String _getRoleEmoji(String role) {
    if (role == 'owner') return '⭐ ';
    return '';
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _storeId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(_storeId!)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    const mainBlue = AppColors.primary;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (_storeId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '채팅',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Column(
        children: [
          // 🔽 채팅 메시지 리스트
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatRooms')
                  .doc(_storeId!)
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
                      style: TextStyle(fontSize: 16, color: AppColors.borderDefault),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final senderId = messageData['senderId'];
                    final message = messageData['text'] ?? '';
                    final isMe = currentUser?.uid == senderId;

                    _loadUserInfo(senderId); // 캐시 없으면 불러오기

                    final userInfo = _userInfoCache[senderId];
                    final name = userInfo?['name'] ?? '...';
                    final role = userInfo?['role'] ?? 'staff';
                    final displayName = "${_getRoleEmoji(role)} $name";

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? mainBlue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              message,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          // 🔽 메시지 입력창
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
                      fillColor: AppColors.background,
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

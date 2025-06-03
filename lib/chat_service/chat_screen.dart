// 매장별 실시간 채팅 화면 (메시지 전송, 읽음 처리, 유저 정보 표시)

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

  String _getRoleEmoji(String role) {
    switch (role) {
      case 'owner':
        return '⭐ '; // 점주 - 별모양
      case 'manager':
        return '💡 '; // 매니저 - 전구모양
      default:
        return '';    // 직원 - 없음
    }
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
      'readBy': [user.uid],
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
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Column(
        children: [
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

                    _loadUserInfo(senderId);

                    final Map<String, dynamic> data = messageData.data() as Map<String, dynamic>;
                    final List<String> readBy =
                    (data.containsKey('readBy') && data['readBy'] is List)
                        ? List<String>.from(data['readBy'])
                        : [];

                    if (!readBy.contains(currentUser?.uid)) {
                      messageData.reference.update({
                        'readBy': FieldValue.arrayUnion([currentUser!.uid])
                      });
                    }

                    final userInfo = _userInfoCache[senderId];
                    final name = userInfo?['name'] ?? '...';
                    final role = userInfo?['role'] ?? 'staff';
                    final displayName = "${_getRoleEmoji(role)}$name";

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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (isMe)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    readBy.length >= _members.length
                                        ? '✔ 모두 읽음'
                                        : '✔ ${readBy.length}/${_members.length}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                constraints: const BoxConstraints(maxWidth: 250), // ✅ 최대 너비 제한
                                decoration: BoxDecoration(
                                  color: isMe ? mainBlue : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  message,
                                  softWrap: true,            // ✅ 줄바꿈 허용
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ],
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

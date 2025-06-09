import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'ChatMessageWidget.dart'; // 분리된 메시지 위젯 import

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
  bool _isNoticeExpanded = false;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("포그라운드 메시지 수신: \${message.notification?.title}");
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

  Stream<List<Map<String, dynamic>>> _noticeStream() {
    return FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(_storeId!)
        .collection('notice')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return {
        ...doc.data(),
        'id': doc.id,
      };
    }).toList());
  }

  Future<void> _registerNotice(String message, String senderId) async {
    if (_storeId == null) return;

    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(_storeId!)
        .collection('notice')
        .add({
      'text': message,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteNotice(String noticeId) async {
    if (_storeId == null) return;

    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(_storeId!)
        .collection('notice')
        .doc(noticeId)
        .delete();
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
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _noticeStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
              final notices = snapshot.data!;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _isNoticeExpanded = !_isNoticeExpanded;
                  });
                },
                child: Container(
                  width: double.infinity,
                  color: Colors.yellow[100],
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '📢 공지사항',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _isNoticeExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 18,
                          ),
                        ],
                      ),
                      if (_isNoticeExpanded)
                        ...notices.map((notice) {

                          return GestureDetector(
                            onLongPress: () {
                              final myRole = _userInfoCache[currentUser?.uid]?['role'];
                              if (myRole == 'owner' || myRole == 'manager') {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("공지 삭제"),
                                    content: const Text("해당 공지를 삭제하시겠습니까?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("취소"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteNotice(notice['id']);
                                        },
                                        child: const Text("삭제"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text("• ${notice['text']}")
                              ,
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatRooms')
                  .doc(_storeId!)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final senderId = messageData['senderId'];
                    _loadUserInfo(senderId); // user info 캐싱

                    return ChatMessageWidget(
                      messageData: messageData,
                      currentUserId: currentUser!.uid,
                      userInfoCache: _userInfoCache,
                      totalMembers: _members.length,
                      storeId: _storeId!,
                      onRegisterNotice: _registerNotice,
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

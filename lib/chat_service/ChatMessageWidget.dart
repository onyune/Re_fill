// chat_message_widget.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../colors.dart';

class ChatMessageWidget extends StatelessWidget {
  final DocumentSnapshot messageData;
  final String currentUserId;
  final Map<String, Map<String, dynamic>> userInfoCache;
  final int totalMembers;
  final String storeId;
  final Function(String message, String senderId) onRegisterNotice;

  const ChatMessageWidget({
    super.key,
    required this.messageData,
    required this.currentUserId,
    required this.userInfoCache,
    required this.totalMembers,
    required this.storeId,
    required this.onRegisterNotice,
  });

  String _getRoleEmoji(String role) {
    switch (role) {
      case 'owner':
        return '⭐ ';
      case 'manager':
        return '💡 ';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final senderId = messageData['senderId'];
    final message = messageData['text'] ?? '';
    final isMe = currentUserId == senderId;

    final Map<String, dynamic> data = messageData.data() as Map<String, dynamic>;
    final List<String> readBy =
    (data.containsKey('readBy') && data['readBy'] is List)
        ? List<String>.from(data['readBy'])
        : [];

    // 읽음 처리
    if (!readBy.contains(currentUserId)) {
      messageData.reference.update({
        'readBy': FieldValue.arrayUnion([currentUserId])
      });
    }

    final userInfo = userInfoCache[senderId];
    final name = userInfo?['name'] ?? '...';
    final role = userInfo?['role'] ?? 'staff';
    final displayName = "${_getRoleEmoji(role)}$name";

    return GestureDetector(
      onLongPress: () {
        final myRole = userInfoCache[currentUserId]?['role'];
        if (myRole == 'owner' || myRole == 'manager') {
          showModalBottomSheet(
            context: context,
            builder: (_) => ListTile(
              leading: const Icon(Icons.announcement),
              title: const Text("공지로 등록"),
              onTap: () {
                Navigator.pop(context);
                onRegisterNotice(message, senderId);
              },
            ),
          );
        }
      },
      child: Align(
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
                      readBy.length >= totalMembers
                          ? '✔ 모두 읽음'
                          : '✔ ${readBy.length}/$totalMembers',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  constraints: const BoxConstraints(maxWidth: 250),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message,
                    softWrap: true,
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
      ),
    );
  }
}

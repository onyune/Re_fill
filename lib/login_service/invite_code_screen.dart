import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:refill/colors.dart';
import 'package:refill/main_navigation.dart';

class InviteCodeScreen extends StatefulWidget {
  const InviteCodeScreen({super.key});

  @override
  State<InviteCodeScreen> createState() => _InviteCodeScreenState();
}

class _InviteCodeScreenState extends State<InviteCodeScreen> {
  final inviteCodeController = TextEditingController();

  @override
  void dispose() {
    inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinStore() async {
    //final inputCode = inviteCodeController.text.trim();               // 대소문자 구분 O
    final inputCode = inviteCodeController.text.trim().toUpperCase();   // 대소문자 구분 X

    if (inputCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 코드를 입력해주세요.')),
      );
      return;
    }

    try {
      final storeQuery = await FirebaseFirestore.instance
          .collection('stores')
          .where('inviteCode', isEqualTo: inputCode)
          .limit(1)
          .get();

      if (storeQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('유효한 초대 코드가 아닙니다.')),
        );
        return;
      }

      final storeDoc = storeQuery.docs.first;
      final storeId = storeDoc.id;
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) return;

      // Firestore에 사용자 정보 업데이트
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'role': 'staff',
        'storeId': storeId,
      }, SetOptions(merge: true));

      // 🔥 chatRooms에도 사용자 추가
      await FirebaseFirestore.instance.collection('chatRooms').doc(storeId).update({
        'members': FieldValue.arrayUnion([userId]),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } catch (e) {
      print('초대코드 처리 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지점 등록 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Re:fill',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '초대 코드 입력',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '초대 코드 입력',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: inviteCodeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: '초대 코드를 입력하세요.',
                hintStyle: const TextStyle(color: AppColors.borderDefault),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _joinStore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '매장 가입하기',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.background,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

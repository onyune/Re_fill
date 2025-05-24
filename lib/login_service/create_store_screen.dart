import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import '../main_navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateStoreScreen extends StatelessWidget {
  const CreateStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefixController = TextEditingController(); // 앞부분
    final suffixController = TextEditingController(); // 뒷부분
    final addressController = TextEditingController(); // 주소

    return Scaffold(
      appBar: AppBar(
        title: const Text('새로운 매장 생성'),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.black,
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: prefixController,
                      decoration: const InputDecoration(labelText: '앞 단어 (예: 서울대)'),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('커피'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: suffixController,
                      decoration: const InputDecoration(labelText: '뒤 단어 (예: 정문점)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: '주소'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final prefix = prefixController.text.trim();
                  final suffix = suffixController.text.trim();
                  final address = addressController.text.trim();
                  final uid = FirebaseAuth.instance.currentUser?.uid;

                  if (prefix.isEmpty || suffix.isEmpty || address.isEmpty || uid == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("모든 항목을 입력해주세요.")),
                    );
                    return;
                  }

                  final fullStoreName = '$prefix 커피 $suffix 점';

                  final storeRef = await FirebaseFirestore.instance.collection('stores').add({
                    'storeName': fullStoreName,
                    'storeNamePrefix': prefix,
                    'storeNameSuffix': suffix,
                    'address': address,
                    'ownerUid': uid,
                    'createdAt': Timestamp.now(),
                    'members': [],
                    'storeType': '카페',
                  });
                  // 🔥 chatRooms도 같이 생성
                  await FirebaseFirestore.instance.collection('chatRooms').doc(storeRef.id).set({
                    'storeId': storeRef.id,
                    'ownerId': uid,
                    'managerId': null,
                    'members': [uid], // 채팅 멤버 목록에도 추가
                  });
                  await FirebaseFirestore.instance.collection('users').doc(uid).update({
                    'storeId': storeRef.id,
                    'role': 'owner',
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainNavigation()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('생성', style: TextStyle(color: AppColors.background)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

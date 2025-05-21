import 'package:flutter/material.dart';

import 'package:refill/colors.dart';
import '../main_navigation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CreateStoreScreen extends StatelessWidget {
  const CreateStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storeNameController = TextEditingController();
    final addressController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('새로운 매장 생성'),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.black,
      ),
      resizeToAvoidBottomInset: true, // 키보드 때문에 밀림 방지
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // 빈 화면 탭 시 키보드 닫힘
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextField(
                controller: storeNameController,
                decoration: const InputDecoration(labelText: '매장 이름'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: '주소'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final storeName = storeNameController.text.trim();
                  final address = addressController.text.trim();
                  final uid = FirebaseAuth.instance.currentUser?.uid;

                  if (storeName.isEmpty || address.isEmpty || uid == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("모든 항목을 입력해주세요.")),
                    );
                    return;
                  }

                  // 매장 생성하고 DocumentReference 받아오기
                  final storeRef = await FirebaseFirestore.instance.collection('stores').add({
                    'storeName': storeName,
                    'address': address,
                    'ownerUid': uid,
                    'createdAt': Timestamp.now(),
                    'members': [], // 직원 목록은 비어 있음
                    // 나중에 사용 -- 'inviteCode': generateInviteCode(), // 랜덤 초대코드
                    // 나중에 사용 -- 'autoOrderEnabled': false,
                    'storeType': '카페',
                  });

                  // 사용자 문서에 storeId와 role도 저장
                  await FirebaseFirestore.instance.collection('users').doc(uid).update({
                    'storeId': storeRef.id,
                    'role': 'owner', // 점주
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  // 메인 화면으로 이동
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
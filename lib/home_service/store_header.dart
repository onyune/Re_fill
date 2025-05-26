// 홈 화면 > 매장명 & 로딩

import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoreHeader extends StatefulWidget {
  const StoreHeader({super.key});

  @override
  State<StoreHeader> createState() => _StoreHeaderState();
}

class _StoreHeaderState extends State<StoreHeader> {
  String? storeName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoreName();
  }

  Future<void> _loadStoreName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final storeId = userDoc.data()?['storeId'];

      if (storeId == null) {
        setState(() {
          storeName = '매장에 가입되지 않았습니다';
          isLoading = false;
        });
        return;
      }

      final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
      setState(() {
        storeName = storeDoc.data()?['storeName'] ?? '이름 없는 매장';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        storeName = '매장 정보를 불러오는 중 오류';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      isLoading ? '불러오는 중...' : (storeName ?? '매장명 없음'),
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}

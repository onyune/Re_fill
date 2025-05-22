import 'dart:math';
import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:refill/setting_service/team_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool lowStockNotification = true;
  String userName = '';
  String role = '';
  String inviteCode = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final data = userDoc.data()!;
      setState(() {
        userName = data['name'] ?? '이름 없음';
        role = data['role'] == 'owner' ? '관리자' : '직원';
      });
    }

    // 관리자인 경우 초대코드 불러오기
    if (role == '관리자') {
      final storeId = userDoc.data()?['storeId'];
      if (storeId != null) {
        final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
        if (storeDoc.exists) {
          final storeData = storeDoc.data();
          setState(() {
            inviteCode = storeData?['inviteCode'] ?? '';
          });
        }
      }
    }
  }

  Future<void> _generateInviteCode() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc.data()?['storeId'];

    if (storeId == null) return;

    final newCode = _randomCode();
    await FirebaseFirestore.instance.collection('stores').doc(storeId).update({
      'inviteCode': newCode,
    });

    setState(() {
      inviteCode = newCode;
    });
  }

  String _randomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '설정',
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
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 유저 정보 박스
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.background,
                    child: Icon(Icons.person, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '안녕하세요!',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$role $userName 님',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 초대 코드 생성 (관리자만 표시)
            if (role == '관리자') ...[
              const Text('팀 초대', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _generateInviteCode,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('초대코드 생성', style: TextStyle(color: Colors.white)),
              ),
              if (inviteCode.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('초대코드: $inviteCode'),
              ],
              const SizedBox(height: 24),
            ],

            const Text('앱 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('재고 부족 알림 설정'),
              value: lowStockNotification,
              onChanged: (value) => setState(() => lowStockNotification = value),
              activeColor: AppColors.primary,
            ),
            const SizedBox(height: 24),

            const Text('매장 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('매장 변경'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            if (role == '관리자') ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('팀 관리'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TeamManagementScreen()),
                  );
                },
              ),
            ],
            const SizedBox(height: 24),

            const Text('개인/보안', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('비밀번호 변경'),
              onTap: () {},
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('계정 탈퇴'),
              onTap: () {},
            ),
            const SizedBox(height: 24),

            Center(
              child: TextButton(
                onPressed: () {
                  // 로그아웃 처리
                },
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    color: AppColors.borderDefault,
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:refill/setting_service/team_management_screen.dart';
import 'package:refill/setting_service/min_stock.dart';
import 'package:refill/setting_service/store_change_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool lowStockNotification = true;
  bool darkMode = false;
  String userName = '';
  String role = ''; // '관리자' or '직원'
  String inviteCode = '';
  bool isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      isGoogleUser = user.providerData.any((info) => info.providerId == 'google.com');
    });

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = userDoc.data();

    if (data != null) {
      setState(() {
        userName = data['name'] ?? '';
        role = data['role'] == 'owner' ? '관리자' : '직원';
      });

      if (data['role'] == 'owner') {
        final storeId = data['storeId'];
        if (storeId != null) {
          final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
          setState(() {
            inviteCode = storeDoc.data()?['inviteCode'] ?? '';
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

  Future<void> _sendPasswordResetEmail() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('비밀번호 변경'),
          content: const Text('비밀번호 재설정 이메일을 보냈습니다.\n메일을 확인 후 다시 로그인해주세요.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              },
              child: const Text('확인'),
            )
          ],
        ),
      );
    } catch (e) {
      print('비밀번호 재설정 오류: $e');
    }
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      if (isGoogleUser) {
        final googleUser = await GoogleSignIn().signIn();
        final googleAuth = await googleUser?.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      } else {
        final controller = TextEditingController();
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('비밀번호 확인'),
            content: TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호 입력'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
            ],
          ),
        );
        final password = controller.text.trim();
        if (password.isEmpty) return;
        final credential = EmailAuthProvider.credential(email: user.email!, password: password);
        await user.reauthenticateWithCredential(credential);
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final role = userDoc['role'];
      final storeId = userDoc['storeId'];

      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      if (role == 'owner' && storeId != null) {
        await FirebaseFirestore.instance.collection('stores').doc(storeId).delete();
      }

      await user.delete();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } catch (e) {
      print('계정 삭제 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainBlue = AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정',
            style: TextStyle(color: mainBlue, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: mainBlue),
      ),
      backgroundColor: const Color(0xFFFBF7FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: mainBlue.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('안녕하세요!',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainBlue)),
                        const SizedBox(height: 8),
                        Text('$role $userName 님',
                            style: const TextStyle(fontSize: 16, color: mainBlue)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            if (role == '관리자') ...[
              const Text('팀 초대', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: _generateInviteCode,
                style: ElevatedButton.styleFrom(backgroundColor: mainBlue),
                child: const Text('초대코드 생성', style: TextStyle(color: Colors.white)),
              ),
              if (inviteCode.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('초대코드: $inviteCode'),
                ),
              const SizedBox(height: 24),
            ],

            const Text('앱 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('재고 부족 알림 설정'),
              value: lowStockNotification,
              onChanged: (value) => setState(() => lowStockNotification = value),
              activeColor: mainBlue,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('다크 모드'),
              value: darkMode,
              onChanged: (value) => setState(() => darkMode = value),
              activeColor: mainBlue,
            ),

            if (role == '관리자')
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('재고 최소 수량 설정'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MinStockListPage())),
              ),

            const Divider(height: 32),

            const Text('매장 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('매장 변경'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreChangePage())),
            ),
            if (role == '관리자')
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('팀 관리'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamManagementScreen())),
              ),

            const Divider(height: 32),

            const Text('개인/보안', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (!isGoogleUser)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('비밀번호 변경'),
                onTap: _sendPasswordResetEmail,
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('계정 탈퇴'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('계정 탈퇴'),
                    content: const Text('정말로 계정을 삭제하시겠습니까?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                      TextButton(onPressed: () {
                        Navigator.pop(context);
                        _deleteAccount();
                      }, child: const Text('탈퇴')),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            Center(
              child: TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
                },
                child: const Text(
                  '로그아웃',
                  style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

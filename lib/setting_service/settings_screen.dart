import 'dart:math';
import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:refill/setting_service/team_management_screen.dart';
import 'package:refill/setting_service/min_stock.dart';

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

      if (data['role'] == 'owner') {
        final storeId = data['storeId'];
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
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인된 사용자 이메일이 없습니다.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('비밀번호 변경'),
          content: const Text('비밀번호 재설정 메일을 보냈습니다.\n이메일을 확인한 후 다시 로그인해주세요.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('비밀번호 재설정 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메일 전송에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final isGoogleUser = user.providerData.any((info) => info.providerId == 'google.com');

    try {
      if (isGoogleUser) {
        final googleUser = await GoogleSignIn().signIn();
        final googleAuth = await googleUser?.authentication;

        if (googleAuth?.accessToken == null || googleAuth?.idToken == null) {
          throw FirebaseAuthException(code: 'ERROR_MISSING_GOOGLE_CREDENTIALS', message: 'Google 인증 실패');
        }

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth!.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      } else {
        final passwordController = TextEditingController();
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('비밀번호 확인'),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호를 입력하세요'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
            ],
          ),
        );

        final password = passwordController.text.trim();
        if (password.isEmpty) return;

        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final role = userData?['role'];
      final storeId = userData?['storeId'];

      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      if (role == 'owner' && storeId != null) {
        await FirebaseFirestore.instance.collection('stores').doc(storeId).delete();
      }

      await user.delete();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      print('계정 삭제 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계정 삭제에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGoogleUser = user?.providerData.any((info) => info.providerId == 'google.com') ?? false;

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
            // 사용자 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
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
                        const Text('안녕하세요!',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 8),
                        Text('$role $userName 님',
                            style: const TextStyle(fontSize: 16, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('재고 최소 수량 설정'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MinStockListPage()));
              },
            ),
            Divider(thickness: 0.8, color: Colors.grey.shade300),

            const SizedBox(height: 24),
            const Text('매장 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('매장 변경'),
              onTap: () {},
            ),
            if (role == '관리자')
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('팀 관리'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamManagementScreen()));
                },
              ),
            Divider(thickness: 0.8, color: Colors.grey.shade300),

            const SizedBox(height: 24),
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
                    content: const Text('정말로 계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _deleteAccount();
                        },
                        child: const Text('탈퇴'),
                      ),
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
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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

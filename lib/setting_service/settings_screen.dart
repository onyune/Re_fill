import 'dart:math';
import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'user_card.dart';
import 'invite_code.dart';
import 'app_settings_section/app_settings.dart';
import 'store_settings_section/store_settings.dart';
import 'security_section.dart';

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
  bool isInviteCodeGenerated = false;

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
        role = data['role'] ?? 'staff';
      });

      if (role == 'owner') {
        final storeId = data['storeId'];
        if (storeId != null) {
          final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
          if (storeDoc.exists) {
            final storeData = storeDoc.data();
            final code = storeData?['inviteCode'] ?? '';
            setState(() {
              inviteCode = code;
              isInviteCodeGenerated = code.isNotEmpty;
            });
          }
        }
      }
    }
  }

  Future<void> _generateInviteCode() async {
    if (isInviteCodeGenerated) return;
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
      isInviteCodeGenerated = true;
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
        builder: (_) => AlertDialog(
          title: const Text('비밀번호 변경'),
          content: const Text('비밀번호 재설정 메일을 보냈습니다.\n로그인을 다시 진행해주세요.'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메일 전송 실패. 다시 시도해주세요.')),
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
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth!.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final storeId = userDoc.data()?['storeId'];

      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      if (role == 'owner' && storeId != null) {
        await FirebaseFirestore.instance.collection('stores').doc(storeId).delete();
      }

      await user.delete();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계정 삭제에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGoogleUser = user?.providerData.any((info) => info.providerId == 'google.com') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 24)),
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
            UserCard(userName: userName, role: role),
            const SizedBox(height: 32),
            if (role == 'owner')
              InviteCodeSection(
                isInviteCodeGenerated: isInviteCodeGenerated,
                inviteCode: inviteCode,
                onGenerateInviteCode: _generateInviteCode,
              ),
            AppSettingsSection(
              lowStockNotification: lowStockNotification,
              onToggleLowStock: (value) => setState(() => lowStockNotification = value),
              role: role,
            ),
            StoreSettingsSection(role: role),
            SecuritySection(
              isGoogleUser: isGoogleUser,
              onResetPassword: _sendPasswordResetEmail,
              onDeleteAccount: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('계정 탈퇴'),
                    content: const Text('정말로 계정을 삭제하시겠습니까?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                      TextButton(onPressed: () async {
                        Navigator.pop(context);
                        await _deleteAccount();
                      }, child: const Text('탈퇴')),
                    ],
                  ),
                );
              },
              onLogout: () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

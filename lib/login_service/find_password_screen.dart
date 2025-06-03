import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:refill/login_service/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class FindPasswordScreen extends StatefulWidget {
  const FindPasswordScreen({super.key});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  final _emailController = TextEditingController();

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("이메일을 입력해주세요.");
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _showSnackBar("해당 이메일로 가입된 계정이 없습니다.");
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnackBar("비밀번호 재설정 메일을 보냈습니다.\n메일이 오지 않는 경우, 스팸함을 확인해주세요.");
    } catch (e) {
      _showSnackBar("비밀번호 재설정에 실패했습니다.");
      print("비밀번호 재설정 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  '비밀번호 찾기',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text("이메일"),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: '이메일을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '비밀번호 재설정 메일 보내기',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text(
                "로그인 화면으로 돌아가기",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

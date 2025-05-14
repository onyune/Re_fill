import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refill/login_service/login_screen.dart'; // 로그인 화면 import (이메일 인증 후 로그인화면으로 돌아가서 재로그인)

class FindIdScreen extends StatefulWidget {
  const FindIdScreen({super.key});

  @override
  State<FindIdScreen> createState() => _FindIdScreenState();
}

class _FindIdScreenState extends State<FindIdScreen> {
  final _emailController = TextEditingController();
  String? _foundUserId;

  Future<void> _sendVerificationAndFindId() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar("이메일을 입력해주세요.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnackBar("인증 메일을 보냈습니다. 메일함을 확인해주세요.");

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _foundUserId = snapshot.docs.first['userId'];
        });
      } else {
        _showSnackBar("이메일은 존재하지만, 아이디 정보를 찾을 수 없습니다.");
      }
    } catch (e) {
      _showSnackBar("존재하지 않는 이메일입니다.");
      print("에러: $e");
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '아이디 찾기',
          style: TextStyle(
            color: Color(0xFF2563EB), // mainBlue 직접 넣기
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent, // 파란색 띠 제거
        elevation: 0, // 그림자 제거
        centerTitle: false, // 왼쪽 정렬
        iconTheme: const IconThemeData(color: Color(0xFF2563EB)), // 아이콘도 파란색
      ),
      backgroundColor: const Color(0xFFFBF7FF),
      body: GestureDetector( // 키보드 닫기용 제스처
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 60, 30, 60),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("이메일"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress, // 이메일 키보드
                    decoration: InputDecoration(
                      hintText: "이메일을 입력하세요",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _sendVerificationAndFindId,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "인증 메일 보내기",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_foundUserId != null) ...[
                    Center(
                      child: Text(
                        "아이디: $_foundUserId",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          "로그인 화면으로 돌아가기",
                          style: TextStyle(color: Color(0xFF2563EB)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

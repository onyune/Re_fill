import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:flutter/material.dart';
import 'package:refill/store_entry_screen.dart';
import 'first_screen.dart'; // 첫 화면 import

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _checkPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  bool _isIdChecked = false;

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _checkIdDuplication() {
    final inputId = _idController.text.trim();
    if (inputId.isEmpty) {
      _showSnackBar('ID를 입력해주세요.');
    } else {
      setState(() {
        _isIdChecked = true;
      });
      _showSnackBar('사용 가능한 ID입니다.');
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isIdChecked) {
      _showSnackBar('ID 중복 확인을 해주세요.');
      return;
    }
    if (_passwordController.text != _checkPasswordController.text) {
      _showSnackBar('비밀번호가 일치하지 않습니다.');
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // Firestore에 사용자 정보 저장
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'id': _idController.text.trim(),
        'hasStore': false, // 매장 없음 표시
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FirstScreen()),
      );
    } on FirebaseAuthException catch (e) {
      print("회원가입 실패");
      if (e.code == 'email-already-in-use') {
        _showSnackBar('이미 등록된 이메일입니다.');
      } else {
        _showSnackBar('회원가입 실패: ${e.message}');
      }
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: const Color(0xFFFBF7FF),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _idController,
                            decoration: _buildInputDecoration('ID'),
                            validator: (value) => value == null || value.isEmpty ? 'ID를 입력해주세요.' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _checkIdDuplication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('중복확인', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration('이름'),
                      validator: (v) => v == null || v.isEmpty ? '이름을 입력해주세요.' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: _buildInputDecoration('이메일'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '이메일을 입력해주세요.';
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) return '올바른 이메일 형식이 아닙니다.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _buildInputDecoration('비밀번호'),
                      validator: (value) {
                        if (value == null || value.length < 6) return '6자 이상 입력해주세요.';
                        if (!RegExp(r'[!@#\\$%^&*(),.?":{}|<>]').hasMatch(value)) {
                          return '특수문자를 포함해야 합니다.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _checkPasswordController,
                      obscureText: true,
                      decoration: _buildInputDecoration('비밀번호 확인'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

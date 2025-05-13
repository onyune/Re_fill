import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main_navigation.dart';
import 'package:refill/login_service/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
  String? _emailErrorText;

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _checkIdDuplication() async {
    final inputId = _idController.text.trim();
    if (inputId.isEmpty) {
      _showSnackBar('ID를 입력해주세요.');
      return;
    }

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: inputId)
          .get();

      if (query.docs.isEmpty) {
        // 사용 가능한 ID
        setState(() {
          _isIdChecked = true;
        });
        _showSnackBar('사용 가능한 ID입니다.');
      } else {
        _showSnackBar('이미 사용 중인 ID입니다.');
      }
    } catch (e) {
      _showSnackBar('중복 확인 중 오류 발생');
      print(e);
    }
  }

  Future<bool> isEmailDuplicated(String email) async {
    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('이메일 중복 확인 중 오류: $e');
      return false;
    }
  }

  Future<void> _signUp() async {
    print("회원가입 시작");

    if (!_formKey.currentState!.validate()) return;

    if (!_isIdChecked) {
      _showSnackBar('ID 중복 확인을 해주세요.');
      return;
    }

    if (_passwordController.text != _checkPasswordController.text) {
      _showSnackBar('비밀번호가 일치하지 않습니다.');
      return;
    }

    final isDuplicateEmail = await isEmailDuplicated(_emailController.text.trim());
    if (isDuplicateEmail) {
      setState(() {
        _emailErrorText = '이미 등록된 이메일입니다.';
      });
      return;
    } else {
      setState(() {
        _emailErrorText = null;
      });
    }


    try {
      print("회원가입 시도");

      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 회원 정보 Firestore에 저장
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'userId': _idController.text.trim(),
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      print("화면 전환 시도");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      print("화면 에러");
      if (e.code == 'email-already-in-use') {
        setState(() {
          _emailErrorText = '이미 등록된 이메일입니다.';
        });
        // showSnackBar 병행 표시하려면 주석 해제
        // _showSnackBar('이미 등록된 이메일입니다.');
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

      errorStyle: TextStyle(color: Colors.red, fontSize: 13),
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
                  decoration: _buildInputDecoration('이메일').copyWith(
                    errorText: _emailErrorText,
                  ),
                  onChanged: (_) {
                    setState(() {
                      _emailErrorText = null;
                    });
                  },
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

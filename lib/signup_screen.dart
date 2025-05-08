import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main_navigation.dart';

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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showSnackBar('이미 등록된 이메일입니다.');
      } else {
        _showSnackBar('회원가입 실패: ${e.message}');
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: suffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: validator,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'ID',
                      controller: _idController,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'ID를 입력해주세요.' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _checkIdDuplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    child: const Text('중복확인'),
                  ),
                ],
              ),
              _buildTextField(
                label: '이름',
                controller: _nameController,
                validator: (v) => v == null || v.isEmpty ? '이름을 입력해주세요.' : null,
              ),
              _buildTextField(
                label: '이메일',
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) return '이메일을 입력해주세요.';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) return '올바른 이메일 형식이 아닙니다.';
                  return null;
                },
              ),
              _buildTextField(
                label: '비밀번호',
                controller: _passwordController,
                obscure: true,
                validator: (value) {
                  if (value == null || value.length < 6) return '6자 이상 입력해주세요.';
                  if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return '특수문자를 포함해야 합니다.';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: '비밀번호 확인',
                controller: _checkPasswordController,
                obscure: true,
                validator: (v) => null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.blue,
                ),
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

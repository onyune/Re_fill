import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main_navigation.dart';
import 'package:refill/login_service/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refill/colors.dart';

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
  String? _idMessage;
  Color? _idMessageColor;
  Color? _idBorderColor;

  bool _isEmailDuplicate = false;

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _checkIdDuplication() async {
    final inputId = _idController.text.trim();
    if (inputId.isEmpty) {
      setState(() {
        _idMessage = 'ID를 입력해주세요.';
        _idMessageColor = AppColors.error;
        _idBorderColor = AppColors.error;
      });
      return;
    }

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: inputId)
          .get();

      if (query.docs.isEmpty) {
        setState(() {
          _idMessage = '사용 가능한 ID입니다.';
          _idMessageColor = AppColors.primary;
          _idBorderColor = AppColors.primary;
          _isIdChecked = true;
        });
      } else {
        setState(() {
          _idMessage = '이미 사용 중인 ID입니다.';
          _idMessageColor = AppColors.error;
          _idBorderColor = AppColors.error;
          _isIdChecked = false;
        });
      }
    } catch (e) {
      setState(() {
        _idMessage = '중복 확인 중 오류 발생';
        _idMessageColor = AppColors.error;
      });
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
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    // ID 중복 확인 여부 확인
    if (!_isIdChecked) {
      _showSnackBar('ID 중복 확인을 해주세요.');
      return;
    }

    // 이메일 중복 확인 (validator에서 쓸 수 없으므로 여기서 처리)
    final isDuplicateEmail = await isEmailDuplicated(_emailController.text.trim());
    if (isDuplicateEmail) {
      setState(() => _isEmailDuplicate = true);
      _formKey.currentState!.validate(); // 다시 에러 반영
      return;
    }

    // 비밀번호 확인
    if (_passwordController.text != _checkPasswordController.text) {
      _showSnackBar('비밀번호가 일치하지 않습니다.');
      return;
    }

    // 회원가입 진행
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'userId': _idController.text.trim(),
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() => _isEmailDuplicate = true);
        _formKey.currentState!.validate(); // 에러 메시지 반영
      } else {
        debugPrint('회원가입 실패: ${e.message}');
      }
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.borderDefault, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.error, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.error, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 13),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, automaticallyImplyLeading: true),
      backgroundColor: AppColors.background,
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
                    color: AppColors.primary,
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
                            decoration: InputDecoration(
                              labelText: 'ID',
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: _idBorderColor ?? AppColors.borderDefault, width: 2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: _idBorderColor ?? AppColors.primary, width: 2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.error, width: 2),
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.error, width: 2),
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              errorStyle: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                            onChanged: (_) {
                              setState(() {
                                _idMessage = null;
                                _idBorderColor = null;
                                _isIdChecked = false;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'ID를 입력해주세요.';
                              }
                              if (value.contains(' ')) {
                                setState(() {
                                  _idMessage = null;
                                });
                                return '공백 없이 입력해주세요.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _checkIdDuplication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('중복확인', style: TextStyle(color: AppColors.background)),
                        ),
                      ],
                    ),
                    if (_idMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                        child: Text(
                          _idMessage!,
                          style: TextStyle(
                            color: _idMessageColor ?? Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration('이름'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '이름을 입력해주세요.';
                        if (value.contains(' ')) return '공백 없이 입력해주세요.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: _buildInputDecoration('이메일'),
                      onChanged: (_) {
                        setState(() {
                          _isEmailDuplicate = false;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return '이메일을 입력해주세요.';
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) return '올바른 이메일 형식이 아닙니다.';
                        if (_isEmailDuplicate) return '이미 등록된 이메일입니다.';
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
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(color: AppColors.background, fontSize: 16),
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

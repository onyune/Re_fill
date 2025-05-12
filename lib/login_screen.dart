import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'find_id_screen.dart';
import 'find_password_screen.dart';
import 'package:refill/main_navigation.dart';
import 'package:refill/google_auth_service/auth_service.dart';    // 구글 계정 로그인 관련 함수 파일 import


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isManager = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Re:fill',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      value: true,
                      groupValue: isManager,
                      onChanged: (value) => setState(() => isManager = true),
                    ),
                    const Text("관리자"),
                    Radio(
                      value: false,
                      groupValue: isManager,
                      onChanged: (value) => setState(() => isManager = false),
                    ),
                    const Text("직원"),
                  ],
                ),

                const SizedBox(height: 16),

                TextField(
                  decoration: InputDecoration(
                    labelText: 'ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'PASSWORD',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavigation()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
               const SizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text("회원가입"),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FindIdScreen()),
                        );
                      },
                      child: const Text("아이디 찾기"),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FindPasswordScreen()),
                        );
                      },
                      child: const Text("비밀번호 찾기"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                OutlinedButton.icon(
                  onPressed: () async {
                    final userCredential = await AuthService.signInWithGoogle();
                    if (userCredential != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainNavigation()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Google 로그인 실패")),
                      );
                    }
                  },
                  icon: Image.asset(
                    'assets/google_logo.png',
                    height: 24,
                    width: 24,
                  ),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

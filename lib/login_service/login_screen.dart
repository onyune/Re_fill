import 'package:flutter/material.dart';
import 'package:refill/login_service/find_id_screen.dart';
import 'package:refill/login_service/signup_screen.dart';
import 'package:refill/login_service/find_password_screen.dart';
import 'package:refill/login_service/first_screen.dart';
import 'package:refill/main_navigation.dart';
import 'package:refill/google_auth_service/auth_service.dart';    // 구글 계정 로그인 관련 함수 파일 import
import 'package:refill/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isManager = true;
  bool _isLoading = false;

  String? _errorMessage;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    final userId = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (_isLoading) return;
    setState(() => _isLoading = true);

    if (userId.isEmpty || password.isEmpty) {
      _setError("아이디와 비밀번호를 모두 입력해주세요.");
      return;
    }

    try {
      // Firestore에서 email 찾기
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _setError("존재하지 않는 아이디입니다.");
        return;
      }

      final email = snapshot.docs.first.data()['email'];

      // 이메일 기반 Firebase Auth 로그인
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = FirebaseAuth.instance.currentUser!.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("사용자 정보가 존재하지 않습니다.")),
        );
        return;
      }

      final userData = userDoc.data();
      final storeId = userData?['storeId'];

      if (storeId == null || storeId.isEmpty) {
        // 매장 미소속 → FirstScreen으로
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FirstScreen()),
        );
      } else {
        // 매장 소속 → MainNavigation으로
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _setError("비밀번호가 틀렸습니다.");
      } else {
        _setError("로그인에 실패했습니다. (${e.code})");
      }
    } catch (e) {
      _setError("알 수 없는 오류가 발생했습니다.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _setError(String msg) {
    setState(() {
      _errorMessage = msg;
      _isLoading = false;
    });
  }

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
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: 'ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'PASSWORD',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 14),
                    ),
                  ),


                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                  )
                      : const Text('로그인', style: TextStyle(color: AppColors.background)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                      color: AppColors.borderDefault,
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
                      color: AppColors.borderDefault,
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
                      final uid = userCredential.user?.uid;

                      if (uid == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("로그인 정보가 올바르지 않습니다.")),
                        );
                        return;
                      }

                      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                      if (!userDoc.exists) {
                        // 처음 로그인한 구글 사용자 → 사용자 문서 생성
                        await FirebaseFirestore.instance.collection('users').doc(uid).set({
                          'email': userCredential.user!.email,
                          'name': userCredential.user!.displayName ?? '',
                          'storeId': '',
                          'role': 'employee',
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                      }
                      final refreshedDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                      final userData = refreshedDoc.data();
                      final storeId = userData?['storeId'];

                      if (storeId == null || storeId.isEmpty) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const FirstScreen()),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainNavigation()),
                        );
                      }
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
                    side: BorderSide(color: AppColors.borderDefault),
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

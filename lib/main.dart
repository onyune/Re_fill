import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'splash_screen.dart';
import 'login_service/login_screen.dart'; //  로그인 화면 경로
import 'main_navigation.dart'; // 홈으로 들어가는 메인 화면

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Re:fill',
      initialRoute: '/', // splash부터 시작
      routes: {
        '/': (context) => const SplashScreen(), // splash 화면
        '/login': (context) => const LoginScreen(), // 기존 로그인
        '/main': (context) => const MainNavigation(), // 홈 화면
      },
    );
  }
}

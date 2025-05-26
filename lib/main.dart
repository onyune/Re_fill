import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'splash_screen.dart';
import 'login_service/login_screen.dart';
import 'main_navigation.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📩 백그라운드 메시지 도착: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('ko'); // 한국어 날짜 포맷 초기화
  // 알림 권한 요청
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
  print('🔔 알림 권한 상태: ${settings.authorizationStatus}');

  // 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 포그라운드 메시지 리스너
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('💬 포그라운드 메시지: ${message.notification?.title}');
  });

  // FCM 토큰 출력
  _printFcmToken();

  runApp(const MyApp());
}

void _printFcmToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  print("🔥 FCM 토큰: $token");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Re:fill',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainNavigation(),
      },
    );
  }
}

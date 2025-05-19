import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_service/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(" 백그라운드 메시지 도착: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
  print('🔔 알림 권한 상태: ${settings.authorizationStatus}');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  // 포그라운드 메시지 수신 시
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('💬 포그라운드 메시지: ${message.notification?.title}');
  });
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
      title: 'Re:fill',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

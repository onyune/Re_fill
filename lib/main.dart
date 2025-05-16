import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_service/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  print("백그라운드 메시지 도착 : ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  _printFcmToken();
  runApp(const MyApp());


}
void _printFcmToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  print("FCM 토큰: $token");
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

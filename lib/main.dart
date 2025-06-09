import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'main_navigation.dart';
import 'splash_screen.dart';
import 'login_service/login_screen.dart';
import 'package:provider/provider.dart';
import 'providers/weather_provider.dart';
import 'providers/holiday_provider.dart';
import 'providers/order_provider.dart';
import 'home_service/low_stock_forecast_screen.dart';
import 'package:refill/setting_service/app_settings_section/auto_order/background_service.dart';
import 'package:refill/setting_service/store_settings_section/order_history_screen.dart';
import 'package:refill/setting_service/app_settings_section/auto_order/auto_order_time.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📩 백그라운드 메시지 도착: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('ko'); // 한국어 날짜 포맷 초기화
  await initializeService(); // 이 줄 추가

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => HolidayProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),

      ],
      child: const MyApp(),
    ),
  );
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
        '/lowStockForecast': (context) => const LowStockForecastScreen(),
        '/orderHistory': (context) => const OrderHistoryScreen(),
        '/autoOrderTime': (context) => const AutoOrderTime(),
      },
    );
  }
}

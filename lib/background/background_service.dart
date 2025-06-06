import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:refill/order_service/auto_order.dart';
import 'package:refill/dart_plugin_registrant.dart'; // ✅ 직접 만든 등록자

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// ✅ 백그라운드 서비스 시작 시 실행되는 함수
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  print('🌀 백그라운드 서비스 onStart 실행됨');
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    print('🔁 Timer 1분마다 실행 중...');
    await autoOrderExecution();
  });
}

/// ✅ 백그라운드 서비스 초기 설정
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
      notificationChannelId: 'auto_order_channel',
      initialNotificationTitle: 'Re:fill 자동 발주 서비스 실행 중',
      initialNotificationContent: '설정된 시간에 맞춰 자동으로 발주합니다.',
    ),
    iosConfiguration: IosConfiguration(),
  );
}

/// ✅ 알림 채널 등록 (startForeground에 반드시 필요!)
Future<void> setupNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'auto_order_channel', // 반드시 위와 동일한 ID
    '자동 발주 알림',
    description: '자동 발주 기능을 위한 백그라운드 서비스 알림 채널',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  await plugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

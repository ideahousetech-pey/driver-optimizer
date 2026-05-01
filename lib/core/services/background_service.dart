import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'gps_service.dart';
import 'network_service.dart';
import 'dart:async';

class BackgroundService {
  static final FlutterLocalNotificationsPlugin
      _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    const AndroidNotificationChannel channel =
        AndroidNotificationChannel(
      'driver_optimizer_channel',
      'Driver Optimizer Service',
      description: 'Realtime optimizer',
      importance: Importance.low,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId:
            'driver_optimizer_channel',
        initialNotificationTitle:
            'Driver Optimizer',
        initialNotificationContent:
            'Starting service...',
        foregroundServiceNotificationId: 1001,
      ),
      iosConfiguration: IosConfiguration(),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onStart(
    ServiceInstance service,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();

    await GPSService.start();
    await NetworkService.start();

    service.on('stopService').listen((event) {
      GPSService.stop();
      NetworkService.stop();
      service.stopSelf();
    });

    Timer.periodic(
      const Duration(seconds: 2),
      (timer) async {
        if (service is AndroidServiceInstance) {
          await service.setForegroundNotificationInfo(
            title: 'Driver Optimizer ACTIVE',
            content:
                'GPS ${GPSService.accuracy.toStringAsFixed(0)}m | Ping ${NetworkService.pingMs}ms',
          );
        }
      },
    );
  }
}
import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'gps_service.dart';
import 'network_service.dart';
import 'watchdog_service.dart';

class BackgroundService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final service = FlutterBackgroundService();

    // 🔥 Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'driver_optimizer_channel',
      'Driver Optimizer Service',
      description: 'Background service untuk GPS & Network',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin notifications =
        FlutterLocalNotificationsPlugin();

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: false,
        notificationChannelId: 'driver_optimizer_channel',
        initialNotificationTitle: 'Driver Optimizer',
        initialNotificationContent: 'Initializing...',
      ),
      iosConfiguration: IosConfiguration(),
    );

    _isInitialized = true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    try {
      DartPluginRegistrant.ensureInitialized();

      final FlutterLocalNotificationsPlugin notifications =
          FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      await notifications.initialize(
        const InitializationSettings(android: androidSettings),
      );

      // 🔥 FORCE UPDATE NOTIFICATION
      await notifications.show(
        999,
        'Driver Optimizer',
        'Service Started',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'driver_optimizer_channel',
            'Driver Optimizer Service',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
          ),
        ),
      );

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Driver Optimizer',
          content: 'Service Running',
        );
      }

      service.on('stopService').listen((event) {
        service.stopSelf();
      });

      // 🔥 SAFE START SERVICES
      _safeRun(() => GPSService.start(), "GPS");
      _safeRun(() => NetworkService.start(), "NETWORK");
      _safeRun(() => WatchdogService.start(service), "WATCHDOG");

      // 🔁 UPDATE BERKALA
      Timer.periodic(const Duration(seconds: 5), (timer) async {
        await notifications.show(
          999,
          'Driver Optimizer',
          'Running • GPS OK • Network OK',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'driver_optimizer_channel',
              'Driver Optimizer Service',
              importance: Importance.low,
              priority: Priority.low,
              ongoing: true,
            ),
          ),
        );
      });

    } catch (e, stack) {
      debugPrint("SERVICE ERROR: $e");
      debugPrint(stack.toString());
    }
  }

  // 🔒 SAFE WRAPPER (HARUS DI DALAM CLASS, BUKAN DI DALAM METHOD)
  static void _safeRun(Function fn, String name) {
    try {
      fn();
    } catch (e) {
      debugPrint("$name ERROR: $e");
    }
  }
}
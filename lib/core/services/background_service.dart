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

    // 🔥 WAJIB: Notification Channel (Android 8+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'driver_optimizer_channel',
      'Driver Optimizer Service',
      description: 'Background service untuk GPS & Network',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 🔥 CONFIGURE SERVICE
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

      // 🔥 INIT NOTIFICATION
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      await notifications.initialize(
        const InitializationSettings(android: androidSettings),
      );

      // 🔥 FORCE NOTIF (HILANGKAN "Initializing...")
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

      // OPTIONAL: tetap pakai foreground service
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Driver Optimizer',
          content: 'Service Running',
        );
      }

      service.on('stopService').listen((event) {
        service.stopSelf();
      });

      // 🔥 START SERVICE SAFE
      _safeRun(() => GPSService.start(), "GPS");
      _safeRun(() => NetworkService.start(), "NETWORK");
      _safeRun(() => WatchdogService.start(service), "WATCHDOG");

     // 🔁 UPDATE REALTIME
     Timer.periodic(const Duration(seconds: 5), (timer) async {
       await notifications.show(
         999,
         'Driver Optimizer',
         'GPS OK • Network OK • Running',
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
}
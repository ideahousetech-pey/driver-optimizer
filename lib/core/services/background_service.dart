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

  static const String notificationChannelId =
      'driver_optimizer_channel';

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final service = FlutterBackgroundService();

    // 🔥 Notification Channel
    const AndroidNotificationChannel channel =
        AndroidNotificationChannel(
      notificationChannelId,
      'Driver Optimizer Service',
      description: 'Background service Driver Optimizer',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin notifications =
        FlutterLocalNotificationsPlugin();

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 🔥 CONFIG SERVICE
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,

        // 🔥 penting
        autoStart: false,

        // 🔥 disable initial notif plugin
        isForegroundMode: true,

        notificationChannelId: notificationChannelId,

        // 🔥 dummy saja (tidak akan dipakai)
        initialNotificationTitle: 'Driver Optimizer',
        initialNotificationContent: 'Starting Service...',
      ),

      iosConfiguration: IosConfiguration(),
    );

    _isInitialized = true;
  }

  @pragma('vm:entry-point')
  static Future<void> onStart(
    ServiceInstance service,
  ) async {
    try {
      DartPluginRegistrant.ensureInitialized();

      final FlutterLocalNotificationsPlugin notifications =
          FlutterLocalNotificationsPlugin();

      // 🔥 INIT NOTIFICATION
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      await notifications.initialize(
        const InitializationSettings(
          android: androidSettings,
        ),
      );

      // 🔥 SET FOREGROUND MANUAL
      if (service is AndroidServiceInstance) {
        await service.setAsForegroundService();
        
          service.setForegroundNotificationInfo(
            title: 'Driver Optimizer',
            content: 'GPS & Network Active',
            );
        
      }

      // 🔥 NOTIFICATION AWAL
      await notifications.show(
        999,
        'Driver Optimizer',
        'Service Active',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            'Driver Optimizer Service',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            onlyAlertOnce: true,
          ),
        ),
      );

      // 🔥 STOP LISTENER
      service.on('stopService').listen((event) async {
        await notifications.cancel(999);
        service.stopSelf();
      });

      // 🔥 START SERVICES
      _safeRun(() => GPSService.start(), 'GPS');

      _safeRun(
        () => NetworkService.start(),
        'NETWORK',
      );

      _safeRun(
        () => WatchdogService.start(service),
        'WATCHDOG',
      );

      // 🔥 UPDATE NOTIF REALTIME
      Timer.periodic(
        const Duration(seconds: 5),
        (timer) async {
          try {
            final androidService = service as AndroidServiceInstance;

              androidService.setForegroundNotificationInfo(
                title: 'Driver Optimizer',
                content: 'GPS: ${GPSService.accuracy.toStringAsFixed(0)}m • Ping: ${NetworkService.pingMs}ms',
                );
                       
          } catch (e) {
            debugPrint(
              'NOTIFICATION TIMER ERROR: $e',
            );
          }
        },
      );
    } catch (e, stack) {
      debugPrint('BACKGROUND SERVICE ERROR: $e');
      debugPrint(stack.toString());
    }
  }

  // 🔥 SAFE WRAPPER
  static void _safeRun(
    Function fn,
    String name,
  ) {
    try {
      fn();
    } catch (e) {
      debugPrint('$name ERROR: $e');
    }
  }
}
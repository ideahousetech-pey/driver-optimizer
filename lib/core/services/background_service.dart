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

    // 🔥 CREATE NOTIFICATION CHANNEL (WAJIB)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'driver_optimizer_channel',
      'Driver Optimizer Service',
      description: 'Background service untuk menjaga GPS & koneksi',
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
      // 🔥 WAJIB untuk background isolate
      DartPluginRegistrant.ensureInitialized();

      // kasih delay biar stabil
      await Future.delayed(const Duration(milliseconds: 300));

      // SET NOTIFICATION
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Driver Optimizer',
          content: 'Service running...',
        );
      }

      // HANDLE STOP
      service.on('stopService').listen((event) {
        service.stopSelf();
      });

      // 🔥 SAFE EXECUTION (ANTI CRASH)
      _safeRun(() => GPSService.start(), "GPS");
      _safeRun(() => NetworkService.start(), "NETWORK");
      _safeRun(() => WatchdogService.start(service), "WATCHDOG");

      // 🔁 HEARTBEAT
      Timer.periodic(const Duration(seconds: 10), (timer) {
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: 'Driver Optimizer',
            content: 'GPS & Network active',
          );
        }
      });

    } catch (e, stack) {
      debugPrint("FATAL SERVICE ERROR: $e");
      debugPrint(stack.toString());
    }
  }

  // 🔒 SAFE WRAPPER
  static void _safeRun(Function fn, String name) {
    try {
      fn();
    } catch (e) {
      debugPrint("$name ERROR: $e");
    }
  }
}
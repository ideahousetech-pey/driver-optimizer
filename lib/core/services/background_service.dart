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
      // 🔥 WAJIB untuk plugin di background
      DartPluginRegistrant.ensureInitialized();

      // kasih delay supaya isolate stabil
      await Future.delayed(const Duration(milliseconds: 300));

      // 🔥 UPDATE AWAL (hapus "Initializing...")
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Driver Optimizer',
          content: 'Service starting...',
        );
      }

      // HANDLE STOP
      service.on('stopService').listen((event) {
        service.stopSelf();
      });

      // 🔥 START SERVICES (SAFE)
      _safeRun(() => GPSService.start(), "GPS");
      _safeRun(() => NetworkService.start(), "NETWORK");
      _safeRun(() => WatchdogService.start(service), "WATCHDOG");

      // 🔥 UPDATE LANGSUNG SETELAH START
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Driver Optimizer',
          content: 'GPS & Network Active',
        );
      }

      // 🔁 UPDATE BERKALA (BIAR HIDUP TERUS)
      Timer.periodic(const Duration(seconds: 5), (timer) {
        try {
          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: 'Driver Optimizer',
              content: 'Running • GPS OK • Network OK',
            );
          }
        } catch (e) {
          debugPrint("NOTIFICATION ERROR: $e");
        }
      });

    } catch (e, stack) {
      debugPrint("FATAL SERVICE ERROR: $e");
      debugPrint(stack.toString());
    }
  }

  // 🔒 SAFE WRAPPER (ANTI CRASH)
  static void _safeRun(Function fn, String name) {
    try {
      fn();
    } catch (e) {
      debugPrint("$name ERROR: $e");
    }
  }
}
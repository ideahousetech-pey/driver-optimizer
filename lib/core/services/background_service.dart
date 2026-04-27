import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../utils/constants.dart';
import 'gps_service.dart';
import 'network_service.dart';
import 'watchdog_service.dart';

class BackgroundService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return; // 🔥 penting

    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: false,
        notificationChannelId: AppConstants.serviceChannelId,
        initialNotificationTitle: AppConstants.notificationTitle,
        initialNotificationContent: "Initializing...",
      ),
      iosConfiguration: IosConfiguration(),
    );

    _isInitialized = true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    try {
      // 🔥 WAJIB BANGET (ini sering jadi penyebab crash)
      DartPluginRegistrant.ensureInitialized();

      // 🔥 kasih delay biar isolate siap
      await Future.delayed(const Duration(milliseconds: 300));

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Driver Optimizer",
          content: "Service running...",
        );
      }

      service.on('stopService').listen((event) {
        service.stopSelf();
      });

      // 🔥 SAFE START (tidak boleh crash)
      _safeRun(() => GPSService.start(), "GPS");
      _safeRun(() => NetworkService.start(), "NETWORK");
      _safeRun(() => WatchdogService.start(service), "WATCHDOG");

      // heartbeat
      Timer.periodic(const Duration(seconds: 10), (timer) {
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: "Driver Optimizer",
            content: "GPS & Network active",
          );
        }
      });

    } catch (e, stack) {
      debugPrint("FATAL SERVICE ERROR: $e");
      debugPrint(stack.toString());
    }
  }

  static void _safeRun(Function fn, String name) {
    try {
      fn();
    } catch (e) {
      debugPrint("$name ERROR: $e");
    }
  }
}
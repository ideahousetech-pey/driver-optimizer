import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../utils/constants.dart';
import 'gps_service.dart';
import 'network_service.dart';
import 'watchdog_service.dart';

class BackgroundService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: false,
        notificationChannelId: AppConstants.serviceChannelId,
        initialNotificationTitle: AppConstants.notificationTitle,
        initialNotificationContent: AppConstants.notificationContent,
      ),
      iosConfiguration: IosConfiguration(),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    try {
      DartPluginRegistrant.ensureInitialized();

      service.on('stopService').listen((event) {
        service.stopSelf();
      });

      // SAFE EXECUTION
      _safe(() => GPSService.start(), "GPS");
      _safe(() => NetworkService.start(), "NETWORK");
      _safe(() => WatchdogService.start(service), "WATCHDOG");

      Timer.periodic(const Duration(seconds: 10), (timer) {
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: "Driver Optimizer",
            content: "Running...",
          );
        }
      });

    } catch (e, s) {
      debugPrint("FATAL SERVICE ERROR: $e");
      debugPrint(s.toString());
    }
  }

  static void _safe(Function fn, String name) {
    try {
      fn();
    } catch (e) {
      debugPrint("$name ERROR: $e");
    }
  }
}
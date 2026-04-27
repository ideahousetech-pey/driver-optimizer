import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../utils/constants.dart';
import 'gps_service.dart';
import 'network_service.dart';
import 'watchdog_service.dart';
import 'package:flutter/foundation.dart';

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
    // Wajib untuk isolate
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: AppConstants.notificationTitle,
        content: "Service aktif",
      );
    }

    // STOP handler
    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    try {
      // START SERVICES
      GPSService.start();
      NetworkService.start();
      WatchdogService.start(service);
    } catch (e) {
      debugPrint("SERVICE ERROR: $e");
    }

    // Update notif berkala
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Driver Optimizer",
          content: "GPS & Network aktif",
        );
      }
    });
  }
}
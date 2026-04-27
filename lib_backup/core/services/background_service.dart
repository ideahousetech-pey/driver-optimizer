import 'dart:async';
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

  static void onStart(ServiceInstance service) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: AppConstants.notificationTitle,
        content: "Service aktif",
      );
    }

    // LISTENER STOP
    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    GPSService.start();
    NetworkService.start();
    WatchdogService.start(service);

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
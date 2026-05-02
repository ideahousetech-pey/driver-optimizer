import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

class BackgroundService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        foregroundServiceNotificationId: 1001,
        notificationChannelId: 'driver_optimizer',
        initialNotificationTitle: 'Driver Optimizer',
        initialNotificationContent: 'Service starting...',
      ),
      iosConfiguration: IosConfiguration(),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onStart(
    ServiceInstance service,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();

    final androidService =
        service as AndroidServiceInstance;

    double accuracy = 0;
    double speed = 0;

    bool networkOnline = false;

    // UPDATE NOTIFICATION
    Future<void> updateNotification() async {
      await androidService
          .setForegroundNotificationInfo(
        title: 'Driver Optimizer ACTIVE',
        content:
            'GPS ${accuracy.toStringAsFixed(0)}m • ${networkOnline ? 'ONLINE' : 'OFFLINE'}',
      );
    }

    // GPS STREAM
    try {
      final enabled =
          await Geolocator.isLocationServiceEnabled();

      if (!enabled) {
        debugPrint('GPS disabled');
      } else {
        LocationPermission permission =
            await Geolocator.checkPermission();

        if (permission ==
            LocationPermission.denied) {
          permission =
              await Geolocator.requestPermission();
        }

        Geolocator.getPositionStream(
          locationSettings:
              const LocationSettings(
            accuracy:
                LocationAccuracy.bestForNavigation,
            distanceFilter: 1,
          ),
        ).listen((position) async {
          accuracy = position.accuracy;
          speed = position.speed * 3.6;

          service.invoke(
            'update',
            {
              'accuracy': accuracy,
              'speed': speed,
              'network': networkOnline,
            },
          );

          await updateNotification();
        });
      }
    } catch (e) {
      debugPrint('GPS ERROR: $e');
    }

    // NETWORK
    Connectivity()
        .onConnectivityChanged
        .listen((event) async {
      networkOnline =
          !event.contains(
            ConnectivityResult.none,
          );

      service.invoke(
        'update',
        {
          'accuracy': accuracy,
          'speed': speed,
          'network': networkOnline,
        },
      );

      await updateNotification();
    });

    // KEEP ALIVE
    Timer.periodic(
      const Duration(seconds: 10),
      (_) async {
        await updateNotification();
      },
    );

    // STOP SERVICE
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }
}

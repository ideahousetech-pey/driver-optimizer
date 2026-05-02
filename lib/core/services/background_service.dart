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
  static Future<void> onStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();

    // Hanya berjalan di Android
    if (service is! AndroidServiceInstance) {
      debugPrint('BackgroundService hanya mendukung Android');
      service.stopSelf();
      return;
    }

    // service sudah otomatis bertipe AndroidServiceInstance setelah pengecekan di atas
    double accuracy = 0;
    double speed = 0;
    bool networkOnline = false;

    Future<void> updateNotification() async {
      try {
        await service.setForegroundNotificationInfo(
          title: 'Driver Optimizer ACTIVE',
          content: 'GPS ${accuracy.toStringAsFixed(0)}m • ${networkOnline ? 'ONLINE' : 'OFFLINE'}',
        );
      } catch (e) {
        debugPrint('Gagal update notifikasi: $e');
      }
    }

    StreamSubscription<Position>? positionSubscription;
    StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
    Timer? keepAliveTimer;

    // GPS stream
    try {
      final gpsEnabled = await Geolocator.isLocationServiceEnabled();
      if (!gpsEnabled) {
        debugPrint('GPS tidak aktif');
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          positionSubscription = Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation,
              distanceFilter: 1,
            ),
          ).listen(
            (Position position) {
              accuracy = position.accuracy;
              speed = position.speed * 3.6; // m/s → km/h
              try {
                service.invoke('update', {
                  'accuracy': accuracy,
                  'speed': speed,
                  'network': networkOnline,
                });
              } catch (e) {
                debugPrint('Error invoke update: $e');
              }
              updateNotification();
            },
            onError: (error) {
              debugPrint('GPS stream error: $error');
            },
          );
        } else {
          debugPrint('Izin lokasi tidak diberikan');
        }
      }
    } catch (e) {
      debugPrint('GPS ERROR: $e');
    }

    // Network monitor
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      networkOnline = !results.contains(ConnectivityResult.none);
      try {
        service.invoke('update', {
          'accuracy': accuracy,
          'speed': speed,
          'network': networkOnline,
        });
      } catch (e) {
        debugPrint('Error invoke update: $e');
      }
      updateNotification();
    });

    // Keep alive notification update
    keepAliveTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) async => updateNotification(),
    );

    // Cleanup ketika stop
    service.on('stopService').listen((event) {
      positionSubscription?.cancel();
      connectivitySubscription?.cancel();
      keepAliveTimer?.cancel();
      service.stopSelf();
    });

    await updateNotification();
  }
}
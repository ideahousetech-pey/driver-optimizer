import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'gps_service.dart';
import 'network_service.dart';

class WatchdogService {
  static Timer? _timer;

  static void start(
    ServiceInstance service,
  ) {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 15),
      (_) async {
        try {
          // GPS WATCHDOG
          if (GPSService.currentPosition ==
              null) {
            debugPrint(
              'WATCHDOG => Restart GPS',
            );

            await GPSService.start();
          }

          // NETWORK WATCHDOG
          if (!NetworkService.isConnected) {
            debugPrint(
              'WATCHDOG => Reconnect Network',
            );

            await NetworkService
                .autoReconnect();
          }
        } catch (e) {
          debugPrint(
            'WATCHDOG ERROR: $e',
          );
        }
      },
    );
  }

  static void stop() {
    _timer?.cancel();
  }
}
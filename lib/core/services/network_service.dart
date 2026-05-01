import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

class NetworkService {
  static Timer? _timer;

  static bool isConnected = false;

  static int pingMs = 0;

  static Future<void> start() async {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        await checkConnection();
      },
    );

    await checkConnection();
  }

  static Future<void> checkConnection() async {
    try {
      final stopwatch = Stopwatch()
        ..start();

      final result =
          await InternetAddress.lookup(
        'google.com',
      );

      stopwatch.stop();

      isConnected = result.isNotEmpty;

      pingMs = stopwatch.elapsedMilliseconds;

      debugPrint(
        'NETWORK => '
        'Connected: $isConnected '
        '| Ping: ${pingMs}ms',
      );

      if (!isConnected) {
        await autoReconnect();
      }
    } catch (e) {
      isConnected = false;

      debugPrint('NETWORK ERROR: $e');
    }
  }

  static Future<void> autoReconnect() async {
    try {
      debugPrint('AUTO RECONNECT...');

      await Future.delayed(
        const Duration(seconds: 2),
      );

      final result =
          await InternetAddress.lookup(
        'google.com',
      );

      isConnected = result.isNotEmpty;

      debugPrint(
        'RECONNECTED => $isConnected',
      );
    } catch (e) {
      debugPrint(
        'RECONNECT FAILED: $e',
      );
    }
  }

  static void stop() {
    _timer?.cancel();
  }
}
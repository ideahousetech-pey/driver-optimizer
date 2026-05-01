import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkService {
  static bool isConnected = false;
  static int pingMs = 0;

  static StreamSubscription? _connectivitySub;
  static Timer? _pingTimer;

  static Future<void> start() async {
    await _checkInternet();

    _connectivitySub?.cancel();

    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((_) async {
      await _checkInternet();
    });

    _pingTimer?.cancel();

    _pingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        await _pingGoogle();
      },
    );
  }

  static Future<void> _checkInternet() async {
    isConnected =
        await InternetConnection().hasInternetAccess;

    debugPrint('Internet: $isConnected');
  }

  static Future<void> _pingGoogle() async {
    try {
      final stopwatch = Stopwatch()..start();

      final result = await InternetAddress.lookup(
        'google.com',
      );

      stopwatch.stop();

      if (result.isNotEmpty) {
        pingMs = stopwatch.elapsedMilliseconds;
      }

      debugPrint('Ping: $pingMs ms');
    } catch (_) {
      pingMs = 999;
    }
  }

  static void stop() {
    _connectivitySub?.cancel();
    _pingTimer?.cancel();
  }
}
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_ping/dart_ping.dart';
import '../../config/app_config.dart';
import '../utils/logger.dart';

class NetworkService {
  static void start() {
    Connectivity().onConnectivityChanged.listen((result) {
      Logger.logInfo("Network Changed: $result");
    });

    Timer.periodic(Duration(seconds: AppConfig.pingInterval), (timer) async {
      final ping = Ping('8.8.8.8', count: 1);

      await for (final event in ping.stream) {
        if (event.response == null) {
          Logger.logError("Network issue detected");
        } else {
          Logger.logInfo(
            "Ping: ${event.response!.time?.inMilliseconds} ms",
          );
        }
      }
    });
  }
}
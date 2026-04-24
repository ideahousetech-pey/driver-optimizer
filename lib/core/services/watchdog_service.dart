import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../config/app_config.dart';
import '../utils/logger.dart';

class WatchdogService {
  static void start(ServiceInstance service) {
    Timer.periodic(Duration(seconds: AppConfig.watchdogInterval), (timer) {
      Logger.logInfo("Watchdog alive");
    });
  }
}
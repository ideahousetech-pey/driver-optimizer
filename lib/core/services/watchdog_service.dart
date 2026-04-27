import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class WatchdogService {
  static void start(ServiceInstance service) {
    try {
      debugPrint("WATCHDOG STARTED");
    } catch (e) {
      debugPrint("WATCHDOG ERROR: $e");
    }
  }
}
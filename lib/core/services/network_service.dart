import 'package:flutter/foundation.dart';

class NetworkService {
  static void start() {
    try {
      debugPrint("NETWORK STARTED");
    } catch (e) {
      debugPrint("NETWORK ERROR: $e");
    }
  }
}
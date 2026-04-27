import 'package:flutter/foundation.dart';

class NetworkService {
  static void start() {
    try {
      debugPrint("Network Service started");
    } catch (e) {
      debugPrint("NETWORK ERROR: $e");
    }
  }
}
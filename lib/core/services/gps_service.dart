import 'package:flutter/foundation.dart';

class GPSService {
  static void start() {
    try {
      debugPrint("GPS Service started");
      // nanti bisa pakai geolocator
    } catch (e) {
      debugPrint("GPS ERROR: $e");
    }
  }
}
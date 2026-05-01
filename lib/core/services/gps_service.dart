import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class GPSService {
  static StreamSubscription<Position>? _stream;

  static double latitude = 0;
  static double longitude = 0;
  static double accuracy = 0;
  static double speed = 0;

  static Future<void> start() async {
    final enabled = await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      debugPrint('GPS disabled');
      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location denied forever');
      return;
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1,
    );

    _stream?.cancel();

    _stream = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(
      (Position position) {
        latitude = position.latitude;
        longitude = position.longitude;
        accuracy = position.accuracy;
        speed = position.speed * 3.6;

        debugPrint(
          'GPS: $latitude, $longitude | acc: $accuracy',
        );
      },
      onError: (e) {
        debugPrint('GPS Error: $e');
      },
    );
  }

  static void stop() {
    _stream?.cancel();
  }
}
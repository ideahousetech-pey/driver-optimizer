import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class GPSService {
  static StreamSubscription<Position>? _positionStream;

  static Position? currentPosition;

  static double accuracy = 0;
  static double speed = 0;

  static Future<void> start() async {
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint('GPS disabled');
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission ==
          LocationPermission.deniedForever) {
        debugPrint(
          'GPS permission denied forever',
        );
        return;
      }

      const LocationSettings settings =
          LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 3,
      );

      await _positionStream?.cancel();

      _positionStream =
          Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen(
        (Position position) {
          currentPosition = position;

          accuracy = position.accuracy;

          speed = position.speed * 3.6;

          debugPrint(
            'GPS => '
            'Acc: ${accuracy.toStringAsFixed(1)}m '
            '| Speed: ${speed.toStringAsFixed(1)} km/h',
          );
        },
        onError: (e) {
          debugPrint(
            'GPS STREAM ERROR: $e',
          );
        },
      );
    } catch (e) {
      debugPrint('GPS SERVICE ERROR: $e');
    }
  }

  static Future<void> stop() async {
    await _positionStream?.cancel();
  }
}
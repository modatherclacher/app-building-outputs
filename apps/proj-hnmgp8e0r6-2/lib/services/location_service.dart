import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Simulated GPS feed.
///
/// Reading the real device GPS would require the `geolocator` plug-in
/// (platform channels), which is outside this build's constraints, so
/// CarSpot ships a deterministic mock that wanders a few metres every
/// couple of seconds, like a GPS trace of someone walking back to the car.
class LocationService extends ChangeNotifier {
  LocationService();

  static const double _startLatitude = 37.7793;
  static const double _startLongitude = -122.4193;
  static const double _metresPerTick = 6;

  final math.Random _random = math.Random(7);
  Timer? _timer;

  double _latitude = _startLatitude;
  double _longitude = _startLongitude;
  double _headingDeg = 35;

  double get latitude => _latitude;
  double get longitude => _longitude;

  /// Direction the "user" is walking, in degrees clockwise from north.
  double get headingDeg => _headingDeg;

  /// Starts the simulated drift. Safe to call multiple times.
  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 2), (_) => _drift());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _drift() {
    _headingDeg = (_headingDeg + (_random.nextDouble() - 0.5) * 30 + 360) % 360;
    final rad = _headingDeg * math.pi / 180;
    const metresPerDegree = 111320.0;
    _latitude += _metresPerTick * math.cos(rad) / metresPerDegree;
    _longitude += _metresPerTick *
        math.sin(rad) /
        (metresPerDegree * math.cos(_latitude * math.pi / 180));
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

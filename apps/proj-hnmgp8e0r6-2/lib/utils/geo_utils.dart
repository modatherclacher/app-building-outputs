import 'dart:math' as math;

class GeoUtils {
  GeoUtils._();

  static double distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0;
    final phi1 = _radians(lat1);
    final phi2 = _radians(lat2);
    final deltaPhi = _radians(lat2 - lat1);
    final deltaLambda = _radians(lon2 - lon1);
    final a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(deltaLambda / 2) *
            math.sin(deltaLambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double bearingDegrees(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final phi1 = _radians(lat1);
    final phi2 = _radians(lat2);
    final deltaLambda = _radians(lon2 - lon1);
    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static int walkingMinutes(double meters) => math.max(1, (meters / 80).ceil());

  static double _radians(double degrees) => degrees * math.pi / 180;
}

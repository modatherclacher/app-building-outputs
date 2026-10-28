import 'package:flutter/foundation.dart';

@immutable
class ParkingSpot {
  const ParkingSpot({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.savedAt,
    this.note,
  });

  final String id;
  final double latitude;
  final double longitude;
  final DateTime savedAt;
  final String? note;

  ParkingSpot copyWith({String? note}) {
    return ParkingSpot(
      id: id,
      latitude: latitude,
      longitude: longitude,
      savedAt: savedAt,
      note: note,
    );
  }
}

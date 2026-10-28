import 'package:flutter/foundation.dart';

import '../models/parking_spot.dart';
import '../services/location_service.dart';

class CarSpotController extends ChangeNotifier {
  CarSpotController({LocationService? locationService})
      : _location = locationService ?? LocationService() {
    _location.addListener(_onLocationTick);
  }

  final LocationService _location;

  ParkingSpot? _currentSpot;
  final List<ParkingSpot> _history = [];

  LocationService get location => _location;
  ParkingSpot? get currentSpot => _currentSpot;
  List<ParkingSpot> get history => List.unmodifiable(_history);

  ParkingSpot saveCurrentLocation() {
    final spot = ParkingSpot(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      latitude: _location.latitude,
      longitude: _location.longitude,
      savedAt: DateTime.now(),
    );
    final previous = _currentSpot;
    if (previous != null) {
      _history.insert(0, previous);
    }
    _currentSpot = spot;
    notifyListeners();
    return spot;
  }

  void updateNote(String note) {
    final current = _currentSpot;
    if (current == null) {
      return;
    }
    _currentSpot = current.copyWith(note: note.isEmpty ? null : note);
    notifyListeners();
  }

  /// The user reached the car: archive the current spot.
  void foundIt() {
    final current = _currentSpot;
    if (current == null) {
      return;
    }
    _history.insert(0, current);
    _currentSpot = null;
    notifyListeners();
  }

  void removeFromHistory(String id) {
    _history.removeWhere((spot) => spot.id == id);
    notifyListeners();
  }

  void _onLocationTick() {
    notifyListeners();
  }

  @override
  void dispose() {
    _location.removeListener(_onLocationTick);
    _location.dispose();
    super.dispose();
  }
}

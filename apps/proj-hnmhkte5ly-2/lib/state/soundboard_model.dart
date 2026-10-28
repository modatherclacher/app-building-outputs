import 'dart:async';

import 'package:flutter/foundation.dart';

import '../audio/engine.dart';
import '../data/catalog.dart';

/// In-memory state for the soundboard: which sounds are playing, at what
/// volume, plus the active category filter.
class SoundboardModel extends ChangeNotifier {
  SoundboardModel(this._engine) {
    _engine.onFinished = _handleFinished;
  }

  final SoundEngine _engine;
  final Set<String> _active = {};
  final Map<String, double> _volumes = {};

  Set<String> get activeIds => Set.unmodifiable(_active);

  bool isActive(String soundId) => _active.contains(soundId);

  double volumeOf(String soundId) => _volumes[soundId] ?? 1.0;

  /// Starts a sound, or stops it again if it is a currently playing loop.
  Future<void> toggle(Sound sound) async {
    if (sound.loop && _active.contains(sound.id)) {
      await stop(sound);
      return;
    }
    _active.add(sound.id);
    notifyListeners();
    await _engine.play(sound, volume: volumeOf(sound.id));
  }

  Future<void> stop(Sound sound) async {
    await _engine.stop(sound.id);
    if (_active.remove(sound.id)) notifyListeners();
  }

  Future<void> stopAll() async {
    for (final id in _active.toList()) {
      await _engine.stop(id);
    }
    _active.clear();
    notifyListeners();
  }

  Future<void> setVolume(Sound sound, double volume) async {
    _volumes[sound.id] = volume;
    notifyListeners();
    await _engine.setVolume(sound.id, volume);
  }

  void _handleFinished(String soundId) {
    if (_active.remove(soundId)) notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_engine.dispose());
    super.dispose();
  }
}

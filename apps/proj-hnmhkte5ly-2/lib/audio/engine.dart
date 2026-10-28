import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

import '../data/catalog.dart';

/// Plays procedurally generated sounds, one [AudioPlayer] per sound so that
/// loops and one-shots can all be layered at the same time.
class SoundEngine {
  final _players = <String, AudioPlayer>{};
  final _buffers = <String, Uint8List>{};

  /// Called when a non-looping sound finishes on its own.
  void Function(String soundId)? onFinished;

  Uint8List _bufferFor(Sound sound) =>
      _buffers.putIfAbsent(sound.id, sound.render);

  AudioPlayer _playerFor(String soundId) {
    return _players.putIfAbsent(soundId, () {
      final player = AudioPlayer();
      player.onPlayerComplete.listen((_) => onFinished?.call(soundId));
      return player;
    });
  }

  Future<void> play(Sound sound, {required double volume}) async {
    final player = _playerFor(sound.id);
    await player.setReleaseMode(
      sound.loop ? ReleaseMode.loop : ReleaseMode.release,
    );
    await player.setVolume(volume.clamp(0.0, 1.0));
    await player.stop();
    await player.play(BytesSource(_bufferFor(sound)));
  }

  Future<void> stop(String soundId) async {
    await _players[soundId]?.stop();
  }

  Future<void> setVolume(String soundId, double volume) async {
    await _players[soundId]?.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _buffers.clear();
  }
}

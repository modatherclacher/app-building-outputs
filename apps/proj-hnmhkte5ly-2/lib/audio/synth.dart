import 'dart:math';
import 'dart:typed_data';

import 'wav.dart';

/// Sample rate used by every generated clip.
const int synthSampleRate = 44100;

/// Signature for a function that renders a sound into WAV bytes.
typedef SoundRenderer = Uint8List Function();

/// A canvas that sums generated clips and renders them into a WAV buffer.
class Track {
  Track(this.durationSeconds);

  final double durationSeconds;
  late Float32List samples =
      Float32List((durationSeconds * synthSampleRate).round());

  /// Mixes [clip] into the track starting at [at] seconds.
  void add(double at, Float32List clip, {double gain = 1.0}) {
    final start = (at * synthSampleRate).round();
    final end = min(start + clip.length, samples.length);
    for (var i = max(start, 0); i < end; i++) {
      samples[i] += clip[i - start] * gain;
    }
  }

  void overlay(Float32List clip, {double gain = 1.0}) =>
      add(0, clip, gain: gain);

  /// Scales the whole track so its peak amplitude reaches [peak].
  void normalize(double peak) {
    var loudest = 0.0;
    for (final value in samples) {
      loudest = max(loudest, value.abs());
    }
    if (loudest == 0) return;
    final gain = peak / loudest;
    for (var i = 0; i < samples.length; i++) {
      samples[i] *= gain;
    }
  }

  /// Trims the tail and crossfades it over the head so the clip loops cleanly.
  void makeLoopable({double fadeSeconds = 0.05}) {
    final fade = (fadeSeconds * synthSampleRate).round();
    if (samples.length <= fade * 2) return;
    final bodyLength = samples.length - fade;
    final body = Float32List(bodyLength);
    for (var i = 0; i < bodyLength; i++) {
      body[i] = samples[i];
    }
    for (var i = 0; i < fade; i++) {
      final t = i / fade;
      body[i] = body[i] * t + samples[bodyLength + i] * (1 - t);
    }
    samples = body;
  }

  Uint8List toWav() => encodeWav(samples, synthSampleRate);
}

/// Generates a harmonic tone with a pitch curve, vibrato and envelopes.
Float32List tone({
  required double seconds,
  required double Function(double t) pitch,
  int harmonics = 1,
  double harmonicFalloff = 0,
  double attack = 0.004,
  double decay = 6,
  double vibratoHz = 0,
  double vibratoDepth = 0,
  double? release,
}) {
  final length = (seconds * synthSampleRate).round();
  final out = Float32List(length);
  final tail = release ?? min(0.03, seconds / 4);
  var phase = 0.0;
  for (var i = 0; i < length; i++) {
    final t = i / synthSampleRate;
    var freq = pitch(t);
    if (vibratoDepth > 0) {
      freq *= 1 + vibratoDepth * sin(2 * pi * vibratoHz * t);
    }
    phase += 2 * pi * freq / synthSampleRate;
    var value = 0.0;
    for (var h = 1; h <= harmonics; h++) {
      value += sin(h * phase) / pow(h, harmonicFalloff);
    }
    final attackEnv = attack <= 0 ? 1.0 : min(1.0, t / attack);
    final releaseEnv = t > seconds - tail
        ? max(0.0, min(1.0, (seconds - t) / max(tail, 1e-6)))
        : 1.0;
    out[i] = value * attackEnv * exp(-decay * t) * releaseEnv;
  }
  return out;
}

/// White noise between -1 and 1.
Float32List noise({required double seconds, int? seed}) {
  final length = (seconds * synthSampleRate).round();
  final out = Float32List(length);
  final rng = Random(seed);
  for (var i = 0; i < length; i++) {
    out[i] = rng.nextDouble() * 2 - 1;
  }
  return out;
}

/// One-pole low-pass filter.
Float32List lowpass(Float32List input, double cutoffHz) {
  final alpha = exp(-2 * pi * cutoffHz / synthSampleRate);
  final out = Float32List(input.length);
  var state = 0.0;
  for (var i = 0; i < input.length; i++) {
    state = (1 - alpha) * input[i] + alpha * state;
    out[i] = state;
  }
  return out;
}

/// One-pole high-pass filter.
Float32List highpass(Float32List input, double cutoffHz) {
  final lp = lowpass(input, cutoffHz);
  final out = Float32List(input.length);
  for (var i = 0; i < input.length; i++) {
    out[i] = input[i] - lp[i];
  }
  return out;
}

/// Band-pass filter built from the one-pole pair.
Float32List bandpass(Float32List input, double lowHz, double highHz) =>
    highpass(lowpass(input, highHz), lowHz);

/// Applies an attack / exponential-decay envelope to a clip.
Float32List enveloped(Float32List input, {double attack = 0, double decay = 0}) {
  final out = Float32List(input.length);
  for (var i = 0; i < input.length; i++) {
    final t = i / synthSampleRate;
    final a = attack <= 0 ? 1.0 : min(1.0, t / attack);
    final d = decay <= 0 ? 1.0 : exp(-decay * t);
    out[i] = input[i] * a * d;
  }
  return out;
}

/// Applies a slow amplitude wobble (e.g. gusts of rain).
Float32List modulated(Float32List input, double hz, double depth) {
  final out = Float32List(input.length);
  for (var i = 0; i < input.length; i++) {
    final t = i / synthSampleRate;
    out[i] = input[i] * (1 - depth + depth * sin(2 * pi * hz * t));
  }
  return out;
}

// ---------------------------------------------------------------------------
// Funny one-shots
// ---------------------------------------------------------------------------

Uint8List renderBoing() {
  final track = Track(0.8)
    ..overlay(tone(
      seconds: 0.78,
      pitch: (t) => 80 + 240 * exp(-4 * t),
      harmonics: 3,
      harmonicFalloff: 1,
      decay: 3.5,
      vibratoHz: 13,
      vibratoDepth: 0.18,
    ));
  track.normalize(0.8);
  return track.toWav();
}

Uint8List renderZap() {
  final track = Track(0.35)
    ..overlay(tone(
      seconds: 0.33,
      pitch: (t) => 60 + 1500 * exp(-14 * t),
      harmonics: 4,
      harmonicFalloff: 0.8,
      decay: 5,
    ));
  track.normalize(0.8);
  return track.toWav();
}

Uint8List renderBloop() {
  final track = Track(0.3)
    ..overlay(tone(
      seconds: 0.28,
      pitch: (t) => 140 + 500 * (1 - exp(-18 * t)),
      harmonics: 2,
      harmonicFalloff: 1,
      decay: 12,
      attack: 0.002,
    ));
  track.normalize(0.8);
  return track.toWav();
}

Uint8List renderWobble() {
  final track = Track(0.7)
    ..overlay(tone(
      seconds: 0.68,
      pitch: (t) => 120 + 300 * exp(-1.5 * t),
      harmonics: 2,
      harmonicFalloff: 1,
      decay: 5,
      vibratoHz: 10,
      vibratoDepth: 0.5,
    ));
  track.normalize(0.8);
  return track.toWav();
}

Uint8List renderTada() {
  final track = Track(1.0);
  const notes = [659.25, 830.61, 987.77];
  for (var i = 0; i < notes.length; i++) {
    track.add(
      i * 0.09,
      tone(
        seconds: 0.85,
        pitch: (_) => notes[i],
        harmonics: 4,
        harmonicFalloff: 1.5,
        decay: 4,
        attack: 0.002,
      ),
      gain: 0.4,
    );
  }
  track.normalize(0.8);
  return track.toWav();
}

// ---------------------------------------------------------------------------
// Lo-fi loops
// ---------------------------------------------------------------------------

Uint8List renderChillKeys() {
  Float32List chord(List<double> frequencies, double seconds) {
    final out = Float32List((seconds * synthSampleRate).round());
    for (final frequency in frequencies) {
      final voice = tone(
        seconds: seconds,
        pitch: (_) => frequency,
        harmonics: 3,
        harmonicFalloff: 1,
        attack: 0.25,
        decay: 0.6,
        release: 0.4,
        vibratoHz: 5,
        vibratoDepth: 0.004,
      );
      for (var i = 0; i < out.length; i++) {
        out[i] += voice[i];
      }
    }
    return out;
  }

  final track = Track(3.0)
    ..add(0.0, chord([220.0, 261.63, 329.63], 1.5), gain: 0.5)
    ..add(1.5, chord([174.61, 220.0, 261.63, 329.63], 1.5), gain: 0.5);
  track.makeLoopable();
  track.normalize(0.5);
  return track.toWav();
}

Uint8List renderBeatLoop() {
  final kick = tone(
    seconds: 0.3,
    pitch: (t) => 40 + 110 * exp(-25 * t),
    decay: 14,
    attack: 0.001,
  );
  final snare = enveloped(
    bandpass(noise(seconds: 0.22, seed: 11), 1200, 6500),
    attack: 0.002,
    decay: 16,
  );
  final hat = enveloped(
    highpass(noise(seconds: 0.08, seed: 12), 7000),
    attack: 0.001,
    decay: 40,
  );

  final track = Track(3.0)
    ..add(0.0, kick)
    ..add(1.5, kick)
    ..add(0.75, snare)
    ..add(2.25, snare);
  for (var i = 0; i < 8; i++) {
    track.add(i * 0.375, hat, gain: 0.3);
  }
  track.makeLoopable();
  track.normalize(0.6);
  return track.toWav();
}

Uint8List renderBassline() {
  final notes = <(double, double, double)>[
    (0.0, 0.65, 110.0),
    (0.75, 0.3, 110.0),
    (1.5, 0.65, 87.31),
    (2.25, 0.3, 98.0),
  ];
  final track = Track(3.0);
  for (final (at, dur, freq) in notes) {
    final clip = lowpass(
      tone(
        seconds: dur,
        pitch: (_) => freq,
        harmonics: 3,
        harmonicFalloff: 1.2,
        attack: 0.006,
        decay: 4,
      ),
      900,
    );
    track.add(at, clip, gain: 0.9);
  }
  track.makeLoopable();
  track.normalize(0.55);
  return track.toWav();
}

Uint8List renderVinylCrackle() {
  final rng = Random(21);
  final track = Track(4.0)
    ..overlay(lowpass(noise(seconds: 4.0, seed: 20), 3000), gain: 0.06);
  for (var i = 0; i < 70; i++) {
    final pop = enveloped(
      highpass(noise(seconds: 0.012, seed: 100 + i), 1200),
      attack: 0.0005,
      decay: rng.nextDouble() * 120 + 60,
    );
    track.add(rng.nextDouble() * 3.9, pop, gain: 0.2 + rng.nextDouble() * 0.5);
  }
  track.makeLoopable();
  track.normalize(0.35);
  return track.toWav();
}

// ---------------------------------------------------------------------------
// Ambient rain loops
// ---------------------------------------------------------------------------

Uint8List renderRainShower() {
  final track = Track(4.0)
    ..overlay(
      modulated(
        highpass(lowpass(noise(seconds: 4.0, seed: 31), 5200), 380),
        0.4,
        0.15,
      ),
      gain: 0.8,
    );
  final rng = Random(32);
  for (var i = 0; i < 7; i++) {
    final plink = tone(
      seconds: 0.12,
      pitch: (_) => 2200 + rng.nextDouble() * 1800,
      decay: 30,
      attack: 0.001,
    );
    track.add(rng.nextDouble() * 3.8, plink, gain: 0.12);
  }
  track.makeLoopable();
  track.normalize(0.55);
  return track.toWav();
}

Uint8List renderHeavyRain() {
  final track = Track(4.0)
    ..overlay(
      modulated(
        highpass(lowpass(noise(seconds: 4.0, seed: 41), 7500), 240),
        0.3,
        0.1,
      ),
      gain: 1.0,
    )
    ..overlay(lowpass(noise(seconds: 4.0, seed: 42), 140), gain: 0.4);
  track.makeLoopable();
  track.normalize(0.65);
  return track.toWav();
}

Uint8List renderRainWindow() {
  final track = Track(4.0)
    ..overlay(lowpass(noise(seconds: 4.0, seed: 51), 2600), gain: 0.5);
  final rng = Random(52);
  for (var i = 0; i < 14; i++) {
    final frequency = 600 + rng.nextDouble() * 2600;
    final tap = tone(
      seconds: 0.04,
      pitch: (_) => frequency,
      harmonics: 2,
      harmonicFalloff: 1,
      decay: 40,
      attack: 0.0008,
    );
    track.add(rng.nextDouble() * 3.8, tap, gain: 0.2 + rng.nextDouble() * 0.3);
  }
  track.makeLoopable();
  track.normalize(0.5);
  return track.toWav();
}

Uint8List renderThunder() {
  final track = Track(6.0)
    ..overlay(
      highpass(lowpass(noise(seconds: 6.0, seed: 61), 4500), 350),
      gain: 0.3,
    );
  for (var i = 0; i < 2; i++) {
    final rumble = enveloped(
      lowpass(noise(seconds: 2.6, seed: 63 + i), 90.0 + i * 40),
      attack: 0.5,
      decay: 1.2 + 0.4 * i,
    );
    track.add(1.2 + i * 2.9, rumble, gain: 1.2 - 0.3 * i);
  }
  track.makeLoopable();
  track.normalize(0.6);
  return track.toWav();
}

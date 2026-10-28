import 'dart:typed_data';

/// Encodes mono 16-bit PCM samples into a WAV file buffer.
Uint8List encodeWav(Float32List samples, int sampleRate) {
  const headerSize = 44;
  final dataLength = samples.length * 2;
  final bytes = Uint8List(headerSize + dataLength);
  final view = ByteData.sublistView(bytes);

  void writeAscii(int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      view.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  writeAscii(0, 'RIFF');
  view.setUint32(4, 36 + dataLength, Endian.little);
  writeAscii(8, 'WAVE');
  writeAscii(12, 'fmt ');
  view.setUint32(16, 16, Endian.little); // chunk size
  view.setUint16(20, 1, Endian.little); // PCM format
  view.setUint16(22, 1, Endian.little); // mono
  view.setUint32(24, sampleRate, Endian.little);
  view.setUint32(28, sampleRate * 2, Endian.little); // byte rate
  view.setUint16(32, 2, Endian.little); // block align
  view.setUint16(34, 16, Endian.little); // bits per sample
  writeAscii(36, 'data');
  view.setUint32(40, dataLength, Endian.little);

  for (var i = 0; i < samples.length; i++) {
    final value = samples[i].clamp(-1.0, 1.0);
    view.setInt16(
      headerSize + i * 2,
      (value * 32767).round(),
      Endian.little,
    );
  }
  return bytes;
}

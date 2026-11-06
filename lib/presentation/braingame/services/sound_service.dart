// sound service untuk feedback benar/salah
// menggunakan audioplayers, generate tone via TTS fallback
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // set volume
    await _correctPlayer.setVolume(0.7);
    await _wrongPlayer.setVolume(0.7);

    _initialized = true;
  }

  /// play feedback benar — short high tone
  Future<void> playCorrect() async {
    // gunakan system notification sound sebagai fallback
    await HapticFeedback.lightImpact();
    await _correctPlayer.stop();
    // generate short beep via data uri
    await _correctPlayer.play(
      BytesSource(_generateBeep(frequency: 880, durationMs: 150)),
    );
  }

  /// play feedback salah — low buzz
  Future<void> playWrong() async {
    await HapticFeedback.heavyImpact();
    await _wrongPlayer.stop();
    await _wrongPlayer.play(
      BytesSource(_generateBeep(frequency: 220, durationMs: 300)),
    );
  }

  /// generate WAV beep tone
  Uint8List _generateBeep({
    required double frequency,
    required int durationMs,
    int sampleRate = 44100,
  }) {
    final numSamples = (sampleRate * durationMs / 1000).round();
    final samples = Uint8List(numSamples * 2); // 16-bit mono

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      // sine wave dengan fade out
      final envelope = 1.0 - (i / numSamples);
      final value = (32767 * envelope * _sin(2 * 3.14159265359 * frequency * t))
          .round();
      // little-endian 16-bit
      samples[i * 2] = value & 0xFF;
      samples[i * 2 + 1] = (value >> 8) & 0xFF;
    }

    // build WAV file
    return _buildWav(samples, sampleRate);
  }

  double _sin(double x) {
    // simple sine approximation
    x = x % (2 * 3.14159265359);
    if (x < 0) x += 2 * 3.14159265359;
    // Taylor series is inaccurate for large x, use dart:math instead
    return _dartSin(x);
  }

  double _dartSin(double x) {
    // using dart's built-in
    return x.isNaN ? 0 : _sinImpl(x);
  }

  double _sinImpl(double x) {
    // normalize to [-pi, pi]
    const pi = 3.14159265359;
    x = x % (2 * pi);
    if (x > pi) x -= 2 * pi;
    // Bhaskara I's approximation
    final abs = x < 0 ? -x : x;
    final sign = x < 0 ? -1.0 : 1.0;
    return sign * 16 * abs * (pi - abs) / (5 * pi * pi - 4 * abs * (pi - abs));
  }

  Uint8List _buildWav(Uint8List samples, int sampleRate) {
    final dataSize = samples.length;
    final fileSize = 36 + dataSize;
    final header = Uint8List(44);
    final bd = ByteData.view(header.buffer);

    // RIFF header
    header[0] = 0x52; // R
    header[1] = 0x49; // I
    header[2] = 0x46; // F
    header[3] = 0x46; // F
    bd.setUint32(4, fileSize, Endian.little);
    header[8] = 0x57; // W
    header[9] = 0x41; // A
    header[10] = 0x56; // V
    header[11] = 0x45; // E

    // fmt chunk
    header[12] = 0x66; // f
    header[13] = 0x6D; // m
    header[14] = 0x74; // t
    header[15] = 0x20; // (space)
    bd.setUint32(16, 16, Endian.little); // chunk size
    bd.setUint16(20, 1, Endian.little); // PCM format
    bd.setUint16(22, 1, Endian.little); // mono
    bd.setUint32(24, sampleRate, Endian.little);
    bd.setUint32(28, sampleRate * 2, Endian.little); // byte rate
    bd.setUint16(32, 2, Endian.little); // block align
    bd.setUint16(34, 16, Endian.little); // bits per sample

    // data chunk
    header[36] = 0x64; // d
    header[37] = 0x61; // a
    header[38] = 0x74; // t
    header[39] = 0x61; // a
    bd.setUint32(40, dataSize, Endian.little);

    // combine header + data
    final wav = Uint8List(44 + dataSize);
    wav.setRange(0, 44, header);
    wav.setRange(44, 44 + dataSize, samples);
    return wav;
  }

  void dispose() {
    _correctPlayer.dispose();
    _wrongPlayer.dispose();
  }
}

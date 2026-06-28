import 'dart:math' as math;
import 'dart:typed_data';

import '../models/morse_timing.dart';

/// Synthesizes a Morse [ToneSegment] timeline into an in-memory 16-bit PCM
/// mono WAV file, ready to hand to an audio player.
class WavSynth {
  const WavSynth();

  static const int sampleRate = 44100;
  static const int _bitsPerSample = 16;
  static const int _channels = 1;

  /// Peak amplitude as a fraction of full scale (headroom to avoid clipping).
  static const double _amplitude = 0.7 * 32767;

  /// Attack/release ramp length, in milliseconds, applied to each tone element
  /// with a raised-cosine (Hann) envelope to eliminate clicks.
  static const double _rampMs = 5.0;

  /// Builds a complete WAV byte buffer for [segments] at pitch [toneHz].
  Uint8List synthesize(List<ToneSegment> segments, {required int toneHz}) {
    final samples = _renderSamples(segments, toneHz);
    return _wrapWav(samples);
  }

  Int16List _renderSamples(List<ToneSegment> segments, int toneHz) {
    final totalSamples = segments.fold<int>(
      0,
      (sum, s) => sum + _msToSamples(s.ms),
    );
    final out = Int16List(totalSamples);

    var offset = 0;
    final twoPiFOverSr = 2 * math.pi * toneHz / sampleRate;
    for (final seg in segments) {
      final n = _msToSamples(seg.ms);
      if (seg.on) {
        final ramp = math.min(_msToSamples(_rampMs.round()), n ~/ 2);
        for (var i = 0; i < n; i++) {
          var gain = 1.0;
          if (ramp > 0 && i < ramp) {
            gain = 0.5 * (1 - math.cos(math.pi * i / ramp));
          } else if (ramp > 0 && i >= n - ramp) {
            gain = 0.5 * (1 - math.cos(math.pi * (n - 1 - i) / ramp));
          }
          out[offset + i] = (_amplitude * gain * math.sin(twoPiFOverSr * i)).round();
        }
      }
      // silence segments stay zero-filled
      offset += n;
    }
    return out;
  }

  int _msToSamples(int ms) => (ms / 1000.0 * sampleRate).round();

  /// Prepends a 44-byte canonical WAV header to the PCM sample data.
  Uint8List _wrapWav(Int16List samples) {
    final dataSize = samples.length * 2; // 16-bit
    final fileSize = 44 + dataSize;
    final bytes = Uint8List(fileSize);
    final view = ByteData.view(bytes.buffer);

    void writeAscii(int at, String s) {
      for (var i = 0; i < s.length; i++) {
        bytes[at + i] = s.codeUnitAt(i);
      }
    }

    const byteRate = sampleRate * _channels * _bitsPerSample ~/ 8;
    const blockAlign = _channels * _bitsPerSample ~/ 8;

    writeAscii(0, 'RIFF');
    view.setUint32(4, fileSize - 8, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    view.setUint32(16, 16, Endian.little); // PCM fmt chunk size
    view.setUint16(20, 1, Endian.little); // audio format = PCM
    view.setUint16(22, _channels, Endian.little);
    view.setUint32(24, sampleRate, Endian.little);
    view.setUint32(28, byteRate, Endian.little);
    view.setUint16(32, blockAlign, Endian.little);
    view.setUint16(34, _bitsPerSample, Endian.little);
    writeAscii(36, 'data');
    view.setUint32(40, dataSize, Endian.little);

    // Sample data, little-endian 16-bit signed.
    var at = 44;
    for (final s in samples) {
      view.setInt16(at, s, Endian.little);
      at += 2;
    }
    return bytes;
  }
}

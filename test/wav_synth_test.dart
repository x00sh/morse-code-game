import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:morse_code_game/models/morse_timing.dart';
import 'package:morse_code_game/services/wav_synth.dart';

void main() {
  const synth = WavSynth();

  String ascii(Uint8List b, int at, int len) =>
      String.fromCharCodes(b.sublist(at, at + len));

  test('produces a valid WAV header', () {
    final bytes = synth.synthesize(
      const [ToneSegment(on: true, ms: 60)],
      toneHz: 600,
    );
    final view = ByteData.view(bytes.buffer);

    // 60 ms at 44100 Hz -> 2646 samples -> 5292 data bytes.
    const expectedSamples = 2646;
    const expectedData = expectedSamples * 2;

    expect(ascii(bytes, 0, 4), 'RIFF');
    expect(ascii(bytes, 8, 4), 'WAVE');
    expect(ascii(bytes, 12, 4), 'fmt ');
    expect(ascii(bytes, 36, 4), 'data');

    expect(view.getUint16(20, Endian.little), 1); // PCM
    expect(view.getUint16(22, Endian.little), 1); // mono
    expect(view.getUint32(24, Endian.little), WavSynth.sampleRate);
    expect(view.getUint16(34, Endian.little), 16); // bits per sample
    expect(view.getUint32(40, Endian.little), expectedData);
    expect(bytes.length, 44 + expectedData);
  });

  test('tone segment contains non-zero samples; silence stays zero', () {
    final tone = synth.synthesize(
      const [ToneSegment(on: true, ms: 60)],
      toneHz: 600,
    );
    final silence = synth.synthesize(
      const [ToneSegment(on: false, ms: 60)],
      toneHz: 600,
    );

    final toneData = tone.sublist(44);
    final silenceData = silence.sublist(44);

    expect(toneData.any((b) => b != 0), isTrue);
    expect(silenceData.every((b) => b == 0), isTrue);
  });

  test('first sample of a tone is ~zero due to the attack envelope', () {
    final bytes = synth.synthesize(
      const [ToneSegment(on: true, ms: 60)],
      toneHz: 600,
    );
    final view = ByteData.view(bytes.buffer);
    expect(view.getInt16(44, Endian.little).abs(), lessThan(50));
  });
}

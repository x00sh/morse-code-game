import 'package:flutter_test/flutter_test.dart';
import 'package:morse_code_game/models/morse_timing.dart';
import 'package:morse_code_game/services/morse_codec.dart';

void main() {
  group('normalize', () {
    test('uppercases, trims, collapses whitespace', () {
      expect(MorseCodec.normalize('  hello   world '), 'HELLO WORLD');
    });
  });

  group('encodeDisplay', () {
    test('encodes a word', () {
      expect(MorseCodec.encodeDisplay('SOS'), '... --- ...');
    });

    test('encodes a phrase with word separator', () {
      expect(MorseCodec.encodeDisplay('E T'), '. / -');
    });
  });

  group('isCorrect', () {
    test('case-insensitive and space-insensitive', () {
      expect(MorseCodec.isCorrect('hello world', 'HELLO WORLD'), isTrue);
      expect(MorseCodec.isCorrect('helloworld', 'HELLO WORLD'), isTrue);
    });

    test('rejects wrong answers', () {
      expect(MorseCodec.isCorrect('helo', 'HELLO'), isFalse);
    });
  });

  group('buildSegments', () {
    const timing = MorseTiming(charWpm: 20, effectiveWpm: 20);

    test('single dit character yields one tone', () {
      final segs = MorseCodec.buildSegments('E', timing);
      expect(segs.length, 1);
      expect(segs.single.on, isTrue);
      expect(segs.single.ms, timing.ditMs);
    });

    test('A = dit, intra-gap, dah', () {
      final segs = MorseCodec.buildSegments('A', timing);
      expect(segs.map((s) => s.on).toList(), [true, false, true]);
      expect(segs[0].ms, timing.ditMs);
      expect(segs[1].ms, timing.intraCharGapMs);
      expect(segs[2].ms, timing.dahMs);
    });

    test('segments strictly alternate, starting and ending on a tone', () {
      final segs = MorseCodec.buildSegments('HELLO WORLD', timing);
      expect(segs.first.on, isTrue);
      expect(segs.last.on, isTrue);
      for (var i = 1; i < segs.length; i++) {
        expect(segs[i].on, isNot(segs[i - 1].on),
            reason: 'segment $i should differ from previous');
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:morse_code_game/models/morse_timing.dart';

void main() {
  group('standard timing at 20 WPM', () {
    const t = MorseTiming(charWpm: 20, effectiveWpm: 20);

    test('PARIS units', () {
      expect(t.ditMs, 60); // 1200 / 20
      expect(t.dahMs, 180); // 3 units
      expect(t.intraCharGapMs, 60); // 1 unit
      expect(t.interCharGapMs, 180); // 3 units
      expect(t.interWordGapMs, 420); // 7 units
    });
  });

  group('Farnsworth (char 20 / overall 10)', () {
    const t = MorseTiming(charWpm: 20, effectiveWpm: 10);

    test('element lengths stay at character speed', () {
      expect(t.ditMs, 60);
      expect(t.dahMs, 180);
      expect(t.intraCharGapMs, 60);
    });

    test('spacing gaps are stretched beyond standard', () {
      expect(t.interCharGapMs, greaterThan(180));
      expect(t.interWordGapMs, greaterThan(420));
    });
  });

  test('overall faster than char never tightens below standard spacing', () {
    const t = MorseTiming(charWpm: 20, effectiveWpm: 40);
    expect(t.interCharGapMs, 180);
    expect(t.interWordGapMs, 420);
  });
}

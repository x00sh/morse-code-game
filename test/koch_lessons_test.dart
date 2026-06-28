import 'package:flutter_test/flutter_test.dart';
import 'package:morse_code_game/models/koch_lessons.dart';
import 'package:morse_code_game/models/morse_alphabet.dart';

void main() {
  group('kKochOrder', () {
    test('has 40 characters, all known to the alphabet', () {
      expect(kKochOrder.length, 41);
      for (final ch in kKochOrder) {
        expect(kMorseAlphabet.containsKey(ch), isTrue, reason: '$ch missing');
      }
    });

    test('starts with K and M and has no duplicates', () {
      expect(kKochOrder[0], 'K');
      expect(kKochOrder[1], 'M');
      expect(kKochOrder.toSet().length, kKochOrder.length);
    });

    test('excludes the + character', () {
      expect(kKochOrder.contains('+'), isFalse);
    });
  });

  group('KochLesson', () {
    test('there are kKochOrder.length - 1 lessons', () {
      expect(kAllLessons.length, kKochOrder.length - 1);
      expect(kAllLessons.first.unlockedCount, kKochInitialUnlockCount);
      expect(kAllLessons.last.unlockedCount, kKochOrder.length);
    });

    test('first lesson introduces both K and M', () {
      expect(const KochLesson(2).newChars, ['K', 'M']);
    });

    test('later lessons introduce a single new character', () {
      expect(const KochLesson(3).newChars, ['U']);
      expect(const KochLesson(4).newChars, ['R']);
    });

    test('unlockedChars is the matching prefix of the order', () {
      const lesson = KochLesson(5);
      expect(lesson.unlockedChars, kKochOrder.sublist(0, 5));
      expect(lesson.unlockedChars.length, lesson.unlockedCount);
    });

    test('isFinal only at the full set', () {
      expect(KochLesson(kKochOrder.length).isFinal, isTrue);
      expect(KochLesson(kKochOrder.length - 1).isFinal, isFalse);
    });
  });

  group('nextUnlockedCount', () {
    test('frontier pass unlocks the next character', () {
      expect(
        nextUnlockedCount(
            sessionUnlockedCount: 2, currentUnlocked: 2, correct: 23, attempts: 25),
        3,
      );
    });

    test('exactly 90% unlocks', () {
      expect(
        nextUnlockedCount(
            sessionUnlockedCount: 2, currentUnlocked: 2, correct: 18, attempts: 20),
        3,
      );
    });

    test('below threshold does not unlock', () {
      expect(
        nextUnlockedCount(
            sessionUnlockedCount: 2, currentUnlocked: 2, correct: 22, attempts: 25),
        2,
      );
    });

    test('replaying a passed lesson never changes the count', () {
      expect(
        nextUnlockedCount(
            sessionUnlockedCount: 3, currentUnlocked: 10, correct: 25, attempts: 25),
        10,
      );
    });

    test('the final lesson cannot unlock further', () {
      final n = kKochOrder.length;
      expect(
        nextUnlockedCount(
            sessionUnlockedCount: n, currentUnlocked: n, correct: 25, attempts: 25),
        n,
      );
    });

    test('zero attempts never unlocks', () {
      expect(
        nextUnlockedCount(
            sessionUnlockedCount: 2, currentUnlocked: 2, correct: 0, attempts: 0),
        2,
      );
    });
  });

  group('pickKochChar', () {
    test('only ever returns an unlocked character', () {
      const lesson = KochLesson(5);
      var i = 0;
      for (var n = 0; n < 100; n++) {
        final ch = pickKochChar(
          unlocked: lesson.unlockedChars,
          newChars: lesson.newChars,
          nextDouble: () => (i++ % 100) / 100,
        );
        expect(lesson.unlockedChars.contains(ch), isTrue);
      }
    });

    test('lesson 1 splits K and M evenly (both weighted)', () {
      const lesson = KochLesson(2);
      String pick(double v) => pickKochChar(
            unlocked: lesson.unlockedChars,
            newChars: lesson.newChars,
            nextDouble: () => v,
          );
      expect(pick(0.0), 'K');
      expect(pick(0.49), 'K');
      expect(pick(0.5), 'M');
      expect(pick(0.99), 'M');
    });

    test('the new character occupies its weighted share of the range', () {
      // unlocked [K, M, U], U is new with weight 2, total weight 4 → U holds
      // the top half of the [0,1) roll range.
      const lesson = KochLesson(3);
      String pick(double v) => pickKochChar(
            unlocked: lesson.unlockedChars,
            newChars: lesson.newChars,
            nextDouble: () => v,
          );
      expect(pick(0.1), 'K');
      expect(pick(0.3), 'M');
      expect(pick(0.6), 'U');
      expect(pick(0.9), 'U');
    });
  });
}

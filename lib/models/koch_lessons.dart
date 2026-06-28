import 'morse_alphabet.dart';

/// Koch-method lesson logic. Pure data + functions (no Flutter/audio imports) so
/// the ordering, lesson derivation, character selection, and unlock decision can
/// be unit-tested without the platform.
///
/// The Koch method drills characters by ear at full character speed, introducing
/// two characters to start (K, M) and one more each time the learner reaches a
/// target accuracy. A lesson is identified by its *unlocked character count* `n`
/// (2..[kKochOrder.length]) rather than a 1-based number, because that count is
/// exactly what we persist — which avoids off-by-one bugs.

/// Standard LCWO Koch character order, filtered to characters the codec knows
/// about ([kMorseAlphabet]). Every LCWO character already exists in the alphabet,
/// so the filter is defensive: it keeps this list valid if the alphabet changes.
final List<String> kKochOrder = const [
  'K', 'M', 'U', 'R', 'E', 'S', 'N', 'A', 'P', 'T', 'L', 'W', 'I', 'J',
  'Z', 'F', 'O', 'Y', 'V', 'G', 'Q', 'H', 'B', 'C', 'D', 'X',
  '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
].where(kMorseAlphabet.containsKey).toList(growable: false);

/// Prompts shown per lesson drill.
const int kKochSessionLength = 25;

/// Accuracy (0..1) required on the frontier lesson to unlock the next character.
const double kKochPassAccuracy = 0.90;

/// How much more likely the newly introduced character is than each older one.
const int kKochNewCharWeight = 2;

/// Characters unlocked on a fresh install (K + M).
const int kKochInitialUnlockCount = 2;

/// Delay before auto-advancing after a one-shot answer, so the revealed
/// character is readable.
const int kKochAdvanceMs = 600;

/// A single Koch lesson, identified by how many characters it unlocks.
class KochLesson {
  const KochLesson(this.unlockedCount);

  /// Number of characters available in this lesson (2..[kKochOrder.length]).
  final int unlockedCount;

  /// The characters quizzed in this lesson: the first [unlockedCount] of the
  /// Koch order.
  List<String> get unlockedChars => kKochOrder.sublist(0, unlockedCount);

  /// The character(s) this lesson introduces. The first lesson introduces both
  /// K and M; every later lesson introduces a single new character.
  List<String> get newChars => unlockedCount <= kKochInitialUnlockCount
      ? kKochOrder.sublist(0, kKochInitialUnlockCount)
      : [kKochOrder[unlockedCount - 1]];

  /// Human label, e.g. `"Lesson 1: +K M"` or `"Lesson 2: +U"`.
  String get label =>
      'Lesson ${unlockedCount - kKochInitialUnlockCount + 1}: ${newChars.join(' ')}';

  /// True when there is no further character to unlock.
  bool get isFinal => unlockedCount >= kKochOrder.length;
}

/// Every lesson, from the starting pair up to the full set.
final List<KochLesson> kAllLessons = [
  for (var n = kKochInitialUnlockCount; n <= kKochOrder.length; n++)
    KochLesson(n),
];

/// Decides the unlock count after finishing a lesson session.
///
/// Returns an *increased* count only when the played lesson is the current
/// frontier ([sessionUnlockedCount] == [currentUnlocked]), it is not already the
/// final lesson, and the session accuracy reached [kKochPassAccuracy]. In every
/// other case (replaying an earlier lesson, the final lesson, too few correct,
/// or no attempts) the count is returned unchanged.
int nextUnlockedCount({
  required int sessionUnlockedCount,
  required int currentUnlocked,
  required int correct,
  required int attempts,
}) {
  final accuracy = attempts == 0 ? 0.0 : correct / attempts;
  final isFrontier = sessionUnlockedCount == currentUnlocked;
  final canGrow = sessionUnlockedCount < kKochOrder.length;
  if (isFrontier && canGrow && accuracy >= kKochPassAccuracy) {
    return currentUnlocked + 1;
  }
  return currentUnlocked;
}

/// Picks the next character to quiz, weighting the newly introduced character(s)
/// by [kKochNewCharWeight]. [nextDouble] supplies a value in [0, 1) (inject
/// `math.Random().nextDouble` in production; a stub in tests).
String pickKochChar({
  required List<String> unlocked,
  required List<String> newChars,
  required double Function() nextDouble,
}) {
  var total = 0;
  for (final ch in unlocked) {
    total += newChars.contains(ch) ? kKochNewCharWeight : 1;
  }
  var roll = nextDouble() * total;
  for (final ch in unlocked) {
    roll -= newChars.contains(ch) ? kKochNewCharWeight : 1;
    if (roll < 0) return ch;
  }
  return unlocked.last; // fallback for floating-point edge at the very end
}

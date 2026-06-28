import '../models/morse_alphabet.dart';
import '../models/morse_timing.dart';

/// Pure text <-> Morse conversions plus the shared tone timeline builder.
class MorseCodec {
  const MorseCodec();

  /// Normalizes text for display/storage: uppercased, trimmed, internal runs of
  /// whitespace collapsed to a single space.
  static String normalize(String text) =>
      text.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Encodes [text] to a display Morse string: characters joined by single
  /// spaces, words joined by " / ". Unknown characters are skipped.
  static String encodeDisplay(String text) {
    final words = normalize(text).split(' ');
    final encodedWords = <String>[];
    for (final word in words) {
      final codes = <String>[];
      for (final ch in word.split('')) {
        final code = kMorseAlphabet[ch];
        if (code != null) codes.add(code);
      }
      if (codes.isNotEmpty) encodedWords.add(codes.join(' '));
    }
    return encodedWords.join(' / ');
  }

  /// Lenient correctness check: case-insensitive and ignoring all whitespace,
  /// so a missed word-gap on a phrase still counts.
  static bool isCorrect(String input, String answer) =>
      _canonical(input) == _canonical(answer);

  static String _canonical(String s) =>
      s.toUpperCase().replaceAll(RegExp(r'\s+'), '');

  /// Builds the tone-on/silence timeline for [text] at the given [timing].
  /// Always starts with a tone and ends with a tone (no leading/trailing gap),
  /// which keeps audio synthesis and the vibration pattern in lock-step.
  static List<ToneSegment> buildSegments(String text, MorseTiming timing) {
    final segments = <ToneSegment>[];
    final words = normalize(text).split(' ').where((w) => w.isNotEmpty).toList();

    for (var wi = 0; wi < words.length; wi++) {
      final chars = words[wi].split('').where(kMorseAlphabet.containsKey).toList();
      for (var ci = 0; ci < chars.length; ci++) {
        final code = kMorseAlphabet[chars[ci]]!;
        for (var ei = 0; ei < code.length; ei++) {
          final isDit = code[ei] == '.';
          segments.add(ToneSegment(on: true, ms: isDit ? timing.ditMs : timing.dahMs));
          if (ei < code.length - 1) {
            segments.add(ToneSegment(on: false, ms: timing.intraCharGapMs));
          }
        }
        if (ci < chars.length - 1) {
          segments.add(ToneSegment(on: false, ms: timing.interCharGapMs));
        }
      }
      if (wi < words.length - 1) {
        segments.add(ToneSegment(on: false, ms: timing.interWordGapMs));
      }
    }
    return segments;
  }
}

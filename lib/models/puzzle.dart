import 'morse_timing.dart';
import 'prompt_mode.dart';

/// A single round: the answer text, its Morse rendering, how it is presented,
/// and the precomputed tone timeline (shared by audio + haptics).
class Puzzle {
  /// The normalized plain-text answer, e.g. "HELLO WORLD".
  final String answer;

  /// Display Morse string, letters joined by spaces and words by " / ",
  /// e.g. ".... . .-.. .-.. ---".
  final String morse;

  /// How this puzzle is presented (visual symbols or audio).
  final PromptMode mode;

  /// Tone-on/silence timeline used to synthesize audio and drive haptics.
  final List<ToneSegment> segments;

  const Puzzle({
    required this.answer,
    required this.morse,
    required this.mode,
    required this.segments,
  });
}

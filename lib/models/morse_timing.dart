/// PARIS-based Morse timing, in milliseconds, derived from words-per-minute.
///
/// This is the single source of truth for element durations. Both the audio
/// synthesizer ([wav_synth]) and the haptic pattern builder ([haptic_service])
/// consume the same [ToneSegment] timeline so audio and vibration stay identical.
///
/// Standard timing (1 "unit" = one dit at character speed):
///   dit = 1u, dah = 3u, intra-character gap = 1u,
///   inter-character gap = 3u, inter-word gap = 7u.
///
/// Farnsworth: characters are sent at the faster character speed while the
/// inter-character and inter-word gaps are stretched so the *overall* speed is
/// slower — easier to recognise characters without slowing the elements down.
class MorseTiming {
  /// Character speed in WPM (governs dit/dah/intra-gap length).
  final int charWpm;

  /// Overall (effective) speed in WPM. When `>= charWpm`, spacing is standard.
  final int effectiveWpm;

  const MorseTiming({required this.charWpm, required this.effectiveWpm});

  /// Dit unit at character speed: 1200 / WPM (PARIS = 50 units/word).
  double get _charUnitMs => 1200.0 / charWpm;

  /// Farnsworth spacing unit. Equals the character unit when no Farnsworth
  /// slow-down is requested; otherwise the extra time is spread across the 19
  /// spacing units in a standard "PARIS " word (4×3 inter-char + 1×7 inter-word).
  double get _spacingUnitMs {
    if (effectiveWpm >= charWpm) return _charUnitMs;
    final wordTimeMs = 60000.0 / effectiveWpm; // 50 units at the overall speed
    final charElementsMs = 31.0 * _charUnitMs; // the 31 "character" units
    final spacingMs = wordTimeMs - charElementsMs; // time left for 19 spacing units
    final unit = spacingMs / 19.0;
    // Never tighter than standard spacing.
    return unit < _charUnitMs ? _charUnitMs : unit;
  }

  int get ditMs => _charUnitMs.round();
  int get dahMs => (3 * _charUnitMs).round();
  int get intraCharGapMs => _charUnitMs.round();
  int get interCharGapMs => (3 * _spacingUnitMs).round();
  int get interWordGapMs => (7 * _spacingUnitMs).round();
}

/// One segment of a Morse timeline: either tone-on or silence, for [ms] millis.
class ToneSegment {
  final bool on;
  final int ms;
  const ToneSegment({required this.on, required this.ms});
}

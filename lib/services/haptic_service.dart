import 'package:vibration/vibration.dart';

import '../models/morse_timing.dart';

/// Vibrates the Morse pattern described by a [ToneSegment] timeline.
///
/// On capable Android/iOS devices this reproduces dits and dahs as distinct
/// buzz lengths. On older devices without custom-pattern support the OS may
/// emulate the pattern as uniform buzzes; we still attempt playback.
class HapticService {
  bool? _hasVibrator;

  /// Whether the device reports a vibrator. Cached after the first check.
  Future<bool> get hasVibrator async {
    _hasVibrator ??= (await Vibration.hasVibrator()) == true;
    return _hasVibrator!;
  }

  /// Plays [segments] as a vibration pattern.
  ///
  /// The `vibration` package expects a pattern of `[wait, on, off, on, ...]`
  /// (the first value is an initial wait). Our timeline always starts with a
  /// tone and strictly alternates on/off, so we prefix a single `0` wait and
  /// append the segment durations in order.
  Future<void> play(List<ToneSegment> segments) async {
    if (segments.isEmpty) return;
    if (!await hasVibrator) return;
    final pattern = <int>[0, ...segments.map((s) => s.ms)];
    await Vibration.vibrate(pattern: pattern);
  }

  Future<void> cancel() async {
    if (await hasVibrator) {
      await Vibration.cancel();
    }
  }
}

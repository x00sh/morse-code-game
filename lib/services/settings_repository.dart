import 'package:shared_preferences/shared_preferences.dart';

import '../models/audio_settings.dart';
import '../models/koch_lessons.dart';

/// Persists [AudioSettings], the best timed-mode score, and Koch-lesson
/// progress using `shared_preferences`.
class SettingsRepository {
  static const _kCharWpm = 'char_wpm';
  static const _kEffectiveWpm = 'effective_wpm';
  static const _kToneHz = 'tone_hz';
  static const _kHaptics = 'haptics_enabled';
  static const _kBestScore = 'best_timed_score';
  static const _kKochUnlocked = 'koch_unlocked_count';

  Future<AudioSettings> loadSettings() async {
    final p = await SharedPreferences.getInstance();
    const defaults = AudioSettings.defaults();
    return AudioSettings(
      charWpm: p.getInt(_kCharWpm) ?? defaults.charWpm,
      effectiveWpm: p.getInt(_kEffectiveWpm) ?? defaults.effectiveWpm,
      toneHz: p.getInt(_kToneHz) ?? defaults.toneHz,
      hapticsEnabled: p.getBool(_kHaptics) ?? defaults.hapticsEnabled,
    );
  }

  Future<void> saveSettings(AudioSettings s) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kCharWpm, s.charWpm);
    await p.setInt(_kEffectiveWpm, s.effectiveWpm);
    await p.setInt(_kToneHz, s.toneHz);
    await p.setBool(_kHaptics, s.hapticsEnabled);
  }

  Future<int> loadBestScore() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kBestScore) ?? 0;
  }

  Future<void> saveBestScore(int score) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kBestScore, score);
  }

  /// Number of Koch characters the learner has unlocked (2 on a fresh install).
  Future<int> loadKochUnlocked() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kKochUnlocked) ?? kKochInitialUnlockCount;
  }

  Future<void> saveKochUnlocked(int count) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kKochUnlocked, count);
  }
}

import 'package:flutter/foundation.dart';

import '../models/audio_settings.dart';
import '../services/settings_repository.dart';

/// Holds the current [AudioSettings] and persists changes.
class SettingsController extends ChangeNotifier {
  SettingsController(this._repo);

  final SettingsRepository _repo;
  AudioSettings _settings = const AudioSettings.defaults();
  AudioSettings get settings => _settings;

  /// Loads persisted settings; call once at startup.
  Future<void> load() async {
    _settings = await _repo.loadSettings();
    notifyListeners();
  }

  Future<void> _update(AudioSettings next) async {
    _settings = next;
    notifyListeners();
    await _repo.saveSettings(next);
  }

  Future<void> setCharWpm(int v) => _update(_settings.copyWith(charWpm: v));
  Future<void> setEffectiveWpm(int v) => _update(_settings.copyWith(effectiveWpm: v));
  Future<void> setToneHz(int v) => _update(_settings.copyWith(toneHz: v));
  Future<void> setHaptics(bool v) => _update(_settings.copyWith(hapticsEnabled: v));
}

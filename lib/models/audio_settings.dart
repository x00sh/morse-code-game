/// User-adjustable audio/feedback settings, persisted via [SettingsRepository].
class AudioSettings {
  /// Character speed in words-per-minute (governs dit/dah length).
  final int charWpm;

  /// Overall (Farnsworth) speed in WPM. Equal to [charWpm] = no Farnsworth.
  final int effectiveWpm;

  /// Tone pitch in Hz for the audio beeps.
  final int toneHz;

  /// Whether to vibrate the Morse pattern alongside (or instead of) audio.
  final bool hapticsEnabled;

  const AudioSettings({
    required this.charWpm,
    required this.effectiveWpm,
    required this.toneHz,
    required this.hapticsEnabled,
  });

  /// Sensible defaults for a new install.
  const AudioSettings.defaults()
      : charWpm = 20,
        effectiveWpm = 20,
        toneHz = 600,
        hapticsEnabled = true;

  AudioSettings copyWith({
    int? charWpm,
    int? effectiveWpm,
    int? toneHz,
    bool? hapticsEnabled,
  }) {
    final newCharWpm = charWpm ?? this.charWpm;
    var newEffective = effectiveWpm ?? this.effectiveWpm;
    // Overall speed can never exceed character speed.
    if (newEffective > newCharWpm) newEffective = newCharWpm;
    return AudioSettings(
      charWpm: newCharWpm,
      effectiveWpm: newEffective,
      toneHz: toneHz ?? this.toneHz,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}

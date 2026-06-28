import 'dart:typed_data';

import 'package:flutter_soloud/flutter_soloud.dart';

/// Plays an in-memory WAV buffer through the SoLoud mixer (low-latency).
///
/// This is the audio abstraction seam: only `init`, `play`, `stop`, and
/// `dispose` are public. SoLoud plays from an in-process mixer with no
/// per-play platform-channel round-trip, so rapid replays start with minimal
/// latency.
class AudioPlayerService {
  final SoLoud _soloud = SoLoud.instance;
  AudioSource? _source; // currently loaded clip
  SoundHandle? _handle; // currently playing instance
  Uint8List? _loadedBytes; // identity key for the loaded clip
  int _seq = 0; // unique loadMem key per clip

  /// Initializes the audio engine. Call once at startup before [play].
  Future<void> init() async {
    if (!_soloud.isInitialized) await _soloud.init();
  }

  /// Stops anything playing and plays [wavBytes] from the start. If [wavBytes]
  /// is the same instance as the last call (a replay), the cached source is
  /// reused; otherwise the previous source is disposed and the new one loaded.
  Future<void> play(Uint8List wavBytes) async {
    if (!identical(wavBytes, _loadedBytes) || _source == null) {
      await _disposeSource();
      _source = await _soloud.loadMem('morse_${_seq++}', wavBytes);
      _loadedBytes = wavBytes;
    } else if (_handle != null) {
      await _soloud.stop(_handle!); // restart from the beginning
    }
    _handle = _soloud.play(_source!);
  }

  Future<void> stop() async {
    if (_handle != null) {
      await _soloud.stop(_handle!);
      _handle = null;
    }
  }

  Future<void> dispose() async {
    _soloud.deinit(); // disposes the engine and all loaded sources
  }

  Future<void> _disposeSource() async {
    if (_source != null) {
      await _soloud.disposeSource(_source!);
      _source = null;
      _loadedBytes = null;
    }
  }
}

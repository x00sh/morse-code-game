import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

/// Plays an in-memory WAV buffer.
///
/// This is the audio abstraction seam: it currently uses `audioplayers`'
/// [BytesSource]. To switch to `flutter_soloud` (lower latency for rapid
/// replays), reimplement these three methods — nothing else in the app needs
/// to change.
class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  /// Stops anything currently playing and plays [wavBytes] from the start.
  Future<void> play(Uint8List wavBytes) async {
    await _player.stop();
    await _player.play(BytesSource(wavBytes, mimeType: 'audio/wav'));
  }

  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();
}

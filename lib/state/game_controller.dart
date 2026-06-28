import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/morse_timing.dart';
import '../models/prompt_mode.dart';
import '../models/puzzle.dart';
import '../services/audio_player_service.dart';
import '../services/content_repository.dart';
import '../services/haptic_service.dart';
import '../services/morse_codec.dart';
import '../services/settings_repository.dart';
import '../services/wav_synth.dart';
import 'settings_controller.dart';

enum GameMode { practice, timed }

enum AnswerFeedback { none, correct, incorrect }

/// Drives a play session: picks puzzles, plays prompts, checks answers, keeps
/// score, and (in timed mode) runs the countdown.
class GameController extends ChangeNotifier {
  GameController({
    required ContentRepository content,
    required AudioPlayerService audio,
    required HapticService haptic,
    required SettingsController settings,
    required SettingsRepository settingsRepo,
    WavSynth synth = const WavSynth(),
  })  : _content = content,
        _audio = audio,
        _haptic = haptic,
        _settings = settings,
        _settingsRepo = settingsRepo,
        _synth = synth;

  static const int timedDurationSeconds = 60;

  final ContentRepository _content;
  final AudioPlayerService _audio;
  final HapticService _haptic;
  final SettingsController _settings;
  final SettingsRepository _settingsRepo;
  final WavSynth _synth;
  final math.Random _random = math.Random();

  GameMode _mode = GameMode.practice;
  GameMode get mode => _mode;

  /// Fixed prompt mode for the session, or null for mixed (random per puzzle).
  PromptMode? _sessionPromptMode;

  ContentSet _contentSet = ContentSet.easyWords;
  ContentSet get contentSet => _contentSet;
  List<String> _pool = const [];

  Puzzle? _current;
  Puzzle? get current => _current;
  Uint8List? _currentWav;

  int _score = 0;
  int get score => _score;
  int _bestScore = 0;
  int get bestScore => _bestScore;

  AnswerFeedback _feedback = AnswerFeedback.none;
  AnswerFeedback get feedback => _feedback;

  bool _revealed = false;
  bool get revealed => _revealed;

  Timer? _timer;
  int _secondsLeft = 0;
  int get secondsLeft => _secondsLeft;
  bool _running = false;
  bool get running => _running;
  bool _finished = false;
  bool get finished => _finished;

  /// Loads persisted best score; call once at startup.
  Future<void> init() async {
    _bestScore = await _settingsRepo.loadBestScore();
  }

  Future<void> startSession({
    required GameMode mode,
    PromptMode? promptMode,
    required ContentSet contentSet,
  }) async {
    _mode = mode;
    _sessionPromptMode = promptMode;
    _contentSet = contentSet;
    _pool = await _content.load(contentSet);
    _score = 0;
    _finished = false;
    _feedback = AnswerFeedback.none;
    _revealed = false;
    _timer?.cancel();

    if (mode == GameMode.timed) {
      _secondsLeft = timedDurationSeconds;
      _running = true;
      _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    } else {
      _running = false;
      _secondsLeft = 0;
    }

    _loadNextPuzzle(autoPlay: true);
  }

  void _loadNextPuzzle({bool autoPlay = false}) {
    if (_pool.isEmpty) return;
    final s = _settings.settings;
    final text = MorseCodec.normalize(_pool[_random.nextInt(_pool.length)]);
    final timing = MorseTiming(charWpm: s.charWpm, effectiveWpm: s.effectiveWpm);
    final segments = MorseCodec.buildSegments(text, timing);
    final mode = _sessionPromptMode ??
        (_random.nextBool() ? PromptMode.visual : PromptMode.audio);

    _current = Puzzle(
      answer: text,
      morse: MorseCodec.encodeDisplay(text),
      mode: mode,
      segments: segments,
    );
    _currentWav =
        mode == PromptMode.audio ? _synth.synthesize(segments, toneHz: s.toneHz) : null;
    _feedback = AnswerFeedback.none;
    _revealed = false;
    notifyListeners();

    if (autoPlay && mode == PromptMode.audio) {
      playPrompt();
    }
  }

  /// Plays the current audio puzzle (and haptics if enabled). No-op for visual.
  Future<void> playPrompt() async {
    final p = _current;
    if (p == null || p.mode != PromptMode.audio) return;
    final s = _settings.settings;
    final wav = _currentWav ??= _synth.synthesize(p.segments, toneHz: s.toneHz);
    if (s.hapticsEnabled) {
      // Fire-and-forget so vibration starts alongside audio.
      unawaited(_haptic.play(p.segments));
    }
    await _audio.play(wav);
  }

  /// Checks [input] against the answer. Returns true when correct, in which
  /// case the score advances and (after a brief flash) the next puzzle loads.
  Future<bool> submit(String input) async {
    final p = _current;
    if (p == null || _finished) return false;

    if (MorseCodec.isCorrect(input, p.answer)) {
      _score++;
      _feedback = AnswerFeedback.correct;
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 350));
      // Only advance if the session is still live (timer may have ended).
      if (!_finished) _loadNextPuzzle(autoPlay: true);
      return true;
    }

    _feedback = AnswerFeedback.incorrect;
    notifyListeners();
    return false;
  }

  /// Practice helper: reveal the answer without scoring.
  void reveal() {
    if (_current == null) return;
    _revealed = true;
    notifyListeners();
  }

  /// Skip to the next puzzle without scoring (practice).
  void skip() => _loadNextPuzzle(autoPlay: true);

  void clearFeedback() {
    if (_feedback != AnswerFeedback.none) {
      _feedback = AnswerFeedback.none;
      notifyListeners();
    }
  }

  void _onTick(Timer t) {
    if (_secondsLeft <= 1) {
      _secondsLeft = 0;
      _endTimed();
    } else {
      _secondsLeft--;
      notifyListeners();
    }
  }

  Future<void> _endTimed() async {
    _timer?.cancel();
    _running = false;
    _finished = true;
    if (_score > _bestScore) {
      _bestScore = _score;
      await _settingsRepo.saveBestScore(_bestScore);
    }
    await _audio.stop();
    notifyListeners();
  }

  /// Stops timers/audio when leaving the game screen.
  void stopSession() {
    _timer?.cancel();
    _running = false;
    _audio.stop();
    _haptic.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audio.dispose();
    super.dispose();
  }
}

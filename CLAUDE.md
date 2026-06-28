# Morse Code Game

A cross-platform (Android-first, iOS later) **Flutter** game. The player is shown a Morse-code prompt —
either a **visual** ·/− string or an **audio** clip of beeps — and must decode it and type the plain-text
answer. The UI is **keyboard-first**: the on-screen keyboard is up almost all the time, so the prompt,
play/replay control, score/timer, and answer field stay visible above it.

## Stack

| Concern | Choice | Notes |
|---|---|---|
| Framework | Flutter / Dart | One codebase for Android + iOS. |
| Audio playback | `audioplayers` (`BytesSource`) | Plays an in-memory WAV. Wrapped by `AudioPlayerService` so `flutter_soloud` can be swapped in later for lower-latency game audio. |
| Audio synthesis | Pure Dart (`dart:typed_data` / `dart:math`) | Whole clip synthesized per puzzle as one 16-bit PCM WAV buffer (`wav_synth.dart`). Hann envelope avoids clicks. |
| Haptics | `vibration` | Vibrates the dit/dah/gap pattern (`haptic_service.dart`); also a no-sound play mode. |
| State management | `provider` + `ChangeNotifier` | `SettingsController`, `GameController`. |
| Persistence | `shared_preferences` | WPM, tone Hz, Farnsworth WPM, haptics on/off, best timed score, Koch lesson progress (unlocked-character count). |
| Content | Bundled JSON assets | `assets/content/*.json`. No backend. |

> The audio-player and state-management choices are the lighter, more API-stable fallbacks named in the
> approved plan, chosen because the project was scaffolded before the Flutter SDK was available to
> compile-verify the newer `flutter_soloud` / Riverpod APIs. The `AudioPlayerService` abstraction keeps
> the SoLoud swap a localized change.

## Architecture

- `lib/models/` — pure data: Morse alphabet, PARIS/Farnsworth timing math, puzzle, settings, Koch lesson ordering/derivation/selection/unlock (`koch_lessons.dart`).
- `lib/services/` — codec, WAV synthesis, audio/haptic playback, content + settings repositories.
- `lib/state/` — `ChangeNotifier` controllers wired with `provider` in `main.dart`.
- `lib/widgets/` — reusable UI pieces (morse visual, prompt panel, answer field, mode-aware score bar, chart sheet).
- `lib/screens/` — home, game (keyboard-aware), settings, Koch lessons list + lesson drill.

`morse_timing.dart` is the **single source of truth** for timing; both `wav_synth.dart` and
`haptic_service.dart` consume the same `ToneSegment` timeline produced by `morse_codec.dart`.

## Game modes

`GameController` drives three `GameMode`s:

- **Practice** — endless puzzles from a chosen content set; tracks score, no timer.
- **Timed** — `timedDurationSeconds` countdown; score vs. persisted best.
- **Lesson** — Koch-method drill (below).

The shared `GameScreen` and `ScoreTimerBar` adapt to the active mode; lessons get their own
`LessonsScreen` (the "Learn" list) and `LessonScreen` (the drill).

## Lessons (Koch method)

Koch lessons drill single characters **by ear** (`PromptMode.audio`) at full character speed.
`koch_lessons.dart` holds all the logic as pure data + functions (no Flutter/audio imports) so
ordering, lesson derivation, character selection, and the unlock decision are unit-tested
(`test/koch_lessons_test.dart`) without the platform. Lesson prompts still flow through
`MorseCodec` / `MorseTiming`, keeping `morse_timing.dart` the single timing source.

- A session is `kKochSessionLength` prompts, one shot each: the answer is revealed and the drill
  auto-advances after `kKochAdvanceMs` regardless of correctness. The score bar shows progress
  (`i/total`) and running accuracy.
- A lesson is identified by its **unlocked-character count** `n` (`2..kKochOrder.length`), not a
  1-based number, because that count is exactly what we persist (avoids off-by-one bugs). The
  first lesson unlocks `K`+`M` (`kKochInitialUnlockCount`); each later lesson adds one more in
  LCWO order. The newly introduced character is weighted `kKochNewCharWeight`× in selection.
- Reaching `kKochPassAccuracy` (90%) on the *frontier* lesson unlocks the next character;
  replaying an already-passed lesson never changes progress. The unlocked count is persisted by
  `SettingsRepository` (`koch_unlocked_count`, default `kKochInitialUnlockCount`) and loaded in
  `GameController.init()`.

## Backlog / future ideas

Deferred from the MVP (considered but not built yet):

- **Encode / tap-out mode** — show a word; user taps out the Morse with dot/dash keys (two-way practice).
- **Daily challenge** — one fixed shared puzzle per day.
- **Hints** — reveal a letter, or replay the audio slowed down.
- **Progress stats** — per-character accuracy and history, persisted locally.
- **Score & streaks** — combo multipliers, accuracy %, streak tracking (beyond the basic timed count).
- **Lives / hearts** — limited wrong answers per round.
- **Online leaderboard** — global rankings (requires a backend + networking).
- Swap `audioplayers` → `flutter_soloud` and `provider` → `flutter_riverpod` once verified on-device.

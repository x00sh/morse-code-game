# Morse Code Game

A cross-platform (Android-first, iOS later) **Flutter** game. The player is shown a Morse-code prompt —
either a **visual** ·/− string or an **audio** clip of beeps — and must decode it and type the plain-text
answer. The UI is **keyboard-first**: the on-screen keyboard is up almost all the time, so the prompt,
play/replay control, score/timer, and answer field stay visible above it.

## CORE DESIGN PRINCIPLES

- **Simplicity** -- always focus on the simplest possible implementation for a given task, if there is a good reason for a more complex implementation, ask the user first

## Stack

| Concern | Choice | Notes |
|---|---|---|
| Framework | Flutter / Dart | One codebase for Android + iOS. |
| Audio playback | `flutter_soloud` (`loadMem`) | Plays an in-memory WAV through SoLoud's in-process mixer for low-latency replays. Wrapped by `AudioPlayerService`. |
| Audio synthesis | Pure Dart (`dart:typed_data` / `dart:math`) | Whole clip synthesized per puzzle as one 16-bit PCM WAV buffer (`wav_synth.dart`). Hann envelope avoids clicks. |
| Haptics | `vibration` | Vibrates the dit/dah/gap pattern (`haptic_service.dart`); also a no-sound play mode. |
| State management | `provider` + `ChangeNotifier` | `SettingsController`, `GameController`. |
| Persistence | `shared_preferences` | WPM, tone Hz, Farnsworth WPM, haptics on/off, best timed score, Koch lesson progress (unlocked-character count). |
| Content | Bundled JSON assets | `assets/content/*.json`. No backend. |

> The state-management choice (`provider`) is the lighter, more API-stable fallback named in the approved
> plan, chosen because the project was scaffolded before the Flutter SDK was available to compile-verify
> the newer Riverpod APIs.

## Architecture

- `lib/models/` — pure data: Morse alphabet, PARIS/Farnsworth timing math, puzzle, settings, Koch lesson ordering/derivation/selection/unlock (`koch_lessons.dart`).
- `lib/services/` — codec, WAV synthesis, audio/haptic playback, content + settings repositories.
- `lib/state/` — `ChangeNotifier` controllers wired with `provider` in `main.dart`.
- `lib/widgets/` — reusable UI pieces (morse visual, prompt panel, answer field, mode-aware score bar, chart sheet).
- `lib/screens/` — home, game (keyboard-aware), settings, Koch lessons list + lesson drill.

`morse_timing.dart` is the **single source of truth** for timing; both `wav_synth.dart` and
`haptic_service.dart` consume the same `ToneSegment` timeline produced by `morse_codec.dart`.

## Theme & style

Cold-war terminal aesthetic — phosphor green on near-black, monospace (Courier Prime), square corners, CRT scanlines, phosphor glow. Centralized in `lib/app_theme.dart`, where the **DESIGN TOKENS** block is the single source of truth the rest of the theme derives from. See `docs/theme.md`.

## Game modes

`GameController` drives three `GameMode`s:

- **Practice** — endless puzzles from a chosen content set; tracks score, no timer.
- **Timed** — `timedDurationSeconds` countdown; score vs. persisted best.
- **Lesson** — Koch-method drill (below).

The shared `GameScreen` and `ScoreTimerBar` adapt to the active mode; lessons get their own
`LessonsScreen` (the "Learn" list) and `LessonScreen` (the drill).

## Lessons (Koch method)

See `docs/koch-lessons.md`.

## Backlog / future ideas

See `docs/backlog.md`.

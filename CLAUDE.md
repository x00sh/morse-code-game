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
| Persistence | `shared_preferences` | WPM, tone Hz, Farnsworth WPM, haptics on/off, best timed score. |
| Content | Bundled JSON assets | `assets/content/*.json`. No backend. |

> The audio-player and state-management choices are the lighter, more API-stable fallbacks named in the
> approved plan, chosen because the project was scaffolded before the Flutter SDK was available to
> compile-verify the newer `flutter_soloud` / Riverpod APIs. The `AudioPlayerService` abstraction keeps
> the SoLoud swap a localized change.

## First-time setup (toolchain not yet installed)

1. Install the **Flutter SDK** and **Android Studio** (with the Android SDK + an emulator or a physical
   device in USB-debugging mode). Verify: `flutter doctor` (resolve the Android checkmarks).
2. From the repo root, generate the native projects (this preserves `lib/`, `pubspec.yaml`, `assets/`,
   `test/`):
   ```
   flutter create --platforms=android,ios .
   ```
3. Add the vibration permission to `android/app/src/main/AndroidManifest.xml`, just inside `<manifest>`
   above the `<application>` tag:
   ```xml
   <uses-permission android:name="android.permission.VIBRATE"/>
   ```
4. Fetch dependencies and run:
   ```
   flutter pub get
   flutter analyze
   flutter test
   flutter run
   ```
   If a package version fails to resolve, run `flutter pub upgrade` and adjust constraints in
   `pubspec.yaml`.

## Architecture

- `lib/models/` — pure data: Morse alphabet, PARIS/Farnsworth timing math, puzzle, settings.
- `lib/services/` — codec, WAV synthesis, audio/haptic playback, content + settings repositories.
- `lib/state/` — `ChangeNotifier` controllers wired with `provider` in `main.dart`.
- `lib/widgets/` — reusable UI pieces (morse visual, prompt panel, answer field, score bar, chart sheet).
- `lib/screens/` — home, game (keyboard-aware), settings.

`morse_timing.dart` is the **single source of truth** for timing; both `wav_synth.dart` and
`haptic_service.dart` consume the same `ToneSegment` timeline produced by `morse_codec.dart`.

## Backlog / future ideas

Deferred from the MVP (considered but not built yet):

- **Encode / tap-out mode** — show a word; user taps out the Morse with dot/dash keys (two-way practice).
- **Progressive lessons (Koch method)** — introduce a few new characters at a time.
- **Daily challenge** — one fixed shared puzzle per day.
- **Hints** — reveal a letter, or replay the audio slowed down.
- **Progress stats** — per-character accuracy and history, persisted locally.
- **Score & streaks** — combo multipliers, accuracy %, streak tracking (beyond the basic timed count).
- **Lives / hearts** — limited wrong answers per round.
- **Online leaderboard** — global rankings (requires a backend + networking).
- Swap `audioplayers` → `flutter_soloud` and `provider` → `flutter_riverpod` once verified on-device.

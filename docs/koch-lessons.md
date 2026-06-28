# Koch Method Lessons

Koch lessons drill single characters **by ear** (`PromptMode.audio`) at full character speed, introducing two characters first (K + M) and adding one more each time the learner passes a session at 90% accuracy.

## File map

| File | Role |
|---|---|
| `lib/models/koch_lessons.dart` | Pure data + functions — no Flutter/audio imports; unit-testable in isolation |
| `lib/state/game_controller.dart` | Drives session state: counters, puzzle loading, timing, unlock persistence |
| `lib/screens/lessons_screen.dart` | Scrollable list of all lessons with lock/pass indicators |
| `lib/screens/lesson_screen.dart` | Active drill UI — score bar, prompt panel, answer field, results dialog |
| `test/koch_lessons_test.dart` | Unit tests for ordering, `KochLesson`, `nextUnlockedCount`, `pickKochChar` |

Lesson prompts flow through `MorseCodec` / `MorseTiming` the same way as Practice and Timed modes, keeping `morse_timing.dart` the single timing source.

## Character order

`kKochOrder` is the standard LCWO sequence, filtered defensively against `kMorseAlphabet` (all 41 characters already exist in the alphabet; the filter keeps the list valid if the alphabet is trimmed later):

```
K M U R E S N A P T L W I . J Z = F O Y , V G 5 / Q 9 2 H 3 8 B ? 4 7 C 1 D 6 0 X
```

## Constants

| Constant | Value | Purpose |
|---|---|---|
| `kKochSessionLength` | 25 | Prompts per drill session |
| `kKochPassAccuracy` | 0.90 | Accuracy threshold to unlock the next character |
| `kKochNewCharWeight` | 2 | Weight multiplier for the newly introduced character |
| `kKochInitialUnlockCount` | 2 | Characters unlocked on a fresh install (K + M) |
| `kKochAdvanceMs` | 600 | ms the app waits after revealing the answer before loading the next prompt |

## `KochLesson`

A lesson is identified by its **unlocked-character count** `n` (range `kKochInitialUnlockCount .. kKochOrder.length`), not a 1-based index, because that count is exactly what is persisted — which eliminates off-by-one bugs.

| Member | Type | Description |
|---|---|---|
| `unlockedCount` | `int` | Identity of this lesson; the count stored in `shared_preferences` |
| `unlockedChars` | `List<String>` | `kKochOrder.sublist(0, unlockedCount)` — characters that can appear in this drill |
| `newChars` | `List<String>` | First lesson: `[K, M]`; every later lesson: `[kKochOrder[unlockedCount - 1]]` |
| `label` | `String` | `"Lesson N: +K M"` or `"Lesson N: +U"` — N is `unlockedCount - kKochInitialUnlockCount + 1` |
| `isFinal` | `bool` | `true` when `unlockedCount == kKochOrder.length` |

`kAllLessons` is the pre-built list of every `KochLesson` from the starting pair to the full set.

## Weighted character selection — `pickKochChar`

Each character in `unlockedChars` is assigned a weight: `kKochNewCharWeight` (2) for each character in `newChars`, and 1 for every older character. A uniform random roll in `[0, total_weight)` selects the character via a sequential bucket walk.

**Worked example — Lesson 3 (K, M, U; U is new):**

| Char | Weight | Cumulative |
|---|---|---|
| K | 1 | 1 |
| M | 1 | 2 |
| U | 2 | 4 |

Total = 4. A roll of 0.0–0.99 → K, 1.0–1.99 → M, 2.0–3.99 → U. U occupies the top half of `[0, 1)` when the roll is normalized.

The `nextDouble` parameter is injected (production: `math.Random().nextDouble`; tests: a deterministic stub), keeping the function pure and testable.

## Unlock logic — `nextUnlockedCount`

The count increases by 1 only when **all four** conditions hold:

1. `sessionUnlockedCount == currentUnlocked` — the session was on the frontier lesson (replaying an earlier lesson never changes progress)
2. `sessionUnlockedCount < kKochOrder.length` — there is a next character to unlock
3. `attempts > 0` — at least one answer was submitted
4. `correct / attempts >= kKochPassAccuracy` — accuracy reached 90%

In every other case the current count is returned unchanged.

## Session flow

```
LessonsScreen (tile tap)
  └─► LessonScreen pushed
        └─► GameController.startSession(GameMode.lesson, lesson)
              ├─ resets _lessonIndex, _lessonCorrect, _lessonAttempts
              └─ _loadNextLessonPuzzle()
                    ├─ pickKochChar() → character
                    ├─ MorseCodec encodes → ToneSegment list
                    ├─ WavSynth synthesizes WAV
                    └─ AudioPlayerService auto-plays

User hears prompt → types answer → submits
  └─► _submitLesson(input)
        ├─ increments _lessonAttempts (and _lessonCorrect if right)
        ├─ sets revealed = true  (answer shown in PromptPanel)
        ├─ waits kKochAdvanceMs (600 ms)
        └─ if _lessonIndex < kKochSessionLength - 1 → _loadNextLessonPuzzle()
           else → _finishLesson()

_finishLesson()
  ├─ calls nextUnlockedCount() with final accuracy
  ├─ if count increased: saves via SettingsRepository.saveKochUnlocked()
  │   and sets _lastSessionUnlocked = true
  └─ sets _finished = true → triggers results dialog in LessonScreen
```

The results dialog shows the session accuracy, an unlock message when `game.lastLessonUnlocked` is true, and three actions: **Home** (back to lesson list), **Retry** (same lesson), and **Next lesson** (enabled only when the lesson just played can advance — i.e. it is not the final lesson and the user either passed or was already past it).

## Persistence

`SettingsRepository` persists a single integer key `koch_unlocked_count` (default `kKochInitialUnlockCount`) via `shared_preferences`.

- **Loaded** in `GameController.init()` at app startup.
- **Saved** in `GameController._finishLesson()` only when `nextUnlockedCount()` returns a higher value — no write on replay or failure.

## Test coverage (`test/koch_lessons_test.dart`)

| Group | What is verified |
|---|---|
| `kKochOrder` | 41 characters, all in `kMorseAlphabet`, starts K M, no duplicates, excludes `+` |
| `KochLesson` | Lesson count = `kKochOrder.length - 1`; correct `newChars` for lesson 1 vs later; `unlockedChars` prefix; `isFinal` boundary |
| `nextUnlockedCount` | Frontier pass unlocks; exactly 90% unlocks; below threshold does not; replay never changes count; final lesson cannot grow; zero attempts never unlocks |
| `pickKochChar` | Always returns an unlocked char; lesson-1 K/M 50–50 split; lesson-3 weighted range (U in top half) |

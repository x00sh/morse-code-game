/// How a puzzle's Morse is presented to the player.
enum PromptMode {
  /// Show the Morse as ·/− symbols; the player reads it.
  visual,

  /// Play the Morse as audio beeps (and optionally haptics); nothing is shown.
  audio,
}

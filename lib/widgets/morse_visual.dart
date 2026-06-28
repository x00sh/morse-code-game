import 'package:flutter/material.dart';

/// Renders a display Morse string (e.g. ".... . / .-.. ---") as large ·/−
/// symbols, wrapping on narrow screens.
class MorseVisual extends StatelessWidget {
  const MorseVisual(this.morse, {super.key});

  final String morse;

  @override
  Widget build(BuildContext context) {
    final display = morse.replaceAll('.', '·').replaceAll('-', '−');
    return Text(
      display,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 34,
        height: 1.4,
        letterSpacing: 4,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

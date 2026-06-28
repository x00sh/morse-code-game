import 'package:flutter/material.dart';

import '../app_theme.dart';

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
      style: AppTheme.morseTextStyle.copyWith(
        color: AppTheme.kColorPrimary,
        shadows: AppTheme.glowShadow(AppTheme.kColorPrimary),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../models/prompt_mode.dart';
import '../state/game_controller.dart';
import 'morse_visual.dart';

/// Shows the current puzzle's prompt: ·/− symbols for visual mode, or a large
/// play/replay button for audio mode.
class PromptPanel extends StatelessWidget {
  const PromptPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    final puzzle = game.current;
    if (puzzle == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final label = puzzle.mode == PromptMode.visual ? 'READ THE CODE' : 'LISTEN';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 2,
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 20),
          if (puzzle.mode == PromptMode.visual)
            MorseVisual(puzzle.morse)
          else
            _PlayButton(onTap: context.read<GameController>().playPrompt),
          if (game.revealed) ...[
            const SizedBox(height: 20),
            Text(
              puzzle.answer,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 2,
                    shadows: AppTheme.glowShadow(AppTheme.kColorPrimary),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.kColorPrimary,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(28),
              child: const Icon(
                Icons.volume_up_rounded,
                size: 56,
                color: AppTheme.kColorPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '> TAP TO PLAY',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                letterSpacing: 1.5,
              ),
        ),
      ],
    );
  }
}

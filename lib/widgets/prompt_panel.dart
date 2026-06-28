import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    final label = puzzle.mode == PromptMode.visual ? 'Read the code' : 'Listen';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
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
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: scheme.primaryContainer,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Icon(Icons.volume_up_rounded,
                  size: 56, color: scheme.onPrimaryContainer),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Tap to replay',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.outline,
                )),
      ],
    );
  }
}

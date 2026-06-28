import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';

/// Compact top bar: score on the left and, in timed mode, the countdown on the
/// right. Stays fixed above the scrolling prompt area.
class ScoreTimerBar extends StatelessWidget {
  const ScoreTimerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Chip(
            icon: Icons.star_rounded,
            label: 'Score',
            value: '${game.score}',
          ),
          if (game.mode == GameMode.timed)
            _Chip(
              icon: Icons.timer_outlined,
              label: 'Time',
              value: '${game.secondsLeft}s',
              highlight: game.secondsLeft <= 10,
              color: game.secondsLeft <= 10 ? scheme.error : null,
            )
          else
            _Chip(
              icon: Icons.emoji_events_outlined,
              label: 'Best',
              value: '${game.bestScore}',
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.onSurface;
    return Row(
      children: [
        Icon(icon, size: 18, color: c),
        const SizedBox(width: 6),
        Text('$label: ',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.outline,
                )),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: c,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

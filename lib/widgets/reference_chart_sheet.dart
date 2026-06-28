import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/morse_alphabet.dart';

/// Shows the Morse reference chart as a draggable bottom sheet. It overlays the
/// game without dismissing the answer field's text.
Future<void> showReferenceChart(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'MORSE REFERENCE',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    mainAxisExtent: 52,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: kReferenceOrder.length,
                  itemBuilder: (context, i) {
                    final ch = kReferenceOrder[i];
                    final code = (kMorseAlphabet[ch] ?? '')
                        .replaceAll('.', '·')
                        .replaceAll('-', '−');
                    return _ChartTile(character: ch, code: code);
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class _ChartTile extends StatelessWidget {
  const _ChartTile({required this.character, required this.code});

  final String character;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.kColorSurface,
        border: Border.all(
          color: AppTheme.kColorPrimary.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            character,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.kColorSecondary,
                ),
          ),
          Text(
            code,
            style: AppTheme.morseTextStyle.copyWith(
              fontSize: 18,
              color: AppTheme.kColorPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/koch_lessons.dart';
import '../state/game_controller.dart';
import '../widgets/reference_chart_sheet.dart';
import 'lesson_screen.dart';

/// The "Learn" list: every Koch lesson, unlocked progressively. Tap an unlocked
/// lesson to drill it. Reads [GameController.unlockedLessonCount] so it reflects
/// new unlocks when you return from a lesson.
class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unlockedCount = context.watch<GameController>().unlockedLessonCount;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LEARN'),
        actions: [
          IconButton(
            tooltip: 'Reference chart',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => showReferenceChart(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'Learn the Morse alphabet a couple of characters at a time, by '
                'ear. Score ${(kKochPassAccuracy * 100).round()}% to unlock the '
                'next character.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: kAllLessons.length,
                itemBuilder: (context, index) {
                  final lesson = kAllLessons[index];
                  final unlocked = lesson.unlockedCount <= unlockedCount;
                  final passed = lesson.unlockedCount < unlockedCount;
                  return _LessonTile(
                    lesson: lesson,
                    unlocked: unlocked,
                    passed: passed,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.unlocked,
    required this.passed,
  });

  final KochLesson lesson;
  final bool unlocked;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      enabled: unlocked,
      leading: Icon(
        unlocked ? Icons.play_circle_outline : Icons.lock_outline,
        color: unlocked ? scheme.primary : scheme.outline,
      ),
      title: Text(lesson.label),
      subtitle: Text('${lesson.unlockedChars.length} characters'),
      trailing: passed
          ? Icon(Icons.check_circle, color: scheme.primary)
          : null,
      onTap: unlocked
          ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LessonScreen(lesson: lesson),
                ),
              )
          : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../models/koch_lessons.dart';
import '../models/prompt_mode.dart';
import '../services/content_repository.dart';
import '../state/game_controller.dart';
import '../widgets/reference_chart_sheet.dart';
import 'game_screen.dart';
import 'lessons_screen.dart';
import 'settings_screen.dart';

/// Landing screen: pick a content set and a mode, or open settings/reference.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ContentSet _set = ContentSet.easyWords;

  void _start(GameMode mode, PromptMode? promptMode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(
          mode: mode,
          promptMode: promptMode,
          contentSet: _set,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Morse Code Game'),
        actions: [
          IconButton(
            tooltip: 'Reference chart',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => showReferenceChart(context),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('Decode the Morse', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Best timed score: ${game.bestScore}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 24),
              Text('Content', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<ContentSet>(
                segments: [
                  for (final s in ContentSet.values)
                    ButtonSegment(value: s, label: Text(s.label)),
                ],
                selected: {_set},
                onSelectionChanged: (sel) => setState(() => _set = sel.first),
                showSelectedIcon: false,
              ),
              const SizedBox(height: 28),
              Text('Learn', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '${game.unlockedLessonCount - kKochInitialUnlockCount + 1} of '
                '${kAllLessons.length} lessons unlocked',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const LessonsScreen()),
                ),
                icon: const Icon(Icons.school_outlined),
                label: const Text('Learn — Koch lessons'),
                style: _bigButton,
              ),
              const SizedBox(height: 28),
              Text('Practice', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => _start(GameMode.practice, PromptMode.audio),
                icon: const Icon(Icons.volume_up_rounded),
                label: const Text('Practice — Audio'),
                style: _bigButton,
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: () => _start(GameMode.practice, PromptMode.visual),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Practice — Visual'),
                style: _bigButton,
              ),
              const SizedBox(height: 28),
              Text('Challenge', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => _start(GameMode.timed, null),
                icon: const Icon(Icons.timer_outlined),
                label: const Text('Timed Challenge (60s)'),
                style: _bigButton,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static final ButtonStyle _bigButton = FilledButton.styleFrom(
    backgroundColor: const Color(0xFF1A3010),
    foregroundColor: AppTheme.kColorPrimary,
    side: const BorderSide(color: AppTheme.kColorPrimary),
    padding: const EdgeInsets.symmetric(vertical: 18),
  );
}

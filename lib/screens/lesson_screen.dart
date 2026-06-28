import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/koch_lessons.dart';
import '../state/game_controller.dart';
import '../widgets/answer_field.dart';
import '../widgets/prompt_panel.dart';
import '../widgets/reference_chart_sheet.dart';
import '../widgets/score_timer_bar.dart';

/// Koch lesson drill: single characters are sent by ear and the learner types
/// each one. Mirrors [GameScreen]'s keyboard-aware layout but with one-shot
/// scoring and an accuracy-based results dialog.
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson});

  final KochLesson lesson;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _resultsShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().startSession(
            mode: GameMode.lesson,
            lesson: widget.lesson,
          );
    });
  }

  Future<void> _handleSubmit(String text) async {
    if (text.trim().isEmpty) return;
    // One shot per character: consume the input regardless of correctness.
    await context.read<GameController>().submit(text);
    if (!mounted) return;
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _maybeShowResults(GameController game) {
    if (game.finished && !_resultsShown) {
      _resultsShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showResultsDialog(game);
      });
    }
  }

  Future<void> _showResultsDialog(GameController game) async {
    _focusNode.unfocus();
    final passed = game.lessonAccuracy >= kKochPassAccuracy;
    final accuracyPct = (game.lessonAccuracy * 100).round();
    final canAdvance = !widget.lesson.isFinal &&
        widget.lesson.unlockedCount + 1 <= game.unlockedLessonCount;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(passed ? 'LESSON PASSED' : 'KEEP PRACTICING'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accuracy: $accuracyPct%'),
            const SizedBox(height: 8),
            if (game.lastLessonUnlocked)
              Text(
                'Unlocked a new character!',
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.primary,
                ),
              )
            else if (!passed)
              Text(
                'Reach ${(kKochPassAccuracy * 100).round()}% to unlock the next '
                'character.',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(); // back to the lessons list
            },
            child: const Text('HOME'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _restart(widget.lesson);
            },
            child: const Text('RETRY'),
          ),
          if (canAdvance)
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => LessonScreen(
                      lesson: KochLesson(widget.lesson.unlockedCount + 1),
                    ),
                  ),
                );
              },
              child: const Text('NEXT LESSON'),
            ),
        ],
      ),
    );
  }

  void _restart(KochLesson lesson) {
    setState(() => _resultsShown = false);
    _controller.clear();
    context.read<GameController>().startSession(
          mode: GameMode.lesson,
          lesson: lesson,
        );
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    _maybeShowResults(game);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) context.read<GameController>().stopSession();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(widget.lesson.label),
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
              const ScoreTimerBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const PromptPanel(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: OutlinedButton.icon(
                          onPressed: game.playPrompt,
                          icon: const Icon(Icons.replay),
                          label: const Text('REPLAY'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnswerField(
                controller: _controller,
                focusNode: _focusNode,
                onSubmit: _handleSubmit,
                feedback: game.feedback,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

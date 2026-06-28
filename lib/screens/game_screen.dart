import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/prompt_mode.dart';
import '../services/content_repository.dart';
import '../state/game_controller.dart';
import '../widgets/answer_field.dart';
import '../widgets/prompt_panel.dart';
import '../widgets/reference_chart_sheet.dart';
import '../widgets/score_timer_bar.dart';

/// The keyboard-aware play surface. The score bar stays fixed at the top, the
/// prompt area scrolls in the middle, and the answer field is pinned directly
/// above the keyboard. The keyboard never drops: the field is autofocused and
/// re-focused after every submit.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.mode,
    required this.promptMode,
    required this.contentSet,
  });

  final GameMode mode;
  final PromptMode? promptMode;
  final ContentSet contentSet;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _resultsShown = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().startSession(
            mode: widget.mode,
            promptMode: widget.promptMode,
            contentSet: widget.contentSet,
          );
    });
  }

  void _onTextChanged() {
    final game = context.read<GameController>();
    // Clear only the red "incorrect" state as the player retypes; keep the
    // green "correct" flash visible until the next puzzle loads.
    if (game.feedback == AnswerFeedback.incorrect) {
      game.clearFeedback();
    }
  }

  Future<void> _handleSubmit(String text) async {
    if (text.trim().isEmpty) return;
    final game = context.read<GameController>();
    final correct = await game.submit(text);
    if (!mounted) return;
    if (correct) {
      _controller.clear();
    } else {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
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
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Time's up!"),
        content: Text(
          'You decoded ${game.score} '
          '${game.score == 1 ? 'puzzle' : 'puzzles'}.\n'
          'Best: ${game.bestScore}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(); // back to home
            },
            child: const Text('Home'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              setState(() => _resultsShown = false);
              _controller.clear();
              context.read<GameController>().startSession(
                    mode: widget.mode,
                    promptMode: widget.promptMode,
                    contentSet: widget.contentSet,
                  );
              _focusNode.requestFocus();
            },
            child: const Text('Play again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    _maybeShowResults(game);

    final title = switch (widget.mode) {
      GameMode.practice => 'Practice',
      GameMode.timed => 'Timed Challenge',
      GameMode.lesson => 'Lesson',
    };

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) context.read<GameController>().stopSession();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(title),
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
                      _ActionButtons(
                        mode: widget.mode,
                        onReplay: game.current?.mode == PromptMode.audio
                            ? game.playPrompt
                            : null,
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

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.mode, this.onReplay});

  final GameMode mode;
  final VoidCallback? onReplay;

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          if (onReplay != null)
            OutlinedButton.icon(
              onPressed: onReplay,
              icon: const Icon(Icons.replay),
              label: const Text('Replay'),
            ),
          if (mode == GameMode.practice)
            OutlinedButton.icon(
              onPressed: game.reveal,
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Reveal'),
            ),
          TextButton.icon(
            onPressed: game.skip,
            icon: const Icon(Icons.skip_next),
            label: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}

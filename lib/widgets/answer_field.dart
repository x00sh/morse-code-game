import 'package:flutter/material.dart';

import '../state/game_controller.dart';

/// The answer text field plus submit button, pinned just above the keyboard.
///
/// The keyboard stays up between puzzles: the field is autofocused and the
/// owning screen re-requests focus after each submit. Autocorrect and
/// suggestions are disabled so the keyboard never "fixes" a decoded word.
class AnswerField extends StatelessWidget {
  const AnswerField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.feedback,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmit;
  final AnswerFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = switch (feedback) {
      AnswerFeedback.correct => Colors.green,
      AnswerFeedback.incorrect => scheme.error,
      AnswerFeedback.none => scheme.outline,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onSubmitted: onSubmit,
              decoration: InputDecoration(
                hintText: 'Type your answer',
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor, width: 2),
                ),
                suffixIcon: switch (feedback) {
                  AnswerFeedback.correct =>
                    const Icon(Icons.check_circle, color: Colors.green),
                  AnswerFeedback.incorrect =>
                    Icon(Icons.cancel, color: scheme.error),
                  AnswerFeedback.none => null,
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => onSubmit(controller.text),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }
}

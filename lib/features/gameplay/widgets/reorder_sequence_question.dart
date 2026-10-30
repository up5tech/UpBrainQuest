import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/core/theme/app_radii.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/core/theme/app_typography.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';

/// Interactive reorder-sequence puzzle (PLAN §2.2.D, Phase 3 task 4).
///
/// The player drags tiles into the correct order. While [evaluation] is
/// `null` the
/// widget reports the current [ReorderAnswer] through [onChanged]; once
/// [evaluation] is set it is locked and shows the correct order.
class ReorderSequenceQuestionWidget extends StatefulWidget {
  const ReorderSequenceQuestionWidget({
    required this.item,
    this.submission,
    this.evaluation,
    required this.onChanged,
    super.key,
  });

  final PuzzleItem item;
  final PlayerAnswer? submission;
  final AnswerEvaluation? evaluation;
  final ValueChanged<PlayerAnswer?> onChanged;

  @override
  State<ReorderSequenceQuestionWidget> createState() =>
      _ReorderSequenceQuestionWidgetState();
}

class _ReorderSequenceQuestionWidgetState
    extends State<ReorderSequenceQuestionWidget> {
  late List<String> _order;

  List<String> get _expected => widget.item.expectedAnswer.cast<String>();

  bool get _locked => widget.evaluation != null;

  @override
  void initState() {
    super.initState();
    final PlayerAnswer? sub = widget.submission;
    if (sub is ReorderAnswer) {
      _order = List<String>.from(sub.order);
    } else {
      // Deterministic scramble: reverse the correct order (never equals the
      // expected order when length > 1, so the player always has work to do).
      _order = List<String>.from(_expected.reversed);
    }
  }

  @override
  void didUpdateWidget(covariant ReorderSequenceQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final PlayerAnswer? sub = widget.submission;
    if (sub is ReorderAnswer) {
      _order = List<String>.from(sub.order);
    } else if (widget.submission == null && !_locked) {
      _order = List<String>.from(_expected.reversed);
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (_locked) return;
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final String moved = _order.removeAt(oldIndex);
      _order.insert(newIndex, moved);
    });
    widget.onChanged(ReorderAnswer(List<String>.from(_order)));
  }

  @override
  Widget build(BuildContext context) {
    if (_locked) return _lockedView();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          AppStrings.sessionReorderHint,
          style: AppTypography.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 280,
          child: ReorderableListView.builder(
            itemBuilder: (BuildContext context, int index) {
              final String tile = _order[index];
              return _tile(tile, index);
            },
            itemCount: _order.length,
            onReorderItem: _onReorder,
            padding: const EdgeInsets.all(AppSpacing.xs),
          ),
        ),
      ],
    );
  }

  Widget _tile(String tile, int index) {
    return Container(
      key: ValueKey<String>(tile),
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: AppColors.elevatedSurface),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.drag_handle, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(tile, style: AppTypography.body)),
        ],
      ),
    );
  }

  Widget _lockedView() {
    final bool correct = widget.evaluation?.isCorrect ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: correct ? AppColors.positive : AppColors.error,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Text(
            correct ? AppStrings.sessionCorrect : AppStrings.sessionIncorrect,
            style: AppTypography.title.copyWith(color: AppColors.textOnAccent),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${AppStrings.sessionCorrectOrder}: ${_expected.join(', ')}',
          style: AppTypography.body,
        ),
      ],
    );
  }
}

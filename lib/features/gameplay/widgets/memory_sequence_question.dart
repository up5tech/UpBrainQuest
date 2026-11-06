import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/core/theme/app_radii.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/core/theme/app_typography.dart';
import 'package:up_brain_quest/core/widgets/app_button.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';

/// Interactive memory-sequence puzzle (PLAN §2.2.D, Phase 3 task 4).
///
/// The player first memorises a short numeric sequence, then reproduces it from
/// a numeric keypad. While [evaluation] is `null` the widget reports a
/// [SequenceAnswer] through [onChanged] once the input matches the target
/// length; once [evaluation] is set it is locked and shows the correct
/// sequence.
class MemorySequenceQuestionWidget extends StatefulWidget {
  const MemorySequenceQuestionWidget({
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
  State<MemorySequenceQuestionWidget> createState() =>
      _MemorySequenceQuestionWidgetState();
}

class _MemorySequenceQuestionWidgetState
    extends State<MemorySequenceQuestionWidget> {
  bool _memorizing = true;
  List<int> _input = const <int>[];

  List<int> get _expected => widget.item.expectedAnswer.cast<int>();

  bool get _locked => widget.evaluation != null;

  int get _minValue => widget.item.interactionConfig?['minValue'] as int? ?? 0;
  int get _maxValue => widget.item.interactionConfig?['maxValue'] as int? ?? 9;

  int get _targetLength => _expected.length;

  @override
  void initState() {
    super.initState();
    final PlayerAnswer? sub = widget.submission;
    if (sub is SequenceAnswer) _input = List<int>.from(sub.sequence);
  }

  void _startRecall() {
    if (_locked) return;
    setState(() => _memorizing = false);
  }

  void _tapDigit(int digit) {
    if (_locked || _memorizing) return;
    if (_input.length >= _targetLength) return;
    setState(() => _input = <int>[..._input, digit]);
    _report();
  }

  void _backspace() {
    if (_locked || _memorizing || _input.isEmpty) return;
    setState(() => _input = _input.sublist(0, _input.length - 1));
    _report();
  }

  void _clear() {
    if (_locked || _memorizing) return;
    setState(() => _input = const <int>[]);
    _report();
  }

  void _report() {
    if (_input.length == _targetLength) {
      widget.onChanged(SequenceAnswer(List<int>.from(_input)));
    } else {
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_locked) return _lockedView();
    if (_memorizing) return _memorizeView();
    return _recallView();
  }

  Widget _memorizeView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.md,
            children: _expected
                .map(
                  (int n) => Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.elevatedSurface,
                      borderRadius: BorderRadius.circular(AppRadii.input),
                    ),
                    child: Text(
                      n.toString(),
                      style: AppTypography.score.copyWith(fontSize: 28),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: context.l10n.sessionMemoryReady,
          onPressed: _startRecall,
        ),
      ],
    );
  }

  Widget _recallView() {
    final List<Widget> digits = <Widget>[];
    for (int d = _minValue; d <= _maxValue; d++) {
      digits.add(_digitButton(d));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < _targetLength; i++)
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.elevatedSurface,
                  borderRadius: BorderRadius.circular(AppRadii.input),
                ),
                child: Text(
                  i < _input.length ? _input[i].toString() : '·',
                  style: AppTypography.title,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: AppSpacing.xs,
          crossAxisSpacing: AppSpacing.xs,
          childAspectRatio: 1.6,
          physics: const NeverScrollableScrollPhysics(),
          children: digits,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            Expanded(
              child: AppButton(
                label: context.l10n.sessionMemoryClear,
                variant: AppButtonVariant.outline,
                onPressed: _clear,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: context.l10n.sessionMemoryDelete,
                variant: AppButtonVariant.outline,
                onPressed: _backspace,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _digitButton(int digit) {
    return SizedBox(
      child: AppButton(
        label: digit.toString(),
        variant: AppButtonVariant.ghost,
        onPressed: () => _tapDigit(digit),
      ),
    );
  }

  Widget _lockedView() {
    final PlayerAnswer? sub = widget.submission;
    final List<int> playerInput = sub is SequenceAnswer
        ? sub.sequence
        : const <int>[];
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
            correct
                ? '${context.l10n.sessionCorrect} — '
                      '${context.l10n.sessionMemoryRecall}'
                : '${context.l10n.sessionIncorrect} — '
                      '${context.l10n.sessionMemoryRecall}',
            style: AppTypography.title.copyWith(color: AppColors.textOnAccent),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${context.l10n.sessionCorrectSequence}: ${_expected.join(', ')}',
          style: AppTypography.body,
        ),
        if (playerInput.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${context.l10n.sessionYourSequence}: ${playerInput.join(', ')}',
            style: AppTypography.bodySecondary,
          ),
        ],
      ],
    );
  }
}

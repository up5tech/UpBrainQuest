import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/core/theme/app_radii.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/core/theme/app_typography.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';
import 'package:up_brain_quest/features/gameplay/widgets/puzzle_symbols.dart';

/// Symbol-selection puzzle used by `visual_pattern` and `odd_one_out` items
/// (PLAN §5.10.B).
///
/// The optional pattern preview is drawn above a grid of selectable symbols.
/// The player's choice is reported as a [SelectedOptionAnswer] carrying the
/// symbol id, so scoring stays a pure comparison in the domain layer.
class SymbolChoiceQuestionWidget extends StatefulWidget {
  const SymbolChoiceQuestionWidget({
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
  State<SymbolChoiceQuestionWidget> createState() =>
      _SymbolChoiceQuestionWidgetState();
}

class _SymbolChoiceQuestionWidgetState
    extends State<SymbolChoiceQuestionWidget> {
  String? _selectedId;

  bool get _locked => widget.evaluation != null;

  List<String> get _preview =>
      (widget.item.interactionConfig?['previewSymbols'] as List<dynamic>?)
          ?.whereType<String>()
          .toList() ??
      const <String>[];

  String get _answerId {
    final List<dynamic> expected = widget.item.expectedAnswer;
    if (expected.length != 1) return '';
    final dynamic only = expected.single;
    return only is String ? only : '';
  }

  @override
  void initState() {
    super.initState();
    final PlayerAnswer? submission = widget.submission;
    if (submission is SelectedOptionAnswer) _selectedId = submission.optionId;
  }

  @override
  void didUpdateWidget(covariant SymbolChoiceQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final PlayerAnswer? submission = widget.submission;
    if (submission is SelectedOptionAnswer) {
      _selectedId = submission.optionId;
    } else if (widget.submission == null) {
      _selectedId = null;
    }
  }

  void _select(String id) {
    if (_locked) return;
    setState(() => _selectedId = id);
    widget.onChanged(SelectedOptionAnswer(id));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_preview.isNotEmpty) ...<Widget>[
          _PatternPreview(symbols: _preview),
          const SizedBox(height: AppSpacing.md),
        ],
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: widget.item.options
              .map(
                (QuestionOption option) => _SymbolTile(
                  option: option,
                  locked: _locked,
                  selected: option.id == _selectedId,
                  correct: _locked && option.id == _answerId,
                  chosenWrong:
                      _locked &&
                      option.id == _selectedId &&
                      option.id != _answerId,
                  onTap: () => _select(option.id),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

/// The symbols shown before the question, with a trailing empty slot for the
/// missing element.
class _PatternPreview extends StatelessWidget {
  const _PatternPreview({required this.symbols});

  final List<String> symbols;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          for (final String symbol in symbols)
            _PreviewSlot(symbol: symbol, empty: symbol == 'blank'),
        ],
      ),
    );
  }
}

class _PreviewSlot extends StatelessWidget {
  const _PreviewSlot({required this.symbol, required this.empty});

  final String symbol;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    final IconData? icon = puzzleSymbolIcon(symbol);
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: empty ? Border.all(color: AppColors.textSecondary) : null,
      ),
      child: empty
          ? const Icon(Icons.more_horiz, color: AppColors.textSecondary)
          : Icon(
              icon ?? Icons.help_outline,
              color: AppColors.textPrimary,
              size: 28,
            ),
    );
  }
}

class _SymbolTile extends StatelessWidget {
  const _SymbolTile({
    required this.option,
    required this.locked,
    required this.selected,
    required this.correct,
    required this.chosenWrong,
    required this.onTap,
  });

  final QuestionOption option;
  final bool locked;
  final bool selected;
  final bool correct;
  final bool chosenWrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IconData? icon = puzzleSymbolIcon(option.id);
    Color borderColor = AppColors.elevatedSurface;
    if (correct) {
      borderColor = AppColors.positive;
    } else if (chosenWrong) {
      borderColor = AppColors.error;
    } else if (selected) {
      borderColor = AppColors.primary;
    }
    final String statusLabel = correct
        ? context.l10n.sessionCorrect
        : chosenWrong
        ? context.l10n.sessionIncorrect
        : '';

    return Semantics(
      button: !locked,
      selected: selected,
      label: option.text,
      child: InkWell(
        onTap: locked ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadii.input),
        child: Container(
          width: 104,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.input),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Numeric answer options carry no symbol, so show the text alone.
              if (icon != null) ...<Widget>[
                Icon(icon, color: AppColors.textPrimary, size: 32),
                const SizedBox(height: AppSpacing.xs),
              ],
              Text(
                option.text,
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary,
              ),
              if (statusLabel.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  statusLabel,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: correct ? AppColors.positive : AppColors.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

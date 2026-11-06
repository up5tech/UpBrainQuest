import 'package:flutter/material.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/core/theme/app_radii.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';

/// Interactive EQ scenario response (PLAN §5.6, §8.3).
///
/// While [evaluation] is `null` the widget is interactive and reports the
/// chosen option through [onChanged]. Once [evaluation] is set the widget is
/// locked and highlights the player's own selection WITHOUT any
/// correct/incorrect framing — EQ items are deliberately non-binary (PLAN §4.3,
/// §4.6). The rubric feedback for the chosen option is surfaced by the feedback
/// card, not here.
class EqScenarioQuestionWidget extends StatefulWidget {
  const EqScenarioQuestionWidget({
    required this.item,
    this.submission,
    this.evaluation,
    required this.onChanged,
    super.key,
  });

  final EqScenarioItem item;
  final PlayerAnswer? submission;
  final AnswerEvaluation? evaluation;
  final ValueChanged<PlayerAnswer?> onChanged;

  @override
  State<EqScenarioQuestionWidget> createState() =>
      _EqScenarioQuestionWidgetState();
}

class _EqScenarioQuestionWidgetState extends State<EqScenarioQuestionWidget> {
  String? _selectedId;

  bool get _locked => widget.evaluation != null;

  @override
  void initState() {
    super.initState();
    final PlayerAnswer? sub = widget.submission;
    if (sub is SelectedOptionAnswer) _selectedId = sub.optionId;
  }

  @override
  void didUpdateWidget(covariant EqScenarioQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final PlayerAnswer? sub = widget.submission;
    if (sub is SelectedOptionAnswer) {
      _selectedId = sub.optionId;
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
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < widget.item.options.length; i++) {
      final QuestionOption option = widget.item.options[i];
      final bool isChosen = _locked && option.id == _selectedId;
      Color? borderColor;
      IconData? trailingIcon;
      Color? iconColor;
      String? statusLabel;
      if (isChosen) {
        borderColor = AppColors.primary;
        trailingIcon = Icons.check_circle;
        iconColor = AppColors.primary;
        statusLabel = context.l10n.sessionYourResponse;
      } else if (!_locked && option.id == _selectedId) {
        borderColor = AppColors.primary;
      }

      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _EqOptionTile(
            text: option.text,
            borderColor: borderColor,
            trailingIcon: trailingIcon,
            iconColor: iconColor,
            statusLabel: statusLabel,
            selected: !_locked && option.id == _selectedId,
            onTap: _locked ? null : () => _select(option.id),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// A selectable response tile for an EQ scenario option.
///
/// Identical interaction contract to the objective MC tile, but never draws a
/// positive/negative (correct/incorrect) color — only a neutral "your response"
/// signal once locked (PLAN §4.3).
class _EqOptionTile extends StatelessWidget {
  const _EqOptionTile({
    required this.text,
    this.borderColor,
    this.trailingIcon,
    this.iconColor,
    this.statusLabel,
    this.selected = false,
    this.onTap,
  });

  final String text;
  final Color? borderColor;
  final IconData? trailingIcon;
  final Color? iconColor;
  final String? statusLabel;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: text,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.input),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.input),
            border: Border.all(
              color: borderColor ?? AppColors.elevatedSurface,
              width: 2,
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
              if (trailingIcon != null) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                Icon(trailingIcon, color: iconColor),
                if (statusLabel != null) ...<Widget>[
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    statusLabel!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: iconColor,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

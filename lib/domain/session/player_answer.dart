/// A player's response to a single question, typed by interaction.
///
/// Kept separate from [QuestionItem] so a submitted answer is immutable once
/// recorded — a question is scored at most once per session (PLAN §3.2).
sealed class PlayerAnswer {
  const PlayerAnswer();
}

/// No answer was recorded for the question (e.g. a timeout or explicit skip).
///
/// Counts as zero points but stays in the scoring denominator (PLAN §4.2).
class UnansweredAnswer extends PlayerAnswer {
  const UnansweredAnswer();
}

/// A single selected option, used by multiple-choice and EQ items.
class SelectedOptionAnswer extends PlayerAnswer {
  const SelectedOptionAnswer(this.optionId);

  final String optionId;
}

/// A reproduced numeric sequence, used by memory-sequence puzzles.
class SequenceAnswer extends PlayerAnswer {
  const SequenceAnswer(this.sequence);

  final List<int> sequence;
}

/// A chosen ordering of tile ids, used by reorder puzzles.
class ReorderAnswer extends PlayerAnswer {
  const ReorderAnswer(this.order);

  final List<String> order;
}

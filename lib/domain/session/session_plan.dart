import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';

/// An immutable, ordered set of questions selected for one session.
///
/// Built by [SessionBuilder]; the order is fixed so a session is reproducible
/// from its seed (PLAN §5.7, §3.2).
class SessionPlan {
  const SessionPlan({required this.items, required this.mode});

  final List<QuestionItem> items;
  final GameMode mode;
}

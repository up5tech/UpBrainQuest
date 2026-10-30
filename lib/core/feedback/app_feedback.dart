import 'package:flutter/services.dart';

/// Small wrapper around platform feedback, gated by the user's sound/haptics
/// preferences (PLAN Phase 8 task 3).
///
/// Feedback is cosmetic only: it never gates gameplay and never reports data
/// anywhere (the app has no analytics).
class AppFeedback {
  const AppFeedback();

  /// Light confirmation when an answer is submitted.
  Future<void> answerSubmitted({
    required bool haptics,
    required bool sound,
  }) async {
    if (haptics) await HapticFeedback.selectionClick();
    if (sound) await SystemSound.play(SystemSoundType.click);
  }

  /// Stronger confirmation when a session is completed.
  Future<void> sessionCompleted({
    required bool haptics,
    required bool sound,
  }) async {
    if (haptics) await HapticFeedback.mediumImpact();
    if (sound) await SystemSound.play(SystemSoundType.click);
  }
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'UpBrainQuest';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navProgress => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeGreeting => 'Train your mind, one quest at a time';

  @override
  String get homeStartQuickQuest => 'Start Quick Quest';

  @override
  String get homeStartIqChallenge => 'Start IQ Challenge';

  @override
  String get homeProgressSummary => 'Your progress';

  @override
  String get homeNoProgress =>
      'No challenges completed yet. Your results will appear here.';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get notAvailableYet => 'This mode is not available yet.';

  @override
  String get exploreTitle => 'Explore modes';

  @override
  String get exploreSubtitle =>
      'Choose a challenge type. Difficulty and length selection arrive in a later phase.';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressEmpty =>
      'No sessions yet. Complete a challenge to see your history here.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingReducedMotion => 'Reduced motion';

  @override
  String get settingReducedMotionHint => 'Minimise animations across the app.';

  @override
  String get settingSound => 'Sound effects';

  @override
  String get settingHaptics => 'Haptics';

  @override
  String get settingAbout => 'About & score disclaimer';

  @override
  String get settingsLoadError => 'Unable to load settings.';

  @override
  String get settingLanguage => 'Language';

  @override
  String get settingLanguageHint =>
      'Choose the language for the interface and questions.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get aboutTitle => 'About UpBrainQuest';

  @override
  String get aboutClose => 'Close';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutLicenses => 'Licenses';

  @override
  String get aboutOffline =>
      'Fully offline. No account, no network, no analytics, and no ads. All content and progress stay on this device.';

  @override
  String get aboutDisclaimer =>
      'UpBrainQuest scores summarize your performance on these game challenges. They are not standardized IQ scores, a clinical EQ assessment, a diagnosis, or a validated measurement of intelligence or emotional ability. Results can vary with familiarity, attention, context, language, and the questions included in a session.';

  @override
  String get modeQuickQuest => 'Quick Quest';

  @override
  String get modeQuickQuestDesc =>
      'A balanced mix of reasoning, memory, and EQ scenarios.';

  @override
  String get modeIqChallenge => 'IQ Challenge';

  @override
  String get modeIqChallengeDesc =>
      'Reasoning puzzles: sequences, patterns, and logic.';

  @override
  String get modePuzzleSprint => 'Puzzle Sprint';

  @override
  String get modePuzzleSprintDesc => 'Short interactive puzzle mechanics.';

  @override
  String get modeEqChallenge => 'EQ Challenge';

  @override
  String get modeEqChallengeDesc =>
      'Scenario choices that practise reflection and communication.';

  @override
  String get modeDailyChallenge => 'Daily Challenge';

  @override
  String get modeDailyChallengeDesc =>
      'A local 5-question challenge chosen by today’s date.';

  @override
  String get sessionUntimedNote =>
      'This mode is untimed — take your time to think.';

  @override
  String get sessionTimedNote =>
      'A timed variant is not available in this build.';

  @override
  String get sessionStart => 'Start session';

  @override
  String get sessionSubmit => 'Submit';

  @override
  String get sessionContinue => 'Continue';

  @override
  String get sessionCorrect => 'Correct';

  @override
  String get sessionIncorrect => 'Not quite';

  @override
  String get sessionExplanation => 'Explanation';

  @override
  String get sessionHint => 'Hint';

  @override
  String get sessionResultTitle => 'Session complete';

  @override
  String get sessionIqScoreLabel => 'IQ Challenge Score';

  @override
  String get sessionScoreDisclaimer =>
      'This is an in-game score based on the questions in this session. It is not a standardized IQ result, a clinical measure, or a diagnosis.';

  @override
  String get sessionAccuracy => 'Accuracy';

  @override
  String get sessionReview => 'Review answers';

  @override
  String get sessionPlayAgain => 'Play again';

  @override
  String get sessionBackHome => 'Back to Home';

  @override
  String get sessionAbandonTitle => 'Leave this session?';

  @override
  String get sessionAbandonBody =>
      'Your progress in this session will be lost if you leave now.';

  @override
  String get sessionAbandonConfirm => 'Leave';

  @override
  String get sessionAbandonCancel => 'Keep playing';

  @override
  String get sessionNotAvailable => 'This mode is not available yet.';

  @override
  String get sessionNoContent =>
      'There are not enough questions available for this mode yet.';

  @override
  String get sessionMemoryReady => 'I memorised it';

  @override
  String get sessionMemoryRecall => 'Reproduce the sequence';

  @override
  String get sessionMemoryClear => 'Clear';

  @override
  String get sessionReorderHint => 'Drag the tiles into the correct order.';

  @override
  String get sessionQuestionOf => 'Question';

  @override
  String get sessionEqScenarioContext => 'Situation';

  @override
  String get sessionEqReflection => 'Reflection';

  @override
  String get sessionEqFollowUp => 'Reflect on this';

  @override
  String get sessionYourResponse => 'Your response';

  @override
  String get sessionEqScoreLabel => 'EQ Practice Score';

  @override
  String get sessionEqScoreDisclaimer =>
      'This is an in-game practice score based on the rubrics in this session. It is not a clinical EQ assessment, a diagnosis, or a validated measure of emotional ability.';

  @override
  String get sessionEqDimensionsTitle => 'Where you focused';

  @override
  String get sessionEqNoScore => 'Practice score not available yet';

  @override
  String get sessionEqReviewHeading => 'Your reflection';

  @override
  String get sessionYourAnswer => 'Your answer';

  @override
  String get sessionCorrectAnswer => 'Correct answer';

  @override
  String get sessionNotAnswered => 'Not answered';

  @override
  String get sessionRubricSummary => 'Rubric';

  @override
  String get sessionResultStatus => 'Result';

  @override
  String get sessionQuestionsCompleted => 'Questions completed';

  @override
  String get sessionIncompleteNote => 'Some questions were left unanswered.';

  @override
  String get sessionResultError => 'This result could not be displayed.';

  @override
  String get sessionQuickQuestMixUnavailable =>
      'Not enough questions for a balanced Quick Quest yet.';

  @override
  String get sessionSaving => 'Saving to history…';

  @override
  String get sessionSaved => 'Saved to your history';

  @override
  String get sessionSaveFailed => 'This session could not be saved.';

  @override
  String get sessionSaveRetry => 'Retry';

  @override
  String get progressLoadError => 'Could not load your progress.';

  @override
  String get progressSessionsCompleted => 'Sessions completed';

  @override
  String get progressBestIq => 'Best IQ Challenge Score';

  @override
  String get progressBestEq => 'Best EQ Practice Score';

  @override
  String get progressRecentTitle => 'Recent game performance';

  @override
  String get homeProgressError => 'Could not load your progress.';

  @override
  String get resetLocalData => 'Reset local data';

  @override
  String get resetLocalDataBody =>
      'This permanently deletes your session history, achievements, and local streaks on this device. Your preferences are kept.';

  @override
  String get resetLocalDataConfirm => 'Delete';

  @override
  String get resetLocalDataCancel => 'Cancel';

  @override
  String get resetLocalDataDone => 'Local history cleared.';

  @override
  String get resetLocalDataFailed => 'Could not clear local data.';

  @override
  String get dailyDoneToday => 'Done today';

  @override
  String get dailyLocalNote =>
      'Generated on this device — not a global competition.';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get achievementUnlocked => 'Unlocked';

  @override
  String get achievementsLoadError => 'Could not load achievements.';

  @override
  String get streakDaySuffix => 'day streak';

  @override
  String get streakNone => 'No local streak yet';

  @override
  String get streakLocalNote => 'Local to this device — not server-verified.';

  @override
  String get achievementFirstQuestTitle => 'First Quest';

  @override
  String get achievementFirstQuestDesc => 'Complete your first session.';

  @override
  String get achievementFiveQuestsTitle => 'Five Completed Quests';

  @override
  String get achievementFiveQuestsDesc => 'Complete five sessions.';

  @override
  String get achievementReasoningTitle => 'Reasoning Explorer';

  @override
  String get achievementReasoningDesc => 'Finish three reasoning sessions.';

  @override
  String get achievementReflectionTitle => 'Reflection Explorer';

  @override
  String get achievementReflectionDesc => 'Finish three EQ sessions.';

  @override
  String get achievementConsistentTitle => 'Consistent Player';

  @override
  String get achievementConsistentDesc => 'Play on three days in a row.';

  @override
  String get retry => 'Retry';

  @override
  String get sessionMemoryDelete => 'Delete';

  @override
  String get sessionCorrectSequence => 'Correct sequence';

  @override
  String get sessionYourSequence => 'Your sequence';

  @override
  String get sessionCorrectOrder => 'Correct order';

  @override
  String get eqDimEmotionAwareness => 'Emotion Awareness';

  @override
  String get eqDimSelfRegulation => 'Self-Regulation';

  @override
  String get eqDimPerspectiveTaking => 'Perspective Taking';

  @override
  String get eqDimConstructiveCommunication => 'Constructive Communication';

  @override
  String get eqDimBoundariesAndAgency => 'Boundaries & Agency';

  @override
  String correctOutOf(int correct, int total) {
    return '$correct / $total correct';
  }

  @override
  String fractionOf(int value, int total) {
    return '$value / $total';
  }
}

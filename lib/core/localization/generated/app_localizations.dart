import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// Product name.
  ///
  /// In en, this message translates to:
  /// **'UpBrainQuest'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Train your mind, one quest at a time'**
  String get homeGreeting;

  /// No description provided for @homeStartQuickQuest.
  ///
  /// In en, this message translates to:
  /// **'Start Quick Quest'**
  String get homeStartQuickQuest;

  /// No description provided for @homeStartIqChallenge.
  ///
  /// In en, this message translates to:
  /// **'Start IQ Challenge'**
  String get homeStartIqChallenge;

  /// No description provided for @homeProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get homeProgressSummary;

  /// No description provided for @homeNoProgress.
  ///
  /// In en, this message translates to:
  /// **'No challenges completed yet. Your results will appear here.'**
  String get homeNoProgress;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @notAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'This mode is not available yet.'**
  String get notAvailableYet;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore modes'**
  String get exploreTitle;

  /// No description provided for @exploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a challenge type. Difficulty and length selection arrive in a later phase.'**
  String get exploreSubtitle;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet. Complete a challenge to see your history here.'**
  String get progressEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingReducedMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduced motion'**
  String get settingReducedMotion;

  /// No description provided for @settingReducedMotionHint.
  ///
  /// In en, this message translates to:
  /// **'Minimise animations across the app.'**
  String get settingReducedMotionHint;

  /// No description provided for @settingSound.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get settingSound;

  /// No description provided for @settingHaptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get settingHaptics;

  /// No description provided for @settingAbout.
  ///
  /// In en, this message translates to:
  /// **'About & score disclaimer'**
  String get settingAbout;

  /// No description provided for @settingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load settings.'**
  String get settingsLoadError;

  /// No description provided for @settingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingLanguage;

  /// No description provided for @settingLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the language for the interface and questions.'**
  String get settingLanguageHint;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About UpBrainQuest'**
  String get aboutTitle;

  /// No description provided for @aboutClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get aboutClose;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutOffline.
  ///
  /// In en, this message translates to:
  /// **'Fully offline. No account, no network, no analytics, and no ads. All content and progress stay on this device.'**
  String get aboutOffline;

  /// No description provided for @aboutDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'UpBrainQuest scores summarize your performance on these game challenges. They are not standardized IQ scores, a clinical EQ assessment, a diagnosis, or a validated measurement of intelligence or emotional ability. Results can vary with familiarity, attention, context, language, and the questions included in a session.'**
  String get aboutDisclaimer;

  /// No description provided for @modeQuickQuest.
  ///
  /// In en, this message translates to:
  /// **'Quick Quest'**
  String get modeQuickQuest;

  /// No description provided for @modeQuickQuestDesc.
  ///
  /// In en, this message translates to:
  /// **'A balanced mix of reasoning, memory, and EQ scenarios.'**
  String get modeQuickQuestDesc;

  /// No description provided for @modeIqChallenge.
  ///
  /// In en, this message translates to:
  /// **'IQ Challenge'**
  String get modeIqChallenge;

  /// No description provided for @modeIqChallengeDesc.
  ///
  /// In en, this message translates to:
  /// **'Reasoning puzzles: sequences, patterns, and logic.'**
  String get modeIqChallengeDesc;

  /// No description provided for @modePuzzleSprint.
  ///
  /// In en, this message translates to:
  /// **'Puzzle Sprint'**
  String get modePuzzleSprint;

  /// No description provided for @modePuzzleSprintDesc.
  ///
  /// In en, this message translates to:
  /// **'Short interactive puzzle mechanics.'**
  String get modePuzzleSprintDesc;

  /// No description provided for @modeEqChallenge.
  ///
  /// In en, this message translates to:
  /// **'EQ Challenge'**
  String get modeEqChallenge;

  /// No description provided for @modeEqChallengeDesc.
  ///
  /// In en, this message translates to:
  /// **'Scenario choices that practise reflection and communication.'**
  String get modeEqChallengeDesc;

  /// No description provided for @modeDailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get modeDailyChallenge;

  /// No description provided for @modeDailyChallengeDesc.
  ///
  /// In en, this message translates to:
  /// **'A local 5-question challenge chosen by today’s date.'**
  String get modeDailyChallengeDesc;

  /// No description provided for @sessionUntimedNote.
  ///
  /// In en, this message translates to:
  /// **'This mode is untimed — take your time to think.'**
  String get sessionUntimedNote;

  /// No description provided for @sessionTimedNote.
  ///
  /// In en, this message translates to:
  /// **'A timed variant is not available in this build.'**
  String get sessionTimedNote;

  /// No description provided for @sessionStart.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get sessionStart;

  /// No description provided for @sessionSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get sessionSubmit;

  /// No description provided for @sessionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get sessionContinue;

  /// No description provided for @sessionCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get sessionCorrect;

  /// No description provided for @sessionIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Not quite'**
  String get sessionIncorrect;

  /// No description provided for @sessionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get sessionExplanation;

  /// No description provided for @sessionHint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get sessionHint;

  /// No description provided for @sessionResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get sessionResultTitle;

  /// No description provided for @sessionIqScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'IQ Challenge Score'**
  String get sessionIqScoreLabel;

  /// No description provided for @sessionScoreDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is an in-game score based on the questions in this session. It is not a standardized IQ result, a clinical measure, or a diagnosis.'**
  String get sessionScoreDisclaimer;

  /// No description provided for @sessionAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get sessionAccuracy;

  /// No description provided for @sessionReview.
  ///
  /// In en, this message translates to:
  /// **'Review answers'**
  String get sessionReview;

  /// No description provided for @sessionPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get sessionPlayAgain;

  /// No description provided for @sessionBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get sessionBackHome;

  /// No description provided for @sessionAbandonTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this session?'**
  String get sessionAbandonTitle;

  /// No description provided for @sessionAbandonBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress in this session will be lost if you leave now.'**
  String get sessionAbandonBody;

  /// No description provided for @sessionAbandonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get sessionAbandonConfirm;

  /// No description provided for @sessionAbandonCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep playing'**
  String get sessionAbandonCancel;

  /// No description provided for @sessionNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This mode is not available yet.'**
  String get sessionNotAvailable;

  /// No description provided for @sessionNoContent.
  ///
  /// In en, this message translates to:
  /// **'There are not enough questions available for this mode yet.'**
  String get sessionNoContent;

  /// No description provided for @sessionMemoryReady.
  ///
  /// In en, this message translates to:
  /// **'I memorised it'**
  String get sessionMemoryReady;

  /// No description provided for @sessionMemoryRecall.
  ///
  /// In en, this message translates to:
  /// **'Reproduce the sequence'**
  String get sessionMemoryRecall;

  /// No description provided for @sessionMemoryClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get sessionMemoryClear;

  /// No description provided for @sessionReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the tiles into the correct order.'**
  String get sessionReorderHint;

  /// No description provided for @sessionQuestionOf.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get sessionQuestionOf;

  /// No description provided for @sessionEqScenarioContext.
  ///
  /// In en, this message translates to:
  /// **'Situation'**
  String get sessionEqScenarioContext;

  /// No description provided for @sessionEqReflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get sessionEqReflection;

  /// No description provided for @sessionEqFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Reflect on this'**
  String get sessionEqFollowUp;

  /// No description provided for @sessionYourResponse.
  ///
  /// In en, this message translates to:
  /// **'Your response'**
  String get sessionYourResponse;

  /// No description provided for @sessionEqScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'EQ Practice Score'**
  String get sessionEqScoreLabel;

  /// No description provided for @sessionEqScoreDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is an in-game practice score based on the rubrics in this session. It is not a clinical EQ assessment, a diagnosis, or a validated measure of emotional ability.'**
  String get sessionEqScoreDisclaimer;

  /// No description provided for @sessionEqDimensionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Where you focused'**
  String get sessionEqDimensionsTitle;

  /// No description provided for @sessionEqNoScore.
  ///
  /// In en, this message translates to:
  /// **'Practice score not available yet'**
  String get sessionEqNoScore;

  /// No description provided for @sessionEqReviewHeading.
  ///
  /// In en, this message translates to:
  /// **'Your reflection'**
  String get sessionEqReviewHeading;

  /// No description provided for @sessionYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get sessionYourAnswer;

  /// No description provided for @sessionCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get sessionCorrectAnswer;

  /// No description provided for @sessionNotAnswered.
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get sessionNotAnswered;

  /// No description provided for @sessionRubricSummary.
  ///
  /// In en, this message translates to:
  /// **'Rubric'**
  String get sessionRubricSummary;

  /// No description provided for @sessionResultStatus.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get sessionResultStatus;

  /// No description provided for @sessionQuestionsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Questions completed'**
  String get sessionQuestionsCompleted;

  /// No description provided for @sessionIncompleteNote.
  ///
  /// In en, this message translates to:
  /// **'Some questions were left unanswered.'**
  String get sessionIncompleteNote;

  /// No description provided for @sessionResultError.
  ///
  /// In en, this message translates to:
  /// **'This result could not be displayed.'**
  String get sessionResultError;

  /// No description provided for @sessionQuickQuestMixUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not enough questions for a balanced Quick Quest yet.'**
  String get sessionQuickQuestMixUnavailable;

  /// No description provided for @sessionSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving to history…'**
  String get sessionSaving;

  /// No description provided for @sessionSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to your history'**
  String get sessionSaved;

  /// No description provided for @sessionSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'This session could not be saved.'**
  String get sessionSaveFailed;

  /// No description provided for @sessionSaveRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get sessionSaveRetry;

  /// No description provided for @progressLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your progress.'**
  String get progressLoadError;

  /// No description provided for @progressSessionsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sessions completed'**
  String get progressSessionsCompleted;

  /// No description provided for @progressBestIq.
  ///
  /// In en, this message translates to:
  /// **'Best IQ Challenge Score'**
  String get progressBestIq;

  /// No description provided for @progressBestEq.
  ///
  /// In en, this message translates to:
  /// **'Best EQ Practice Score'**
  String get progressBestEq;

  /// No description provided for @progressRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent game performance'**
  String get progressRecentTitle;

  /// No description provided for @homeProgressError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your progress.'**
  String get homeProgressError;

  /// No description provided for @resetLocalData.
  ///
  /// In en, this message translates to:
  /// **'Reset local data'**
  String get resetLocalData;

  /// No description provided for @resetLocalDataBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your session history, achievements, and local streaks on this device. Your preferences are kept.'**
  String get resetLocalDataBody;

  /// No description provided for @resetLocalDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get resetLocalDataConfirm;

  /// No description provided for @resetLocalDataCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get resetLocalDataCancel;

  /// No description provided for @resetLocalDataDone.
  ///
  /// In en, this message translates to:
  /// **'Local history cleared.'**
  String get resetLocalDataDone;

  /// No description provided for @resetLocalDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not clear local data.'**
  String get resetLocalDataFailed;

  /// No description provided for @dailyDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get dailyDoneToday;

  /// No description provided for @dailyLocalNote.
  ///
  /// In en, this message translates to:
  /// **'Generated on this device — not a global competition.'**
  String get dailyLocalNote;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get achievementUnlocked;

  /// No description provided for @achievementsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load achievements.'**
  String get achievementsLoadError;

  /// No description provided for @streakDaySuffix.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get streakDaySuffix;

  /// No description provided for @streakNone.
  ///
  /// In en, this message translates to:
  /// **'No local streak yet'**
  String get streakNone;

  /// No description provided for @streakLocalNote.
  ///
  /// In en, this message translates to:
  /// **'Local to this device — not server-verified.'**
  String get streakLocalNote;

  /// No description provided for @achievementFirstQuestTitle.
  ///
  /// In en, this message translates to:
  /// **'First Quest'**
  String get achievementFirstQuestTitle;

  /// No description provided for @achievementFirstQuestDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first session.'**
  String get achievementFirstQuestDesc;

  /// No description provided for @achievementFiveQuestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Five Completed Quests'**
  String get achievementFiveQuestsTitle;

  /// No description provided for @achievementFiveQuestsDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete five sessions.'**
  String get achievementFiveQuestsDesc;

  /// No description provided for @achievementReasoningTitle.
  ///
  /// In en, this message translates to:
  /// **'Reasoning Explorer'**
  String get achievementReasoningTitle;

  /// No description provided for @achievementReasoningDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish three reasoning sessions.'**
  String get achievementReasoningDesc;

  /// No description provided for @achievementReflectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reflection Explorer'**
  String get achievementReflectionTitle;

  /// No description provided for @achievementReflectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish three EQ sessions.'**
  String get achievementReflectionDesc;

  /// No description provided for @achievementConsistentTitle.
  ///
  /// In en, this message translates to:
  /// **'Consistent Player'**
  String get achievementConsistentTitle;

  /// No description provided for @achievementConsistentDesc.
  ///
  /// In en, this message translates to:
  /// **'Play on three days in a row.'**
  String get achievementConsistentDesc;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @sessionMemoryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get sessionMemoryDelete;

  /// No description provided for @sessionCorrectSequence.
  ///
  /// In en, this message translates to:
  /// **'Correct sequence'**
  String get sessionCorrectSequence;

  /// No description provided for @sessionYourSequence.
  ///
  /// In en, this message translates to:
  /// **'Your sequence'**
  String get sessionYourSequence;

  /// No description provided for @sessionCorrectOrder.
  ///
  /// In en, this message translates to:
  /// **'Correct order'**
  String get sessionCorrectOrder;

  /// No description provided for @eqDimEmotionAwareness.
  ///
  /// In en, this message translates to:
  /// **'Emotion Awareness'**
  String get eqDimEmotionAwareness;

  /// No description provided for @eqDimSelfRegulation.
  ///
  /// In en, this message translates to:
  /// **'Self-Regulation'**
  String get eqDimSelfRegulation;

  /// No description provided for @eqDimPerspectiveTaking.
  ///
  /// In en, this message translates to:
  /// **'Perspective Taking'**
  String get eqDimPerspectiveTaking;

  /// No description provided for @eqDimConstructiveCommunication.
  ///
  /// In en, this message translates to:
  /// **'Constructive Communication'**
  String get eqDimConstructiveCommunication;

  /// No description provided for @eqDimBoundariesAndAgency.
  ///
  /// In en, this message translates to:
  /// **'Boundaries & Agency'**
  String get eqDimBoundariesAndAgency;

  /// No description provided for @correctOutOf.
  ///
  /// In en, this message translates to:
  /// **'{correct} / {total} correct'**
  String correctOutOf(int correct, int total);

  /// No description provided for @fractionOf.
  ///
  /// In en, this message translates to:
  /// **'{value} / {total}'**
  String fractionOf(int value, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

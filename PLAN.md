# UpBrainQuest — IQ & EQ Challenge

## Product & Engineering Implementation Plan

**Document type:** Product requirements, technical architecture, implementation roadmap, and acceptance criteria  
**Target platform:** Android and iOS  
**Framework:** Flutter / Dart  
**Product model:** Fully offline, single-player mobile game  
**Gameplay:** Hybrid quiz, logic puzzle, memory challenge, and emotional-intelligence scenario game  
**Visual direction:** Modern UI, rich gradients, restrained motion, responsive layouts  
**Backend:** None  
**Working rule:** Implement and verify one phase at a time. Do not begin the next phase while the current phase has failing acceptance criteria.

---

## 1. Product Vision

UpBrainQuest is a polished mobile game that helps players explore reasoning skills and practise reflecting on emotional and social situations through short, replayable challenges. The game combines IQ-inspired reasoning puzzles, memory and pattern challenges, and EQ-oriented interactive scenarios in one offline experience.

The product should feel like a casual brain-training game rather than a clinical testing tool. Sessions should be quick to start, easy to understand, visually rewarding, and useful even when the device has no internet connection.

### 1.1 Product goals

1. Deliver a complete single-player game on Android and iOS using Flutter.
2. Support reasoning challenges, memory/pattern puzzles, and EQ social scenarios in one coherent session system.
3. Work without accounts, a server, remote APIs, remote assets, or network access.
4. Save local progress, session history, achievements, settings, and daily activity across app restarts.
5. Explain answers and choices so a player learns something instead of seeing only a score.
6. Use a consistent modern visual system with gradients, responsive layouts, and small, meaningful animations.
7. Keep scoring transparent and appropriately limited: game scores are not presented as standardized IQ results, clinical EQ measures, or diagnoses.
8. Keep the codebase testable and maintainable so additional local question packs and puzzle types can be added later without redesigning the app.

### 1.2 Non-goals for the initial release

The first release must not include:

- Accounts, authentication, cloud synchronization, backend services, remote configuration, or server-side content.
- Multiplayer, global leaderboards, social feeds, or online competitions.
- Generative AI, AI-based psychological advice, chatbots, or external AI APIs.
- Ads, paid subscriptions, in-app purchases, or monetization SDKs.
- Clinical/diagnostic assessment, medical claims, standardized IQ conversion, age-based IQ norms, or claims that the app measures a person's true intelligence or emotional intelligence.
- User-generated question authoring or downloadable content packs.
- An elaborate 2D physics engine. Use standard Flutter widgets and animations for the initial puzzle types. Add Flame only if a later mini-game genuinely requires a game loop or canvas-based simulation.

### 1.3 Target audience

General audiences who enjoy casual puzzle games, self-reflection, and short brain-training sessions. Avoid designing the product as a tool for employers, schools, clinicians, or other high-stakes decision-makers.

### 1.4 Product principles

- **Offline by design:** all questions, illustrations, explanations, rules, and app logic ship with the application.
- **Learning over judgment:** answer feedback explains reasoning and trade-offs without shaming the player.
- **Honest scores:** describe what each score represents and what it does not represent.
- **Small sessions:** users can complete a short challenge in approximately 3–8 minutes.
- **Accessible first:** touch targets, contrast, text scaling, motion, and screen-reader descriptions are part of the design, not late additions.
- **No dark patterns:** rewards encourage play without guilt-driven streak messaging, misleading rank claims, or manipulative notifications.
- **Content as data:** questions are separated from gameplay code and validated before they are used.

---

## 2. Core Experience and Game Modes

### 2.1 Primary navigation

Use a simple bottom navigation bar with four destinations:

1. **Home** — recommended challenge, quick play, progress summary, and daily challenge entry.
2. **Explore** — IQ, puzzle, and EQ categories; difficulty and session-length selections.
3. **Progress** — past sessions, skill breakdowns, personal bests, and achievements.
4. **Settings** — sound, haptics, motion preferences, language readiness, data controls, and app information.

The active game session should have its own route and should not be part of the persistent bottom navigation shell. Prevent accidental navigation from silently discarding a session.

### 2.2 Game modes

#### A. Quick Quest

A balanced mixed session combining reasoning, memory/pattern puzzles, and EQ scenarios.

- Default length: 10 questions.
- Target duration: 5–8 minutes.
- Recommended initial mix: 5 IQ/reasoning items, 2 memory or pattern items, and 3 EQ scenarios. Adjust the mix when the installed content bank is too small, but never silently substitute questions from the wrong domain.
- Show a pre-session summary of the mode, question count, and optional timer rules.
- Save the completed result locally.

#### B. IQ Challenge

A reasoning-focused session with a mixture of:

- Number and symbol sequences.
- Pattern recognition.
- Logic and deduction.
- Visual/spatial reasoning using Flutter-drawn shapes or bundled assets.
- Short-term memory and sequence recall.
- Simple arithmetic reasoning where the answer tests a pattern rather than calculation speed alone.

Initial default: 10 questions. The game must not imply that success proves or measures a standardized IQ.

#### C. EQ Challenge

A scenario-based mode in which players choose how to respond to social or emotional situations. Possible themes include:

- Naming or noticing emotions.
- Pausing before responding under stress.
- Understanding another person's perspective.
- Communicating needs and boundaries.
- Handling disagreement constructively.
- Responding to feedback or disappointment.
- Supporting a friend while respecting their autonomy.

EQ questions should use contextual feedback and a transparent author-defined rubric. Avoid suggesting that every human situation has a single universally correct response.

#### D. Puzzle Sprint

A short collection of interactive puzzle mechanics. Initial mechanics should be implemented as normal Flutter widgets wherever practical:

- Multiple-choice pattern completion.
- Tap-to-reorder number or symbol sequences.
- Memory sequence reproduction.
- Odd-one-out challenges.
- Optional timed round with a clearly visible timer.

Do not implement all puzzle mechanics at once. Deliver at least three polished, reliable puzzle mechanics first; add further types only when content and tests are available.

#### E. Daily Challenge

A local daily session selected deterministically from bundled content using the device's local calendar date. It must be playable offline and must not depend on a server.

- Target length: 5 questions.
- The same device date should resolve to the same daily question set for the installed content version.
- Save the completion date and result locally.
- Make it clear that the challenge is generated locally and is not a globally synchronized competition.
- No claim of worldwide ranking or server-verified streaks.
- Handle device-date changes defensively. A local streak is a convenience feature, not a tamper-proof record.

Daily Challenge and streaks may be scheduled after the core gameplay is complete; they must not delay a stable MVP.

### 2.3 Difficulty model

Every question has a content-authored difficulty label:

- **Easy** — one obvious rule or a simple social context.
- **Medium** — requires combining clues or weighing competing responses.
- **Hard** — requires multiple reasoning steps or interpreting nuanced context.

Difficulty labels are for game organization and progression, not calibrated psychometric difficulty. Do not claim that the question bank has item-response-theory calibration or population norms unless such validation is actually performed.

The initial release may provide three difficulty filters and a simple progression unlock. Keep the question bank usable without unlocks so a player can still play any mode offline.

---

## 3. Gameplay Loop

### 3.1 Standard session flow

1. The player opens Home or Explore.
2. The player selects a game mode, difficulty, and session length when available.
3. A short pre-session screen explains the mode and any timer or scoring rules.
4. `SessionBuilder` selects a valid set of unique questions from the bundled question bank.
5. The game presents one question or puzzle at a time.
6. The player submits an answer or interaction.
7. The game locks that response, gives immediate visual feedback, and displays an explanation or contextual reflection.
8. The player advances to the next question.
9. After the final question, the score engine calculates results and skill breakdowns.
10. The result is saved to local storage in a database transaction.
11. The Results screen shows score, accuracy, time used where relevant, category breakdown, learning feedback, and the option to review answers.
12. Progress and achievement summaries update from the saved result.
13. The player can replay, return Home, or start another mode.

### 3.2 Session state machine

Represent the active session explicitly. A recommended state model is:

- `ready` — session created; no answer submitted yet.
- `answering` — current question is interactive.
- `feedback` — answer submitted and explanation is visible.
- `paused` — optional timed session is paused or the app is inactive.
- `completed` — all items have been answered or the session has ended according to its rules.
- `abandoned` — session intentionally exited before completion; optionally save an incomplete record for later analytics, but never include it in completed-session scores.

Required invariants:

- A question can be scored at most once per session.
- Repeated taps while feedback is being shown must not submit multiple answers.
- A completed session is immutable except for a narrowly scoped migration or repair process.
- The Results screen must derive its displayed result from the same persisted/session result model used by the score engine.
- An interrupted session must not accidentally become a completed session.
- Navigating away must show a confirmation before abandoning an active session.

### 3.3 Timer policy

Do not make speed the dominant component of the core score. Reading and reflection speed varies by person and accessibility needs.

- Default mode: untimed questions, optionally showing a non-competitive elapsed time.
- Timed mode: explicitly labelled as a challenge variant with clear instructions.
- When an app becomes inactive, pause active timers by default. Resume only after the UI state is restored and the player can see that the timer is running.
- Use a monotonic elapsed-time mechanism during a session rather than repeatedly comparing wall-clock time. Persist only the final elapsed duration unless resume support is added and tested.
- If a timer reaches zero, the question follows an explicit rule: unanswered questions score as unanswered/incorrect for the session denominator. Explain this before the game starts.

---

## 4. Score Design and Responsible Interpretation

This section is mandatory. Implementing agents must not invent more authoritative claims than this plan allows.

### 4.1 Naming and interpretation

The app may show an **IQ Challenge Score** and an **EQ Practice Score** because those labels describe the game modes. They must be clearly described as in-game scores derived from the app's own content and rules.

Recommended explanatory copy:

> UpBrainQuest scores summarize your performance on these game challenges. They are not standardized IQ scores, a clinical EQ assessment, a diagnosis, or a validated measurement of intelligence or emotional ability. Results can vary with familiarity, attention, context, language, and the questions included in a session.

Use this copy on first result exposure, in score details, and in About/Disclaimer. Do not convert the score into statements such as “your IQ is 126,” “genius,” “below average,” a mental-health label, or a percentile compared with a population.

### 4.2 IQ Challenge Score

Use an in-game 0–100 percentage-based score; do not use the conventional IQ scale (mean 100, standard deviation 15) or any equivalent mapping.

For a completed session:

- Each question has an authored point weight, for example 1–3.
- Each correctly answered question earns its point weight.
- An incorrect, unanswered, or timed-out question earns zero points.
- The denominator includes all scored questions in the completed session, including unanswered questions.
- `IQ Challenge Score = round(100 × earnedWeightedPoints / possibleWeightedPoints)`.
- If the denominator is zero, treat the session as invalid and do not display a numeric score.

Keep speed separate. If a timed mode grants a bonus, show it as a separate bonus or mode-specific statistic; do not quietly alter the core 0–100 score in a way that makes sessions incomparable. If the product later decides to use different scoring in timed mode, version the algorithm and label the mode clearly.

The score is a summary of correctness on this session's selected questions only. It is not a standardized intelligence measure and should not be converted to a purported IQ value.

### 4.3 EQ Practice Score

EQ scenarios are context-dependent and must not be scored using simplistic labels like “good person” or “bad person.” For each scenario, content authors provide:

- The context and any relevant uncertainty.
- Plausible response options, including more than one potentially constructive choice where appropriate.
- An author-defined rubric for each option and skill dimension.
- An explanation of likely benefits, risks, and trade-offs.

Initial dimensions:

1. **Emotion awareness** — recognizes or names relevant feelings and signals.
2. **Self-regulation** — considers pausing, calming down, or responding intentionally.
3. **Perspective-taking** — considers another person's possible context without pretending to know their mind.
4. **Constructive communication** — expresses needs, asks questions, listens, or sets boundaries respectfully.
5. **Boundaries and agency** — respects consent and autonomy, including the player's own limits.

Each dimension may use a small rubric such as 0–2 or 0–3 per response option. Rubrics must describe the quality of the response in that specific scenario, not the worth of the person choosing it.

A simple baseline scoring model:

- Each question has a maximum possible rubric score defined in the content data.
- The selected option contributes the scenario's rubric points.
- `EQ Practice Score = round(100 × earnedRubricPoints / possibleRubricPoints)` for the completed session.
- Store and display the component skill dimensions separately so a single aggregate score does not conceal what was being practised.
- If options have different maximums, the authored content validator must ensure the denominator is defined consistently for that item.

When explaining an answer, use language such as “This response may help because…” and “One risk is…”. Avoid presenting one choice as universally correct if context could reasonably change the best response.

### 4.4 Mixed Quest score

For Quick Quest, show separate IQ/reasoning and EQ practice summaries. A single overall number may be shown only as a secondary **Quest Completion Score** (0–100) that combines authored in-game points according to a fixed documented formula. It must not be branded as a real IQ/EQ composite.

Prefer showing:

- Questions completed.
- Correct answers in objectively scored reasoning items.
- IQ Challenge Score where applicable.
- EQ Practice Score where applicable.
- Skill-dimension feedback.
- Elapsed time, shown separately.
- Personal best for the same mode and score algorithm version.

### 4.5 Score algorithm versioning

Every persisted result must record `scoreAlgorithmVersion`, beginning at `1`. If scoring logic changes in the future, old results must remain interpretable. Do not silently recalculate historical scores with new rules.

### 4.6 Content-quality rules for EQ

- Do not create questions that assess or infer a player's mental-health status.
- Do not treat eye contact, neurotypical social conventions, extroversion, compliance, or emotional suppression as universal signs of healthy EQ.
- Include respectful assertiveness, boundaries, asking clarifying questions, and seeking help as possible constructive responses.
- Avoid culturally narrow assumptions where possible; add context when social norms may differ.
- Do not advise users to tolerate harassment, abuse, coercion, or unsafe behavior in the name of empathy.
- When a scenario involves a safety concern, prioritize boundaries and seeking appropriate help rather than trying to “win” the social interaction.

---

## 5. Question Bank and Content System

### 5.1 Content storage

All initial content is bundled with the app in local JSON files under `assets/content/`. Runtime question delivery must not require network access.

Suggested content files:

```text
assets/
  content/
    manifest.json
    en/
      iq_questions.json
      puzzle_questions.json
      eq_scenarios.json
    images/
      puzzles/
      illustrations/
```

If a second language is added, use language-specific content files and explicit locale selection. Do not mix languages inside a question unless that is intentional pedagogical content.

### 5.2 Content manifest

`manifest.json` should define:

- Schema version.
- Content pack version.
- Supported locales.
- Content files included in the pack.
- Expected item counts by domain/type.
- Optional checksums if the build pipeline can reliably generate and validate them.

The app must reject malformed question data gracefully and log developer-readable diagnostics in debug/test builds. Never crash the Home screen because one content record is invalid.

### 5.3 Minimum MVP content target

Before the initial MVP is considered content-complete, author at least:

- **50 IQ/reasoning questions** across at least four reasoning categories.
- **15 puzzle interaction items** supporting at least three actual mechanics; items may also be included in the reasoning count only if the content taxonomy clearly distinguishes the mechanic from the skill domain.
- **40 EQ scenarios** across the five initial skill dimensions.
- At least three authored difficulty levels, with adequate representation at each level.
- Correct answers and explanations for every objectively scored question.
- Contextual feedback and a rubric for every EQ option.

These are product targets, not psychometric validation requirements. Content should be original or appropriately licensed. Do not copy copyrighted question banks from standardized IQ tests.

### 5.4 Recommended question model

Use typed Dart models with explicit validation. A shared base model can hold common fields, with subtype models for multiple-choice reasoning items, interactive puzzle items, and EQ scenarios.

Common fields:

- `id`: stable unique string, e.g. `iq_sequence_001`.
- `domain`: `iq`, `puzzle`, or `eq`.
- `contentType`: such as `multiple_choice`, `memory_sequence`, `reorder_sequence`, or `scenario_choice`.
- `skill`: stable taxonomy key, not localized display text.
- `difficulty`: `easy`, `medium`, or `hard`.
- `prompt`: localized prompt text.
- `instructions`: optional action instructions.
- `explanation`: explanation shown after the response, when appropriate.
- `hint`: optional hint; if hints affect score, that rule must be explicit and tested.
- `estimatedSeconds`: optional author-estimated reading/solving time.
- `pointsWeight`: positive integer for objective IQ/reasoning questions only.
- `locale`: BCP-47-like locale key such as `en`.
- `tags`: list of stable tags for selection/filtering.
- `contentVersion`: version number for this item.
- `attribution`: optional source/license note for external assets or adapted content.

Additional fields for objective multiple choice:

- `options`: at least two choices, each with a stable `id` and localized `text`.
- `correctOptionId`: must reference exactly one valid option for single-answer items.
- `explanation`: should explain the rule, not only repeat the answer.

Additional fields for puzzle interactions:

- `interactionConfig`: typed, validated configuration for the puzzle mechanic.
- `expectedAnswer`: typed data appropriate to the mechanic; do not use arbitrary executable expressions in JSON.
- `hints`: optional list of progressively revealing hints.

Additional fields for EQ scenarios:

- `scenarioContext`: enough context for the choices to be understandable.
- `options`: plausible response options.
- `rubricByOption`: mapping of option ID to dimension scores and contextual feedback.
- `skillDimensions`: dimensions that the scenario is intended to practise.
- `feedbackTone`: optional content style key, not arbitrary executable code.
- `followUpReflection`: optional question that invites reflection without requiring free-text data to be uploaded anywhere.

### 5.5 Example JSON: objective reasoning item

```json
{
  "schemaVersion": 1,
  "contentPackVersion": "1.0.0",
  "items": [
    {
      "id": "iq_sequence_001",
      "domain": "iq",
      "contentType": "multiple_choice",
      "skill": "pattern_recognition",
      "difficulty": "easy",
      "locale": "en",
      "prompt": "Which number comes next in the sequence?",
      "instructions": "Look for the rule that connects each number.",
      "options": [
        { "id": "a", "text": "11" },
        { "id": "b", "text": "13" },
        { "id": "c", "text": "15" },
        { "id": "d", "text": "17" }
      ],
      "correctOptionId": "b",
      "explanation": "Explain the intended sequence rule here, including why the other options do not fit.",
      "hint": "Compare the difference between consecutive numbers.",
      "estimatedSeconds": 25,
      "pointsWeight": 1,
      "tags": ["sequence", "numbers"],
      "contentVersion": 1
    }
  ]
}
```

This record is a schema illustration only; authors must ensure that any actual example question has a logically unambiguous rule.

### 5.6 Example JSON: EQ scenario item

```json
{
  "id": "eq_feedback_001",
  "domain": "eq",
  "contentType": "scenario_choice",
  "skill": "constructive_communication",
  "difficulty": "medium",
  "locale": "en",
  "scenarioContext": "A teammate gives you critical feedback in a meeting. You feel defensive, but you want to understand the concern.",
  "prompt": "What is a constructive next step?",
  "options": [
    { "id": "a", "text": "Ask for a specific example and listen before responding." },
    { "id": "b", "text": "Agree with every point immediately, even if you are unsure." },
    { "id": "c", "text": "Respond with a personal criticism of your teammate." }
  ],
  "rubricByOption": {
    "a": {
      "scores": {
        "emotion_awareness": 2,
        "self_regulation": 2,
        "perspective_taking": 2,
        "constructive_communication": 3,
        "boundaries_and_agency": 2
      },
      "feedback": "Asking for an example can clarify the concern and gives you time to respond thoughtfully. You can still disagree after you understand the feedback."
    },
    "b": {
      "scores": {
        "emotion_awareness": 1,
        "self_regulation": 2,
        "perspective_taking": 1,
        "constructive_communication": 1,
        "boundaries_and_agency": 0
      },
      "feedback": "Staying calm can help, but agreeing before you understand may hide important questions or boundaries."
    },
    "c": {
      "scores": {
        "emotion_awareness": 0,
        "self_regulation": 0,
        "perspective_taking": 0,
        "constructive_communication": 0,
        "boundaries_and_agency": 0
      },
      "feedback": "A personal attack is likely to escalate the disagreement and move attention away from the feedback itself."
    }
  },
  "skillDimensions": ["emotion_awareness", "self_regulation", "perspective_taking", "constructive_communication", "boundaries_and_agency"],
  "followUpReflection": "What would help you feel ready to respond to difficult feedback?",
  "contentVersion": 1
}
```

The example illustrates a data shape, not a validated EQ rubric. Content authors must review each scenario for context, ambiguity, cultural assumptions, and appropriate feedback. The app must not suggest that these scores are clinically validated.

### 5.7 Question selection rules

Create a pure, unit-testable `SessionBuilder` that accepts a mode, selected difficulty, content bank, recent question IDs, requested count, and an optional deterministic seed.

Requirements:

- No duplicate question IDs within a session.
- Include the requested domain mix when enough valid content exists.
- Distribute questions across available skills and difficulties rather than repeatedly selecting one category.
- Avoid questions from the most recent configurable number of completed sessions where enough alternatives exist.
- Never return fewer questions silently. Return a typed selection error or show a clear message if the installed question bank cannot satisfy the requested session.
- Daily Challenge selection must be deterministic for a date and content-pack version.
- Random selection must be injectable so tests can use a predictable seed.
- Do not make question selection depend on remote services, device identifiers, or hidden analytics.

### 5.8 Content validation tooling

Create tests or a developer tool that checks:

- Duplicate or missing IDs.
- Unknown domains, question types, skills, and difficulty keys.
- Missing prompts/options/explanations.
- Invalid `correctOptionId` references.
- EQ option IDs missing rubrics or feedback.
- Rubric scores outside the defined range.
- Empty or inconsistent score denominators.
- Unsupported locale files.
- Invalid interaction configurations.
- Insufficient question counts for a mode.
- Unexpected remote URLs in content data.

The content validator should fail CI/tests for invalid bundled content. At runtime, malformed records must be excluded safely and reported in debug mode.

---

## 6. Technical Architecture

### 6.1 Architectural approach

Use a feature-first structure with a lightweight MVVM-style separation:

- **Presentation:** Flutter pages/widgets and view models/controllers.
- **Domain:** typed models, session state, question selection, scoring rules, and use cases when the logic is non-trivial or reused.
- **Data:** bundled JSON loading, local SQLite persistence, repositories, and preferences.

Keep UI rendering separate from scoring, session construction, and persistence. Widgets must not parse raw JSON, execute scoring formulas, or issue SQL queries.

### 6.2 Recommended stack

Resolve package versions that are compatible with the project's installed stable Flutter/Dart SDK when implementation begins. Do not copy version numbers from this plan blindly. Review current official package docs, changelogs, platform minimums, and licenses before adding dependencies.

Recommended choices:

- **Flutter / Dart:** UI, layout, animations, accessibility, and app lifecycle.
- **flutter_riverpod:** reactive state management and testable dependency injection.
- **go_router:** typed/centralized route organization and navigation. Keep routing simple; do not introduce nested navigators without a product need.
- **drift + SQLite:** local persistence for game sessions, question attempts, and achievements; supports transactions and schema migrations.
- **shared_preferences:** non-critical simple preferences only, using a current supported API such as `SharedPreferencesAsync` or `SharedPreferencesWithCache`; do not store authoritative session records here.
- **json_serializable** (optional but recommended if it reduces boilerplate): JSON model generation. If used, include generated files in the normal build workflow and validate deserialization.
- **intl / Flutter gen-l10n:** date formatting and future-ready localization. Do not hard-code user-facing strings in score engines or repositories.
- **Flutter built-in animation APIs:** `AnimatedSwitcher`, `AnimatedContainer`, `TweenAnimationBuilder`, and `AnimationController` for most motion.
- **fl_chart** (optional): only if the Progress page needs richer charts than basic custom Flutter widgets. Use accessible labels and a text alternative for every chart.
- **uuid** (optional): local unique IDs if IDs are not generated deterministically. Stable question IDs must never be random.

Avoid adding packages for small features that can be implemented safely with Flutter itself. Do not add Flame to the MVP unless a concrete interaction cannot reasonably be implemented with regular Flutter widgets.

### 6.3 Dependency rules

- Presentation may depend on domain abstractions and state management.
- Domain logic must not depend on Flutter widgets, plugins, SQLite, or platform APIs.
- Repositories implement data access contracts and may depend on local data sources.
- Widgets must not access the database directly.
- Scoring code must be pure Dart where feasible.
- Never import a concrete SQLite DAO into a view model if a repository interface can keep the boundary clear.
- Keep all random-number generation injectable.
- Keep clocks/date providers injectable for daily challenge and streak tests.
- Avoid service locators or global mutable singletons beyond controlled app composition.

### 6.4 Suggested folder structure

Adapt to the generated Flutter project and current package APIs, but preserve the separation of concerns and feature ownership shown below.

```text
up_brain_quest/
├── android/
├── ios/
├── assets/
│   ├── content/
│   │   ├── manifest.json
│   │   └── en/
│   │       ├── iq_questions.json
│   │       ├── puzzle_questions.json
│   │       └── eq_scenarios.json
│   ├── images/
│   │   ├── icons/
│   │   ├── puzzles/
│   │   └── illustrations/
│   ├── fonts/                  # Only if licensed bundled fonts are required
│   └── audio/                  # Optional; omit if not needed
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── app_bootstrap.dart
│   │   ├── router.dart
│   │   └── providers.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── extensions/
│   │   ├── localization/
│   │   ├── logging/
│   │   ├── result/
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_gradients.dart
│   │   │   ├── app_spacing.dart
│   │   │   ├── app_typography.dart
│   │   │   └── app_theme.dart
│   │   ├── utils/
│   │   └── widgets/
│   │       ├── app_button.dart
│   │       ├── app_card.dart
│   │       ├── app_progress_bar.dart
│   │       ├── app_empty_state.dart
│   │       ├── app_error_state.dart
│   │       └── accessible_icon_button.dart
│   ├── data/
│   │   ├── content/
│   │   │   ├── question_asset_loader.dart
│   │   │   ├── content_manifest.dart
│   │   │   └── content_validator.dart
│   │   ├── database/
│   │   │   ├── app_database.dart
│   │   │   ├── tables/
│   │   │   ├── daos/
│   │   │   └── migrations/
│   │   ├── repositories/
│   │   └── preferences/
│   ├── domain/
│   │   ├── models/
│   │   ├── enums/
│   │   ├── repositories/
│   │   ├── services/
│   │   │   ├── session_builder.dart
│   │   │   ├── iq_score_calculator.dart
│   │   │   ├── eq_score_calculator.dart
│   │   │   ├── achievement_engine.dart
│   │   │   └── daily_challenge_builder.dart
│   │   └── use_cases/
│   └── features/
│       ├── home/
│       │   ├── presentation/
│       │   └── application/
│       ├── explore/
│       ├── gameplay/
│       │   ├── presentation/
│       │   ├── application/
│       │   └── widgets/
│       ├── iq_challenge/
│       ├── puzzle_sprint/
│       ├── eq_challenge/
│       ├── results/
│       ├── progress/
│       ├── achievements/
│       └── settings/
├── test/
│   ├── unit/
│   ├── data/
│   ├── widget/
│   ├── golden/                 # Optional, add only if maintained
│   ├── support/
│   └── fixtures/
├── integration_test/
├── analysis_options.yaml
├── pubspec.yaml
├── README.md
└── PLAN.md
```

Do not create empty folders or abstraction classes simply to match this tree. Add files when a feature requires them. A smaller but well-separated implementation is better than boilerplate-heavy “clean architecture.”

### 6.5 Error handling

Use typed domain/data errors where they improve recoverability, for example:

- `ContentLoadFailure`
- `ContentValidationFailure`
- `QuestionSelectionFailure`
- `SessionSaveFailure`
- `DatabaseMigrationFailure`

The UI should present a recoverable error state with a retry or return action where possible. Do not expose stack traces to end users. In debug and test environments, include useful error context in logs. Since this app has no backend, do not add network retry logic or network error banners.

---

## 7. Local Persistence and Offline Requirements

### 7.1 Source of truth

- Bundled assets are the source of truth for question content and explanations.
- SQLite via Drift is the source of truth for completed sessions, attempts, progress, and achievements.
- Shared preferences are for lightweight non-critical settings such as sound, haptics, reduced motion, and chosen locale.
- Derived values such as overall accuracy or skill summaries should be calculated from persisted session/attempt data or cached with an explicit invalidation strategy. Avoid maintaining multiple conflicting sources of truth.

### 7.2 Initial database schema

Use typed Drift tables or equivalent normalized SQLite tables. Exact names can change if the same semantics are preserved.

#### `game_sessions`

- `id` — primary key, generated locally.
- `mode` — quick quest, IQ challenge, EQ challenge, puzzle sprint, or daily challenge.
- `status` — completed or abandoned; unfinished sessions are not scored as completed.
- `started_at` — UTC timestamp.
- `completed_at` — nullable UTC timestamp.
- `duration_ms` — nullable/integer elapsed duration.
- `question_count` — number of items in the session.
- `answered_count` — number of submitted responses.
- `iq_score` — nullable 0–100 in-game score.
- `eq_score` — nullable 0–100 practice score.
- `quest_completion_score` — nullable secondary mixed-session score if implemented.
- `earned_points` and `possible_points` — nullable aggregate point values.
- `score_algorithm_version` — integer.
- `content_pack_version` — string.
- `daily_local_date` — nullable ISO local date for daily challenges.

#### `question_attempts`

- `id` — primary key.
- `session_id` — foreign key to `game_sessions`.
- `question_id` — stable ID from bundled content.
- `domain` and `skill` — copied snapshots for historical reporting.
- `question_order` — order within the session.
- `submitted_answer_json` — typed/validated answer snapshot, without unnecessary personal text.
- `is_correct` — nullable for EQ items or questions that do not have a binary correctness result.
- `earned_points` and `possible_points` — numeric snapshots.
- `rubric_scores_json` — optional EQ dimension scores.
- `elapsed_ms` — optional per-item duration.
- `hint_used` — boolean if hints exist and this statistic is shown.
- `answered_at` — nullable timestamp.
- Unique constraint: one attempt per `session_id` + `question_id` unless the product explicitly allows repeated identical IDs in a future mode.

#### `achievements`

- `id` — stable achievement key.
- `unlocked_at` — nullable timestamp.
- `progress_value` — current local progress if applicable.
- `target_value` — target for progressive achievements.
- `definition_version` — version of the achievement rules.

#### `daily_activity`

- `local_date` — local ISO date primary key.
- `completed_daily_challenge` — boolean.
- `completed_sessions_count` — integer.
- `created_at` — UTC timestamp.

A small `app_metadata` table may be added for database/content migration metadata if needed. Avoid storing unnecessary user identifiers or device fingerprints.

### 7.3 Persistence rules

- Save a completed session and all associated attempts in one database transaction.
- If persistence fails, do not falsely show the result as safely saved. Keep the result in memory and present a recoverable warning with Retry and Continue options.
- Use database schema migrations; never delete user progress merely to apply a schema change.
- Write database migration tests from each supported schema version.
- Store session timestamps in UTC and convert them to device-local time for display.
- Daily challenge date keys are based on the device's local date; document that moving the device clock can affect local streaks.
- Avoid putting critical history and score records in SharedPreferences.
- Provide a **Reset local data** setting with a confirmation step. It must clearly explain which local data will be deleted.
- No account identifier, advertising ID, analytics ID, or remote synchronization token should be created.

### 7.4 Offline guarantee

The release build must not depend on a network connection for launch or any core feature.

- No backend or remote API client.
- No Firebase, remote config, analytics, crash-reporting upload, ads, or social SDK in the MVP.
- No remote fonts, image URLs, question loading, or feature flags.
- All essential illustrations, fonts, sounds, and questions are bundled in the app.
- Audit plugin transitive dependencies and release permissions before shipping.
- Remove the Android Internet permission from the release manifest if no selected dependency genuinely requires it. If a platform/plugin requires network permission, document why and verify that the app still makes no network requests.
- Core integration tests must pass in airplane mode or with networking disabled.
- A failed or unavailable network connection must never block app startup or gameplay.

---

## 8. UI/UX Design System

### 8.1 Design direction

Use a modern, premium-feeling brain-game aesthetic:

- Deep navy/indigo surfaces with violet and cyan/teal accent gradients.
- Bright gradient hero cards for selected challenges and progress moments.
- Neutral, high-contrast reading surfaces for question text and explanations.
- Rounded cards and buttons with restrained shadows.
- Clear typography hierarchy and generous spacing.
- Small visual motifs such as sparkles, abstract brain/connection lines, geometric shapes, and achievement icons.
- Avoid using gradients behind long paragraphs or low-contrast text.

Define colors, gradients, radii, spacing, and text styles in shared theme files. Do not hard-code one-off colors across feature screens.

### 8.2 Suggested design tokens

These are starting values, not an excuse to ignore contrast testing. Adjust based on actual rendering and accessibility checks.

- Background: deep navy, e.g. `#0B1020` for a dark theme.
- Primary surface: e.g. `#151D33`.
- Elevated surface: e.g. `#202B45`.
- Primary accent: violet/purple, e.g. `#7C5CFF`.
- Secondary accent: cyan, e.g. `#29C7D8`.
- Supporting accent: blue, e.g. `#4C8DFF`.
- Positive state: accessible green with sufficient contrast.
- Caution state: accessible amber.
- Error state: accessible red.
- Text: near-white for dark surfaces and near-black for light surfaces.
- Spacing scale: 4, 8, 12, 16, 24, 32.
- Corner radius: 12 for inputs, 16 for standard cards, 24 for large hero cards.
- Minimum interactive target: target 48×48 logical pixels where practical.

Use Flutter's `ColorScheme` and theme system. A dark theme is the primary art direction. A light theme can be added if the implementation can support it consistently without delaying the MVP. Do not implement an incomplete theme toggle.

### 8.3 Main screens

#### Home

- Branding: UpBrainQuest.
- Main CTA: “Start Quick Quest”.
- Secondary cards: IQ Challenge, Puzzle Sprint, EQ Challenge.
- Daily Challenge card with local completion state.
- Progress summary: last result or a welcoming empty state.
- Achievement preview and streak only after these systems are implemented.
- Do not label the score as a standardized IQ.

#### Explore

- Mode cards with icon/illustration, one-sentence description, expected length, and difficulty selection.
- Explain whether a mode is timed.
- Provide a clear CTA and avoid a dense grid of tiny controls.

#### Gameplay

- Current question number and progress indicator.
- Prompt and instructions at the top of the content area.
- Sufficient space for puzzle options or interaction controls.
- Optional hint affordance.
- Large answer choices with full-row tap targets.
- Submit/continue controls that are clearly disabled when inappropriate.
- Immediate feedback state with explanation.
- Timer only in explicitly timed modes.
- Prevent accidental exit or loss of a response.

#### EQ scenario

- Show the scenario separately from the question.
- Avoid using stereotyped faces as the sole emotional cue. Text context must carry essential meaning.
- Present choices neutrally; do not color choices as “good” or “bad” before the user answers.
- Explain the trade-offs after a selection.
- Do not force free-text disclosure. If optional reflection text is implemented, keep it local and offer deletion.

#### Results

- Clear completion state.
- Distinct score cards for IQ Challenge Score and EQ Practice Score when relevant.
- Accuracy/completed-count and elapsed time.
- Skill-dimension breakdown and a short explanation of what the result means.
- Review answers action.
- Replay and Home actions.
- Small celebratory animation, not a blocking animation.
- Disclaimer access near score details.

#### Progress

- Historical session list with mode, date, score and duration.
- Progress charts only where multiple data points make a chart meaningful.
- Label trend charts as changes in game performance, not improvements in innate intelligence.
- Always provide text equivalents for chart values.
- Empty state with an obvious way to play the first challenge.

#### Settings

- Sound effects on/off.
- Haptics on/off.
- Reduced motion.
- Language setting only when the app actually includes the language content and translations.
- About and score disclaimer.
- Reset local data with destructive-action confirmation.

### 8.4 Animation system

Use animations for feedback and continuity, not decoration on every element.

Recommended motion:

- Route transition: subtle fade/slide, approximately 180–260 ms.
- Answer selection: short border/fill animation.
- Correct/incorrect feedback: quick icon/scale transition; avoid flashing.
- Progress bar: animate after a response.
- Results score reveal: short count-up or fade, with an immediate accessible final value.
- Achievement unlock: brief celebration with a skip/close path.

Requirements:

- Respect reduced-motion settings.
- Avoid fast flashing, repetitive vibration, forced long animations, or animation that delays access to the next action.
- Use deterministic, testable animation boundaries where possible.
- Dispose `AnimationController`s correctly and test lifecycle interruptions.
- Never use animation alone to communicate correctness, errors, or progress; pair it with text/icons/semantics.

### 8.5 Responsive and accessible layouts

- Support small Android phones, modern large phones, and iOS devices with safe areas.
- Keep question content readable without clipping at 200% text scaling where feasible; scroll rather than overflow.
- Do not assume portrait width is always available. Handle landscape gracefully or explicitly lock orientation only if a puzzle mechanic truly requires it.
- Use `SafeArea`, flexible layouts, and scrolling content thoughtfully.
- Add semantic labels to interactive icons and custom puzzle controls.
- Never communicate correctness or score solely through color.
- Verify color contrast, focus behavior where applicable, screen-reader order, and larger text.
- Avoid touch targets smaller than 44–48 logical pixels.

---

## 9. State Management and Routing

### 9.1 Riverpod usage

Use Riverpod for scoped dependencies and reactive feature state. Avoid storing all application state in one giant notifier.

Recommended provider responsibilities:

- Question bank provider: loads, validates, and exposes immutable content.
- Repository providers: expose local repositories and database access.
- Session controller/provider: active session state and commands.
- Results provider: calculates and loads completed result summaries.
- Progress provider: aggregates history and achievement state.
- Settings provider: reads and writes non-critical preferences.

Keep pure engines such as `SessionBuilder` and score calculators as ordinary Dart classes/functions, injected into controllers. This makes them straightforward to unit-test without building widget trees.

### 9.2 Routing

Recommended routes:

- `/` — Home.
- `/explore` — Explore modes.
- `/progress` — Progress.
- `/settings` — Settings.
- `/session/setup/:mode` — mode setup.
- `/session/play/:sessionId` — active gameplay.
- `/session/result/:sessionId` — completed result.
- `/session/review/:sessionId` — answer review.
- `/achievements` — achievements, if enabled.

The concrete route pattern may change to fit go_router conventions. Ensure session state cannot be lost merely because a page rebuilds. The route should not treat route parameters as trusted arbitrary input; validate IDs and mode names.

---

## 10. Analytics, Privacy, and Local Data

Because the app is fully offline, there must be no remote analytics, telemetry, crash upload, ad measurement, or behavioral tracking SDK in the MVP.

- Collect only the local data needed for gameplay, progress, settings, and user-visible features.
- Do not ask for a name, date of birth, contacts, location, microphone, camera, or photos.
- Do not infer age, personality type, mental-health status, or personal traits from scores.
- Any free-text reflection must remain local and be deletable; omit it from the MVP unless it adds clear user value.
- Add an in-app explanation of local storage and a reset option.
- Avoid advertising IDs or device fingerprinting.
- Keep sensitive values out of logs and error messages.
- Check app store privacy declarations against actual dependencies and behavior.

---

## 11. Testing Strategy

Testing is required at every phase, not reserved for the release phase.

### 11.1 Unit tests

Cover:

- JSON parsing and model validation.
- Content manifest parsing.
- Duplicate IDs and invalid option/rubric references.
- Session construction for each game mode.
- Domain mix and difficulty filters.
- No duplicate questions in one session.
- Deterministic random selection when seeded.
- Deterministic daily challenge selection by date and content version.
- IQ score boundaries, weighted questions, unanswered items, and zero denominator.
- EQ rubric calculations and dimension breakdowns.
- Score algorithm version recorded with a result.
- Achievement unlock conditions.
- Streak behavior across consecutive days, missed days, and local date changes.
- Elapsed-time calculations and app pause/resume logic.
- Database insert/update queries and transaction rollback behavior.
- Database schema migrations.

### 11.2 Widget tests

Cover:

- Home screen loading, success and content-error states.
- Navigation between the primary destinations.
- Mode setup selections.
- Each question widget type.
- Answer selection, submit locking, feedback and continue controls.
- EQ feedback copy and selected-option result.
- Results for IQ, EQ, and mixed modes.
- Empty progress history and populated progress history.
- Reset-data confirmation.
- Reduced-motion behavior where practical.
- Dynamic text scaling and narrow layouts.

### 11.3 Integration tests

At minimum, automate the critical user journeys:

1. Fresh install → Home → Quick Quest → answer every question → Results → Home.
2. IQ Challenge → complete → score saved → close/relaunch app → score remains in Progress.
3. EQ Challenge → choose options → see contextual feedback → finish → view skill breakdown.
4. Complete a session while offline/airplane mode is enabled.
5. Force a save error or simulate repository failure and verify that the app reports it honestly without losing the in-memory result.
6. Reset local data and verify that sessions, attempts, progress, and achievements are removed as described.
7. Resume or abandon an interrupted session according to the implemented policy.

### 11.4 Static analysis and build checks

Before each phase is accepted:

- `dart format --output=none --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- Build for the target platform(s) touched by the phase.
- Run content validation tests whenever JSON content changes.

Use the project's actual supported Dart/Flutter versions and adapt commands where current tooling differs. Keep analysis warnings at zero unless a specific exception is documented and justified.

### 11.5 Manual QA matrix

Manually test at least:

- A small Android screen and a large Android screen.
- A representative iPhone size.
- Dark mode; light mode only if implemented.
- System text scaling.
- Screen reader basics for Home, gameplay, feedback, and Results.
- Device rotation or the explicit orientation policy.
- Backgrounding the app during a timed question.
- Repeated fast taps on submit/continue.
- Empty database, normal database, and migration from the previous schema.
- App launch and a complete session with network disabled.

### 11.6 Definition of test quality

Do not chase coverage percentage at the expense of useful assertions. Prioritize score correctness, session integrity, offline behavior, persistence, and question selection. Document any manual-only test and why it cannot be automated.

---

## 12. Implementation Roadmap

Complete the phases sequentially. Each phase must end with a runnable app, passing tests for the scope, a short implementation summary, and a list of known issues. Do not build all phases in one unreviewable change.

## Phase 0 — Repository Discovery and Project Baseline

### Goals

Understand the repository state and establish a stable Flutter development baseline before implementing features.

### Tasks

1. Inspect the existing repository, README, app entry point, dependency configuration, platform folders, and existing tests.
2. If no Flutter project exists, create one using the installed stable Flutter SDK and the chosen package identifier. If a project already exists, preserve working configuration and adapt it rather than regenerating it blindly.
3. Confirm the installed Flutter/Dart versions and target minimum Android/iOS versions. Choose package versions compatible with those constraints.
4. Add/update `analysis_options.yaml` and enforce formatting/static analysis.
5. Create `PLAN.md` in the repository and summarize the planned architecture in `README.md`.
6. Set up the basic CI command set if CI exists; do not introduce a complex pipeline unnecessarily.
7. Identify generated files and document the commands required to regenerate them.

### Deliverables

- A building Flutter project.
- Baseline analysis configuration.
- Documented SDK/package compatibility decisions.
- A passing baseline test/build.

### Acceptance criteria

- `flutter pub get` succeeds.
- `flutter analyze` passes without unexplained warnings.
- `flutter test` passes.
- A debug build launches on at least one target device/emulator.
- The repository has no unnecessary backend/Firebase/analytics dependencies.

---

## Phase 1 — App Shell, Theme, Navigation, and Design System

### Goals

Create the visual foundation and usable navigation shell before implementing full gameplay.

### Tasks

1. Implement app bootstrap and a clear provider composition point.
2. Implement `MaterialApp.router` or the current equivalent recommended by the selected router package.
3. Add the primary navigation destinations: Home, Explore, Progress, Settings.
4. Add theme tokens for colors, gradients, typography, spacing, radii, shadows, and component states.
5. Create reusable buttons, cards, progress indicators, empty states, and error states.
6. Implement responsive/safe-area behavior and shared screen scaffolding.
7. Set up localization support so text is not scattered across business logic, even if only one locale ships in the first milestone.
8. Add a reduced-motion preference abstraction before using complex animations.
9. Use placeholders/empty states where features are not yet implemented; do not show fake scores as real user progress.

### Deliverables

- Functional app shell.
- Home, Explore, Progress, and Settings placeholders.
- Reusable visual components and theme.
- Navigation tests and a short UI consistency note.

### Acceptance criteria

- All four main destinations are reachable and back navigation behaves correctly.
- Layout does not overflow at narrow phone widths.
- All interactive buttons have meaningful semantic labels.
- Colors and type are sourced from theme tokens rather than scattered literals.
- Reduced-motion preference can be read by UI components.
- No placeholder data is presented as actual completed progress.

---

## Phase 2 — Content Models, JSON Loader, and Content Validation

### Goals

Build the offline content system before gameplay depends on it.

### Tasks

1. Define typed domain enums/models for question domain, content type, skill, difficulty, options, rubric dimensions, and validation results.
2. Define the JSON schema contract and `manifest.json` structure.
3. Implement the asset loader for the bundled question files.
4. Implement parsing and validation, including duplicate ID detection and reference checking.
5. Implement typed error results for content-load failures.
6. Add a starter content bank sufficient for development, labelled as draft where needed.
7. Add fixtures for valid content, malformed content, missing fields, duplicate IDs, and incorrect references.
8. Ensure the loader can be tested without launching a widget tree.
9. Add a developer-facing validation command or automated test that scans every bundled content file.

### Deliverables

- Stable question model contracts.
- Asset loader and validator.
- Initial bundled content and validation tests.
- Documented content-authoring instructions.

### Acceptance criteria

- All bundled content loads without network access.
- Invalid JSON or invalid records produce understandable diagnostic errors.
- Invalid records do not crash Home or silently turn into incorrect questions.
- IDs/options/rubrics validate as expected.
- The content bank can be extended by adding a correctly structured JSON item without changing gameplay code.

---

## Phase 3 — Core Session Engine and IQ Challenge

### Goals

Deliver a complete reasoning gameplay loop with correct deterministic scoring and answer feedback.

### Tasks

1. Implement `SessionBuilder` and domain-specific session configuration.
2. Implement session state transitions and immutable answer submissions.
3. Implement objective answer evaluation and `IqScoreCalculator` as pure Dart.
4. Implement at least these first three mechanics: multiple-choice reasoning, pattern/sequence selection, and memory sequence reproduction. A fourth mechanic such as reorder sequence may be added if the first three are stable.
5. Implement the gameplay screen: question progress, answer selection, feedback state, explanation, and continue action.
6. Add question hints only if the hint-score policy is explicitly defined. Default MVP behavior should avoid score penalties for optional hints unless the user is told otherwise.
7. Implement pre-session instructions and the standard untimed mode.
8. Add a timed variant only after lifecycle and pause/resume behavior are tested.
9. Prevent double submissions and ensure each answer is counted exactly once.
10. Create the initial bank of at least 50 IQ/reasoning questions across four or more categories by the content-complete milestone.
11. Add unit/widget tests for every mechanic and objective scoring edge case.

### Deliverables

- Playable IQ Challenge.
- Reusable session state machine.
- Three polished puzzle mechanics.
- Score calculator and explanation flow.
- IQ content bank and tests.

### Acceptance criteria

- The player can launch a reasoning session, answer every question, receive feedback, and reach a result screen.
- The same input data produces the same score.
- Unanswered questions are counted in the denominator according to the documented rules.
- Repeated taps cannot double-score an answer.
- No question repeats inside one session.
- The UI calls the score an in-game challenge score and never converts it into a purported standardized IQ.
- All scoring boundary tests pass.

---

## Phase 4 — EQ Scenario Gameplay and Rubric Scoring

### Goals

Deliver EQ practice as an explanatory, context-sensitive experience rather than a simple right/wrong morality quiz.

### Tasks

1. Implement the EQ scenario model and validate that each option maps to a valid rubric.
2. Implement `EqScoreCalculator` as pure Dart.
3. Define and document the dimension rubric and maximum-score normalization.
4. Design a dedicated scenario layout with context, response options, and post-answer feedback.
5. Show a balanced explanation of benefits and trade-offs; support more than one constructive option where appropriate.
6. Add dimension breakdowns for emotion awareness, self-regulation, perspective-taking, constructive communication, and boundaries/agency.
7. Create at least 40 EQ scenarios before the content-complete milestone.
8. Review scenario text for ambiguity, stereotypes, unsafe advice, and overly judgmental language.
9. Add tests that verify rubric calculations and UI copy do not label the player as good/bad or diagnose the player.

### Deliverables

- Playable EQ Challenge.
- Rubric engine and dimension breakdown.
- EQ result/feedback UI.
- Initial EQ scenario bank and content review checklist.

### Acceptance criteria

- Every EQ option has valid rubric points and contextual feedback.
- The selected option maps to the expected skill scores.
- More than one option can receive meaningful credit where the content supports it.
- Feedback avoids shaming language and clearly acknowledges context and trade-offs.
- Results are labelled “EQ Practice Score” or equivalent, with a visible explanation that the score is not a validated assessment.

---

## Phase 5 — Mixed Quick Quest, Results, Review, and Score Presentation

### Goals

Unify modes into a coherent mixed experience and make results useful and honest.

### Tasks

1. Implement Quick Quest selection with a balanced domain mix.
2. Implement the Results domain model, including separate IQ and EQ summaries where applicable.
3. Implement the mixed session's secondary Quest Completion Score only if its formula is fixed, documented, and tested. Otherwise omit it.
4. Add answer review with each question, the player's response, the explanation, and the appropriate correctness or rubric summary.
5. Add score disclaimer content and expose it near the result and in About.
6. Add empty, incomplete, invalid, and error states.
7. Add restrained result animations with immediate final values for accessibility.
8. Test result summaries against the exact answers recorded by the session engine.

### Deliverables

- Mixed Quick Quest.
- Results and Review screens.
- Score interpretation/disclaimer UI.
- End-to-end widget and domain tests for all main modes.

### Acceptance criteria

- Quick Quest uses the intended content mix when enough valid items exist.
- If a requested mix cannot be satisfied, the user receives a clear recoverable message.
- Results accurately reflect saved answers and the scoring algorithm version.
- IQ and EQ values are not merged into a claim about real-world intelligence.
- Answer review always matches the completed session.
- The player can replay or leave results without corrupting history.

---

## Phase 6 — Local Database, History, and Progress

### Goals

Persist all relevant progress reliably across app restarts.

### Tasks

1. Add Drift/SQLite database initialization and lifecycle management.
2. Define tables for sessions and question attempts, then achievements/daily activity if those features are being implemented in this milestone.
3. Implement repository interfaces and local implementations.
4. Save session plus attempts transactionally.
5. Implement schema versioning and migration tests.
6. Add the session history list and progress aggregates.
7. Display trends only when enough data exists; use honest labels such as “recent game performance.”
8. Add error handling for database initialization and save failures.
9. Add reset-local-data flow with confirmation.
10. Ensure the Home/Progress UI uses actual local records and sensible empty states.

### Deliverables

- Persistent local database.
- Session/result repositories.
- Progress and history screens.
- Database migration and error-recovery tests.

### Acceptance criteria

- Completed sessions and attempts persist across force-close/relaunch.
- A completed session and its attempts are written atomically.
- Failed saves are not represented as successful durable saves.
- Database migrations preserve supported historical data.
- Reset-local-data removes the documented records after confirmation.
- The app remains fully usable without a network connection.

---

## Phase 7 — Achievements, Daily Challenge, and Replayability

### Goals

Add lightweight progression without compromising transparency or offline functionality.

### Tasks

1. Implement an achievement definition list, for example: First Quest, Five Completed Quests, Reasoning Explorer, Reflection Explorer, and Consistent Player.
2. Implement `AchievementEngine` as a pure/testable domain service.
3. Add achievement progress and unlock records to local persistence.
4. Implement deterministic Daily Challenge selection using local date and content version.
5. Track local daily completions and streaks with documented date-change behavior.
6. Add a small achievement collection screen and home preview.
7. Add replay behavior that avoids immediate repetition where enough content exists.
8. Keep rewards cosmetic/informational only; no purchases or manipulative notifications.

### Deliverables

- Local achievements.
- Daily Challenge.
- Local streak state.
- Tests for unlock, date, content-version, and replay rules.

### Acceptance criteria

- Achievements unlock exactly once when their conditions are met.
- Daily Challenge selection is deterministic for the same local date and content version.
- Daily challenge state works entirely offline.
- Streaks handle same day, next day, and missed-day cases correctly.
- No claim is made that a streak or leaderboard is globally verified.

---

## Phase 8 — Visual Polish, Accessibility, Localization Readiness, and Content QA

### Goals

Bring the app to a coherent, shippable quality level.

### Tasks

1. Refine gradients, hierarchy, spacing, typography, icons, and illustrations across all screens.
2. Add animation only where it supports feedback or navigation.
3. Finish reduced-motion behavior and haptics/sound preferences if those features exist.
4. Check semantics, text scaling, contrast, touch targets, and screen-reader navigation.
5. Complete content copy-editing and EQ scenario safety/context review.
6. Verify every mode has adequate question coverage and that no duplicate IDs or unsupported question types remain.
7. Add a second app locale only if complete UI translations and matching localized content are available. Otherwise keep the code localization-ready but do not show a nonfunctional language selector.
8. Ensure illustrations/fonts/audio are licensed and bundled.
9. Test error/empty/loading states and responsive layouts.
10. Remove debug-only placeholders and sample scores from release UI.

### Deliverables

- Consistent polished UI.
- Completed accessibility checks.
- Content QA report.
- Localization readiness notes.

### Acceptance criteria

- No overflow on supported screen sizes and tested text scaling.
- All key controls expose meaningful semantics.
- Reduced-motion preference is respected.
- Correct/incorrect feedback is not conveyed by color alone.
- All bundled content passes validation and EQ content review.
- No placeholder score or fake history appears in a release build.

---

## Phase 9 — Release Readiness, Offline Audit, and Documentation

### Goals

Verify the app behaves as a real offline product and document how to build and maintain it.

### Tasks

1. Run all static analysis, unit, widget, integration, and content validation tests.
2. Build release artifacts for the agreed target platforms.
3. Run core gameplay in airplane mode or with connectivity disabled.
4. Audit Android permissions, iOS capabilities, dependencies, and transitive SDKs for unexpected network/analytics behavior.
5. Verify no remote assets or API calls exist in the runtime path.
6. Check startup time, memory usage, frame pacing, and asset size on representative devices.
7. Verify database migration and reset behavior against a realistic history dataset.
8. Complete README build instructions, architecture note, question-authoring guide, scoring explanation, and known limitations.
9. Add an in-app About/Disclaimer section.
10. Prepare a release checklist and record the exact Flutter/Dart/package versions used for the build.

### Deliverables

- Release builds.
- Offline audit checklist.
- Final test report.
- README and maintenance documentation.
- Known limitations list.

### Acceptance criteria

- App launches and completes all core modes with networking disabled.
- No backend or remote content dependency exists.
- Release build succeeds for each agreed target.
- Critical test suite passes.
- Permissions and dependency audit is documented.
- App store privacy declarations are consistent with actual app behavior.
- README supports a new developer building and running the project from a clean checkout.

---

## 13. Cross-Phase Definition of Done

A phase is done only when all applicable items are satisfied:

1. The feature is implemented and integrated into the running app, not left as pseudo-code or a TODO.
2. The changed code follows the folder, dependency, and state-management boundaries in this plan.
3. User-visible text is localizable and does not embed product logic in widgets.
4. Loading, empty, invalid, error, and success states are considered.
5. Tests cover the feature's important behavior and edge cases.
6. `dart format`, `flutter analyze`, and relevant tests pass.
7. The feature works offline and introduces no unapproved service or SDK.
8. Accessibility and reduced-motion implications are considered.
9. The implementation summary identifies files changed, commands executed, test results, and any known limitations.
10. The plan is updated if a meaningful technical decision changes. Do not quietly diverge from score definitions or data semantics.

---

## 14. Coding Agent Operating Instructions

These instructions are intended for Claude Code, Codex, or another coding agent implementing this repository.

1. Read this complete `PLAN.md` before editing code.
2. Inspect the existing repository first. Do not assume it is an empty project.
3. Work one phase at a time in roadmap order unless a dependency requires a small preparatory change.
4. At the start of each phase, state the phase objective and the specific files/features to be affected in your working notes or implementation summary.
5. Prefer small, coherent changes over a single huge rewrite.
6. Do not add cloud services, network calls, analytics, ads, authentication, or online-only features.
7. Do not add dependencies without explaining what need they satisfy. Verify package maintenance status, current APIs, platform support, license, and compatibility with the installed Flutter/Dart SDK.
8. Do not use an IQ conversion, population ranking, diagnosis, clinical EQ label, or any other claim prohibited by Section 4.
9. Keep score algorithms in testable pure Dart code and version persisted results.
10. Use deterministic fixtures and injectable random/date sources for gameplay tests.
11. Do not hard-code question content into widget code. Store authored questions in the validated content bank.
12. Do not use lorem ipsum, arbitrary fake scores, or fake history in release screens.
13. Do not silence analyzer warnings or test failures merely to make the pipeline green. Explain and resolve the underlying issue.
14. Do not continue to the next phase while the current phase has failing acceptance criteria. If blocked, describe the blocker and propose the smallest justified adjustment.
15. At the end of a phase, report: summary, key files changed, dependency changes, test/build commands and results, acceptance criteria status, known limitations, and next phase.
16. Keep `README.md` aligned with the real setup and commands.
17. If a feature is intentionally deferred, document it in the phase summary and keep its placeholder honest and non-interactive.
18. Preserve local user data when changing database schemas.
19. Keep all app content available on a fresh install without downloading anything.
20. If implementation reality requires a change to this plan, explain the trade-off and update the plan rather than making an undocumented design change.

---

## 15. MVP Release Checklist

### Product and gameplay

- [ ] Home, Explore, Progress, and Settings are functional.
- [ ] Quick Quest, IQ Challenge, EQ Challenge, and at least three puzzle mechanics work end to end.
- [ ] Every answered item receives appropriate feedback.
- [ ] Session state prevents double submission and accidental corruption.
- [ ] Results and answer review match the player's submitted answers.
- [ ] At least 50 IQ/reasoning questions, 15 puzzle interaction items, and 40 EQ scenarios pass validation and content review.
- [ ] IQ/EQ score disclaimer is accessible and understandable.

### Scoring and content

- [ ] IQ score uses the documented 0–100 in-game formula.
- [ ] EQ score uses explicit author-defined rubrics and dimension scores.
- [ ] No score is converted into a standardized IQ or clinical EQ statement.
- [ ] Score algorithm version is persisted.
- [ ] Invalid content is reported and cannot crash the app.

### Offline and persistence

- [ ] First launch works without connectivity.
- [ ] All questions and assets are bundled locally.
- [ ] Completed sessions and attempts persist across relaunch.
- [ ] Database transaction, migration, save-error, and reset paths are tested.
- [ ] No account, network API, analytics upload, ads SDK, or online-only dependency exists.
- [ ] Platform permissions and dependencies have been audited.

### UX and accessibility

- [ ] Responsive layouts work on small and large phones.
- [ ] No critical text overflow exists at supported text scaling.
- [ ] Touch targets and semantic labels are adequate.
- [ ] Reduced motion is honored.
- [ ] Color is not the only signal for correctness or status.
- [ ] Error and empty states are designed, not left blank.

### Engineering and release

- [ ] Formatting and static analysis pass.
- [ ] Unit, widget, content validation, and integration tests pass.
- [ ] Release builds succeed for target platforms.
- [ ] Offline test plan has passed.
- [ ] README/build instructions and content-authoring instructions are current.
- [ ] Known limitations are documented.

---

## 16. Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Scores are misunderstood as clinical or standardized tests | Misleading user expectations and reputational risk | Use clear score names, disclaimers, no IQ conversion, and honest result copy. |
| EQ options feel moralizing or culturally narrow | Reduced trust and poor learning experience | Use contextual rubrics, acknowledge trade-offs, review content, and avoid “good/bad person” labels. |
| Content bank is too small and questions repeat | Poor replayability | Set minimum content targets, distribute by skill, track recent IDs, and surface a recoverable message if content is insufficient. |
| Too many architecture abstractions slow delivery | High complexity and difficult maintenance | Use feature-first MVVM-style separation, add use cases only for non-trivial/reused logic, and avoid empty abstraction layers. |
| Database migration breaks history | User progress loss | Version the schema, add migration tests, and never reset the DB to apply an update. |
| Animations hurt performance or accessibility | Poor device compatibility | Prefer built-in animations, keep durations short, respect reduced motion, and test on representative devices. |
| Third-party package introduces network behavior or unnecessary permissions | Violates the offline requirement | Minimize dependencies, audit transitive packages and platform manifests, and test in airplane mode. |
| Daily streak differs after time-zone/device-date changes | Confusing progress | Use local dates consistently, document behavior, test date boundaries, and avoid claiming server verification. |
| Random session generation makes bugs hard to reproduce | Fragile tests | Inject a seeded random source and persist question ordering in each session. |
| Old results appear inconsistent after scoring changes | Confusing history | Persist score algorithm and content versions; do not silently recalculate old results. |

---

## 17. Decisions to Keep Stable

Unless implementation evidence proves otherwise, preserve these decisions throughout development:

1. The app is Flutter/Dart and fully offline.
2. Bundled JSON is the source of question content.
3. Local SQLite/Drift is the source of truth for sessions and progress.
4. Riverpod manages reactive state/dependencies; views do not own business rules.
5. Score calculators and session selection are pure/testable domain logic.
6. IQ Challenge Score is a 0–100 game performance score, not a standardized IQ.
7. EQ Practice Score is derived from explicit scenario rubrics, not a clinical or validated EQ test.
8. No backend, accounts, remote analytics, ads, or online leaderboard in the initial release.
9. Content and score logic are versioned so new releases can preserve historical meaning.
10. Implement phases sequentially and verify acceptance criteria before moving on.

---

## 18. Official Technical References

Use these sources to confirm current recommended patterns and package APIs when implementation begins. Because Flutter and packages evolve, validate the current stable versions and platform requirements rather than copying version numbers from an older lockfile or tutorial.

- Flutter app architecture guide: https://docs.flutter.dev/app-architecture/guide
- Flutter offline-first architecture guidance: https://docs.flutter.dev/app-architecture/design-patterns/offline-first
- Riverpod: https://riverpod.dev/
- `flutter_riverpod` package: https://pub.dev/packages/flutter_riverpod
- `go_router` package: https://pub.dev/packages/go_router
- Drift package: https://pub.dev/packages/drift
- `shared_preferences` package: https://pub.dev/packages/shared_preferences
- Flutter internationalization: https://docs.flutter.dev/ui/internationalization
- Flutter testing overview: https://docs.flutter.dev/testing/overview

---

## Final Implementation Principle

Build UpBrainQuest as a complete, trustworthy offline game before adding optional features. The first success criterion is not the number of screens or animations; it is a reliable, enjoyable loop in which question selection is correct, scoring is transparent, EQ feedback is thoughtful, results persist, and the product never claims to measure more than its content and scoring rules can support.

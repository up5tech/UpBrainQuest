# Architecture

UpBrainQuest is a fully offline Flutter app with a **feature-first structure and a
lightweight MVVM-style separation** (PLAN §6.1). The dependency direction is strict:

```
Presentation  ──▶  Domain  ◀──  Data
 (pages,          (models,         (JSON loading,
  widgets,         engines,          SQLite, repos,
  controllers)     use cases)        preferences)
```

## Layers

| Layer | Directory | Responsibility |
| --- | --- | --- |
| Presentation | `lib/features/`, `lib/app/` | Pages, widgets, controllers, router, provider composition |
| Domain | `lib/domain/` | Pure Dart models, engines, and repository contracts |
| Data | `lib/data/` | Bundled JSON loading, Drift/SQLite, repositories, preferences |
| Core | `lib/core/` | Theme tokens, strings, logging, feedback, shared widgets |

Rules:

- **Domain is pure Dart.** No Flutter widgets, SQLite, or platform APIs. Score
  calculators, `SessionBuilder`, `AchievementEngine`, `StreakCalculator`, and
  `DailyChallengeSelector` are unit-testable without a widget tree.
- **Widgets never touch the database.** They read providers; the data layer owns
  persistence.
- **Randomness and clocks are injectable.** Session building takes a seeded `Random`;
  the Daily Challenge seed derives from the local date + content version; streak math
  takes a `today` argument.
- **No service locators or global mutable singletons** outside the app composition root
  (`lib/app/providers.dart`).

## Key components

### Domain

| Component | File | Role |
| --- | --- | --- |
| `ContentParser` / `ContentBank` | `domain/content/` | Validate and parse bundled JSON into typed items |
| `SessionBuilder` | `domain/session/session_builder.dart` | Select questions by mode, difficulty, recency, and domain mix |
| `IqScoreCalculator` | `domain/scoring/` | Objective 0–100 score (versioned) |
| `EqScoreCalculator` | `domain/scoring/` | Rubric-based 0–100 practice score + per-dimension scores |
| `AchievementEngine` | `domain/achievements/` | Pure achievement evaluation over aggregate stats |
| `StreakCalculator` | `domain/daily/daily.dart` | Same-day / next-day / missed-day streak logic |
| `DailyChallengeSelector` | `domain/daily/daily.dart` | FNV-1a seed from `localDate|contentVersion` |
| `SessionResult` | `domain/session/session_result.dart` | Immutable finished-session snapshot |

### Data

| Component | File | Role |
| --- | --- | --- |
| `ContentLoader` / `ContentRepository` | `data/content/` | Load bundled assets and parse them |
| `AppDatabase` | `data/database/app_database.dart` | Drift schema **v3** with migrations |
| `DriftSessionHistoryRepository` | `data/history/` | Transactional session + attempts save, history, progress, recent IDs |
| `DriftProgressRepository` | `data/progress/` | Achievements (unlock once), daily activity, streaks |
| `SettingsRepository` | `data/preferences/` | Non-critical preferences (reduced motion, sound, haptics) |

### Presentation / application

| Component | File | Role |
| --- | --- | --- |
| `SessionController` | `features/gameplay/application/` | Async state machine: start → submit → continue → complete |
| `SessionCompletionService` | `features/gameplay/application/` | Save session → record daily activity → evaluate/persist achievements |
| Providers | `lib/app/providers.dart` | Composition root for data, content, history, progress, settings |

## Data flow

1. **Content load** — `contentProvider` reads `assets/content/` through
   `ContentLoader`, validates it with `ContentParser`, and exposes a `ContentBank`.
2. **Setup** — the setup page builds a `SessionRequest` (mode, count, seed, recent
   IDs, content version) and calls `SessionController.start`.
3. **Gameplay** — the controller holds an `ActiveSession`; each answer is evaluated
   once via `evaluateAnswer` and can never be double-scored.
4. **Results** — `toResult()` produces a `SessionResult`; the result page saves it
   through `SessionCompletionService` and shows a saving/saved/failed banner.
5. **Persistence** — the session and its attempts are written in one transaction; the
   daily-activity row is updated; achievements are evaluated and unlocked at most once.
6. **Progress** — `progressSummaryProvider`, `achievementsProvider`,
   `dailyStatusProvider`, and `streakProvider` refresh after a save or a reset.

## Database schema (v3)

| Table | Purpose |
| --- | --- |
| `app_metadata_entries` | Content/database bookkeeping |
| `game_sessions` | One row per completed session (scores, counts, version, timestamps) |
| `question_attempts` | Per-question snapshots; FK to session, `UNIQUE(session_id, question_id)` |
| `achievements` | Progress + `unlockedAt` (never re-dated) |
| `daily_activity` | Per-local-date completion counts and daily-challenge flag |

Migrations: `onCreate` creates all tables; `onUpgrade` adds tables for v1→v2 and
v2→v3 without touching existing rows. `schemaVersion` must be bumped whenever the
migration is extended.

## Determinism

- `SessionBuilder` takes an injectable `Random`. The Daily Challenge passes a seed
  derived from the local date and content version, and deliberately ignores recent
  question IDs so the same date always yields the same set.
- `StreakCalculator` takes `today`, so tests cover same-day, next-day, and missed-day
  cases without touching the system clock.

## Why these dependencies

- **`drift` + `sqlite3` + `path_provider` directly** (not `drift_flutter`): the latter
  pulls end-of-life native packages; `package:sqlite3` 3.x bundles SQLite through Dart
  build hooks.
- **`custom_lint` is not used**: it conflicts with `drift_dev` on `analyzer` ranges;
  `riverpod_lint` runs as an analysis-server plugin instead.

# UpBrainQuest

**IQ & EQ Challenge** — a fully offline, single-player mobile game for Android and iOS.

UpBrainQuest combines IQ-inspired reasoning puzzles, memory and pattern challenges, and
EQ-oriented interactive scenarios into short, replayable sessions. There is no backend,
no account, no analytics, and no network access: every question, illustration, and rule
ships inside the app.

> **Current status: Phase 0 — Repository Discovery and Project Baseline.**
> The app shell, navigation, and gameplay screens are not implemented yet. See
> [Implementation Roadmap](#implementation-roadmap) in `PLAN.md`.

---

## Table of contents

- [Requirements](#requirements)
- [Getting started](#getting-started)
- [Baseline commands](#baseline-commands)
- [Architecture](#architecture)
- [Package and SDK compatibility decisions](#package-and-sdk-compatibility-decisions)
- [Generated files and how to regenerate them](#generated-files-and-how-to-regenerate-them)
- [Offline guarantees](#offline-guarantees)
- [Repository layout](#repository-layout)
- [Implementation roadmap](#implementation-roadmap)
- [Known limitations](#known-limitations)

---

## Requirements

| Tool | Version | Notes |
| --- | --- | --- |
| Flutter | **3.47.7** (stable) | Required. The project targets this SDK. |
| Dart | **3.13.5** | Ships with Flutter 3.47.7. `pubspec.yaml` declares `sdk: ^3.13.5`. |
| Xcode | **26.1.1** | For iOS builds. CocoaPods 1.16.2 required. |
| Android SDK | compile/target **36**, min **24** | Matches the Flutter 3.47.7 defaults. NDK **28.2.13676358**. |

Platform minimums inherited from the Flutter 3.47.7 templates:

- **Android** — `minSdk 24`, `compileSdk 36`, `targetSdk 36`, Java 17, Kotlin 2.4.0, AGP 9.1.0, Gradle 9.3.1.
- **iOS** — deployment target **15.0**.

Verify your local toolchain at any time with:

```sh
flutter doctor -v
```

---

## Getting started

```sh
# 1. Fetch dependencies
flutter pub get

# 2. Regenerate the code-generation outputs (see below)
dart run build_runner build

# 3. Run on a connected device or simulator
flutter run

# 4. Run the test suite
flutter test
```

> **If `flutter test` fails with a WebSocket error** (`Unable to connect to flutter_tester
> process: WebSocketException: Invalid WebSocket upgrade request`), a system-wide HTTP proxy
> is intercepting the local connection to the test runner. Bypass it for localhost:
>
> ```sh
> NO_PROXY="localhost,127.0.0.1,::1" no_proxy="localhost,127.0.0.1,::1" flutter test
> ```

---

## Baseline commands

These are the commands that must pass before a phase is accepted (PLAN §11.4):

```sh
dart format --output=none --set-exit-if-changed .   # formatting is enforced
flutter analyze                                     # zero warnings required
flutter test                                        # full suite must pass
flutter build ios --simulator --debug               # debug build for the simulator
flutter build apk --debug                           # debug build for Android
```

There is no CI configuration in this repository yet. When CI is introduced, wire the
commands above into the pipeline in that order; do not add a complex pipeline.

### Integration tests

Integration tests run against a real device or simulator, because they verify things a
host-side test cannot — for example that the bundled SQLite native library actually
works on the target platform:

```sh
# iOS simulator
flutter test integration_test/ -d <simulator-udid>

# Android emulator or device
flutter test integration_test/ -d <device-id>
```

### Verified Phase 0 baseline

| Check | Result |
| --- | --- |
| `flutter pub get` | Success |
| `dart run build_runner build` | Success — 479-line `app_database.g.dart`, no analyzer errors |
| `flutter analyze` | **No issues found** (zero warnings, zero errors) |
| `dart format --output=none --set-exit-if-changed .` | Clean |
| `flutter test` | **8/8 passed** (3 widget + 5 database) |
| `flutter test integration_test/ -d <iPhone 17 Pro sim>` | **1/1 passed** — on-device database verified |
| `flutter build ios --simulator --debug` | Success — `build/ios/iphonesimulator/Runner.app` |
| `flutter build apk --debug` | Success — `build/app/outputs/flutter-apk/app-debug.apk` |
| App launch on iPhone 17 Pro simulator | Launched and rendered the dark theme |
| Android release `INTERNET` permission | Not present (debug/profile manifests only) |

---

## Architecture

UpBrainQuest uses a **feature-first structure with a lightweight MVVM-style separation**
(PLAN §6.1). The three layers have a strict dependency direction:

```
Presentation  ──▶  Domain  ◀──  Data
 (widgets,        (models,         (JSON loading,
  view models)     engines,          SQLite, repos,
                    use cases)       preferences)
```

Rules the codebase enforces (PLAN §6.3):

- **Domain logic is pure Dart.** Score calculators, session selection, and the achievement
  engine must not import Flutter widgets, SQLite, or platform APIs. This keeps them
  unit-testable without building a widget tree.
- **Widgets never touch the database.** They talk to view models and providers; the data
  layer owns all persistence.
- **Randomness and clocks are injectable.** Session building and daily challenges receive a
  seeded random source and an injectable date provider so tests are deterministic.
- **No service locators or global mutable singletons** beyond the app composition root.

### Layer contents

| Layer | Directory | Responsibility |
| --- | --- | --- |
| Presentation | `lib/features/`, `lib/app/` | Pages, widgets, view models. |
| Domain | `lib/domain/` | Typed models, enums, `SessionBuilder`, score calculators, use cases. |
| Data | `lib/data/` | Bundled JSON loading, Drift/SQLite persistence, repositories, preferences. |
| Core | `lib/core/` | Theme tokens, errors, logging, result types, shared widgets. |

### Key design decisions

- **Bundled JSON is the source of question content.** Questions live in
  `assets/content/` and are validated before use, so a malformed record can never crash
  the Home screen.
- **Drift/SQLite is the source of truth for progress.** Completed sessions, attempts, and
  achievements persist across app restarts. Schema changes go through migrations — user
  data is never deleted to apply an update.
- **Scores are transparent and non-clinical.** The app shows an *IQ Challenge Score* and an
  *EQ Practice Score*, both 0–100 in-game figures derived from the app's own content and
  rules. They are never converted into a standardized IQ value, a percentile, or a
  diagnosis. See PLAN §4 and `lib/domain/` for the scoring engines in Phase 3+.
- **Session state is explicit.** `ready → answering → feedback → paused → completed/abandoned`.
  A question can be scored at most once, and repeated taps during feedback cannot submit
  twice.

---

## Package and SDK compatibility decisions

Every dependency was chosen against the installed Flutter 3.47.7 / Dart 3.13.5 SDK, its
current pub.dev release, and the platform minimums above.

### Runtime dependencies

| Package | Version | Why |
| --- | --- | --- |
| `flutter_riverpod` | `^3.4.3` | Reactive state and dependency injection (PLAN §9.1). Requires Dart `^3.12.0`. |
| `go_router` | `^18.1.1` | Centralized, typed routing (PLAN §9.2). Requires Flutter `>=3.44.0`. |
| `drift` | `^2.35.3` | Typed SQLite persistence with transactions and migrations (PLAN §7.2). |
| `sqlite3` | `^3.8.0` | SQLite bindings. **3.x bundles SQLite into the app through Dart build hooks**, so no separate native-lib package is needed. |
| `path_provider` | `^2.1.6` | Resolves the on-device application support directory. |
| `shared_preferences` | `^2.5.6` | Non-critical preferences only (sound, haptics, reduced motion). |
| `intl` | `^0.20.3` | Date and number formatting. |
| `flutter_localizations` | SDK | Required by `intl` for locale-aware date formatting. |
| `json_annotation` | `^4.12.0` | Annotations for JSON model generation. |

### Dev dependencies

| Package | Version | Why |
| --- | --- | --- |
| `build_runner` | `^2.17.1` | Runs the Drift and JSON code generators. |
| `drift_dev` | `^2.35.2` | Generates the typed database layer (`*.g.dart`). |
| `json_serializable` | `^6.15.2` | Generates JSON `fromJson`/`toJson` implementations. |
| `riverpod_lint` | `^3.1.9` | Riverpod-specific lint rules. |
| `flutter_lints` | `^6.0.0` | Baseline Flutter lint set. |

### Decisions worth recording

1. **`drift_flutter` was intentionally not used.** It still depends on
   `sqlite3_flutter_libs` and `sqlcipher_flutter_libs`, both of which are marked
   `+eol` and are obsolete since `package:sqlite3` 3.x. The upstream drift platform
   guide states these packages are no longer necessary because SQLite is bundled
   automatically. This project depends on `drift` + `sqlite3` + `path_provider`
   directly, which keeps two end-of-life native packages out of the dependency graph.

2. **`custom_lint` was intentionally not used.** `custom_lint` and `drift_dev` 2.35.x
   resolve to incompatible `analyzer`/`dart_style` version ranges. `riverpod_lint` 3.x
   ships as an analysis-server plugin and is enabled through the top-level `plugins:`
   mapping in `analysis_options.yaml`, so no `custom_lint` dependency is needed.

3. **No `fl_chart`, no `uuid`, no `json_serializable`-free path yet.** Charting and ID
   generation are deferred until PLAN §5.7 and §8.3 actually need them; stable question
   IDs are authored, never random.

4. **No Flame.** The MVP puzzle mechanics are implemented with standard Flutter widgets
   and built-in animations (PLAN §1.2).

---

## Generated files and how to regenerate them

The project uses code generation. Generated files are **committed** to the repository so a
clean checkout builds without an extra toolchain step.

| Generated file | Produced by | Source |
| --- | --- | --- |
| `lib/data/database/app_database.g.dart` | `drift_dev` | `lib/data/database/app_database.dart` |
| `**/*.g.dart` (JSON models) | `json_serializable` | The annotated model source |

Regenerate everything with:

```sh
dart run build_runner build
```

Useful variants:

```sh
# Force a clean rebuild (use after changing a table definition)
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs

# Only the Drift builder
dart run build_runner build --build-filter="lib/data/database/*.g.dart"
```

> **Note on `build_runner` 2.17:** the `--delete-conflicting-outputs` flag was removed in
> this release and is ignored with a warning. `dart run build_runner build` performs the
> same conflict resolution automatically.

**Do not hand-edit `*.g.dart` files.** Change the source model and regenerate.

---

## Offline guarantees

PLAN §7.4 requires that the release build never depends on a network connection.

- No backend, no remote API client, no Firebase, no remote config, no analytics, no
  crash-reporting upload, no ads, no social SDK.
- No remote fonts, images, questions, or feature flags. All content is bundled.
- The Android **release** manifest declares no `INTERNET` permission. The permission
  exists only in the debug and profile manifests, where the Flutter tool needs it for
  hot reload and debugging.

To verify the offline claim, run the app in airplane mode and complete a full session.

---

## Repository layout

```text
up_brain_quest/
├── android/                     # Android host project (minSdk 24, target 36)
├── ios/                         # iOS host project (deployment target 15.0)
├── assets/
│   └── content/                 # Bundled question JSON — added in Phase 2
├── lib/
│   ├── main.dart                # Entry point
│   ├── app/                     # Bootstrap, router, provider composition
│   ├── core/                    # Theme tokens, logging, errors, shared widgets
│   ├── data/                    # JSON loading, Drift database, repositories
│   ├── domain/                  # Models, enums, engines, use cases
│   └── features/                # Home, Explore, Gameplay, Results, Progress, Settings
├── test/
│   ├── data/                    # Database tests
│   └── widget_test.dart         # App shell tests
├── integration_test/
│   └── database_test.dart       # On-device database verification
├── analysis_options.yaml        # Strict lint configuration
├── pubspec.yaml
├── PLAN.md                      # Product and engineering plan
└── README.md
```

---

## Implementation roadmap

Phases are implemented and verified one at a time. A phase is not started while the
previous phase has failing acceptance criteria.

| Phase | Scope | Status |
| --- | --- | --- |
| 0 | Repository discovery and project baseline | **Complete** |
| 1 | App shell, theme, navigation, design system | Next |
| 2 | Content models, JSON loader, content validation | Planned |
| 3 | Core session engine and IQ Challenge | Planned |
| 4 | EQ scenario gameplay and rubric scoring | Planned |
| 5 | Mixed Quick Quest, results, review, score presentation | Planned |
| 6 | Local database, history, progress | Planned |
| 7 | Achievements, daily challenge, replayability | Planned |
| 8 | Visual polish, accessibility, localization readiness | Planned |
| 9 | Release readiness, offline audit, documentation | Planned |

See `PLAN.md` for the full task list and acceptance criteria of each phase.

---

## Known limitations

These are current gaps, not defects:

- **No game content ships yet.** The question bank, manifest, and content loader arrive in
  Phase 2. The app currently shows a placeholder home screen that says so explicitly
  rather than displaying fake scores or fake history (PLAN §14.12).
- **Only a dark theme is implemented.** A light theme is deliberately absent — PLAN §8.2
  forbids shipping an incomplete theme toggle.
- **No localization yet.** The code is structured for `gen-l10n`, but only the `en` locale
  exists and no language selector is shown.
- **The database holds only an `app_metadata` table.** It exists to prove the Drift
  code-generation and native-SQLite toolchain end to end from the first commit. The full
  session and attempt schema arrives in Phase 6 as a schema migration.
- **The Android toolchain on this machine is incomplete** (`cmdline-tools` missing, SDK
  licenses not accepted), so the iOS simulator is the verified target for the Phase 0
  debug build. The Android configuration is committed and matches the Flutter defaults.
  An Android debug APK builds successfully (`flutter build apk --debug`); running it on
  an emulator was not attempted because no emulator image or SDK licence is available
  on this machine.

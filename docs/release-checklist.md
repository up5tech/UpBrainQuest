# Release Checklist

_Recorded from the Phase 9 verification run._

## 1. Toolchain

| Tool | Version |
| --- | --- |
| Flutter | **3.47.8** (stable, revision `737ba8f885`) |
| Dart | **3.13.7** |
| DevTools | 2.60.0 |
| Xcode | 26.1.1 |
| CocoaPods | 1.16.2 |
| Android | compile/target SDK 36, minSdk 24, Java 17, AGP 9.1.0, Gradle 9.3.1 |

## 2. Declared package versions

Runtime: `flutter_riverpod ^3.4.3`, `go_router ^18.1.1`, `drift ^2.35.3`,
`sqlite3 ^3.8.0`, `path_provider ^2.1.6`, `shared_preferences ^2.5.6`,
`intl ^0.20.3`, `json_annotation ^4.12.0`, `flutter_localizations` (SDK).

Dev: `build_runner ^2.17.1`, `drift_dev ^2.35.2`, `json_serializable ^6.15.2`,
`riverpod_lint ^3.1.9`, `flutter_lints ^6.0.0`, `integration_test` (SDK).

## 3. Build and test results

| Check | Command | Result |
| --- | --- | --- |
| Dependencies | `flutter pub get` | Success |
| Code generation | `dart run build_runner build` | Success |
| Formatting | `dart format lib test` | Clean |
| Static analysis | `flutter analyze` | **No issues found** (exit 0) |
| Host tests | `flutter test` | **109/109 passed** |
| Android release | `flutter build apk --release` | **`app-release.apk` (61.1 MB)** |
| iOS release (unsigned) | `flutter build ios --release --no-codesign` | **`Runner.app` (20.1 MB)** |

All commands must be prefixed with the localhost proxy bypass on this machine:

```sh
NO_PROXY="localhost,127.0.0.1,::1" no_proxy="localhost,127.0.0.1,::1" <command>
```

## 4. Identifiers

| Platform | Identifier |
| --- | --- |
| Dart package | `up_brain_quest` |
| Android `applicationId` / namespace | `com.upbrainquest.up_brain_quest` |
| iOS `PRODUCT_BUNDLE_IDENTIFIER` | `com.upbrainquest.up_brain_quest` (aligned in Phase 9) |

## 5. Signing (blocking for store upload)

- **Android:** `android/app/build.gradle.kts` signs release builds with the **debug
  key** (Flutter template default). Create a keystore, add a `release` signing config,
  and remove the debug fallback before uploading.
- **iOS:** the artifact is built with `--no-codesign`. Distribution needs an Apple
  Developer team, provisioning profile, and a signed archive.

## 6. Offline and privacy

- Offline audit: see [`offline-audit.md`](offline-audit.md). Release manifest has no
  `INTERNET` permission; no network/analytics/ad dependencies; no remote assets; the
  content parser warns on remote URLs.
- Store declarations: **no data collected, no data shared, no tracking**; all data is
  local and removed by "Reset local data" or uninstalling.

## 7. Manual release checks

1. Airplane-mode playthrough: Quick Quest, IQ Challenge, EQ Challenge, Daily Challenge;
   verify save, history, achievements, streak, and reset.
2. Verify the About dialog shows version, offline statement, score disclaimer, and
   licenses.
3. Check the app icon/splash and store screenshots.
4. Confirm the release version (`pubspec.yaml` `version: 1.0.0+1`) matches
   `lib/core/app_info.dart`.

## 8. Release commands

```sh
flutter pub get
dart run build_runner build
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --release            # or --split-per-abi / appbundle
flutter build ios --release --no-codesign
```

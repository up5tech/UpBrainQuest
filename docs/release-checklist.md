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

_Re-verified on 2026-11-07 after the content QA pass._

| Check | Command | Result |
| --- | --- | --- |
| Dependencies | `flutter pub get` | Success |
| Code generation | `dart run build_runner build` | Success |
| Formatting | `dart format lib test` | Clean |
| Static analysis | `flutter analyze` | **No issues found** (exit 0) |
| Host tests | `flutter test` | **132/132 passed** |
| Android release | `flutter build apk --release` | **`app-release.apk` (61.7 MB)** |
| iOS release (unsigned) | `flutter build ios --release --no-codesign` | **`Runner.app` (21.3 MB)** |

### Android configuration verification (2026-11-21)

Verified with Flutter **3.47.9**, Dart **3.13.7**, and Flutter's configured JDK
**21** (Java source/target remains 17). Android Command-line Tools **22.0** were
installed from the [official download](https://developer.android.com/studio), with
the published SHA-256 verified, to enable Flutter's final AAB symbols check.

| Check | Result |
| --- | --- |
| Formatting / static analysis | Clean / no issues |
| Host tests | **143/143 passed** |
| Release APK / AAB | **61.8 MB / 60.3 MB**, signed with the upload key |
| Packaged metadata | `Up Brain Quest`, `com.up5.upbrainquest`, `1.0.0` / `1` |
| Release permissions | No `INTERNET` permission |
| Missing credentials / missing keystore | Both rejected by release validation |
| Debug APK without upload credentials | Builds successfully |
| iOS integration test (iPhone 17, iOS 27.0) | Pass |
| iOS simulator debug build / launch | Pass |

For direct `./gradlew` commands, set `JAVA_HOME` to the `jdk-dir` reported by
`flutter config --list`. Flutter builds already use that JDK; this machine's shell
otherwise selects GraalVM 24, which fails Android's debug JDK image transform.

All commands must be prefixed with the localhost proxy bypass on this machine:

```sh
NO_PROXY="localhost,127.0.0.1,::1" no_proxy="localhost,127.0.0.1,::1" <command>
```

## 4. Identifiers

| Setting | Value |
| --- | --- |
| App display name (Android and iOS) | `Up Brain Quest` |
| Dart package | `up_brain_quest` |
| Android `applicationId` / namespace | `com.up5.upbrainquest` |
| iOS `PRODUCT_BUNDLE_IDENTIFIER` | `com.up5.upbrainquest` |
| Version / build (both platforms) | `1.0.0` / `1`, from `pubspec.yaml` |

## 5. Signing

- **Android:** `android/app/build.gradle.kts` uses the `release` upload signing config.
  Place the existing upload keystore at `android/app/android-key.keystore`, copy
  `android/key.properties.example` to `android/key.properties`, and fill in both
  passwords. The configured alias is `android-key-alias`. The keystore and
  `key.properties` are gitignored; keep a backup outside the repository.
  `MYAPP_UPLOAD_STORE_FILE` accepts an absolute path or a path relative to
  `android/app`. Gradle properties override environment variables, which override
  `key.properties`, using the same four `MYAPP_UPLOAD_*` names. Release builds fail
  if a setting or keystore is missing; they never fall back to the debug key.
  Debug builds do not require upload credentials.
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
python3 tool/content_release_gate.py   # must pass before a store build
flutter build apk --release            # or --split-per-abi
flutter build appbundle --release      # upload-key-signed Google Play bundle
flutter build ios --release --no-codesign
```

## 9. Content sign-off (blocking for store upload)

The content gate is separate from the build: PLAN §11 requires every Version 1
item to be approved, so drafts may not ship. Run:

```sh
python3 tool/content_release_gate.py
```

It fails while any item is `status: draft` or while `contentPackVersion` carries
a `-draft` suffix, and it re-checks the manifest counts, locale parity, answer
keys and EQ rubric coverage. Current state on 2026-11-07: **the gate fails** —
660 records across the 330 items are still `draft` at pack `0.8.1-draft`.
Closing it needs the human copy-edit, the EQ safety review and the native
Vietnamese read-through; after that, mark every item `final`, bump the pack
version, and re-run the gate plus `tool/eq_audit.py`.

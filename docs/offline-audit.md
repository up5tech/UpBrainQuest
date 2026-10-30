# Offline Audit

_Phase 9 deliverable. This checklist proves the runtime path has no network
dependency, so the app works in airplane mode and needs no privacy-sensitive SDKs._

## 1. Android permissions

| Manifest | `INTERNET` | Why |
| --- | --- | --- |
| `android/app/src/main/AndroidManifest.xml` (release) | **Absent** | The shipped app cannot open sockets |
| `android/app/src/debug/AndroidManifest.xml` | Present | Flutter tooling (hot reload / debugger) |
| `android/app/src/profile/AndroidManifest.xml` | Present | Flutter tooling (profile mode) |

No other permissions (camera, location, contacts, storage, ads ID) are declared.

## 2. iOS capabilities

- `ios/Runner/Info.plist` contains **no `NSAppTransportSecurity`** exception, so the
  app has no ATS allowance to talk to arbitrary hosts.
- No background modes, push, or network entitlements are configured.
- `CADisableMinimumFrameDurationOnPhone` is enabled for 120 Hz rendering; it has no
  network meaning.

## 3. Dependencies

Runtime packages: `flutter`, `cupertino_icons`, `flutter_riverpod`, `go_router`,
`drift`, `sqlite3`, `path_provider`, `shared_preferences`, `intl`,
`flutter_localizations`, `json_annotation`.

None of these are network clients, analytics SDKs, ad SDKs, crash reporters, or
webviews. `sqlite3` bundles SQLite through Dart build hooks; `path_provider` and
`shared_preferences` are local platform storage.

## 4. Runtime code scan

`test/release/offline_audit_test.dart` fails the build if `lib/` ever contains:

- `package:http/`, `package:dio/`, `HttpClient(`, `WebSocket(`
- `Image.network(`, `NetworkImage(`
- `Firebase.`, `url_launcher`

It also asserts the release manifest has no `INTERNET` permission, the debug/profile
manifests do, the pubspec has no network/analytics/ad packages, and the iOS plist has
no ATS exception.

## 5. Content

- All questions ship as bundled JSON under `assets/content/`.
- `ContentParser._scanForUrls` raises an `unexpectedUrl` warning if any authored
  prompt/option/explanation contains an `http://` or `https://` URL, so content cannot
  quietly point at a remote asset.
- No remote fonts, images, or feature flags are used. Illustrations are Material icons.

## 6. Manual verification

The automated checks cover configuration and code. The final release check is manual:

1. Put the device in airplane mode (or disable Wi-Fi and mobile data).
2. Launch the app, complete a Quick Quest, an IQ Challenge, an EQ Challenge, and the
   Daily Challenge.
3. Confirm results save, the Progress history and achievements update, and Settings
   load — all with no network.

## 7. Store privacy declarations

Consistent with the above:

- **Data collected: none.** No accounts, no identifiers, no analytics, no crash
  reporting, no ads.
- **Data shared: none.**
- **Local storage only:** sessions/attempts/achievements/daily activity in SQLite;
  preferences in shared preferences. Both stay on the device and are removed by
  "Reset local data" (progress) or by uninstalling the app.
- **Tracking: none.**

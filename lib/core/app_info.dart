/// Static app identity used by the About dialog.
///
/// Keep [version] in sync with `pubspec.yaml` (`version:`). It is a constant
/// rather than a runtime lookup so the app needs no extra platform dependency.
abstract final class AppInfo {
  const AppInfo._();

  static const String version = '1.0.0+1';
}

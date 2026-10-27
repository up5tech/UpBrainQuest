import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kDebugMode;

/// Minimal application logger.
///
/// The product is fully offline, so there is no crash-reporting upload and no
/// remote telemetry (PLAN §10). Logging exists purely to give developers
/// readable diagnostics for content and storage problems (PLAN §5.2, §6.5).
///
/// Logs are emitted only in debug and test builds. In release builds every
/// call is a no-op so that user-identifiable or sensitive values can never
/// leak into a device log (PLAN §10).
abstract final class AppLogger {
  /// Whether logging is currently enabled.
  ///
  /// This is `true` in debug mode. Test builds use `dart:developer` logging
  /// only when the test explicitly opts in, so that test output stays clean.
  static bool get isEnabled => kDebugMode;

  /// Logs an informational message.
  static void info(String message) => _write('INFO', message);

  /// Logs a recoverable problem, optionally with an associated error.
  static void warn(String message, [Object? error, StackTrace? stackTrace]) {
    _write('WARN', message, error, stackTrace);
  }

  /// Logs a failure.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _write('ERROR', message, error, stackTrace);
  }

  static void _write(
    String level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (!isEnabled) {
      return;
    }
    developer.log(
      message,
      name: 'up_brain_quest',
      level: switch (level) {
        'ERROR' => 1000,
        'WARN' => 900,
        _ => 800,
      },
      error: error,
      stackTrace: stackTrace,
    );
  }
}

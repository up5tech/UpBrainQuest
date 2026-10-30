import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

/// Guards the "no network at runtime" promise (PLAN §1.2, §7.4, §10).
///
/// These are file-level assertions so a future dependency or manifest change
/// cannot quietly reintroduce networking.
void main() {
  group('Offline audit', () {
    test('release Android manifest does not request INTERNET', () {
      final String manifest = _read('android/app/src/main/AndroidManifest.xml');
      expect(manifest, isNot(contains('android.permission.INTERNET')));
    });

    test('INTERNET exists only in debug/profile manifests for tooling', () {
      expect(
        _read('android/app/src/debug/AndroidManifest.xml'),
        contains('android.permission.INTERNET'),
      );
      expect(
        _read('android/app/src/profile/AndroidManifest.xml'),
        contains('android.permission.INTERNET'),
      );
    });

    test('pubspec has no network, analytics, ad, or webview packages', () {
      final String pubspec = _read('pubspec.yaml').toLowerCase();
      for (final String forbidden in <String>[
        'package:http',
        'dio:',
        'firebase',
        'sentry',
        'amplitude',
        'segment',
        'google_mobile_ads',
        'url_launcher',
        'webview',
        'connectivity',
      ]) {
        expect(
          pubspec.contains(forbidden),
          isFalse,
          reason: 'pubspec.yaml must not depend on "$forbidden"',
        );
      }
    });

    test('runtime code uses no network APIs or remote images', () {
      final List<String> forbidden = <String>[
        'package:http/',
        'HttpClient(',
        'Image.network(',
        'NetworkImage(',
        'package:dio/',
        'Firebase.',
        'url_launcher',
        'WebSocket(',
      ];
      for (final FileSystemEntity entity in Directory(
        'lib',
      ).listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final String source = entity.readAsStringSync();
        for (final String needle in forbidden) {
          expect(
            source.contains(needle),
            isFalse,
            reason: '${entity.path} must not use "$needle"',
          );
        }
      }
    });

    test('iOS Info.plist declares no App Transport Security exception', () {
      final String plist = _read('ios/Runner/Info.plist');
      expect(plist, isNot(contains('NSAppTransportSecurity')));
    });
  });
}

import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Resolves the on-device locations used by the local data layer.
///
/// The app is fully offline and stores everything locally (PLAN §7). This
/// class is the single place that knows how to turn a logical file name into
/// an absolute path, which keeps the rest of the data layer free of platform
/// calls and makes it straightforward to unit test (PLAN §6.3).
abstract final class DatabasePaths {
  const DatabasePaths._();

  /// Returns the directory that holds the local SQLite database files.
  ///
  /// Uses the application support directory so that the database is excluded
  /// from user-visible "Documents" browsing and is not eligible for cloud
  /// backup of user documents.
  static Future<Directory> databaseDirectory() async {
    final Directory supportDirectory = await getApplicationSupportDirectory();
    final Directory databaseDirectory = Directory(
      '${supportDirectory.path}${Platform.pathSeparator}database',
    );

    if (!databaseDirectory.existsSync()) {
      databaseDirectory.createSync(recursive: true);
    }

    return databaseDirectory;
  }

  /// Returns the absolute path of a database file inside [databaseDirectory].
  static Future<File> databaseFile(String fileName) async {
    final Directory directory = await databaseDirectory();
    return File('${directory.path}${Platform.pathSeparator}$fileName');
  }
}

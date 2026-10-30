import 'dart:convert';

/// Shared, dependency-free helpers for the content parser and models.
///
/// Kept in its own library so [ContentManifest] and [ContentParser] can both
/// use them without creating an import cycle.

/// Thrown when a required manifest/field is structurally absent.
class ContentFieldException implements Exception {
  const ContentFieldException(this.field);

  final String field;

  @override
  String toString() => 'Missing or invalid content field: $field';
}

/// Returns the value as a [String] or `null` when it is not a string.
String? readString(dynamic value) => value is String ? value : null;

/// Coerces a JSON list into a list of strings, dropping non-string entries.
List<String> stringList(dynamic value) {
  if (value is List<dynamic>) {
    return value.whereType<String>().toList();
  }
  return <String>[];
}

/// Coerces a JSON map into a map of string keys to int values.
Map<String, int>? intMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    final Map<String, int> result = <String, int>{};
    value.forEach((String key, dynamic v) {
      if (v is int) {
        result[key] = v;
      }
    });
    return result;
  }
  return null;
}

/// Decodes a JSON string into a [Map<String, dynamic>].
///
/// Throws [FormatException] when the text is not a JSON object.
Map<String, dynamic> decodeObject(String jsonString) {
  final dynamic decoded = jsonDecode(jsonString);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  throw const FormatException('Expected a JSON object at the top level.');
}

import 'dart:convert';

/// Deep-converts Hive / dynamic maps into JSON-safe [Map<String, dynamic>].
///
/// Hive returns nested [Map] values as `Map<dynamic, dynamic>`, which breaks
/// typed `fromJson` constructors. Round-tripping through JSON fixes this.
Map<String, dynamic> deepJsonMap(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    // Still encode/decode to normalize nested dynamic maps inside.
    return jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
  }
  if (raw is Map) {
    return jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
  }
  throw ArgumentError('Expected a Map, got ${raw.runtimeType}');
}

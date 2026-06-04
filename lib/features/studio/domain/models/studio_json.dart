/// Defensive JSON readers shared by the Studio models.
///
/// The Studio endpoints return numbers as either ints, doubles, or numeric
/// strings depending on the field, and several keys are optional. These helpers
/// keep `fromJson` parsing tolerant so a missing/oddly-typed field degrades to a
/// sane default instead of throwing — matching how `video_model.dart` parses
/// the feed payloads.
library;

int asInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is double) return v.round();
  if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.round() ?? fallback;
  return fallback;
}

double asDouble(dynamic v, [double fallback = 0]) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

String asString(dynamic v, [String fallback = '']) {
  if (v == null) return fallback;
  return v.toString();
}

bool asBool(dynamic v, [bool fallback = false]) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
  }
  return fallback;
}

DateTime? asDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

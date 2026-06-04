// Number / date formatting shared across the Studio screens, ported from the
// official Loops client's helpers so the UI reads identically.

/// Compact counts: 1_500 -> "1.5K", 2_300_000 -> "2.3M".
String formatCompact(num n) {
  final abs = n.abs();
  if (abs >= 1000000) {
    return '${(n / 1000000).toStringAsFixed(abs >= 10000000 ? 0 : 1)}M';
  }
  if (abs >= 1000) {
    return '${(n / 1000).toStringAsFixed(abs >= 10000 ? 0 : 1)}K';
  }
  return n.round().toString();
}

/// Signed percentage label: 0 -> "0%", 12 -> "+12%", -4 -> "-4%".
String formatChangePct(double pct) {
  if (pct == 0) return '0%';
  final rounded = pct.round();
  return pct > 0 ? '+$rounded%' : '$rounded%';
}

/// Short relative time: "just now", "5m ago", "3h ago", "2d ago", "1w ago",
/// falling back to an absolute date past ~5 weeks.
String formatRelative(DateTime? then) {
  if (then == null) return '';
  final diff = DateTime.now().difference(then);
  final m = diff.inMinutes;
  if (m < 1) return 'just now';
  if (m < 60) return '${m}m ago';
  final h = diff.inHours;
  if (h < 24) return '${h}h ago';
  final d = diff.inDays;
  if (d < 7) return '${d}d ago';
  final w = (d / 7).floor();
  if (w < 5) return '${w}w ago';
  return '${then.year}-${then.month.toString().padLeft(2, '0')}-${then.day.toString().padLeft(2, '0')}';
}

/// Relative "added" date for links: "today", "3d ago", "2w ago", "5mo ago".
String formatAddedRelative(DateTime? then) {
  if (then == null) return '';
  final d = DateTime.now().difference(then).inDays;
  if (d < 1) return 'today';
  if (d < 7) return '${d}d ago';
  if (d < 30) return '${(d / 7).floor()}w ago';
  if (d < 365) return '${(d / 30).floor()}mo ago';
  return '${(d / 365).floor()}y ago';
}

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const List<String> _weekdays = [
  'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
];

/// "Mar 5" from an ISO yyyy-MM-dd string.
String formatShortDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${_months[d.month - 1]} ${d.day}';
}

/// "Wed, Mar 5" from an ISO yyyy-MM-dd string.
String formatLongDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';
}

/// Hostname of a URL with a leading "www." stripped, falling back to the raw
/// string when it can't be parsed.
String hostnameOf(String url) {
  final uri = Uri.tryParse(url);
  final host = uri?.host ?? '';
  if (host.isEmpty) return url;
  return host.startsWith('www.') ? host.substring(4) : host;
}

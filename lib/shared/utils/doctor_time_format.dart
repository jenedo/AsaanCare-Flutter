/// Formatting helpers shared across doctor appointment widgets. Kept in one
/// place so time/price strings stay consistent between Home and Dashboard.
library;

/// Two-letter (or single-letter) initials for an avatar fallback.
String initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final value = parts.first;
    return value.substring(0, value.length >= 2 ? 2 : 1).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

/// "just now" / "10 min ago" / "3 hr ago" / "2 d ago".
String relativeTime(DateTime value, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(value);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours} hr ago';
  return '${diff.inDays} d ago';
}

/// Countdown label for an upcoming time: "Ready now" / "in 42 min" / "in 2 hr".
String etaLabel(DateTime value, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final minutes = value.difference(reference).inMinutes;
  if (minutes <= 0) return 'Ready now';
  if (minutes < 60) return 'in $minutes min';
  final hours = (minutes / 60).ceil();
  return 'in $hours hr';
}

/// "10:30\nAM" style stacked clock label used in the appointment tile.
String clockLabel(DateTime value) {
  final hour = value.hour == 0
      ? 12
      : value.hour > 12
      ? value.hour - 12
      : value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute\n$period';
}

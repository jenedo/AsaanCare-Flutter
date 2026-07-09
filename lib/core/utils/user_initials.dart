class UserInitials {
  const UserInitials._();

  static String fromName(String? value) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return '?';

    final parts = clean
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) return '?';

    final first = parts.first.substring(0, 1).toUpperCase();
    if (parts.length == 1) return first;

    final last = parts.last.substring(0, 1).toUpperCase();
    return '$first$last';
  }
}

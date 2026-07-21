import 'package:flutter/material.dart';

/// Centralised doctor-app color tokens.
///
/// These mirror the teal palette already used across the doctor screens so we
/// do not reintroduce per-file hex drift. Prefer these over inline `Color(...)`
/// literals inside doctor/shared widgets.
class DoctorColors {
  const DoctorColors._();

  static const Color primary = Color(0xFF006D5B);
  static const Color primaryDark = Color(0xFF005A4B);
  static const Color primaryMid = Color(0xFF007568);
  static const Color mint = Color(0xFFE9F8F5);
  static const Color background = Color(0xFFF5F7F6);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F3438);
  static const Color textMuted = Color(0xFF6F8588);
  static const Color border = Color(0xFFE3ECEA);
  static const Color warning = Color(0xFFFF9800);
  static const Color success = Color(0xFF21B66F);
  static const Color danger = Color(0xFFF44336);
  static const Color neutralPill = Color(0xFFEDF1F0);
  static const Color neutralPillText = Color(0xFF5B6E71);

  /// Deterministic accent colors for initials avatars. Pick with
  /// `avatarPalette[id.hashCode.abs() % avatarPalette.length]`.
  static const List<Color> avatarPalette = [
    Color(0xFF9C4DFF),
    Color(0xFFEF4A8A),
    Color(0xFFFF8A00),
    Color(0xFF5C6CFF),
    Color(0xFF00C896),
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00816C), Color(0xFF005A4B)],
  );

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x140D5C63), blurRadius: 16, offset: Offset(0, 5)),
  ];
}

/// Shared spacing rhythm for doctor/shared widgets.
class DoctorSpacing {
  const DoctorSpacing._();

  static const double screenHorizontal = 16;
  static const double cardGap = 12;
  static const double cardPadding = 12;
  static const double radiusCard = 16;
  static const double radiusPill = 999;
}

import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color primary = Color(0xFF075B5F);
  static const Color primaryDark = Color(0xFF063F43);
  static const Color primaryLight = Color(0xFF0F8F86);
  static const Color accent = Color(0xFF23B47E);

  static const Color background = Color(0xFFF6FBF9);
  static const Color surface = Colors.white;
  static const Color surfaceTint = Color(0xFFF9FCFB);
  static const Color softTeal = Color(0xFFE8F6F2);
  static const Color softGreen = Color(0xFFEAF8EF);
  static const Color border = Color(0xFFDDEDEA);

  static const Color textDark = Color(0xFF102A36);
  static const Color textMuted = Color(0xFF647780);
  static const Color textLight = Color(0xFFFFFFFF);

  static const Color danger = Color(0xFFB42318);
  static const Color warning = Color(0xFFFFA726);
  static const Color success = Color(0xFF21A67A);

  static const double radiusSmall = 12;
  static const double radiusMedium = 16;
  static const double radiusLarge = 22;
  static const double radiusXLarge = 28;

  static const List<BoxShadow> softShadow = [
    BoxShadow(blurRadius: 24, offset: Offset(0, 10), color: Color(0x12075B5F)),
  ];

  static ThemeData lightTheme() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: primary,
          onPrimary: textLight,
          primaryContainer: softTeal,
          onPrimaryContainer: primaryDark,
          secondary: accent,
          onSecondary: textDark,
          secondaryContainer: softGreen,
          onSecondaryContainer: textDark,
          tertiary: primaryLight,
          onTertiary: textLight,
          tertiaryContainer: softTeal,
          onTertiaryContainer: primaryDark,
          error: danger,
          onError: textLight,
          errorContainer: const Color(0xFFFDECEA),
          onErrorContainer: danger,
          surface: surface,
          onSurface: textDark,
          surfaceTint: surfaceTint,
          surfaceDim: const Color(0xFFE8EFED),
          surfaceBright: surface,
          surfaceContainerLowest: surface,
          surfaceContainerLow: surfaceTint,
          surfaceContainer: background,
          surfaceContainerHigh: const Color(0xFFF0F6F4),
          surfaceContainerHighest: softTeal,
          onSurfaceVariant: textMuted,
          outline: border,
          outlineVariant: const Color(0xFFECF2F0),
          shadow: primaryDark,
          scrim: const Color(0x99062022),
          inverseSurface: textDark,
          onInverseSurface: const Color(0xFFF1F8F6),
          inversePrimary: const Color(0xFF78D5CC),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        foregroundColor: textDark,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        labelStyle: const TextStyle(color: textMuted, fontSize: 14),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: danger, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textLight,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textLight,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: border),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: softTeal,
        disabledColor: border,
        side: const BorderSide(color: border),
        labelStyle: const TextStyle(
          color: textDark,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: const TextStyle(
          color: primary,
          fontWeight: FontWeight.w900,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    );
  }
}

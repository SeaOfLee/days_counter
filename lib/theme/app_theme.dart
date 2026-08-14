import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds the light/dark [ThemeData] for the app's lavender/mascot
/// visual identity (see docs/dayward-widget-mockups.png).
class AppTheme {
  AppTheme._();

  static const _cardRadius = 20.0;

  /// Bundled in `assets/fonts/` and declared in `pubspec.yaml`, rather than
  /// fetched at runtime by the `google_fonts` package as it was before —
  /// that made first launch depend on the network and contradicted the
  /// app's "no networking" App Privacy answer.
  static const _fontFamily = 'Quicksand';

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
    ).copyWith(
      primary: AppColors.accent,
      secondary: AppColors.cardLavender,
      surface: Colors.white,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textMuted,
    );

    return _themeFrom(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.background,
      cardColor: Colors.white,
      foreground: AppColors.textPrimary,
      muted: AppColors.textMuted,
      inputFill: AppColors.cardPaleLavender,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.accent,
      secondary: AppColors.surfaceDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textMutedDark,
    );

    return _themeFrom(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDark,
      foreground: AppColors.textPrimaryDark,
      muted: AppColors.textMutedDark,
      inputFill: AppColors.moonBadgeDark,
    );
  }

  static ThemeData _themeFrom({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color cardColor,
    required Color foreground,
    required Color muted,
    required Color inputFill,
  }) {
    final segmentedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    // Only the four roles the design actually specifies are set here; the
    // rest inherit Quicksand from ThemeData.fontFamily below. These carry
    // fontFamily explicitly because appBarTheme reuses titleLarge directly,
    // before ThemeData has applied the family to the text theme.
    const textStyleFamily = _fontFamily;
    final textTheme = TextTheme(
      displayMedium: const TextStyle(
        fontFamily: textStyleFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ).copyWith(color: foreground),
      titleLarge: const TextStyle(
        fontFamily: textStyleFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ).copyWith(color: foreground),
      titleMedium: const TextStyle(
        fontFamily: textStyleFamily,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ).copyWith(color: muted),
      bodyMedium: const TextStyle(
        fontFamily: textStyleFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ).copyWith(color: muted),
    );

    return ThemeData(
      fontFamily: _fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        labelStyle: TextStyle(color: muted),
        floatingLabelStyle: TextStyle(color: muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(segmentedShape),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? AppColors.accent
                : cardColor;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? Colors.white
                : muted;
          }),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: muted,
        textColor: foreground,
        tileColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
      ),
    );
  }
}

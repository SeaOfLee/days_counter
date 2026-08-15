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

  // Every overridden role is paired with its `on*` counterpart below.
  // Overriding `primary` or `surface` alone leaves the matching foreground
  // at whatever ColorScheme.fromSeed derived for *its* generated palette,
  // which is how unreadable pairings slip in unnoticed.
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
    ).copyWith(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      primaryContainer: AppColors.cardLavender,
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.cardLavender,
      onSecondary: AppColors.textPrimary,
      surface: Colors.white,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.cardPaleLavender,
      onSurfaceVariant: AppColors.textMuted,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.textLabel,
      outlineVariant: AppColors.divider,
    );

    return _themeFrom(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.background,
      cardColor: Colors.white,
      foreground: AppColors.textPrimary,
      muted: AppColors.textMuted,
      label: AppColors.textLabel,
      inputFill: AppColors.cardPaleLavender,
      border: AppColors.divider,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      primaryContainer: AppColors.moonBadgeDark,
      onPrimaryContainer: AppColors.textPrimaryDark,
      secondary: AppColors.surfaceDark,
      onSecondary: AppColors.textPrimaryDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.moonBadgeDark,
      onSurfaceVariant: AppColors.textMutedDark,
      error: AppColors.errorDark,
      onError: AppColors.onAccent,
      outline: AppColors.textLabelDark,
      outlineVariant: AppColors.moonBadgeDark,
    );

    return _themeFrom(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDark,
      foreground: AppColors.textPrimaryDark,
      muted: AppColors.textMutedDark,
      label: AppColors.textLabelDark,
      inputFill: AppColors.moonBadgeDark,
      border: AppColors.moonBadgeDark,
    );
  }

  static ThemeData _themeFrom({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color cardColor,
    required Color foreground,
    required Color muted,
    required Color label,
    required Color inputFill,
    required Color border,
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
      // Text fields and InputDecorator children resolve to bodyLarge. It was
      // undefined, so typed input fell back to a Material default colour
      // rather than the palette — the main reason the editor read badly.
      bodyLarge: const TextStyle(
        fontFamily: textStyleFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ).copyWith(color: foreground),
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
        // Same accent-contrast problem as the selected segment: the white
        // "+" measured about 2.4:1, below even the 3:1 bar for icons.
        foregroundColor: AppColors.onAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        // `label` rather than `muted`: the muted tone is tuned for text on
        // card backgrounds and falls under 4.5:1 against the input fill.
        labelStyle: TextStyle(color: label),
        floatingLabelStyle: TextStyle(color: label),
        hintStyle: TextStyle(color: label),
        helperStyle: TextStyle(color: label),
        errorStyle: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600),
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
        // Without these the error state was unthemed: a borderless field
        // gave no visual signal at all beyond the message.
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.accent,
        selectionColor: AppColors.accent.withValues(alpha: 0.35),
        selectionHandleColor: AppColors.accent,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(segmentedShape),
          // The control sits on the scaffold, and in dark mode cardColor is
          // nearly the same tone — without a border the unselected half read
          // as empty space rather than a button.
          side: WidgetStatePropertyAll(BorderSide(color: border)),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? AppColors.accent
                : inputFill;
          }),
          // onAccent, not white: white on the light lavender accent measures
          // about 2.4:1.
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? AppColors.onAccent
                : label;
          }),
        ),
      ),
      // The editor opens the stock showDatePicker, which had no theme at all
      // and so rendered entirely from ColorScheme.fromSeed's generated
      // palette rather than this one.
      datePickerTheme: DatePickerThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.accent,
        headerForegroundColor: AppColors.onAccent,
        dividerColor: border,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
        headerHeadlineStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: AppColors.onAccent,
        ),
        headerHelpStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.onAccent,
        ),
        weekdayStyle: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          color: label,
        ),
        dayStyle: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.onAccent;
          if (states.contains(WidgetState.disabled)) return muted;
          return foreground;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.accent
              : Colors.transparent;
        }),
        todayForegroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.onAccent
              : AppColors.accent;
        }),
        todayBorder: BorderSide(color: AppColors.accent),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.onAccent
              : foreground;
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.accent
              : Colors.transparent;
        }),
        yearStyle: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500),
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: label),
        confirmButtonStyle: TextButton.styleFrom(foregroundColor: AppColors.accent),
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

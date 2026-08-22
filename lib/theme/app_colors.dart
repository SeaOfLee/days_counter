import 'package:flutter/material.dart';

/// Design tokens for the lavender/mascot visual identity
/// (see docs/dayward-widget-mockups.png).
class AppColors {
  AppColors._();

  // Light theme
  static const background = Color(0xFFF5F2FA);
  static const textPrimary = Color(0xFF1C1A22);
  static const textMuted = Color(0xFF8B8696);
  static const divider = Color(0xFFE4DFEE);

  // Card tint palette, cycled per event (see EventCard).
  static const cardCream = Color(0xFFFBFAF6);
  static const cardLavender = Color(0xFFE3D9F3);
  static const cardPeach = Color(0xFFFBE9D6);
  static const cardPaleLavender = Color(0xFFF1EDFA);

  static const cardTints = [
    cardCream,
    cardLavender,
    cardPeach,
    cardPaleLavender,
  ];

  // Derived accent for interactive elements (FAB, selected segment) —
  // not present in the mockup, which shows no buttons.
  static const accent = Color(0xFFB49CE8);

  /// Ink for text and icons sitting *on* [accent]. The accent is a light
  /// lavender, so white on it measures about 2.4:1 — well under the 4.5:1
  /// text minimum. This near-black reads at roughly 7:1 instead.
  static const onAccent = Color(0xFF241F33);

  /// A second readable weight on [accent], for the unit label beside a
  /// milestone day count. [onAccent] measures about 6.7:1 there and this
  /// about 5.0:1 — both clear of the 4.5:1 text minimum, which white
  /// (2.4:1) and [textMuted] are not. Mirrored in the widget's
  /// DaysCounterWidget.swift.
  static const onAccentMuted = Color(0xFF3A3350);

  /// Form labels. [textMuted] is tuned for secondary text on card
  /// backgrounds; on the paler input fill it drops to about 3:1, so labels
  /// get their own slightly darker tone.
  static const textLabel = Color(0xFF6B6577);

  static const error = Color(0xFFB3261E);

  // Dark theme
  static const backgroundDark = Color(0xFF161320);
  static const surfaceDark = Color(0xFF1F1B2E);
  static const textPrimaryDark = Color(0xFFF1EDFA);
  static const textMutedDark = Color(0xFF8D86A3);
  static const moonBadgeDark = Color(0xFF2C2740);

  /// Same reasoning as [textLabel]: [textMutedDark] on the dark input fill
  /// measures about 4.1:1, just under the bar. This lifts it to about 6:1.
  static const textLabelDark = Color(0xFFADA6C2);

  static const errorDark = Color(0xFFF2B8B5);
}

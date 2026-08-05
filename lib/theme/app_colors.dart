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

  // Dark theme
  static const backgroundDark = Color(0xFF161320);
  static const surfaceDark = Color(0xFF1F1B2E);
  static const textPrimaryDark = Color(0xFFF1EDFA);
  static const textMutedDark = Color(0xFF8D86A3);
  static const moonBadgeDark = Color(0xFF2C2740);
}

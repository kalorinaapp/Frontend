import 'package:flutter/cupertino.dart';

class ThemeHelper {
  static bool get isLightMode => true; // This will be connected to ThemeProvider later

  // Gradient Colors from Design
  static const Color gradientStartBlue = Color(0xFF74A9DA);
  static const Color gradientEndPurple = Color(0xFF8C4CA2);
  static const Color gradientStartOrange = Color(0xFFFF6A00);
  static const Color gradientEndPink = Color(0xFFEE0979);

  // Button Gradient Colors from Figma
  static const Color buttonGradientStart = Color(0xFFFF6A00); // FF6A00 at 15%
  static const Color buttonGradientEnd = Color(0xFFEE0979);   // EE0979 at 100%

  // Colors
  static Color get background => isLightMode 
      ? CupertinoColors.systemBackground 
      : CupertinoColors.systemBackground.darkColor;

  static Color get cardBackground => isLightMode 
      ? CupertinoColors.secondarySystemBackground 
      : CupertinoColors.secondarySystemBackground.darkColor;

  static Color get textPrimary => isLightMode 
      ? CupertinoColors.label 
      : CupertinoColors.label.darkColor;

  static Color get textSecondary => isLightMode 
      ? CupertinoColors.secondaryLabel 
      : CupertinoColors.secondaryLabel.darkColor;

  static Color get divider => isLightMode 
      ? CupertinoColors.separator 
      : CupertinoColors.separator.darkColor;

  static Color get accent => isLightMode 
      ? CupertinoColors.activeBlue 
      : CupertinoColors.activeBlue.darkColor;

  static Color get destructive => CupertinoColors.systemRed;

  // Text Styles
  static TextStyle get title1 => const TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      );

  static TextStyle get title2 => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.36,
      );

  static TextStyle get title3 => const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
      );

  static TextStyle get headline => const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
      );

  static TextStyle get body1 => const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.41,
      );

  static TextStyle get callout => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.32,
      );

  static TextStyle get subhead => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.24,
      );

  static TextStyle get footnote => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.08,
      );

  static TextStyle get caption1 => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      );

  static TextStyle get caption2 => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.06,
      );

  static TextStyle textStyleWithColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}

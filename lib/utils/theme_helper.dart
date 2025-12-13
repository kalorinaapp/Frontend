import 'package:flutter/cupertino.dart';

class ThemeHelper {
  static bool _isLightMode = true;
  
  static bool get isLightMode => _isLightMode;
  
  static void setLightMode(bool isLight) {
    _isLightMode = isLight;
  }
  
  static void updateSystemBrightness(Brightness brightness) {
    // This can be used to sync with system brightness if needed
    // For now, we'll keep it simple and just use our theme provider
  }

  // Gradient Colors from Design
  static const Color gradientStartBlue = Color(0xFF74A9DA);
  static const Color gradientEndPurple = Color(0xFF8C4CA2);
  static const Color gradientStartOrange = Color(0xFFFF6A00);
  static const Color gradientEndPink = Color(0xFFEE0979);

  // Button Gradient Colors from Figma
  static const Color buttonGradientStart = Color(0xFFFF6A00); // FF6A00 at 15%
  static const Color buttonGradientEnd = Color(0xFFEE0979);   // EE0979 at 100%

  // Colors - Based on Cal AI modern design
  static Color get background => isLightMode 
      ? CupertinoColors.systemBackground 
      : const Color(0xFF1C1C1E); // Dark gray background like Cal AI

  static Color get cardBackground => isLightMode 
      ? CupertinoColors.extraLightBackgroundGray 
      : const Color(0xFF2C2C2E); // Elevated card color - sleek and modern

  static Color get textPrimary => isLightMode 
      ? CupertinoColors.label 
      : const Color(0xFFFFFFFF); // Pure white for best contrast

  static Color get textSecondary => isLightMode 
      ? CupertinoColors.secondaryLabel 
      : const Color(0xFF8E8E93); // Subtle gray for secondary text

  static Color get divider => isLightMode 
      ? CupertinoColors.systemGrey4 
      : const Color(0xFF38383A); // Subtle divider for dark mode

  static Color get accent => isLightMode 
      ? CupertinoColors.activeBlue 
      : CupertinoColors.activeBlue;

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

  static TextStyle textStyleWithColorAndSize(TextStyle style, Color color, double fontSize) {
    return style.copyWith(color: color, fontSize: fontSize);
  }
  
  // Helper method to create theme-aware containers
  static BoxDecoration getCardDecoration() {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: divider),
    );
  }
  
  // Helper method to create theme-aware button decoration
  static BoxDecoration getButtonDecoration({bool isSelected = false}) {
    return BoxDecoration(
      color: isSelected ? textPrimary : background,
      border: Border.all(
        color: isSelected ? textPrimary : divider,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(12),
    );
  }
}

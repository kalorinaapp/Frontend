import 'package:flutter/cupertino.dart';

/// Global animations helper for consistent page transitions and element appearances
class PageAnimations {
  // Animation durations
  static const Duration standardDuration = Duration(milliseconds: 900);
  static const Duration fastDuration = Duration(milliseconds: 600);
  static const Duration slowDuration = Duration(milliseconds: 1200);

  /// Creates a title fade animation with gentle scale
  static Animation<double> createTitleAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
  }

  /// Creates a content fade animation for cards/buttons
  static Animation<double> createContentAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0.3,
          0.85,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  /// Wraps a widget with fade + scale animation for titles
  static Widget animatedTitle({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).animate(animation),
        child: child,
      ),
    );
  }

  /// Wraps a widget with fade + subtle scale animation for content
  static Widget animatedContent({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(animation),
        child: child,
      ),
    );
  }

  /// Creates an animated selection card with smooth transitions
  /// Use this for selectable options/cards that change appearance when selected
  static Widget animatedSelectionCard({
    required bool isSelected,
    required VoidCallback onTap,
    required Widget child,
    Color? selectedColor,
    Color? unselectedColor,
    Color? selectedBorderColor,
    Color? unselectedBorderColor,
    double borderRadius = 12,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          border: Border.all(
            color: isSelected 
                ? (selectedBorderColor ?? selectedColor ?? CupertinoColors.activeBlue)
                : (unselectedBorderColor ?? CupertinoColors.systemGrey4),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: (selectedBorderColor ?? selectedColor ?? CupertinoColors.activeBlue)
                    .withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            else
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: child,
      ),
    );
  }
}


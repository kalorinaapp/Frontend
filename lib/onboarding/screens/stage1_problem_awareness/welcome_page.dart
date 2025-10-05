import 'package:flutter/cupertino.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';

class WelcomePage extends StatelessWidget {
  final ThemeProvider themeProvider;

  const WelcomePage({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.rectangle_stack,
                  size: 60,
                  color: CupertinoColors.systemGreen,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Title
              Text(
                'Welcome to Cal AI',
                style: ThemeHelper.textStyleWithColor(
                  ThemeHelper.title1,
                  ThemeHelper.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'Your personal AI-powered nutrition assistant',
                style: ThemeHelper.textStyleWithColor(
                  ThemeHelper.title3,
                  CupertinoColors.systemGreen,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Description
              Text(
                'Track your meals, get nutritional insights, and achieve your health goals with the power of artificial intelligence.',
                style: ThemeHelper.textStyleWithColor(
                  ThemeHelper.body1,
                  ThemeHelper.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

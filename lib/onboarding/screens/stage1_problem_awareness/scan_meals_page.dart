import 'package:flutter/cupertino.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';

class ScanMealsPage extends StatelessWidget {
  final ThemeProvider themeProvider;

  const ScanMealsPage({super.key, required this.themeProvider});

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
                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.camera,
                  size: 60,
                  color: CupertinoColors.systemBlue,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Title
              Text(
                'Scan & Log Meals',
                style: ThemeHelper.textStyleWithColor(
                  ThemeHelper.title1,
                  ThemeHelper.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'Just point and shoot',
                style: ThemeHelper.textStyleWithColor(
                  ThemeHelper.title3,
                  CupertinoColors.systemBlue,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Description
              Text(
                'Take a photo of your meal and let our AI instantly identify ingredients and calculate nutritional values.',
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

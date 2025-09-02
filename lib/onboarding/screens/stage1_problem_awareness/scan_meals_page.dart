import 'package:flutter/cupertino.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';

class ScanMealsPage extends StatelessWidget {
  final ThemeProvider themeProvider;

  const ScanMealsPage({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
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
            style: ThemeHelper.title1,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            'Just point and shoot',
            style: ThemeHelper.title3.copyWith(
              color: CupertinoColors.systemBlue,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            'Take a photo of your meal and let our AI instantly identify ingredients and calculate nutritional values.',
            style: ThemeHelper.body1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

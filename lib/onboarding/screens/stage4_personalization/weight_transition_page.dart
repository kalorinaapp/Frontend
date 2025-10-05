import 'package:flutter/cupertino.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';

class WeightTransitionPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const WeightTransitionPage({super.key, required this.themeProvider});

  @override
  State<WeightTransitionPage> createState() => _WeightTransitionPageState();
}

class _WeightTransitionPageState extends State<WeightTransitionPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            
            // Main Title
            Center(
              child: Text(
                'Imaš veliki potencijal\nostvariti svoj cilj',
                style: ThemeHelper.title2.copyWith(
                  color: const Color(0xFF1E1822), // Dark purple/grey color
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 100),
            
            // Subtitle
            Center(
              child: Text(
                'Your weight transition',
                style: ThemeHelper.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black, // Dark purple/grey color
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Weight transition graph
            Center(
              child: Column(
                children: [
                  // Graph container with PNG image
                  Transform.scale(
                    scale: 1.5,
                    child: Image.asset(
                      'assets/images/weight_bars.png',
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class WeightTransitionPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const WeightTransitionPage({super.key, required this.themeProvider});

  @override
  State<WeightTransitionPage> createState() => _WeightTransitionPageState();
}

class _WeightTransitionPageState extends State<WeightTransitionPage> {
  late OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF5F5), // Light pink at top
            Color(0xFFFFE8E8), // Slightly deeper pink at bottom
          ],
        ),
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

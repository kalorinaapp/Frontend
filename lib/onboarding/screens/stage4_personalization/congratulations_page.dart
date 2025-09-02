import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class CongratulationsPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const CongratulationsPage({super.key, required this.themeProvider});

  @override
  State<CongratulationsPage> createState() => _CongratulationsPageState();
}

class _CongratulationsPageState extends State<CongratulationsPage> {
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
            
            // Congratulatory Title
            Center(
              child: Text(
                'Bravo! Upravo si napravio/la veliki korak na svom putu.',
                style: ThemeHelper.title2.copyWith(
                  color: const Color(0xFF1E1822), // Dark purple/grey color
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Informational Paragraph
            Text(
              'Jeste li znali da je praćenje kalorija znanstveno dokazana metoda mršavljenja - i to i do dvostruko brže? Što ste dosljedniji, veća je vjerojatnost da ćete postići svoje ciljeve.',
              style: ThemeHelper.body1.copyWith(
                color: const Color(0xFF1E1822), // Dark purple/grey color
                height: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
            
            const Spacer(),
            
           
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class ExtraCaloriesPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const ExtraCaloriesPage({super.key, required this.themeProvider});

  @override
  State<ExtraCaloriesPage> createState() => _ExtraCaloriesPageState();
}

class _ExtraCaloriesPageState extends State<ExtraCaloriesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set this page to use dual buttons (Yes/No)
      _controller.setDualButtonMode(true);
    });
  }

  @override
  void dispose() {
    // Reset to single button mode when leaving this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.setDualButtonMode(false);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            
            // Title
            Center(
              child: Text(
                "Add extra calories to the next day?",
                style: ThemeHelper.title1.copyWith(
                  color: CupertinoColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Recommendation
            Center(
              child: Text(
                "(Recommended)",
                style: ThemeHelper.body1.copyWith(
                  color: CupertinoColors.systemGrey,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Two columns - one at start, one at end
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/extracalories1.png',
                  width: 150,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            // Second column at end
            Align(
              alignment: Alignment(1, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/extracalories2.png',
                    width: 150,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

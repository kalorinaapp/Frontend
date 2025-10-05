import 'package:flutter/cupertino.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';

class HereForYouPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const HereForYouPage({super.key, required this.themeProvider});

  @override
  State<HereForYouPage> createState() => _HereForYouPageState();
}

class _HereForYouPageState extends State<HereForYouPage> {
  // late OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    // _controller = Get.find<OnboardingController>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // Title
          Center(
            child: Text(
              "We're here for you!",
              style: ThemeHelper.title2.copyWith(
                color: CupertinoColors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 120),
          
          // Hands illustration placeholder
         Center(
           child: Image.asset(
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            'assets/images/support.png',
           ),
         ),
          
          const SizedBox(height: 40),
          
          // Support message box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "The journey to your goal might be challenging at times, but we're here to support you every step of the way. You won't have to face it alone.",
              style: ThemeHelper.body1.copyWith(
                color: CupertinoColors.black,fontWeight: FontWeight.bold,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // const Spacer(),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class CalorieAdjustmentPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const CalorieAdjustmentPage({super.key, required this.themeProvider});

  @override
  State<CalorieAdjustmentPage> createState() => _CalorieAdjustmentPageState();
}

class _CalorieAdjustmentPageState extends State<CalorieAdjustmentPage>
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
    
    // Initialize with default values if not set
    if (_controller.getIntData('daily_calorie_goal') == null) {
      _controller.setIntData('daily_calorie_goal', 2250);
    }
    if (_controller.getIntData('steps_burned_calories') == null) {
      _controller.setIntData('steps_burned_calories', 200);
    }
    });
  }

  @override
  void dispose() {
    // Reset to single button mode when leaving this page
    _controller.setDualButtonMode(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          
          // Title
          Center(
            child: Text(
              "Add calories burned back to your daily goal?",
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
          
          const SizedBox(height: 80),
          
          // Information card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Today's goal
                Row(
                  children: [
                    Image.asset('assets/images/flame.png', width: 24, height: 24),
                     
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                      "Today's goal:",
                      style: ThemeHelper.body1.copyWith(
                        color: CupertinoColors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                Obx(() => Text(
                  "${_controller.getIntData('daily_calorie_goal') ?? 2250} Calories",
                  style: ThemeHelper.body1.copyWith(
                    color: CupertinoColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                  ],
                ),
                
                      ]
                    ),
                    
                
                const SizedBox(height: 24),
                
                // Steps/Burned calories
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/feet.png', width: 24, height: 24),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Steps:",
                              style: ThemeHelper.body1.copyWith(
                                color: CupertinoColors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                    Obx(() => Text(
                      "+${_controller.getIntData('steps_burned_calories') ?? 200} Calories",
                      style: ThemeHelper.body1.copyWith(
                        color: CupertinoColors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                          ],
                        ),
                      ],
                    ),
                    
                  ],
                ),
              ],
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }
}

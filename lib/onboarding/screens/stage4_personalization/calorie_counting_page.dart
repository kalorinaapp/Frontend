import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../controller/onboarding.controller.dart';

class CalorieCountingPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const CalorieCountingPage({super.key, required this.themeProvider});

  @override
  State<CalorieCountingPage> createState() => _CalorieCountingPageState();
}

class _CalorieCountingPageState extends State<CalorieCountingPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
  }

  // Calculate daily calorie goal based on user data
  int _calculateDailyCalorieGoal() {
    final int? weight = _controller.getIntData('weight');
    final int? height = _controller.getIntData('height');
    final String? goal = _controller.getStringData('goal');
    final double? weightLossSpeed = _controller.getDoubleData('weight_loss_speed');
    
    if (weight == null || height == null) {
      return 2000; // Default fallback
    }
    
    // Convert to kg if needed
    final bool isLbs = _controller.getBoolData('weight_unit_lbs') ?? true;
    final double weightKg = isLbs ? weight * 0.453592 : weight.toDouble();
    final double heightCm = isLbs ? height * 2.54 : height.toDouble();
    
    // Calculate BMR using Mifflin-St Jeor Equation
    // BMR = 10 * weight(kg) + 6.25 * height(cm) - 5 * age + 5 (for men)
    // For simplicity, assuming average age of 30 and male
    final double bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * 30) + 5;
    
    // Calculate TDEE (Total Daily Energy Expenditure) - assuming sedentary activity
    final double tdee = bmr * 1.2;
    
    // Adjust based on goal
    double calorieGoal = tdee;
    if (goal == 'lose_weight') {
      // Create deficit based on weight loss speed
      final double weeklyDeficit = (weightLossSpeed ?? 0.5) * 7700; // 7700 calories = 1kg
      final double dailyDeficit = weeklyDeficit / 7;
      calorieGoal = tdee - dailyDeficit;
    } else if (goal == 'gain_weight') {
      // Add surplus for weight gain
      calorieGoal = tdee + 500; // 500 calorie surplus
    }
    
    return calorieGoal.round();
  }

  // Calculate calories burned from steps
  int _calculateStepsCalories() {
    final int? weight = _controller.getIntData('weight');
    if (weight == null) return 200; // Default fallback
    
    // Convert to kg if needed
    final bool isLbs = _controller.getBoolData('weight_unit_lbs') ?? true;
    final double weightKg = isLbs ? weight * 0.453592 : weight.toDouble();
    
    // Assuming 10,000 steps per day (average)
    // Calories burned per step = 0.04 * weight(kg)
    final double caloriesPerStep = 0.04 * weightKg;
    final int steps = 10000;
    final double totalCalories = caloriesPerStep * steps;
    
    return totalCalories.round();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 393,
      height: 852,
      decoration: BoxDecoration(color: ThemeHelper.background),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            
            // Title
            SizedBox(
              width: 278,
              child: Text(
                l10n.countBurnedCaloriesTowardsGoal,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 30,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Subtitle
            SizedBox(
              width: 311,
              child: Text(
                l10n.recommended,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 20,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Main information card
            Container(
              width: 278,
              height: 197,
              decoration: ShapeDecoration(
                color: ThemeHelper.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's goal section
                    Row(
                      children: [
                        // Apple icon
                        Image.asset(
                          'assets/icons/apple.png',
                          width: 40,
                          height: 40,
                          color: ThemeHelper.textPrimary,
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Today's goal text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 301,
                                child: Text(
                                  l10n.todaysGoal,
                                  style: TextStyle(
                                    color: ThemeHelper.textPrimary,
                                    fontSize: 18,
                                    fontFamily: 'Instrument Sans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 301,
                                child: Text(
                                  '${_calculateDailyCalorieGoal()} ${l10n.calories}',
                                  style: TextStyle(
                                    color: ThemeHelper.textPrimary,
                                    fontSize: 24,
                                    fontFamily: 'Instrument Sans',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Steps section
                    Row(
                      children: [
                        // Steps icon
                        Image.asset(
                          'assets/icons/steps.png',
                          width: 36,
                          height: 36,
                          color: ThemeHelper.textPrimary,
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Steps text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 301,
                                child: Text(
                                  l10n.stepsLabel,
                                  style: TextStyle(
                                    color: ThemeHelper.textPrimary,
                                    fontSize: 18,
                                    fontFamily: 'Instrument Sans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 301,
                                child: Text(
                                  '+${_calculateStepsCalories()} ${l10n.calories}',
                                  style: TextStyle(
                                    color: ThemeHelper.textPrimary,
                                    fontSize: 24,
                                    fontFamily: 'Instrument Sans',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
           
          ],
        ),
      ),
    );
  }
}

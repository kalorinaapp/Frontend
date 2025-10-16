import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../../../providers/theme_provider.dart';
import '../../controller/onboarding.controller.dart';

class CalorieTransferPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const CalorieTransferPage({super.key, required this.themeProvider});

  @override
  State<CalorieTransferPage> createState() => _CalorieTransferPageState();
}

class _CalorieTransferPageState extends State<CalorieTransferPage>
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
      return 2250; // Default fallback
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

  // Calculate transferable calories from yesterday (max 200)
  int _calculateTransferableCalories() {
    final int yesterdayGoal = _calculateDailyCalorieGoal();
    final int yesterdayEaten = 2100; // From the image
    
    final int excessCalories = max(0, yesterdayGoal - yesterdayEaten);
    return min(200, excessCalories); // Cap at 200 calories
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final int yesterdayGoal = _calculateDailyCalorieGoal();
    final int transferableCalories = _calculateTransferableCalories();
    final int todayGoal = yesterdayGoal + transferableCalories;
    
    // Yesterday's data
    final int yesterdayEaten = 2100;
    final double yesterdayProgress = (yesterdayEaten / yesterdayGoal).clamp(0.0, 1.0);
    
    // Today's data
    final int todayEaten = 2100;
    final double todayProgress = (todayEaten / todayGoal).clamp(0.0, 1.0);

    return Container(
      width: 393,
      height: 852,
      decoration: const BoxDecoration(color: Colors.white),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              
              // Title
              SizedBox(
                width: 339,
                child: Text(
                  'Prebaci dodatne kalorije na sljedeći dan?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF1E1822),
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
                  '(Recommended)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF1E1822),
                    fontSize: 20,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Yesterday Card (Left aligned)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 274,
                  height: 176,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with apple icon
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/apple.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Yesterday',
                            style: TextStyle(
                              color: const Color(0xFF1E1822),
                              fontSize: 16,
                              fontFamily: 'Instrument Sans',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Calorie count
                      Text(
                        '$yesterdayEaten/$yesterdayGoal',
                        style: TextStyle(
                          color: const Color(0xFF1E1822),
                          fontSize: 32,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Progress bar
                      Stack(
                        children: [
                          Container(
                            width: 175,
                            height: 6,
                            decoration: const ShapeDecoration(
                              color: Color(0x261E1822),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                              ),
                            ),
                          ),
                          Container(
                            width: 175 * yesterdayProgress,
                            height: 6,
                            decoration: const ShapeDecoration(
                              color: Color(0xFF0CC0DF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Calories left text
                      Text(
                        'Calories Left',
                        style: TextStyle(
                          color: const Color(0xFF1E1822),
                          fontSize: 14,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
              
              const SizedBox(height: 20),
              
              // Today Card (Right aligned)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 274,
                  height: 178,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with apple icon
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/apple.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Today',
                            style: TextStyle(
                              color: const Color(0xFF1E1822),
                              fontSize: 16,
                              fontFamily: 'Instrument Sans',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Calorie count
                      Text(
                        '$todayEaten/$todayGoal',
                        style: TextStyle(
                          color: const Color(0xFF1E1822),
                          fontSize: 32,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Progress bar with transfer indicator
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 175,
                            height: 6,
                            decoration: const ShapeDecoration(
                              color: Color(0x261E1822),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                              ),
                            ),
                          ),
                          Container(
                            width: 175 * todayProgress,
                            height: 6,
                            decoration: const ShapeDecoration(
                              color: Color(0xFF0CC0DF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                              ),
                            ),
                          ),
                          // Transfer indicator with light blue container
                          if (transferableCalories > 0)
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0CC0DF).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '+$transferableCalories',
                                  style: TextStyle(
                                    color: const Color(0xFF0CC0DF),
                                    fontSize: 12,
                                    fontFamily: 'Instrument Sans',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Calories left text
                      Text(
                        'Calories Left',
                        style: TextStyle(
                          color: const Color(0xFF1E1822),
                          fontSize: 14,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
              
             
            ],
          ),
        ),
      ),
    );
  }
}

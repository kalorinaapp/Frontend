import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../../utils/page_animations.dart';
import '../../controller/onboarding.controller.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;

class WeightLossMotivationPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const WeightLossMotivationPage({super.key, required this.themeProvider});

  @override
  State<WeightLossMotivationPage> createState() => _WeightLossMotivationPageState();
}

class _WeightLossMotivationPageState extends State<WeightLossMotivationPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late OnboardingController _controller;
  late AnimationController _animationController;
  late Animation<double> _circleAnimation;
  late Animation<double> _motivationAnimation;
  late Animation<double> _encouragementAnimation;
  late Animation<double> _statsAnimation;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    
    _circleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    
    _motivationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _encouragementAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _statsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Calculate weight change goal based on current and desired weight
  double _getWeightChangeGoal() {
    final int? currentWeightInt = _controller.getIntData('weight');
    final double? desiredWeight = _controller.getDoubleData('desired_weight');
    final bool isCurrentMetric = _controller.getBoolData('is_metric') ?? true;
    final bool isDesiredLbs = _controller.getBoolData('weight_unit_lbs') ?? true;
    final String? goal = _controller.getStringData('goal');
    
    debugPrint('🔍 Weight Change Calculation:');
    debugPrint('   Current Weight (int): $currentWeightInt');
    debugPrint('   Desired Weight (double): $desiredWeight');
    debugPrint('   Current Unit (isMetric): $isCurrentMetric');
    debugPrint('   Desired Unit (isLbs): $isDesiredLbs');
    debugPrint('   Goal: $goal');
    
    if (currentWeightInt == null || desiredWeight == null) {
      debugPrint('   ⚠️ Missing weight data, returning default');
      return isDesiredLbs ? 5.0 : 2.3; // Default fallback based on unit
    }
    
    // Convert current weight to double
    double currentWeight = currentWeightInt.toDouble();
    double desiredWeightNormalized = desiredWeight;
    
    // Convert both weights to kg for consistent calculation, then convert back to desired unit
    // Step 1: Convert current weight to kg
    if (!isCurrentMetric) {
      // Current weight is in lbs, convert to kg
      currentWeight = currentWeight * 0.453592;
      debugPrint('   Converted current weight from lbs to kg: $currentWeight kg');
    }
    
    // Step 2: Convert desired weight to kg
    if (isDesiredLbs) {
      // Desired weight is in lbs, convert to kg
      desiredWeightNormalized = desiredWeightNormalized * 0.453592;
      debugPrint('   Converted desired weight from lbs to kg: $desiredWeightNormalized kg');
    }
    
    // Step 3: Calculate difference in kg
    double weightChangeKg = 0.0;
    if (goal == 'lose_weight') {
      weightChangeKg = currentWeight - desiredWeightNormalized;
      debugPrint('   Weight loss (kg): $weightChangeKg kg');
    } else if (goal == 'gain_weight') {
      weightChangeKg = desiredWeightNormalized - currentWeight;
      debugPrint('   Weight gain (kg): $weightChangeKg kg');
    } else {
      // maintain_weight - should be 0
      weightChangeKg = 0.0;
      debugPrint('   Maintaining weight: 0 kg');
    }
    
    // Step 4: Convert result back to desired unit system if needed
    double result = weightChangeKg > 0 ? weightChangeKg : 0.0;
    if (isDesiredLbs) {
      // Convert kg back to lbs for display
      result = result * 2.20462;
      debugPrint('   Final result (lbs): $result lbs');
    } else {
      debugPrint('   Final result (kg): $result kg');
    }
    
    return result;
  }
  
  String _getWeightChangeSign() {
    final String? goal = _controller.getStringData('goal');
    if (goal == 'lose_weight') {
      return '-';
    } else if (goal == 'gain_weight') {
      return '+';
    }
    return '';
  }

  // Get motivational message based on goal and amount
  String _getMotivationalMessage(AppLocalizations localizations, double weightChangeAmount, bool isLbs) {
    final String? goal = _controller.getStringData('goal');
    
    // Convert to kg for consistent categorization
    double amountInKg = isLbs ? weightChangeAmount * 0.453592 : weightChangeAmount;
    
    if (goal == 'lose_weight') {
      if (amountInKg < 5) {
        return 'Every small step counts!\nYou\'re already on the right track!';
      } else if (amountInKg < 10) {
        return localizations.youHaveGreatPotentialLose;
      } else if (amountInKg < 20) {
        return 'Your journey to better health starts now!\nWe believe in your success!';
      } else {
        return 'You\'ve taken the first step towards a healthier you!\nWe\'re here to support you every step of the way!';
      }
    } else if (goal == 'gain_weight') {
      if (amountInKg < 5) {
        return 'Small gains lead to big results!\nYou\'re on the right path!';
      } else if (amountInKg < 10) {
        return localizations.youHaveGreatPotentialGain;
      } else if (amountInKg < 15) {
        return 'Building strength takes time and dedication!\nWe\'re with you all the way!';
      } else {
        return 'Your muscle-building journey begins now!\nCommitment is key to your transformation!';
      }
    }
    return localizations.youHaveGreatPotentialLose;
  }

  // Get encouragement message based on goal and amount
  String _getEncouragementMessage(AppLocalizations localizations, double weightChangeAmount, bool isLbs) {
    final String? goal = _controller.getStringData('goal');
    
    // Convert to kg for consistent categorization
    double amountInKg = isLbs ? weightChangeAmount * 0.453592 : weightChangeAmount;
    
    if (goal == 'lose_weight') {
      if (amountInKg < 5) {
        return 'You\'re doing amazing!';
      } else if (amountInKg < 10) {
        return localizations.youveGotThis;
      } else if (amountInKg < 20) {
        return localizations.stayStrong;
      } else {
        return 'You\'re stronger than you think!';
      }
    } else if (goal == 'gain_weight') {
      if (amountInKg < 5) {
        return 'Every rep counts!';
      } else if (amountInKg < 10) {
        return localizations.stayStrong;
      } else if (amountInKg < 15) {
        return 'Consistency is your power!';
      } else {
        return 'Beast mode activated!';
      }
    }
    return localizations.youveGotThis;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final localizations = AppLocalizations.of(context)!;

    final double weightChangeGoal = _getWeightChangeGoal();
    final bool isLbs = _controller.getBoolData('weight_unit_lbs') ?? true;
    final String weightUnit = isLbs ? 'lbs' : 'kg';
    final String weightSign = _getWeightChangeSign();

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
          
          // Weight change goal circle
          PageAnimations.animatedContent(
            animation: _circleAnimation,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: ThemeHelper.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 207, 173, 128), // Light tan/brown border
                  width: 12,
                ),
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$weightSign${weightChangeGoal.toStringAsFixed(1)}',
                        style: ThemeHelper.title1.copyWith(
                          color: ThemeHelper.textPrimary,
                          fontSize: 22.4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: weightUnit,
                        style: ThemeHelper.title1.copyWith(
                          color: ThemeHelper.textPrimary,
                          fontSize: 16.8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Main motivational message
          PageAnimations.animatedContent(
            animation: _motivationAnimation,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$weightSign${weightChangeGoal.toStringAsFixed(1)}$weightUnit',
                    style: ThemeHelper.title2.copyWith(
                      color: ThemeHelper.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' ${localizations.isRealisticGoal}\n${_getMotivationalMessage(localizations, weightChangeGoal, isLbs)}',
                    style: ThemeHelper.title2.copyWith(
                      color: ThemeHelper.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Encouragement message
          PageAnimations.animatedContent(
            animation: _encouragementAnimation,
            child: Text(
              _getEncouragementMessage(localizations, weightChangeGoal, isLbs),
              style: ThemeHelper.title1.copyWith(
                color: ThemeHelper.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Statistics box
          PageAnimations.animatedContent(
            animation: _statsAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeHelper.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Graph icon placeholder
                  Image.asset(
                    'assets/icons/graph.png',
                    width: 36,
                    height: 36,
                    color: ThemeHelper.textPrimary,
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Statistics text
                  Expanded(
                    child: Text(
                      localizations.nineOutOfTenUsers,
                      style: ThemeHelper.body1.copyWith(
                        color: ThemeHelper.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }
}

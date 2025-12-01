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
    
    if (currentWeightInt == null || desiredWeight == null) {
      return isDesiredLbs ? 5.0 : 2.3; // Default fallback based on unit
    }
    
    // Convert current weight to double
    double currentWeight = currentWeightInt.toDouble();
    double desiredWeightNormalized = desiredWeight;
    
    // Ensure both weights are in the same unit (let's use the desired weight's unit)
    // If current is metric (kg) but desired is lbs, convert current to lbs
    // If current is imperial (lbs) but desired is kg, convert current to kg
    if (isCurrentMetric && isDesiredLbs) {
      // Current is in kg, desired is in lbs - convert current to lbs
      currentWeight = currentWeight * 2.20462;
    } else if (!isCurrentMetric && !isDesiredLbs) {
      // Current is in lbs, desired is in kg - convert current to kg
      currentWeight = currentWeight * 0.453592;
    }
    // If both are in the same unit system, no conversion needed
    
    // For lose_weight: positive number (current - desired)
    // For gain_weight: positive number (desired - current)
    if (goal == 'lose_weight') {
      final double weightLoss = currentWeight - desiredWeightNormalized;
      return weightLoss > 0 ? weightLoss : 0.0;
    } else if (goal == 'gain_weight') {
      final double weightGain = desiredWeightNormalized - currentWeight;
      return weightGain > 0 ? weightGain : 0.0;
    }
    
    return isDesiredLbs ? 5.0 : 2.3; // Default fallback based on unit
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
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
          
          const SizedBox(height: 40),
          
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
          
          const SizedBox(height: 60),
          
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
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

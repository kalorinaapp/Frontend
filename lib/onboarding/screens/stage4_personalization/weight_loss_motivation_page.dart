import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class WeightLossMotivationPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const WeightLossMotivationPage({super.key, required this.themeProvider});

  @override
  State<WeightLossMotivationPage> createState() => _WeightLossMotivationPageState();
}

class _WeightLossMotivationPageState extends State<WeightLossMotivationPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
  }

  // Calculate weight loss goal based on current and desired weight
  double _getWeightLossGoal() {
    final int? currentWeightInt = _controller.getIntData('weight');
    final double? desiredWeight = _controller.getDoubleData('desired_weight');
    
    // Convert int to double if needed
    final double? currentWeight = currentWeightInt?.toDouble();
    
    if (currentWeight != null && desiredWeight != null) {
      final double weightLoss = currentWeight - desiredWeight;
      return weightLoss > 0 ? weightLoss : 0.0;
    }
    return 5.0; // Default fallback
  }

  // Get current weight for categorization
  double _getCurrentWeight() {
    final int? currentWeightInt = _controller.getIntData('weight');
    final bool isLbs = _controller.getBoolData('weight_unit_lbs') ?? true;
    
    if (currentWeightInt != null) {
      double weight = currentWeightInt.toDouble();
      // Convert to kg for consistent categorization
      if (isLbs) {
        weight = weight * 0.453592; // Convert lbs to kg
      }
      return weight;
    }
    return 70.0; // Default fallback
  }

  // Get motivational message based on weight category
  String _getMotivationalMessage() {
    final double currentWeight = _getCurrentWeight();
    
    if (currentWeight < 60) {
      return 'Every small step counts!\nYou\'re already on the right track!';
    } else if (currentWeight < 80) {
      return 'You have great potential to achieve your goal!\nLet\'s make it happen together!';
    } else if (currentWeight < 100) {
      return 'Your journey to better health starts now!\nWe believe in your success!';
    } else {
      return 'You\'ve taken the first step towards a healthier you!\nWe\'re here to support you every step of the way!';
    }
  }

  // Get encouragement message based on weight category
  String _getEncouragementMessage() {
    final double currentWeight = _getCurrentWeight();
    
    if (currentWeight < 60) {
      return 'You\'re doing amazing!';
    } else if (currentWeight < 80) {
      return 'You\'ve got this!';
    } else if (currentWeight < 100) {
      return 'Stay strong!';
    } else {
      return 'You\'re stronger than you think!';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final double weightLossGoal = _getWeightLossGoal();
    final bool isLbs = _controller.getBoolData('weight_unit_lbs') ?? true;
    final String weightUnit = isLbs ? 'lbs' : 'kg';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          
          // Weight loss goal circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: CupertinoColors.white,
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
                      text: '-${weightLossGoal.toStringAsFixed(0)}',
                      style: ThemeHelper.title1.copyWith(
                        color: CupertinoColors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: weightUnit,
                      style: ThemeHelper.title1.copyWith(
                        color: CupertinoColors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Main motivational message
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '-${weightLossGoal.toStringAsFixed(0)}$weightUnit',
                  style: ThemeHelper.title2.copyWith(
                    color: CupertinoColors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' is a realistic goal.\n${_getMotivationalMessage()}',
                  style: ThemeHelper.title2.copyWith(
                    color: CupertinoColors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Encouragement message
          Text(
            _getEncouragementMessage(),
            style: ThemeHelper.title1.copyWith(
              color: CupertinoColors.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 60),
          
          // Statistics box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Graph icon placeholder
                Image.asset('assets/icons/graph.png', width: 36, height: 36),
                
                const SizedBox(width: 16),
                
                // Statistics text
                Expanded(
                  child: Text(
                    '9 out of 10 users say they\nsee results in first week of\nusing Kalorina',
                    style: ThemeHelper.body1.copyWith(
                      color: CupertinoColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

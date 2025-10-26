import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../controller/onboarding.controller.dart';

class ProgressMotivationPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const ProgressMotivationPage({super.key, required this.themeProvider});

  @override
  State<ProgressMotivationPage> createState() => _ProgressMotivationPageState();
}

class _ProgressMotivationPageState extends State<ProgressMotivationPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
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

  // Get personalized title based on weight category
  String _getPersonalizedTitle(AppLocalizations l10n) {
    final double currentWeight = _getCurrentWeight();
    
    if (currentWeight < 60) {
      return l10n.youHaveGreatPotential;
    } else if (currentWeight < 80) {
      return l10n.youHaveGreatPotential;
    } else if (currentWeight < 100) {
      return l10n.yourJourneyToBetterHealth;
    } else {
      return l10n.youTookFirstStepToHealthier;
    }
  }

  // Get personalized tip cards based on weight category
  List<Map<String, String>> _getPersonalizedTips(AppLocalizations l10n) {
    final double currentWeight = _getCurrentWeight();
    
    if (currentWeight < 60) {
      return [
        {'icon': 'assets/icons/track.png', 'text': l10n.trackYourFoodAndExercise},
        {'icon': 'assets/icons/cutlery.png', 'text': l10n.focusOnNutrientDenseFoods},
        {'icon': 'assets/icons/apple.png', 'text': l10n.maintainYourHealthyHabits},
        {'icon': 'assets/icons/up.png', 'text': l10n.stayConsistentSeeRealResults},
      ];
    } else if (currentWeight < 80) {
      return [
        {'icon': 'assets/icons/track.png', 'text': l10n.trackYourFoodAndExercise},
        {'icon': 'assets/icons/cutlery.png', 'text': l10n.balanceCarbsProteinAndFats},
        {'icon': 'assets/icons/apple.png', 'text': l10n.stickToYourPersonalizedPlan},
        {'icon': 'assets/icons/up.png', 'text': l10n.stayConsistentSeeRealResults},
      ];
    } else if (currentWeight < 100) {
      return [
        {'icon': 'assets/icons/track.png', 'text': l10n.trackYourFoodAndExercise},
        {'icon': 'assets/icons/cutlery.png', 'text': l10n.focusOnWholeUnprocessedFoods},
        {'icon': 'assets/icons/apple.png', 'text': l10n.followYourPersonalizedMealPlan},
        {'icon': 'assets/icons/up.png', 'text': l10n.stayConsistentSeeRealResults},
      ];
    } else {
      return [
        {'icon': 'assets/icons/track.png', 'text': l10n.trackYourFoodAndExercise},
        {'icon': 'assets/icons/cutlery.png', 'text': l10n.focusOnPortionControlAndNutrition},
        {'icon': 'assets/icons/apple.png', 'text': l10n.followYourPersonalizedPlan},
        {'icon': 'assets/icons/up.png', 'text': l10n.stayConsistentSeeRealResults},
      ];
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            
            // Main title
            Text(
              _getPersonalizedTitle(l10n),
              style: ThemeHelper.title1.copyWith(
                color: ThemeHelper.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Tip cards
            ..._getPersonalizedTips(l10n).asMap().entries.map((entry) {
              final int index = entry.key;
              final Map<String, String> tip = entry.value;
              return Column(
                children: [
                  if (index > 0) const SizedBox(height: 16),
                  _buildTipCard(
                    icon: tip['icon']!,
                    text: tip['text']!,
                  ),
                ],
              );
            }).toList(),
            
            const SizedBox(height: 40),
            
            // Progress section
            Image.asset('assets/images/progress.png'),
         
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard({
    required String icon,
    required String text,
  }) {
    // Check if this is the apple icon to make it bigger
    final bool isAppleIcon = icon.contains('apple.png');
    
    return Container(
      width: 250,
      height: 36, // Increased from 30 to 35
      decoration: ShapeDecoration(
        color: ThemeHelper.cardBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Image.asset(
              icon,
              width: isAppleIcon ? 20 : 16, // Apple icon is bigger
              height: isAppleIcon ? 20 : 16, // Apple icon is bigger
              color: ThemeHelper.textPrimary,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Text
          Expanded(
            child: Text(
              text,
              style: ThemeHelper.body1.copyWith(
                color: ThemeHelper.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

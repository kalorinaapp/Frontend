import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../../utils/page_animations.dart';
import '../../../l10n/app_localizations.dart';
import '../../controller/onboarding.controller.dart';

class PersonalGoalsPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const PersonalGoalsPage({super.key, required this.themeProvider});

  @override
  State<PersonalGoalsPage> createState() => _PersonalGoalsPageState();
}

class _PersonalGoalsPageState extends State<PersonalGoalsPage>
    with SingleTickerProviderStateMixin {
  late OnboardingController _controller;
  late AnimationController _animationController;
  late Animation<double> _titleAnimation;
  late List<Animation<double>> _optionAnimations;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    );
    
    _titleAnimation = PageAnimations.createTitleAnimation(_animationController);
    
    // Staggered option animations for 4 options
    _optionAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.25 + (index * 0.1),
            0.5 + (index * 0.1),
            curve: Curves.easeOut,
          ),
        ),
      );
    });
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Widget _buildAnimatedOption({
    required int index,
    required String value,
    required String iconPath,
    required String label,
  }) {
    return PageAnimations.animatedContent(
      animation: _optionAnimations[index],
      child: Obx(() {
        final isSelected = _controller.getStringData('personal_goal') == value;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: PageAnimations.animatedSelectionCard(
            isSelected: isSelected,
            onTap: () {
              _controller.setStringData('personal_goal', value);
            },
            selectedColor: ThemeHelper.textPrimary,
            unselectedColor: ThemeHelper.cardBackground,
            selectedBorderColor: ThemeHelper.textPrimary,
            unselectedBorderColor: ThemeHelper.divider,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  const SizedBox(width: 8.0),
                  Image.asset(iconPath, width: 48, height: 48),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      label,
                      style: ThemeHelper.headline.copyWith(
                        color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // Title
          PageAnimations.animatedTitle(
            animation: _titleAnimation,
            child: Text(
              textAlign: TextAlign.center,
              l10n.whatWouldYouLikeToAchieve,
              style: ThemeHelper.title2.copyWith(
                color: ThemeHelper.textPrimary,
              ),
            ),
          ),
          
          const SizedBox(height: 80),
          
          // Personal goals selection options
          Column(
            children: [
              // Option 1: Stay motivated and disciplined
              _buildAnimatedOption(
                index: 0,
                value: 'stay_motivated',
                iconPath: 'assets/icons/broccoli.png',
                label: l10n.stayMotivatedAndDisciplined,
              ),
              
              // Option 2: Feel better about your body
              _buildAnimatedOption(
                index: 1,
                value: 'feel_better_body',
                iconPath: 'assets/icons/lightning.png',
                label: l10n.feelBetterAboutYourBody,
              ),
              
              // Option 3: Improve health long-term
              _buildAnimatedOption(
                index: 2,
                value: 'improve_health',
                iconPath: 'assets/icons/wrist.png',
                label: l10n.improveHealthLongTerm,
              ),
              
              // Option 4: Increase mood and energy
              _buildAnimatedOption(
                index: 3,
                value: 'increase_mood_energy',
                iconPath: 'assets/icons/flex.png',
                label: l10n.increaseMoodAndEnergy,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

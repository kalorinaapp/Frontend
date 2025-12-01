import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../../utils/page_animations.dart';
import '../../controller/onboarding.controller.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;

class DietaryPreferencePage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const DietaryPreferencePage({super.key, required this.themeProvider});

  @override
  State<DietaryPreferencePage> createState() => _DietaryPreferencePageState();
}

class _DietaryPreferencePageState extends State<DietaryPreferencePage>
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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _titleAnimation = PageAnimations.createTitleAnimation(_animationController);
    
    // Staggered option animations
    _optionAnimations = List.generate(5, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.3 + (index * 0.08),
            0.55 + (index * 0.08),
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
  
  String _getIconPath(String baseIconPath, bool isSelected) {
    // In light mode, when selected, the background is black, so use white icons
    // In dark mode, when selected, the background is white, so use regular icons
    if (isSelected && ThemeHelper.isLightMode) {
      // Replace the icon name with its white version
      final baseName = baseIconPath.split('/').last.replaceAll('.png', '');
      return baseIconPath.replaceAll('$baseName.png', '${baseName}_white.png');
    }
    // Otherwise use regular icons
    return baseIconPath;
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
        final isSelected = _controller.getStringData('dietary_preference') == value;
        final currentIconPath = _getIconPath(iconPath, isSelected);
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: PageAnimations.animatedSelectionCard(
            isSelected: isSelected,
            onTap: () {
              _controller.setStringData('dietary_preference', value);
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
                  const SizedBox(width: 16),
                  Image.asset(currentIconPath, width: 32, height: 32),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: ThemeHelper.headline.copyWith(
                      color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
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
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Title
            PageAnimations.animatedTitle(
              animation: _titleAnimation,
              child: Center(
                child: Text(
                  localizations.doYouFollowDiet,
                  style: ThemeHelper.title3.copyWith(
                    color: ThemeHelper.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            // const SizedBox(height: 16),
            
            // // Informational banner with carrot icon
            // PageAnimations.animatedContent(
            //   animation: _infoAnimation,
            //   child: Container(
            //     width: double.infinity,
            //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //     decoration: BoxDecoration(
            //       color: ThemeHelper.cardBackground,
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: Row(
            //       children: [
            //         // Carrot icon
            //         const Text('🥕', style: TextStyle(fontSize: 24)),
            //         const SizedBox(width: 12),
            //         // Informational text
            //         Expanded(
            //           child: Text(
            //             localizations.helpTrackCaloriesDiet,
            //             style: ThemeHelper.caption1.copyWith(
            //               fontSize: 13,
            //               color: ThemeHelper.textSecondary,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            
            const SizedBox(height: 60),
            
            // Dietary preference selection options
            Column(
              children: [
                // Option 1: Classic
                _buildAnimatedOption(
                  index: 0,
                  value: 'classic',
                  iconPath: 'assets/icons/plates.png',
                  label: localizations.classic,
                ),
                
                // Option 2: Carnivore
                _buildAnimatedOption(
                  index: 1,
                  value: 'carnivore',
                  iconPath: 'assets/icons/chicken.png',
                  label: localizations.carnivore,
                ),
                
                // Option 3: Keto
                _buildAnimatedOption(
                  index: 2,
                  value: 'keto',
                  iconPath: 'assets/icons/avacado.png',
                  label: localizations.keto,
                ),
                
                // Option 4: Vegan
                _buildAnimatedOption(
                  index: 3,
                  value: 'vegan',
                  iconPath: 'assets/icons/vegan.png',
                  label: localizations.vegan,
                ),
                
                // Option 5: Vegetarian
                _buildAnimatedOption(
                  index: 4,
                  value: 'vegetarian',
                  iconPath: 'assets/icons/vegetarian.png',
                  label: localizations.vegetarian,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

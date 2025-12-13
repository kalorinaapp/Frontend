import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;
import '../../../utils/page_animations.dart';

class GoalSelectionPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const GoalSelectionPage({super.key, required this.themeProvider});

  @override
  State<GoalSelectionPage> createState() => _GoalSelectionPageState();
}

class _GoalSelectionPageState extends State<GoalSelectionPage> 
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  
  late OnboardingController _controller;
  late AnimationController _animationController;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late List<Animation<double>> _optionAnimations;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    
    _titleAnimation = PageAnimations.createTitleAnimation(_animationController);
    
    _subtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _optionAnimations = List.generate(3, (index) {
      final startInterval = 0.3 + (index * 0.12);
      final endInterval = (startInterval + 0.3).clamp(0.0, 1.0);
      
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      color: ThemeHelper.background,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Title with animation
          PageAnimations.animatedTitle(
            animation: _titleAnimation,
            child: Center(
              child: Text(
                localizations.whatIsYourGoal,
                style: ThemeHelper.title3.copyWith(
                  color: ThemeHelper.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle with icon with animation
          PageAnimations.animatedContent(
            animation: _subtitleAnimation,
            child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Target icon
              SizedBox(
                                 child: const Text('🎯', style: TextStyle(fontSize: 32),),

                
                 ),
              
              // const SizedBox(width: 8),
              // Subtitle text
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  
                  localizations.selectGoalThatSuitsYou,
                  style: ThemeHelper.caption1.copyWith(
                    fontSize: 13,
                    color: ThemeHelper.textSecondary,
                  ),
                ),
              ),
            ],
            ),
          ),
          
          const SizedBox(height: 80),
          
          // Goal selection options
          Column(
            children: [
              // Option 1: Lose Weight
              PageAnimations.animatedContent(
                animation: _optionAnimations[0],
                child: Obx(() {
                  final isSelected = _controller.getStringData('goal') == 'lose_weight';
                  return PageAnimations.animatedSelectionCard(
                    isSelected: isSelected,
                    onTap: () {
                      _controller.setStringData('goal', 'lose_weight');
                    },
                    selectedColor: ThemeHelper.textPrimary,
                    unselectedColor: ThemeHelper.cardBackground,
                    selectedBorderColor: ThemeHelper.textPrimary,
                    unselectedBorderColor: ThemeHelper.divider,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Image.asset(
                              'assets/icons/lose.png',
                              key: ValueKey(isSelected),
                              width: 24,
                              height: 24,
                              color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            style: ThemeHelper.headline.copyWith(
                              color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            child: Text(localizations.loseWeight),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),
              
              // Option 2: Maintain Weight
              PageAnimations.animatedContent(
                animation: _optionAnimations[1],
                child: Obx(() {
                  final isSelected = _controller.getStringData('goal') == 'maintain_weight';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: PageAnimations.animatedSelectionCard(
                      isSelected: isSelected,
                      onTap: () {
                        _controller.setStringData('goal', 'maintain_weight');
                      },
                      selectedColor: ThemeHelper.textPrimary,
                      unselectedColor: ThemeHelper.cardBackground,
                      selectedBorderColor: ThemeHelper.textPrimary,
                      unselectedBorderColor: ThemeHelper.divider,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Image.asset(
                                'assets/icons/maintain.png',
                                key: ValueKey(isSelected),
                                width: 24,
                                height: 24,
                                color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              style: ThemeHelper.headline.copyWith(
                                color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              child: Text(localizations.maintainWeight),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              
              // Option 3: Gain Weight
              PageAnimations.animatedContent(
                animation: _optionAnimations[2],
                child: Obx(() {
                  final isSelected = _controller.getStringData('goal') == 'gain_weight';
                  return PageAnimations.animatedSelectionCard(
                    isSelected: isSelected,
                    onTap: () {
                      _controller.setStringData('goal', 'gain_weight');
                    },
                    selectedColor: ThemeHelper.textPrimary,
                    unselectedColor: ThemeHelper.cardBackground,
                    selectedBorderColor: ThemeHelper.textPrimary,
                    unselectedBorderColor: ThemeHelper.divider,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Image.asset(
                              'assets/icons/gain.png',
                              key: ValueKey(isSelected),
                              width: 24,
                              height: 24,
                              color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            style: ThemeHelper.headline.copyWith(
                              color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            child: Text(localizations.gainWeight),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

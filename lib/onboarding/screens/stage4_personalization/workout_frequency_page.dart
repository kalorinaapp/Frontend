import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;
import '../../../utils/page_animations.dart';

class WorkoutFrequencyPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const WorkoutFrequencyPage({super.key, required this.themeProvider});

  @override
  State<WorkoutFrequencyPage> createState() => _WorkoutFrequencyPageState();
}

class _WorkoutFrequencyPageState extends State<WorkoutFrequencyPage> 
    with SingleTickerProviderStateMixin {
  late OnboardingController _controller;
  late AnimationController _animationController;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late List<Animation<double>> _optionAnimations;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _titleAnimation = PageAnimations.createTitleAnimation(_animationController);
    
    // Subtitle animation
    _subtitleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );
    
    // Staggered animations for workout options
    _optionAnimations = List.generate(4, (index) {
      final startInterval = 0.3 + (index * 0.1);
      final endInterval = (startInterval + 0.25).clamp(0.0, 1.0);
      
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
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
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
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
                localizations.howManyWorkoutsPerWeek,
                style: ThemeHelper.title1.copyWith(
                  color: ThemeHelper.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle with animation
          PageAnimations.animatedContent(
            animation: _subtitleAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeHelper.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  localizations.selectBestOption,
                  style: ThemeHelper.caption1.copyWith(
                    fontSize: 13,
                    color: ThemeHelper.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Workout frequency options
          Column(
            children: [
              // Option 1: 0 - Ne treniram
              PageAnimations.animatedContent(
                animation: _optionAnimations[0],
                child: Obx(() {
                  final isSelected = _controller.getStringData('workout_frequency') == '0';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: PageAnimations.animatedSelectionCard(
                      isSelected: isSelected,
                      onTap: () {
                        _controller.setStringData('workout_frequency', '0');
                        _controller.validatePage(_controller.currentPage.value);
                      },
                      selectedColor: ThemeHelper.textPrimary,
                      unselectedColor: ThemeHelper.cardBackground,
                      selectedBorderColor: ThemeHelper.textPrimary,
                      unselectedBorderColor: ThemeHelper.divider,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Image.asset(
                                  'assets/icons/warning.png',
                                  key: ValueKey(isSelected),
                                  width: 24,
                                  height: 24,
                                  color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  style: ThemeHelper.headline.copyWith(
                                    color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  child: const Text('0'),
                                ),
                                const SizedBox(height: 4),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  style: ThemeHelper.subhead.copyWith(
                                    color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                  ),
                                  child: Text(localizations.noWorkouts),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              
              // Option 2: 1-2 - Treninzi s vremena na vrijeme
              PageAnimations.animatedContent(
                animation: _optionAnimations[1],
                child: Obx(() {
                  final isSelected = _controller.getStringData('workout_frequency') == '1-2';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: PageAnimations.animatedSelectionCard(
                      isSelected: isSelected,
                      onTap: () {
                        _controller.setStringData('workout_frequency', '1-2');
                        _controller.validatePage(_controller.currentPage.value);
                      },
                      selectedColor: ThemeHelper.textPrimary,
                      unselectedColor: ThemeHelper.cardBackground,
                      selectedBorderColor: ThemeHelper.textPrimary,
                      unselectedBorderColor: ThemeHelper.divider,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Image.asset(
                                  'assets/icons/shoe.png',
                                  key: ValueKey(isSelected),
                                  width: 24,
                                  height: 24,
                                  color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    style: ThemeHelper.headline.copyWith(
                                      color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    child: const Text('1-2'),
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    style: ThemeHelper.subhead.copyWith(
                                      color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                    ),
                                    child: Text(localizations.occasionalWorkouts),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              
              // Option 3: 3-5 - Nekoliko treninga tjedno
              PageAnimations.animatedContent(
                animation: _optionAnimations[2],
                child: Obx(() {
                  final isSelected = _controller.getStringData('workout_frequency') == '3-5';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: PageAnimations.animatedSelectionCard(
                      isSelected: isSelected,
                      onTap: () {
                        _controller.setStringData('workout_frequency', '3-5');
                        _controller.validatePage(_controller.currentPage.value);
                      },
                      selectedColor: ThemeHelper.textPrimary,
                      unselectedColor: ThemeHelper.cardBackground,
                      selectedBorderColor: ThemeHelper.textPrimary,
                      unselectedBorderColor: ThemeHelper.divider,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Image.asset(
                                  'assets/icons/weights.png',
                                  key: ValueKey(isSelected),
                                  width: 24,
                                  height: 24,
                                  color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    style: ThemeHelper.headline.copyWith(
                                      color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    child: const Text('3-5'),
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    style: ThemeHelper.subhead.copyWith(
                                      color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                    ),
                                    child: Text(localizations.severalWorkoutsWeekly),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              
              // Option 4: 6-7 - Predani sportaš
              PageAnimations.animatedContent(
                animation: _optionAnimations[3],
                child: Obx(() {
                  final isSelected = _controller.getStringData('workout_frequency') == '6-7';
                  return PageAnimations.animatedSelectionCard(
                    isSelected: isSelected,
                    onTap: () {
                      _controller.setStringData('workout_frequency', '6-7');
                      _controller.validatePage(_controller.currentPage.value);
                    },
                    selectedColor: ThemeHelper.textPrimary,
                    unselectedColor: ThemeHelper.cardBackground,
                    selectedBorderColor: ThemeHelper.textPrimary,
                    unselectedBorderColor: ThemeHelper.divider,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Image.asset(
                                'assets/icons/apple.png',
                                key: ValueKey(isSelected),
                                width: 24,
                                height: 24,
                                color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                style: ThemeHelper.headline.copyWith(
                                  color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                child: const Text('6-7'),
                              ),
                              const SizedBox(height: 4),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                style: ThemeHelper.subhead.copyWith(
                                  color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                ),
                                child: Text(localizations.dedicatedAthlete),
                              ),
                            ],
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

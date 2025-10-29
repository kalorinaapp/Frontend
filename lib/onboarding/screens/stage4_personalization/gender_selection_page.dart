import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;
import '../../../utils/page_animations.dart';

class GenderSelectionPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const GenderSelectionPage({super.key, required this.themeProvider});

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> 
    with SingleTickerProviderStateMixin {
  late OnboardingController _controller;
  late AnimationController _animationController;
  late Animation<double> _titleAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    
    // Setup animations using global animations helper
    _animationController = AnimationController(
      vsync: this,
      duration: PageAnimations.standardDuration,
    );
    
    _titleAnimation = PageAnimations.createTitleAnimation(_animationController);
    _contentAnimation = PageAnimations.createContentAnimation(_animationController);
    
    // Start animations
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
    
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
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
                    localizations.selectYourGender,
                    style: ThemeHelper.textStyleWithColor(
                      ThemeHelper.title1,
                      ThemeHelper.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Informational message box with animation
              PageAnimations.animatedContent(
                animation: _contentAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeHelper.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '👉',
                        style: TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          localizations.genderSelectionInfo,
                          style: ThemeHelper.textStyleWithColor(
                            ThemeHelper.caption1.copyWith(fontSize: 13),
                            ThemeHelper.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          
              const SizedBox(height: 120),
              
              // Gender selection buttons with animation
              PageAnimations.animatedContent(
                animation: _contentAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Male button
                    Obx(() {
                      final isSelected = _controller.getStringData('selected_gender') == 'male';
                      return PageAnimations.animatedSelectionCard(
                        isSelected: isSelected,
                        onTap: () {
                          _controller.setStringData('selected_gender', 'male');
                        },
                        selectedColor: ThemeHelper.textPrimary,
                        unselectedColor: ThemeHelper.background,
                        selectedBorderColor: ThemeHelper.textPrimary,
                        unselectedBorderColor: ThemeHelper.divider,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              // Leading icon
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Image.asset(
                                    "assets/icons/male.png",
                                    key: ValueKey(isSelected),
                                    height: 24,
                                    width: 24,
                                    color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),

                              // Centered label
                              Expanded(
                                child: Center(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    style: ThemeHelper.textStyleWithColor(
                                      ThemeHelper.headline,
                                      isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                    ),
                                    child: Text(
                                      localizations.maleGender,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),

                              // Trailing spacer to balance the leading icon width
                              const SizedBox(width: 32),
                            ],
                          ),
                        ),
                      );
                    }),
                  
                  const SizedBox(height: 16),
                  
                  // Female button
                  Obx(() {
                    final isSelected = _controller.getStringData('selected_gender') == 'female';
                    return PageAnimations.animatedSelectionCard(
                      isSelected: isSelected,
                      onTap: () {
                        _controller.setStringData('selected_gender', 'female');
                      },
                      selectedColor: ThemeHelper.textPrimary,
                      unselectedColor: ThemeHelper.background,
                      selectedBorderColor: ThemeHelper.textPrimary,
                      unselectedBorderColor: ThemeHelper.divider,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            // Leading icon
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Image.asset(
                                  "assets/icons/female.png",
                                  key: ValueKey(isSelected),
                                  height: 24,
                                  width: 24,
                                  color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),

                            // Centered label
                            Expanded(
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  style: ThemeHelper.textStyleWithColor(
                                    ThemeHelper.headline,
                                    isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                                  ),
                                  child: Text(
                                    localizations.femaleGender,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),

                            // Trailing spacer to balance the leading icon width
                            const SizedBox(width: 32),
                          ],
                        ),
                      ),
                    );
                  }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

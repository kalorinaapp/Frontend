// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:get/get.dart';
import 'providers/theme_provider.dart';
import 'onboarding/controller/onboarding.controller.dart';

// Import onboarding pages
import 'onboarding/screens/stage1_problem_awareness/welcome_page.dart';
import 'onboarding/screens/stage1_problem_awareness/scan_meals_page.dart';
import 'onboarding/screens/stage4_personalization/gender_selection_page.dart';
import 'onboarding/screens/stage4_personalization/workout_frequency_page.dart';
import 'onboarding/screens/stage4_personalization/hear_about_us_page.dart';
import 'onboarding/screens/stage4_personalization/congratulations_page.dart';
import 'onboarding/screens/stage4_personalization/goal_selection_page.dart';
import 'onboarding/screens/stage4_personalization/dietary_preference_page.dart';
import 'onboarding/screens/stage4_personalization/personal_goals_page.dart';
import 'onboarding/screens/stage4_personalization/weight_transition_page.dart';
import 'onboarding/screens/stage4_personalization/support_page.dart';
import 'onboarding/screens/stage4_personalization/notification_permission_page.dart';

// Post-Onboarding Screens
import 'onboarding/screens/post_onboarding/create_account_page.dart';

class OnboardingScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const OnboardingScreen({super.key, required this.themeProvider});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late OnboardingController _controller;

  // Add your custom pages here
  late List<Widget> _pages;

  void _handlePageLogic(int page) {
    // Add any special logic for specific pages here
    _controller.showNavigation.value = true;
  }

  @override
  void initState() {
    super.initState();

    // Initialize onboarding pages
    _pages = [
      WelcomePage(themeProvider: widget.themeProvider),
      ScanMealsPage(themeProvider: widget.themeProvider),
      GenderSelectionPage(themeProvider: widget.themeProvider),
      WorkoutFrequencyPage(themeProvider: widget.themeProvider),
      HearAboutUsPage(themeProvider: widget.themeProvider),
      CongratulationsPage(themeProvider: widget.themeProvider),
      GoalSelectionPage(themeProvider: widget.themeProvider),
      DietaryPreferencePage(themeProvider: widget.themeProvider),
      PersonalGoalsPage(themeProvider: widget.themeProvider),
      WeightTransitionPage(themeProvider: widget.themeProvider),
      SupportPage(themeProvider: widget.themeProvider),
      NotificationPermissionPage(themeProvider: widget.themeProvider),
      // Add more pages here as you create them
    ];

    // Initialize the controller and set total pages
    _controller = Get.put(OnboardingController());
    _controller.setTotalPages(_pages.length);

    // Register page validations
    _controller.registerPageValidation(
      2, // Gender selection page (index 2)
      PageValidationConfig(
        dataKey: 'selected_gender',
        validationType: ValidationType.singleChoice,
      ),
    );
    
    _controller.registerPageValidation(
      3, // Workout frequency page (index 3)
      PageValidationConfig(
        dataKey: 'workout_frequency',
        validationType: ValidationType.singleChoice,
      ),
    );
    
    _controller.registerPageValidation(
      4, // Hear about us page (index 4)
      PageValidationConfig(
        dataKey: 'hear_about_us',
        validationType: ValidationType.singleChoice,
      ),
    );
    
    _controller.registerPageValidation(
      6, // Goal selection page (index 6)
      PageValidationConfig(
        dataKey: 'goal',
        validationType: ValidationType.singleChoice,
      ),
    );
    
    _controller.registerPageValidation(
      7, // Dietary preference page (index 7)
      PageValidationConfig(
        dataKey: 'dietary_preference',
        validationType: ValidationType.singleChoice,
      ),
    );
    
    _controller.registerPageValidation(
      8, // Personal goals page (index 8)
      PageValidationConfig(
        dataKey: 'personal_goal',
        validationType: ValidationType.singleChoice,
      ),
    );

    // _controller.registerPageValidation(
    //   5, // Congratulations page (index 5)
    //   PageValidationConfig(
    //     dataKey: 'congratulations',
    //     validationType: ValidationType.singleChoice,
    //   ),
    // );

    // Initialize AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Listen to controller page changes and sync with PageController
    _controller.currentPage.listen((page) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      _handlePageLogic(page);
    });

    // Also call for initial page
    _handlePageLogic(0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (!_controller.isLastPage) {
      _controller.goToNextPage();
    } else {
      // Navigate to main app
      _startApp();
    }
  }

  void _previousPage() {
    if (_controller.currentPage.value > 0) {
      _controller.goToPreviousPage();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _startApp() {
    // Navigate to post-onboarding flow starting with CreateAccountPage
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => CreateAccountPage(themeProvider: widget.themeProvider),
      ),
    );
  }

  void _onPageChanged(int page) {
    _controller.currentPage.value = page;
    _controller.validatePage(page);
    _handlePageLogic(page);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: _controller.currentPage.value == 5 || _controller.currentPage.value == 9
                                ? null
                                : Colors.white,
          navigationBar: null,
          child: Column(
            children: [
                             Obx(() => Container(
                 decoration: BoxDecoration(
                   gradient: _controller.currentPage.value == 5 || _controller.currentPage.value == 9
                       ? const LinearGradient(
                          //  begin: Alignment.topCenter,
                          //  end: Alignment.bottomCenter,
                           colors: [
                             Color(0xFFFFF5F5), // Light pink at top
                             Color(0xFFFFE8E8), // Slightly deeper pink at bottom
                           ],
                         )
                       : null,
                   color: _controller.currentPage.value == 5 || _controller.currentPage.value == 9
                       ? null
                       : Colors.white,
                 ),
                 height: 60,
               )),
              // Custom navigation with back button and progress bar
              Obx(
                () => _controller.showNavigation.value
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: _controller.currentPage.value == 5 || _controller.currentPage.value == 9
                              ? const LinearGradient(
                                  // begin: Alignment.topCenter,
                                  // end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFFF5F5), // Light pink at top
                                    Color(0xFFFFE8E8), // Slightly deeper pink at bottom
                                  ],
                                )
                              : null,
                          color: _controller.currentPage.value == 5 || _controller.currentPage.value == 9
                              ? null
                              : Colors.white,
                          border: null,
                        ),
                        child: Row(
                          children: [
                            // Back button
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                _previousPage();
                              },
                              child: SvgPicture.asset(
                                'assets/icons/back.svg',
                                width: 20,
                                height: 20,
                              ),
                            ),
                              
                            const SizedBox(width: 16),
                              
                            // Progress bar
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: _controller.currentPage.value == 5 || _controller.currentPage.value == 9
                                      ? const LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Color(0xFFFFF5F5), // Light pink
                                            Color(0xFFFFE8E8), // Slightly deeper pink
                                          ],
                                        )
                                      : null,
                                  color: _controller.currentPage.value == 5 || _controller.currentPage.value == 9
                                      ? null
                                      : CupertinoColors.systemGrey3,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Stack(
                                      children: [
                                        Obx(
                                          () => AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                            width: constraints.maxWidth *
                                                _controller.progressPercentage,
                                            height: 6,
                                            decoration: BoxDecoration(
                                             color: CupertinoColors.black,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                              
                            const SizedBox(width: 16),
                              
                            // Theme switch button
                            // GestureDetector(
                            //   onTap: () {
                            //     HapticFeedback.mediumImpact();
                            //     if (ThemeHelper.isLightMode) {
                            //       widget.themeProvider.setDarkTheme();
                            //     } else {
                            //       widget.themeProvider.setLightTheme();
                            //     }
                            //   },
                            //   child: Container(
                            //     height: 40,
                            //     width: 40,
                            //     decoration: BoxDecoration(
                            //       color: CupertinoColors.systemGrey6,
                            //       shape: BoxShape.circle,
                            //       border: Border.all(
                            //         color: CupertinoColors.systemGrey4,
                            //         width: 1,
                            //       ),
                            //     ),
                            //     child: Icon(
                            //       ThemeHelper.isLightMode
                            //           ? CupertinoIcons.moon
                            //           : CupertinoIcons.sun_max,
                            //       size: 20,
                            //       color: CupertinoColors.black,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
          
              // PageView content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: _onPageChanged,
                  children: _pages,
                ),
              ),
          
              // Bottom button
              Obx(
                () => _controller.showNavigation.value
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 16,
                          right: 16,
                          left: 16,
                          bottom: 36,
                        ),
                                                 decoration: BoxDecoration(
                           gradient: _controller.currentPage.value == 5 || _controller.currentPage.value == 9
                               ? const LinearGradient(
                                   begin: Alignment.topCenter,
                                   end: Alignment.bottomCenter,
                                   colors: [
                                     Color(0xFFFFF5F5), // Light pink at top
                                     Color(0xFFFFE8E8), // Slightly deeper pink at bottom
                                   ],
                                 )
                               : null,
                           color: _controller.currentPage.value == 5 || _controller.currentPage.value == 9
                               ? null
                               : Colors.white,
                           border: Border(
                             top: BorderSide(
                               color: _controller.currentPage.value == 5 || _controller.currentPage.value == 9
                                   ? Colors.transparent
                                   : CupertinoColors.systemGrey3,
                               width: 1.0,
                             ),
                           ),
                         ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Obx(
                                () => Container(
                                  decoration: BoxDecoration(
                                    gradient: _controller.isNextButtonEnabled.value
                                        ? const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0xFFFF6A00), // FF6A00 at 15%
                                              Color(0xFFEE0979), // EE0979 at 100%
                                            ],
                                            stops: [0.15, 1.0],
                                          )
                                        : null,
                                    color: _controller.isNextButtonEnabled.value
                                        ? null
                                        : CupertinoColors.systemGrey3,
                                    borderRadius: BorderRadius.circular(1000),
                                  ),
                                  child: CupertinoButton(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    color: null,
                                    borderRadius: BorderRadius.circular(1000),
                                    onPressed: _controller.isNextButtonEnabled.value
                                        ? () {
                                            HapticFeedback.mediumImpact();
                                            _nextPage();
                                          }
                                        : null,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Obx(
                                          () => Text(
                                            // _controller.isLastPage
                                            //     ? 'Get Started'
                                            //     : 'Nastavi',
                                            'Nastavi',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: _controller.isNextButtonEnabled.value
                                                  ? CupertinoColors.white
                                                  : CupertinoColors.systemGrey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}

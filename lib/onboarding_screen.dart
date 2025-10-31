// ignore_for_file: deprecated_member_use
import 'package:calorie_ai_app/authentication/create.account.dart';
import 'package:calorie_ai_app/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:get/get.dart';
import 'onboarding/pages/calorie_tracking_experience_page.dart' show CalorieTrackingExperiencePage;
import 'onboarding/pages/gif.onboarding.dart' show GIFScreen;
import 'onboarding/pages/how_it_works_page.dart' show HowItWorksPage;
import 'onboarding/screens/stage4_personalization/birth_date_page.dart' show BirthDatePage;
import 'onboarding/screens/stage4_personalization/consistency_health_page.dart' show ConsistencyHealthPage;
import 'onboarding/screens/stage4_personalization/desired_weight_page.dart' show DesiredWeightPage;
import 'onboarding/screens/stage4_personalization/progress_motivation_page.dart' show ProgressMotivationPage;
import 'onboarding/screens/stage4_personalization/support_motivation_page.dart' show SupportMotivationPage;
import 'onboarding/screens/stage4_personalization/calorie_counting_page.dart' show CalorieCountingPage;
import 'onboarding/screens/stage4_personalization/calorie_transfer_page.dart' show CalorieTransferPage;
import 'onboarding/screens/stage4_personalization/weight_loss_motivation_page.dart' show WeightLossMotivationPage;
import 'onboarding/screens/stage4_personalization/weight_loss_speed_page.dart' show WeightLossSpeedPage;
import 'onboarding/screens/stage4_personalization/goal_generation_page.dart' show GoalGenerationPage;
import 'onboarding/screens/stage4_personalization/height_weight_page.dart' show HeightWeightPage;
import 'onboarding/screens/stage4_personalization/rating.dart' show RatingPage;
import 'onboarding/screens/stage4_personalization/referral.page.dart' show ReferralPage;
import 'onboarding/screens/stage4_personalization/all_done_page.dart' show AllDonePage;
import 'providers/theme_provider.dart';
import 'onboarding/controller/onboarding.controller.dart';
// Import onboarding pages
import 'onboarding/screens/stage4_personalization/gender_selection_page.dart';
import 'onboarding/screens/stage4_personalization/workout_frequency_page.dart';
import 'onboarding/screens/stage4_personalization/hear_about_us_page.dart';
import 'onboarding/screens/stage4_personalization/congratulations_page.dart';
import 'onboarding/screens/stage4_personalization/goal_selection_page.dart';
import 'onboarding/screens/stage4_personalization/dietary_preference_page.dart';
import 'onboarding/screens/stage4_personalization/personal_goals_page.dart';
import 'onboarding/screens/stage4_personalization/notification_permission_page.dart';
import 'utils/theme_helper.dart' show ThemeHelper;

class OnboardingScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const OnboardingScreen({super.key, required this.themeProvider});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late OnboardingController _controller;

  // Add your custom pages here
  late List<Widget> _pages;

  void _handlePageLogic(int page) {
    // Add any special logic for specific pages here
    
    // Hide navigation for goal generation page
    if (page == 24) { // GoalGenerationPage index
      _controller.showNavigation.value = false;
    } else {
      _controller.showNavigation.value = true;
    }
    
    // Enable dual button mode only for calorie counting page
    if (page == 20) { // CalorieCountingPage index
      _controller.setDualButtonMode(true);
    } else {
      _controller.setDualButtonMode(false);
    }
    
    // Ensure first page (CreateAccountPage) always has button enabled
    if (page == 0) {
      _controller.isNextButtonEnabled.value = true;
    }
  }

        // final InAppReview inAppReview = InAppReview.instance;



  @override
  void initState() {
    super.initState();

    // Initialize the controller first to get current page
    _controller = Get.find<OnboardingController>();
    
    // Initialize onboarding pages
    _pages = [
      CreateAccountPage(themeProvider: widget.themeProvider, isLogin: true),
      CalorieTrackingExperiencePage(themeProvider: widget.themeProvider),
      HowItWorksPage(themeProvider: widget.themeProvider),
      GIFScreen(themeProvider: widget.themeProvider,),
      GenderSelectionPage(themeProvider: widget.themeProvider),
      WorkoutFrequencyPage(themeProvider: widget.themeProvider),
      // ScanMealsPage(themeProvider: widget.themeProvider),
      
      
      HearAboutUsPage(themeProvider: widget.themeProvider),
      CongratulationsPage(themeProvider: widget.themeProvider),
      HeightWeightPage(themeProvider: widget.themeProvider),
      BirthDatePage(themeProvider: widget.themeProvider),
      GoalSelectionPage(themeProvider: widget.themeProvider),
      DesiredWeightPage(themeProvider: widget.themeProvider),
      WeightLossMotivationPage(themeProvider: widget.themeProvider),
      WeightLossSpeedPage(themeProvider: widget.themeProvider),
      DietaryPreferencePage(themeProvider: widget.themeProvider),
      PersonalGoalsPage(themeProvider: widget.themeProvider),
      ProgressMotivationPage(themeProvider: widget.themeProvider),
      SupportMotivationPage(themeProvider: widget.themeProvider),
      NotificationPermissionPage(themeProvider: widget.themeProvider),
      CalorieCountingPage(themeProvider: widget.themeProvider),
      CalorieTransferPage(themeProvider: widget.themeProvider),

      ConsistencyHealthPage(themeProvider: widget.themeProvider),

      RatingPage(themeProvider: widget.themeProvider),

      ReferralPage(themeProvider: widget.themeProvider, userName: '',),

      GoalGenerationPage(themeProvider: widget.themeProvider, userName: '',),
      
      AllDonePage(themeProvider: widget.themeProvider),
      
      // WeightTransitionPage(themeProvider: widget.themeProvider),
      // HealthConsistencyScreen(themeProvider: widget.themeProvider),
      // SupportPage(themeProvider: widget.themeProvider),
      // CalorieAdjustmentPage(themeProvider: widget.themeProvider),
      // ExtraCaloriesPage(themeProvider: widget.themeProvider),
     
      // Add more pages here as you create them
      // ExtraCaloriesPage(themeProvider: widget.themeProvider),
      // RatingPage(themeProvider: widget.themeProvider,),

      
      
      //ConsistencyHealthPage(themeProvider: widget.themeProvider),
    ];

    // Set total pages
    _controller.setTotalPages(_pages.length);
    
    // Sync PageController to current page after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_controller.currentPage.value);
      }
    });

    // Register page validations
    _controller.registerPageValidation(
      1, // Calorie tracking experience page
      PageValidationConfig(
        dataKey: 'calorie_tracking_experience',
        validationType: ValidationType.singleChoice,
      ),
    );
    
    _controller.registerPageValidation(
      4, // Gender selection page (index 2)
      PageValidationConfig(
        dataKey: 'selected_gender',
        validationType: ValidationType.singleChoice,
      ),
    );
    
    _controller.registerPageValidation(
      5, // Workout frequency page (index 3)
      PageValidationConfig(
        dataKey: 'workout_frequency',
        validationType: ValidationType.singleChoice,
      ),
    );

    _controller.registerPageValidation(
      6, // Hear about us page index fixed
      PageValidationConfig(
        dataKey: 'hear_about_us',
        validationType: ValidationType.singleChoice,
      ),
    );

    // Height/Weight page validation (index depends on _pages order). Here: HeightWeightPage at index 8.
    _controller.registerPageValidation(
      8,
      PageValidationConfig(
        dataKey: 'height',
        validationType: ValidationType.numberInput,
      ),
    );
    _controller.registerPageValidation(
      8,
      PageValidationConfig(
        dataKey: 'weight',
        validationType: ValidationType.numberInput,
      ),
    );
    
    _controller.registerPageValidation(
      9, // Birth date page (index 7)
      PageValidationConfig(
        dataKey: 'birth_date',
        validationType: ValidationType.dateInput,
      ),
    );
    
    _controller.registerPageValidation(
      10, // Goal selection page (index 8)
      PageValidationConfig(
        dataKey: 'goal',
        validationType: ValidationType.singleChoice,
      ),
    );
    
    _controller.registerPageValidation(
      14, // Dietary preference page (index 9)
      PageValidationConfig(
        dataKey: 'dietary_preference',
        validationType: ValidationType.singleChoice,
      ),
    );
    
    _controller.registerPageValidation(
      15, // Personal goals page (index 10)
      PageValidationConfig(
        dataKey: 'personal_goal',
        validationType: ValidationType.singleChoice,
      ),
    );
    
    // _controller.registerPageValidation(
    //   13, // Calorie adjustment page (index 13)
    //   PageValidationConfig(
    //     dataKey: 'calorie_adjustment_choice',
    //     validationType: ValidationType.singleChoice,
    //   ),
    // );

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

    //   WidgetsBinding.instance.addPostFrameCallback((_) async {
    //    if (await inAppReview.isAvailable()) {
    //     inAppReview.requestReview();
    //   }
    // });

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
      final String? goal = _controller.getStringData('goal');
      final int currentPage = _controller.currentPage.value;
      
      // If on goal selection page (10) and user selected "maintain_weight", skip to page 14
      if (currentPage == 10 && goal == 'maintain_weight') {
        // Directly jump to page 14, bypassing pages 11, 12, and 13
        if (_pageController.hasClients) {
          _pageController.jumpToPage(14);
        }
        _controller.currentPage.value = 14;
        _controller.validatePage(14);
        _handlePageLogic(14);
      } else {
        _controller.goToNextPage();
      }
    } else {
      // Navigate to main app
      _startApp();
    }
  }


  void _previousPage() {
    if (_controller.currentPage.value > 0) {
      final int currentPage = _controller.currentPage.value;
      final String? goal = _controller.getStringData('goal');
      
      // If on dietary preference page (14) and came from goal selection (maintain_weight), go back to page 10
      if (currentPage == 14 && goal == 'maintain_weight') {
        // Jump back to page 10, bypassing pages 13, 12, and 11
        if (_pageController.hasClients) {
          _pageController.jumpToPage(10);
        }
        _controller.currentPage.value = 10;
        _controller.validatePage(10);
        _handlePageLogic(10);
      } else {
        _controller.goToPreviousPage();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  void _startApp() {
    // Navigate to post-onboarding flow starting with CreateAccountPage
    // Navigator.of(context).push(
    //   CupertinoPageRoute(
    //     builder: (context) => ExclusiveOfferPage(themeProvider: widget.themeProvider,),
    //   ),
    // );
     Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => CreateAccountPage(themeProvider: widget.themeProvider,),
      ),
    );
  }

  void _onPageChanged(int page) {
    _controller.currentPage.value = page;
    _controller.validatePage(page);
    _handlePageLogic(page);
  }

  Widget _buildSingleButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Obx(
            () => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1000),
              ),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                color: ThemeHelper.textPrimary,
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
                        AppLocalizations.of(context)!.continue_,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _controller.isNextButtonEnabled.value
                              ? ThemeHelper.background
                              : ThemeHelper.textSecondary,
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
    );
  }

  Widget _buildDualButtons() {
    return Column(
      children: [
        Row(
          children: [
            // No button
            Expanded(
              child: CupertinoButton(
                sizeStyle: CupertinoButtonSize.small,
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: ThemeHelper.cardBackground,
                borderRadius: BorderRadius.circular(12),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _controller.setDualButtonChoice('no');
                  
                  // Set specific data based on current page
                  if (_controller.currentPage.value == 20) { // CalorieCountingPage
                    _controller.setBoolData('count_burned_calories', false);
                  }
                  
                  _nextPage();
                },
                child: Text(
                  AppLocalizations.of(context)!.no,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Yes button
            Expanded(
              child: CupertinoButton(
                sizeStyle: CupertinoButtonSize.small,
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: ThemeHelper.textPrimary,
                borderRadius: BorderRadius.circular(12),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _controller.setDualButtonChoice('yes');
                  
                  // Set specific data based on current page
                  if (_controller.currentPage.value == 20) { // CalorieCountingPage
                    _controller.setBoolData('count_burned_calories', true);
                  }
                  
                  _nextPage();
                },
                child: Text(
                  AppLocalizations.of(context)!.yes,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.background,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor:  ThemeHelper.background,
          navigationBar: null,
          child: Column(
            children: [
                             Obx(() => Container(
                 decoration: BoxDecoration(
                   color: _controller.currentPage.value == 5 || _controller.currentPage.value == 10
                       ? null
                       : ThemeHelper.background,
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
                          color:  ThemeHelper.background,
                          border: null,
                        ),
                        child: Row(
                          children: [
                            // Back button (hidden on first page)
                            _controller.currentPage.value > 0
                                ? GestureDetector(
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      _previousPage();
                                    },
                                    child: SvgPicture.asset(
                                      color: ThemeHelper.textPrimary,
                                      'assets/icons/back.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                  )
                                : const SizedBox(width: 20, height: 20),
                              
                            const SizedBox(width: 16),
                              
                            // Progress bar
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color:  ThemeHelper.divider,
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
                                             color: ThemeHelper.textPrimary,
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
                              
                         //   Theme switch button
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                if (ThemeHelper.isLightMode) {
                                  widget.themeProvider.setDarkTheme();
                                } else {
                                  widget.themeProvider.setLightTheme();
                                }
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: ThemeHelper.cardBackground,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ThemeHelper.divider,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  ThemeHelper.isLightMode
                                      ? CupertinoIcons.moon
                                      : CupertinoIcons.sun_max,
                                  size: 20,
                                  color: ThemeHelper.textPrimary,
                                ),
                              ),
                            ),
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
                           
                           color:  ThemeHelper.background,
                           border: Border(
                             top: BorderSide(
                               color: ThemeHelper.divider,
                               width: 1.0,
                             ),
                           ),
                         ),
                        child: Obx(
                          () => _controller.isDualButtonMode.value
                              ? _buildDualButtons()
                              : _buildSingleButton(),
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

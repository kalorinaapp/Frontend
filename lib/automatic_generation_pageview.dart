// ignore_for_file: deprecated_member_use
import 'package:calorie_ai_app/authentication/create.account.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:get/get.dart';
import 'onboarding/screens/stage4_personalization/desired_weight_page.dart' show DesiredWeightPage;
import 'onboarding/screens/stage4_personalization/goal_selection_page.dart' show GoalSelectionPage;
import 'onboarding/screens/stage4_personalization/height_weight_page.dart' show HeightWeightPage;
import 'onboarding/screens/stage4_personalization/weight_loss_speed_page.dart' show WeightLossSpeedPage;
import 'providers/theme_provider.dart';
import 'onboarding/controller/onboarding.controller.dart';
// Import onboarding pages
import 'onboarding/screens/stage4_personalization/workout_frequency_page.dart';
import 'utils/theme_helper.dart' show ThemeHelper;

class AutomaticGenerationPageview extends StatefulWidget {
  final ThemeProvider themeProvider;

  const AutomaticGenerationPageview({super.key, required this.themeProvider});

  @override
  State<AutomaticGenerationPageview> createState() => _AutomaticGenerationPageviewState();
}

class _AutomaticGenerationPageviewState extends State<AutomaticGenerationPageview>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late OnboardingController _controller;

  // Add your custom pages here
  late List<Widget> _pages;

  void _handlePageLogic(int page) {
    // Add any special logic for specific pages here
    _controller.showNavigation.value = true;
    
    // Enable dual button mode only for calorie counting page
    if (page == 20) { // CalorieCountingPage index
      _controller.setDualButtonMode(true);
    } else {
      _controller.setDualButtonMode(false);
    }
  }

        // final InAppReview inAppReview = InAppReview.instance;



  @override
  void initState() {
    super.initState();

    // Initialize onboarding pages
    _pages = [
      WorkoutFrequencyPage(themeProvider: widget.themeProvider),
      HeightWeightPage(themeProvider: widget.themeProvider),
      GoalSelectionPage(themeProvider: widget.themeProvider),
      DesiredWeightPage(themeProvider: widget.themeProvider),
      WeightLossSpeedPage(themeProvider: widget.themeProvider),
      
    ];

    // Initialize the controller and set total pages
    _controller = Get.put(OnboardingController());
    _controller.setTotalPages(_pages.length);

    // Register page validations
    _controller.registerPageValidation(
      0, // Gender selection page (index 2)
      PageValidationConfig(
        dataKey: 'workout_frequency',
        validationType: ValidationType.singleChoice,
      ),
    );
    

    _controller.registerPageValidation(
      2, // Hear about us page index fixed
      PageValidationConfig(
        dataKey: 'goal',
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
      // // Check if we should skip weight loss related pages
      // if (_shouldSkipWeightLossPages()) {
      //   _controller.goToNextPage();
      //   // Skip weight loss motivation page if not losing weight
      //   if (_controller.currentPage.value == 11 && _controller.getStringData('goal') != 'lose_weight') {
      //     _controller.goToNextPage();
      //   }
      //   // Skip weight loss speed page if not losing weight
      //   if (_controller.currentPage.value == 12 && _controller.getStringData('goal') != 'lose_weight') {
      //     _controller.goToNextPage();
      //   }
      // } else {
      //   _controller.goToNextPage();
      // }
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
                        _controller.currentPage.value == _pages.length  ? 'Generiraj Svoj Plan' : 'Nastavi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _controller.isNextButtonEnabled.value
                              ? CupertinoColors.white
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
                color: CupertinoColors.black,
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
                child: const Text(
                  'No',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
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
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
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
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: _controller.currentPage.value == 5 || _controller.currentPage.value == 10
                                ? null
                                : ThemeHelper.background,
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
                          color: _controller.currentPage.value == 5 || _controller.currentPage.value == 10
                              ? null
                              : ThemeHelper.background,
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
                                color: ThemeHelper.textPrimary,
                                'assets/icons/back.svg',
                                width: 20,
                                height: 20,
                              ),
                            ),
                              
                            const SizedBox(width: 16),
                           
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
                               color: _controller.currentPage.value == 5 || _controller.currentPage.value == 10
                                   ? Colors.transparent
                                   : ThemeHelper.divider,
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

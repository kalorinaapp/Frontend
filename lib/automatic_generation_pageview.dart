// ignore_for_file: deprecated_member_use
import 'package:calorie_ai_app/authentication/create.account.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:get/get.dart';
import 'authentication/user.controller.dart';
import 'constants/app_constants.dart';
import 'providers/language_provider.dart';
import 'services/progress_service.dart';
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
  bool _isSubmitting = false;

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

  void _nextPage() async {
    if (!_controller.isLastPage) {
      debugPrint('========== Moving from Page ${_controller.currentPage.value} ==========');
      debugPrint('Current Page Data: ${_controller.getAllData()}');
      debugPrint('==========================================');
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
      await _startApp();
    }
  }


  void _previousPage() {
    if (_controller.currentPage.value > 0) {
      _controller.goToPreviousPage();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _startApp() async {
    // Set loading state
    setState(() {
      _isSubmitting = true;
    });
    
    // Get all collected data
    final allData = _controller.getAllData();
    
    debugPrint('========== Submitting Onboarding Data ==========');
    debugPrint('All Data: $allData');
    debugPrint('==========================================');
    
    // Prepare data for API - map onboarding fields to user model
    final Map<String, dynamic> userData = {};
    
    // Workout frequency -> workoutsPerWeek and activityLevel
    if (allData['workout_frequency'] != null) {
      final workoutFreq = allData['workout_frequency'];
      switch (workoutFreq) {
        case 'sedentary':
          userData['workoutsPerWeek'] = 0;
          userData['activityLevel'] = 'sedentary';
          break;
        case 'light':
          userData['workoutsPerWeek'] = 2;
          userData['activityLevel'] = 'lightly_active';
          break;
        case 'moderate':
          userData['workoutsPerWeek'] = 4;
          userData['activityLevel'] = 'moderately_active';
          break;
        case 'active':
          userData['workoutsPerWeek'] = 6;
          userData['activityLevel'] = 'very_active';
          break;
        case 'very_active':
          userData['workoutsPerWeek'] = 7;
          userData['activityLevel'] = 'extremely_active';
          break;
      }
    }
    
    // Height and weight
    if (allData['height'] != null) {
      final height = allData['height'] as num;
      final isMetric = allData['is_metric'] as bool? ?? true;
      
      // Convert height to cm based on the unit system used
      int heightInCm;
      if (isMetric) {
        // Height is already in cm
        heightInCm = height.round();
      } else {
        // Height is in inches, convert to cm
        heightInCm = (height * 2.54).round();
      }
      
      userData['height'] = heightInCm;
      debugPrint('Height: $height ${isMetric ? 'cm' : 'inches'} -> $heightInCm cm');
    }
    if (allData['weight'] != null) {
      final weight = allData['weight'] as num;
      final isMetric = allData['is_metric'] as bool? ?? true;
      
      // Convert weight to kg based on the unit system used
      int weightInKg;
      if (isMetric) {
        // Weight is already in kg
        weightInKg = weight.round();
      } else {
        // Weight is in lbs, convert to kg
        weightInKg = (weight / 2.20462).round();
      }
      
      userData['weight'] = weightInKg;
      debugPrint('Weight: $weight ${isMetric ? 'kg' : 'lbs'} -> $weightInKg kg');
    }
    
    // Set units based on user's preference (but always send height/weight in metric)
    final isMetric = allData['is_metric'] as bool? ?? true;
    userData['units'] = isMetric ? 'metric' : 'imperial';
    userData['isImperial'] = !isMetric;
    
    // Goal -> fitnessGoals
    if (allData['goal'] != null) {
      final goal = allData['goal'];
      switch (goal) {
        case 'lose_weight':
          userData['fitnessGoals'] = 'weight_loss';
          break;
        case 'gain_weight':
          userData['fitnessGoals'] = 'weight_gain';
          break;
        case 'maintain_weight':
          userData['fitnessGoals'] = 'maintenance';
          break;
        case 'build_muscle':
          userData['fitnessGoals'] = 'muscle_gain';
          break;
      }
    }
    
    // Desired weight -> targetWeight and weightGoal
    if (allData['desired_weight'] != null) {
      final targetWeight = (allData['desired_weight'] as num).round();
      // Ensure target weight is within valid range (20-500 kg)
      if (targetWeight >= 20 && targetWeight <= 500) {
        userData['targetWeight'] = targetWeight;
        userData['weightGoal'] = targetWeight;
        debugPrint('Target Weight: $targetWeight kg');
      } else {
        debugPrint('Target weight $targetWeight is out of range (20-500 kg)');
      }
    }
    
    // Weight loss speed -> weeklyGoal and speedToGoal
    if (allData['weight_loss_speed'] != null) {
      final speed = allData['weight_loss_speed'] as double;
      // Ensure weekly goal is within valid range (-2 to 2 kg/week)
      if (speed >= -2 && speed <= 2) {
        userData['weeklyGoal'] = speed;
        debugPrint('Weekly Goal: $speed kg/week');
        
        // Map speed to speedToGoal
        if (speed <= 0.3) {
          userData['speedToGoal'] = 'slow';
        } else if (speed <= 0.9) {
          userData['speedToGoal'] = 'moderate';
        } else {
          userData['speedToGoal'] = 'fast';
        }
      } else {
        debugPrint('Weekly goal $speed is out of range (-2 to 2 kg/week)');
      }
    }
    
    debugPrint('========== Mapped User Data for API ==========');
    debugPrint('User Data: $userData');
    debugPrint('==========================================');
    
    // Update user via API if user is logged in
    if (AppConstants.userId.isNotEmpty) {
      try {
        final userController = Get.find<UserController>();
        final languageProvider = Get.find<LanguageProvider>();
        final progressService = Get.find<ProgressService>();
        
        // Get current date for progress fetch
        final now = DateTime.now();
        final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        
        // First update user, then fetch progress sequentially
        final updateSuccess = await userController.updateUser(
          AppConstants.userId,
          userData,
          context,
          widget.themeProvider,
          languageProvider,
        );
        
        if (updateSuccess) {
          // Only fetch progress after user update succeeds
          await progressService.fetchDailyProgress(dateYYYYMMDD: dateStr);
        }
        
        if (updateSuccess) {
          debugPrint('========== User Updated Successfully ==========');
          debugPrint('========== Daily Progress Fetched ==========');
          
          // Close the pageview and return to set goals screen
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });
            Navigator.of(context).pop();
          }
        } else {
          debugPrint('========== User Update Failed ==========');
          debugPrint('Error: ${userController.errorMessage.value}');
          
          // Still close the pageview even if update failed
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        debugPrint('========== Error Updating User ==========');
        debugPrint('Error: $e');
        
        // Close the pageview even if there was an error
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          Navigator.of(context).pop();
        }
      }
    } else {
      // If not logged in, navigate to CreateAccountPage
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => CreateAccountPage(themeProvider: widget.themeProvider,),
        ),
      );
    }
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
                // Add subtle background for disabled state
                color: !_controller.isNextButtonEnabled.value 
                    ? ThemeHelper.cardBackground 
                    : null,
              ),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                // Use theme-aware color for active state, transparent for disabled
                color: _controller.isNextButtonEnabled.value 
                    ? ThemeHelper.textPrimary 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(1000),
                onPressed: (_controller.isNextButtonEnabled.value && !_isSubmitting)
                    ? () {
                        HapticFeedback.mediumImpact();
                        _nextPage();
                      }
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSubmitting)
                      CupertinoActivityIndicator(
                        color: ThemeHelper.background,
                      )
                    else
                      Obx(
                        () => Text(
                          _controller.currentPage.value == _pages.length || (_controller.getStringData('goal') != 'maintain_weight')  ? 'Generiraj Svoj Plan' : 'Nastavi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            // Active: background color, Inactive: secondary text color
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
                  'No',
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
                  'Yes',
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

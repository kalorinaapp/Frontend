// ignore_for_file: deprecated_member_use
import 'package:calorie_ai_app/authentication/create.account.dart';
import 'package:calorie_ai_app/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:get/get.dart';
import 'onboarding/pages/calorie_tracking_experience_page.dart' show CalorieTrackingExperiencePage;
// import 'onboarding/pages/gif.onboarding.dart' show GIFScreen;
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
import 'providers/language_provider.dart';
import 'onboarding/controller/onboarding.controller.dart';
import 'screens/home_screen.dart';
import 'constants/app_constants.dart';
import 'authentication/user.controller.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'utils/user.prefs.dart' show UserPrefs;

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
  bool _isLoadingProgress = false; // Flag to prevent saving during initial load

  // Build onboarding pages (rebuilt on theme changes)
  List<Widget> _buildPages() {
    return [
      CreateAccountPage(
        key: const ValueKey('create_account'),
        themeProvider: widget.themeProvider,
        isAfterOnboardingCompletion: false, // First page of onboarding
      ),
      CalorieTrackingExperiencePage(
        key: const ValueKey('calorie_tracking_experience'),
        themeProvider: widget.themeProvider,
      ),
      HowItWorksPage(
        key: const ValueKey('how_it_works'),
        themeProvider: widget.themeProvider,
      ),
      // GIFScreen(themeProvider: widget.themeProvider,),
      GenderSelectionPage(
        key: const ValueKey('gender_selection'),
        themeProvider: widget.themeProvider,
      ),
      WorkoutFrequencyPage(
        key: const ValueKey('workout_frequency'),
        themeProvider: widget.themeProvider,
      ),
      // ScanMealsPage(themeProvider: widget.themeProvider),
      HearAboutUsPage(
        key: const ValueKey('hear_about_us'),
        themeProvider: widget.themeProvider,
      ),
      CongratulationsPage(
        key: const ValueKey('congratulations'),
        themeProvider: widget.themeProvider,
      ),
      HeightWeightPage(
        key: const ValueKey('height_weight'),
        themeProvider: widget.themeProvider,
      ),
      BirthDatePage(
        key: const ValueKey('birth_date'),
        themeProvider: widget.themeProvider,
      ),
      GoalSelectionPage(
        key: const ValueKey('goal_selection'),
        themeProvider: widget.themeProvider,
      ),
      DesiredWeightPage(
        key: const ValueKey('desired_weight'),
        themeProvider: widget.themeProvider,
      ),
      WeightLossMotivationPage(
        key: const ValueKey('weight_loss_motivation'),
        themeProvider: widget.themeProvider,
      ),
      WeightLossSpeedPage(
        key: const ValueKey('weight_loss_speed'),
        themeProvider: widget.themeProvider,
      ),
      DietaryPreferencePage(
        key: const ValueKey('dietary_preference'),
        themeProvider: widget.themeProvider,
      ),
      PersonalGoalsPage(
        key: const ValueKey('personal_goals'),
        themeProvider: widget.themeProvider,
      ),
      ProgressMotivationPage(
        key: const ValueKey('progress_motivation'),
        themeProvider: widget.themeProvider,
      ),
      SupportMotivationPage(
        key: const ValueKey('support_motivation'),
        themeProvider: widget.themeProvider,
      ),
      NotificationPermissionPage(
        key: const ValueKey('notification_permission'),
        themeProvider: widget.themeProvider,
      ),
      CalorieCountingPage(
        key: const ValueKey('calorie_counting'),
        themeProvider: widget.themeProvider,
      ),
      CalorieTransferPage(
        key: const ValueKey('calorie_transfer'),
        themeProvider: widget.themeProvider,
      ),
      ConsistencyHealthPage(
        key: const ValueKey('consistency_health'),
        themeProvider: widget.themeProvider,
      ),
      RatingPage(
        key: const ValueKey('rating'),
        themeProvider: widget.themeProvider,
      ),
      ReferralPage(
        key: const ValueKey('referral'),
        themeProvider: widget.themeProvider,
        userName: '',
      ),
      GoalGenerationPage(
        key: const ValueKey('goal_generation'),
        themeProvider: widget.themeProvider,
        userName: '',
      ),
      AllDonePage(
        key: const ValueKey('all_done'),
        themeProvider: widget.themeProvider,
      ),
    ];
  }

  void _handlePageLogic(int page) {
    // Add any special logic for specific pages here
    
    // Hide navigation for goal generation page only on first visit
    // Check if coming from AllDonePage (page 24) - if so, keep navigation visible
    if (page == 23) { // GoalGenerationPage index
      // Only hide navigation if we're progressing forward (not going back)
      // This is handled inside GoalGenerationPage itself
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

  Future<void> _loadOnboardingProgress() async {
    try {
      _isLoadingProgress = true; // Prevent saving during load
      
      final savedPage = await UserPrefs.getOnboardingCurrentPage();
      if (savedPage != null && savedPage >= 0) {
        final totalPages = _buildPages().length;
        if (savedPage < totalPages) {
          debugPrint('📖 Loading saved onboarding progress: page $savedPage');
          
          // Wait for PageController to be ready
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Set the page on the controller
          _controller.currentPage.value = savedPage;
          
          // Validate the loaded page
          _controller.validatePage(savedPage);
          
          // Sync PageController after frame is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _pageController.hasClients) {
              _pageController.jumpToPage(savedPage);
              debugPrint('✅ PageController synced to saved page: $savedPage');
            } else {
              // If PageController not ready, try again after a delay
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted && _pageController.hasClients) {
                  _pageController.jumpToPage(savedPage);
                  debugPrint('✅ PageController synced to saved page (retry): $savedPage');
                }
              });
            }
          });
        }
      }
      
      // Allow saving again after a short delay to ensure PageController is synced
      await Future.delayed(const Duration(milliseconds: 300));
      _isLoadingProgress = false;
    } catch (e) {
      debugPrint('⚠️ Error loading onboarding progress: $e');
      _isLoadingProgress = false;
    }
  }

  void _saveOnboardingProgress(int page) async {
    try {
      await UserPrefs.setOnboardingCurrentPage(page);
      debugPrint('💾 Saved onboarding progress: page $page');
    } catch (e) {
      debugPrint('⚠️ Error saving onboarding progress: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize the controller first to get current page
    _controller = Get.find<OnboardingController>();
    
    // Set total pages
    _controller.setTotalPages(_buildPages().length);
    
    // Load saved onboarding progress (this will also sync PageController)
    _loadOnboardingProgress();
    
    // Fallback: Sync PageController to current page after frame is built (in case no saved page)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Wait a bit to ensure saved page is loaded first
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted && _pageController.hasClients) {
        final currentPage = _controller.currentPage.value;
        // Only sync if we haven't already synced to a saved page
        final savedPage = await UserPrefs.getOnboardingCurrentPage();
        if (savedPage == null || savedPage == currentPage) {
          _pageController.jumpToPage(currentPage);
        }
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
      3, // Gender selection page (index 2)
      PageValidationConfig(
        dataKey: 'selected_gender',
        validationType: ValidationType.singleChoice,
      ),
    );
    
    _controller.registerPageValidation(
      4, // Workout frequency page (index 3)
      PageValidationConfig(
        dataKey: 'workout_frequency',
        validationType: ValidationType.singleChoice,
      ),
    );

    _controller.registerPageValidation(
      5, // Hear about us page index fixed
      PageValidationConfig(
        dataKey: 'hear_about_us',
        validationType: ValidationType.singleChoice,
      ),
    );

    // Height/Weight page validation (index depends on _pages order). Here: HeightWeightPage at index 8.
    _controller.registerPageValidation(
      7,
      PageValidationConfig(
        dataKey: 'height',
        validationType: ValidationType.numberInput,
      ),
    );
    _controller.registerPageValidation(
      7,
      PageValidationConfig(
        dataKey: 'weight',
        validationType: ValidationType.numberInput,
      ),
    );
    
    _controller.registerPageValidation(
      8, // Birth date page (index 7)
      PageValidationConfig(
        dataKey: 'birth_date',
        validationType: ValidationType.dateInput,
      ),
    );
    
    _controller.registerPageValidation(
      9, // Goal selection page (index 8)
      PageValidationConfig(
        dataKey: 'goal',
        validationType: ValidationType.singleChoice,
      ),
    );
    
    _controller.registerPageValidation(
      13, // Dietary preference page (index 9)
      PageValidationConfig(
        dataKey: 'dietary_preference',
        validationType: ValidationType.singleChoice,
      ),
    );
    
    _controller.registerPageValidation(
      14, // Personal goals page (index 10)
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
      // Save progress whenever page changes (but not during initial load)
      if (!_isLoadingProgress) {
        _saveOnboardingProgress(page);
      }
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
      if (currentPage == 9 && goal == 'maintain_weight') {
        // Directly jump to page 14, bypassing pages 11, 12, and 13
        if (_pageController.hasClients) {
          _pageController.jumpToPage(13);
        }
        _controller.currentPage.value = 13;
        _controller.validatePage(13);
        _handlePageLogic(13);
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
      
      // If on AllDonePage (24) or GoalGenerationPage (23), skip GoalGenerationPage and go directly to ReferralPage (22)
      if (currentPage == 24 || currentPage == 23) {
        // Jump back to ReferralPage (22), skipping GoalGenerationPage
        if (_pageController.hasClients) {
          _pageController.jumpToPage(22);
        }
        _controller.currentPage.value = 22;
        _controller.validatePage(22);
        _handlePageLogic(22);
      }
      // If on dietary preference page (14) and came from goal selection (maintain_weight), go back to page 10
      else if (currentPage == 13 && goal == 'maintain_weight') {
        // Jump back to page 10, bypassing pages 13, 12, and 11
        if (_pageController.hasClients) {
          _pageController.jumpToPage(9);
        }
        _controller.currentPage.value = 9;
        _controller.validatePage(9);
        _handlePageLogic(9);
      } else {
        _controller.goToPreviousPage();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  // Helper method to map workout frequency to activity level
  String _mapWorkoutFrequencyToActivityLevel(String workoutFreq) {
    switch (workoutFreq) {
      case '0':
        return 'sedentary';
      case '1-2':
        return 'lightly_active';
      case '3-5':
        return 'moderately_active';
      case '6-7':
        return 'very_active';
      default:
        return 'lightly_active';
    }
  }

  // Helper method to map workout frequency to number
  int _mapWorkoutFrequencyToNumber(String workoutFreq) {
    switch (workoutFreq) {
      case '0':
        return 0;
      case '1-2':
        return 2;
      case '3-5':
        return 4;
      case '6-7':
        return 6;
      default:
        return 2;
    }
  }

  // Helper method to map goal to fitness goal
  String _mapGoalToFitnessGoal(String goal) {
    switch (goal) {
      case 'lose_weight':
        return 'weight_loss';
      case 'gain_weight':
        return 'weight_gain';
      case 'maintain_weight':
        return 'maintenance';
      default:
        return 'maintenance';
    }
  }

  // Helper method to map hear_about_us to valid enum values
  String _mapHearAboutUsToEnum(String hearAboutUs) {
    switch (hearAboutUs.toLowerCase()) {
      case 'google_play':
      case 'app_store':
        return 'app_store';
      case 'youtube':
      case 'tiktok':
      case 'instagram':
        return 'social_media';
      case 'influencer':
        return 'advertisement';
      case 'friends_family':
        return 'friend_referral';
      case 'other':
        return 'other';
      default:
        return 'other';
    }
  }



  // Helper method to get target weight (simplified - assumes metric units)
  double _getTargetWeight() {
    final double? desiredWeight = _controller.getDoubleData('desired_weight');
    if (desiredWeight != null) {
      return desiredWeight;
    }
    return (_controller.getIntData('weight') ?? 70).toDouble();
  }

  // Helper function to filter onboarding data for user profile update (excludes auth and identity fields)
  Map<String, dynamic> _filterOnboardingDataForUpdate(Map<String, dynamic> onboardingData) {
    // Fields to exclude from profile update
    final excludedFields = {
      'email',
      'password',
      'firstName',
      'lastName',
      'provider',
      'providerId',
      'supabaseId',
      'revenueCatId',
      'referrerId',
      'oneSignalId',
    };
    
    // Create filtered map
    final Map<String, dynamic> filtered = {};
    onboardingData.forEach((key, value) {
      if (!excludedFields.contains(key) && value != null) {
        filtered[key] = value;
      }
    });
    
    return filtered;
  }

  // Collect onboarding data for user profile update
  Future<Map<String, dynamic>> _collectOnboardingDataForUpdate() async {
    // Extract birth date and calculate age
    final birthDate = _controller.getDateTimeData('birth_date');
    int age = 25; // default age
    if (birthDate != null) {
      final now = DateTime.now();
      age = now.year - birthDate.year;
      if (now.month < birthDate.month || 
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
    }

    // Get device timezone
    String timezone = 'Europe/Zagreb'; // Default fallback
    try {
      timezone = await FlutterNativeTimezone.getLocalTimezone();
    } catch (e) {
      debugPrint('⚠️ Error getting timezone, using default: $e');
    }

    // Get current language from SharedPreferences or default
    String languageCode = 'en';
    try {
      final prefs = await SharedPreferences.getInstance();
      languageCode = prefs.getString('selected_language') ?? 'en';
    } catch (e) {
      // Use default
    }

    // Map onboarding data to API format (excluding auth fields)
    final onboardingData = {
      // Basic profile info
      "age": age,
      "weight": (_controller.getIntData('weight') ?? 70).toDouble(),
      "height": _controller.getIntData('height') ?? 170,
      "gender": _controller.getStringData('selected_gender') ?? 'male',
      "birthdate": DateTime.now().toIso8601String().split('T').first,

      // Activity and fitness
      "activityLevel": _mapWorkoutFrequencyToActivityLevel(_controller.getStringData('workout_frequency') ?? '0'),
      "dailyCalorieGoal": _controller.getIntData('daily_calorie_goal') ?? 2250,
      "workoutsPerWeek": _mapWorkoutFrequencyToNumber(_controller.getStringData('workout_frequency') ?? '0'),
      "fitnessGoals": _mapGoalToFitnessGoal(_controller.getStringData('goal') ?? 'maintain_weight'),
      "targetWeight": _getTargetWeight(),
      "weeklyGoal": _controller.getDoubleData('weight_loss_speed') ?? 0.7,
      "speedToGoal": _controller.getDoubleData('weight_loss_speed') ?? 0.7,

      // Dietary preferences
      "dietaryPreferences": [_controller.getStringData('dietary_preference') ?? 'classic'],
      "allergies": [],
      "healthConditions": [],

      // Preferences
      "timezone": timezone,
      "language": languageCode,
      "units": _controller.getBoolData('is_metric') ?? true ? "metric" : "imperial",

      // Onboarding questionnaire fields
      "hearAboutUs": _mapHearAboutUsToEnum(_controller.getStringData('hear_about_us') ?? ''),
      "triedOtherCalorieTrackingApps": false,
      "whatStoppingFromReachingGoals": "",
      "followSpecificDiet": _controller.getStringData('dietary_preference') != 'classic',
      "specificDiet": _controller.getStringData('dietary_preference') ?? '',
      "whatWouldLikeToAccomplish": _controller.getStringData('personal_goal') ?? '',
    };

    // Filter out null values and auth fields
    return _filterOnboardingDataForUpdate(onboardingData);
  }

  void _startApp() async {
    // Mark onboarding as completed
    await UserPrefs.setOnboardingCompleted(true);
    // Clear saved progress since onboarding is complete
    await UserPrefs.clearOnboardingProgress();
    debugPrint('✅ Onboarding marked as completed');
    
    // Check if user is authenticated (has token and userId)
    if (AppConstants.authToken.isEmpty || AppConstants.userId.isEmpty) {
      // If not authenticated, navigate to CreateAccountPage
      debugPrint('⚠️ User not authenticated: navigating to CreateAccountPage');
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => CreateAccountPage(
            themeProvider: widget.themeProvider,
            isAfterOnboardingCompletion: true, // Shown after completing onboarding
          ),
        ),
      );
      return;
    }
    
    // If authenticated, update user profile with onboarding data (without await)
    _collectOnboardingDataForUpdate().then((updateData) {
      if (updateData.isNotEmpty) {
        try {
          final userController = Get.find<UserController>();
          final languageProvider = Get.find<LanguageProvider>();
          
          // Call updateUser without await (fire-and-forget)
          userController.updateUser(
            AppConstants.userId,
            updateData,
            context,
            widget.themeProvider,
            languageProvider,
          );
          debugPrint('📝 Updating user profile with onboarding data (non-blocking)');
        } catch (e) {
          debugPrint('⚠️ Error updating user profile: $e');
        }
      }
    });
    
    // Navigate directly to HomeScreen
    LanguageProvider? languageProvider;
    try {
      languageProvider = Get.find<LanguageProvider>();
    } catch (e) {
      // LanguageProvider not available, create default
      languageProvider = LanguageProvider();
    }
    
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(
        builder: (context) => HomeScreen(
          themeProvider: widget.themeProvider,
          languageProvider: languageProvider!,
        ),
      ),
      (route) => false, // Remove all previous routes
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
              // Top spacer/header background (hidden on first page)
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    color: _controller.currentPage.value == 5 ||
                            _controller.currentPage.value == 10
                        ? null
                        : ThemeHelper.background,
                  ),
                  height: _controller.currentPage.value == 0 ? 0 : 60,
                ),
              ),
              // Custom navigation with back button and progress bar
              Obx(
                () => _controller.showNavigation.value
                    ? (_controller.currentPage.value == 0
                        // No top navigation on the very first page
                        ? const SizedBox.shrink()
                        : Container(
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
                            // Back button (hidden on first page, and hidden on second page if user just registered)
                            _controller.currentPage.value > 0 && 
                            !(_controller.currentPage.value == 1 && _controller.isRegistrationComplete.value)
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
                              
                            // Progress bar (hidden on first page)
                            if (_controller.currentPage.value > 0)
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
                              )
                            else
                              const Spacer(),

                            const SizedBox(width: 16),

                            // Theme switch button - only show on second onboarding page (index 1)
                            // if (_controller.currentPage.value == 1)
                            //   GestureDetector(
                            //     onTap: () {
                            //       HapticFeedback.mediumImpact();
                            //       if (ThemeHelper.isLightMode) {
                            //         widget.themeProvider.setDarkTheme();
                            //       } else {
                            //         widget.themeProvider.setLightTheme();
                            //       }
                            //     },
                            //     child: Container(
                            //       height: 32,
                            //       width: 32,
                            //       decoration: BoxDecoration(
                            //         color: ThemeHelper.cardBackground,
                            //         shape: BoxShape.circle,
                            //         border: Border.all(
                            //           color: ThemeHelper.divider,
                            //           width: 1,
                            //         ),
                            //       ),
                            //       child: Icon(
                            //         ThemeHelper.isLightMode
                            //             ? CupertinoIcons.moon
                            //             : CupertinoIcons.sun_max,
                            //         size: 18,
                            //         color: ThemeHelper.textPrimary,
                            //       ),
                            //     ),
                            //   ),
                          ],
                        ),
                      ))
                    : const SizedBox.shrink(),
              ),
          
              // PageView content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: _onPageChanged,
                  children: _buildPages(),
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

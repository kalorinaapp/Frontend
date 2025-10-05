// ignore_for_file: unused_local_variable
import 'dart:async' show Completer;
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math' show Random;
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignIn;
import 'package:onesignal_flutter/onesignal_flutter.dart' show OneSignal, OSLogLevel;
import 'package:sign_in_with_apple/sign_in_with_apple.dart'
    show AppleIDAuthorizationScopes, SignInWithApple;
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, GoTrueClientSignInProvider, OAuthProvider, Supabase, AuthChangeEvent;
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../onboarding/controller/onboarding.controller.dart';
import '../onboarding/pages/how_it_works_page.dart' show HowItWorksPage;
import 'user.controller.dart';
import '../../screens/language_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';

class CreateAccountPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  final bool isLogin;

  const CreateAccountPage({
    super.key, 
    required this.themeProvider,
    this.isLogin = false,
  });

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late OnboardingController _controller;
  late UserController _userController;

  late OnboardingController _onboardingController;
  LanguageProvider? _languageProvider;
  
  // Language state
  String _currentLanguageCode = 'en';
  String _currentLanguageFlag = '🇬🇧';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onboardingController = Get.find<OnboardingController>();
      try {
        _languageProvider = Get.find<LanguageProvider>();
      } catch (e) {
        debugPrint('LanguageProvider not found: $e');
      }
      _loadCurrentLanguage();
    });

    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.Debug.setAlertLevel(OSLogLevel.none);
    // OneSignal.consentRequired(_requireConsent);

    // NOTE: Replace with your own app ID from https://www.onesignal.com
    OneSignal.initialize("5e051ce3-f17b-478b-a53e-f975af027029");

    _handleAllowNotifications();

    _controller = Get.find<OnboardingController>();
    _userController = Get.put(UserController());

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animation when page loads
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
  }


    void _handleAllowNotifications() {
    // Request system notification permission via OneSignal and proceed
    () async {
      try {
        // On iOS this shows the native permission dialog; on Android this is a no-op
        final bool accepted = await OneSignal.Notifications.requestPermission(true);
        debugPrint('OneSignal permission accepted: $accepted');
      } catch (e) {
        debugPrint('OneSignal permission request error: $e');
      } finally {
      }
    }();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // Load current language from shared preferences
  Future<void> _loadCurrentLanguage() async {
    try {
      debugPrint('Loading current language from shared preferences...');
      
      // Always load the original saved language code from SharedPreferences for display
      final prefs = await SharedPreferences.getInstance();
      String savedLanguage = prefs.getString('selected_language') ?? 'hr';
      debugPrint('Saved language from prefs: $savedLanguage');
      
      // Get language info using the original saved code
      final languageInfo = _getLanguageInfo(savedLanguage);
      debugPrint('Language info: $languageInfo');
      
      setState(() {
        _currentLanguageCode = savedLanguage; // Use the original code for display
        _currentLanguageFlag = languageInfo['flag'] ?? '🇬🇧';
      });
      debugPrint('Language state updated: $_currentLanguageCode with flag $_currentLanguageFlag');
    } catch (e) {
      debugPrint('Error loading language: $e');
      // Set default values if there's an error
      setState(() {
        _currentLanguageCode = 'hr';
        _currentLanguageFlag = '🇭🇷';
      });
    }
  }

  // Get language information by code
  Map<String, String> _getLanguageInfo(String code) {
    const languages = {
      'en': {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
      'hr': {'code': 'hr', 'name': 'Hrvatski', 'flag': '🇭🇷'},
      'sr': {'code': 'sr', 'name': 'Srpski', 'flag': '🇷🇸'},
      'bs': {'code': 'bs', 'name': 'Bosanski', 'flag': '🇧🇦'},
      'sl': {'code': 'sl', 'name': 'Slovenščina', 'flag': '🇸🇮'},
      'cg': {'code': 'cg', 'name': 'Crnogorski', 'flag': '🇲🇪'}, // Keep original code for display
      'mk': {'code': 'mk', 'name': 'Македонски', 'flag': '🇲🇰'}, // Keep original code for display
      'bg': {'code': 'bg', 'name': 'Български', 'flag': '🇧🇬'},
      'ro': {'code': 'ro', 'name': 'Română', 'flag': '🇷🇴'},
      'hu': {'code': 'hu', 'name': 'Magyar', 'flag': '🇭🇺'},
    };
    
    return languages[code] ?? {'code': 'en', 'name': 'English', 'flag': '🇬🇧'};
  }

  // Language changer widget
  Widget _buildLanguageChanger() {
    debugPrint('Building language changer with: $_currentLanguageCode and $_currentLanguageFlag');
    return GestureDetector(
      onTap: () async {
        debugPrint('Language changer tapped - navigating to language selection screen');
        try {
          final result = await  Navigator.push(context, CupertinoPageRoute(builder: (context) =>  LanguageSelectionScreen()));
          
          debugPrint('Returned from language selection with result: $result');
          
          // Reload language after returning from selection screen
          if (result != null || mounted) {
            await _loadCurrentLanguage();
          }
        } catch (e) {
          debugPrint('Error navigating to language selection: $e');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: ThemeHelper.isLightMode 
              ? CupertinoColors.white 
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ThemeHelper.isLightMode
                ? CupertinoColors.black.withOpacity(0.2)
                : CupertinoColors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentLanguageFlag,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              _currentLanguageCode.toUpperCase(),
              style: ThemeHelper.textStyleWithColorAndSize(
                ThemeHelper.caption1,
                ThemeHelper.textPrimary,
                12,
              ).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to convert accommodation index to string
  // String _getAccommodationTypeString() {
  //   final int? accommodationIndex = _controller.getIntData('accommodationType');
  //   if (accommodationIndex == null || accommodationIndex == -1) {
  //     return 'hotel'; // default value
  //   }
    
  //   switch (accommodationIndex) {
  //     case 0:
  //       return 'hotel';
  //     case 1:
  //       return 'airbnb';
  //     case 2:
  //       return 'hostel';
  //     case 3:
  //       return 'luxury';
  //     default:
  //       return 'hotel';
  //   }
  // }

  // Helper method to generate random ID
  String _generateRandomId({String prefix = '', int length = 12}) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final randomString = String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
    return prefix.isNotEmpty ? '${prefix}_$randomString' : randomString;
  }

  // Helper function to collect login data
  Map<String, dynamic> _collectLoginData(String? userId, String? email, String? name) {
    return {
      "email": email ?? '',
      "providerId": userId.toString(),
      "provider": "google", // Will be updated per provider
    };
  }

  // Helper function to collect all onboarding data
  Map<String, dynamic> _collectOnboardingData(String? userId, String? email, String? name) {
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

    // Parse name into first and last name with validation
    final fullName = (name ?? '').toString().trim();
    final nameParts = fullName.split(' ').where((part) => part.isNotEmpty).toList();
    
    // Clean and validate name parts (only letters, spaces, hyphens, apostrophes, dots)
    String cleanName(String name) {
      return name.replaceAll(RegExp(r"[^a-zA-Z\s\-'.]+"), '').trim();
    }
    
    String firstName = '';
    String lastName = 'Last';
    
    if (nameParts.isNotEmpty) {
      firstName = cleanName(nameParts.first);
      if (nameParts.length > 1) {
        lastName = cleanName(nameParts.sublist(1).join(' '));
      }
    }
    
    // Fallback to email-based name if no valid name found
    if (firstName.isEmpty && email != null && email.isNotEmpty) {
      final emailPart = email.split('@').first;
      firstName = cleanName(emailPart.replaceAll(RegExp(r'[^a-zA-Z]+'), ' ').trim());
      if (firstName.isEmpty) {
        firstName = 'User'; // Ultimate fallback
      }
    }
    
    // Ensure firstName is not empty and valid (API requirement)
    if (firstName.isEmpty || !RegExp(r"^[a-zA-Z\s\-'.]+$").hasMatch(firstName)) {
      firstName = 'User';
    }
    
    // Ensure lastName is valid if present
    if (lastName.isNotEmpty && !RegExp(r"^[a-zA-Z\s\-'.]+$").hasMatch(lastName)) {
      lastName = 'Last';
    }

    // Map onboarding data to API format
    return {
      // Basic authentication fields
      "email": email ?? '',
      "password": "Random1@", // Default password for OAuth users
      "firstName": firstName,
      "lastName": lastName,

      // Basic profile info
      "age": age,
      "weight": (_controller.getIntData('weight') ?? 70).toDouble(),
      "height": _controller.getIntData('height') ?? 170,
      "gender": _controller.getStringData('selected_gender') ?? 'male',
      "birthdate": birthDate?.toIso8601String().split('T').first ?? '',

      // Activity and fitness
      "activityLevel": _mapWorkoutFrequencyToActivityLevel(_controller.getStringData('workout_frequency') ?? '0'),
      "dailyCalorieGoal": _controller.getIntData('daily_calorie_goal') ?? 2250,
      "workoutsPerWeek": _mapWorkoutFrequencyToNumber(_controller.getStringData('workout_frequency') ?? '0'),
      "fitnessGoals": _mapGoalToFitnessGoal(_controller.getStringData('goal') ?? 'maintain_weight'),
      "targetWeight": (_controller.getIntData('weight') ?? 70).toDouble(), // Default to current weight
      "weeklyGoal": 0.5, // Default weekly goal in kg
      "speedToGoal": "moderate", // Default speed

      // Dietary preferences
      "dietaryPreferences": [_controller.getStringData('dietary_preference') ?? 'classic'],
      "allergies": [], // Empty array as default
      "healthConditions": [], // Empty array as default

      // Preferences
      "timezone": "Europe/Zagreb", // Default timezone for Croatian app
      "language": "hr", // Croatian language
      "units": _controller.getBoolData('is_metric') ?? true ? "metric" : "imperial",

      // OAuth fields
      "provider": "google", // Will be updated per provider
      "providerId": userId.toString(),
      "supabaseId": _generateRandomId(prefix: 'supabase_user_id', length: 8),
      "revenueCatId": _generateRandomId(prefix: 'revenuecat_user_id', length: 8),

      // Referral tracking
      "referrerId": _generateRandomId(prefix: 'referrer_user_id', length: 8),

      // Onboarding questionnaire fields
      "hearAboutUs": _mapHearAboutUsToEnum(_controller.getStringData('hear_about_us') ?? ''),
      "triedOtherCalorieTrackingApps": false, // Default value
      "whatStoppingFromReachingGoals": "", // Empty as default
      "followSpecificDiet": _controller.getStringData('dietary_preference') != 'classic',
      "specificDiet": _controller.getStringData('dietary_preference') ?? '',
      "whatWouldLikeToAccomplish": _controller.getStringData('personal_goal') ?? '',
    };
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

  // ignore: unused_element
  // void _continueToNextPage() {
  //   Navigator.of(context).push(
  //     CupertinoPageRoute(
  //       builder: (context) => AddNamePage(themeProvider: widget.themeProvider),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: _languageProvider != null 
          ? Listenable.merge([widget.themeProvider, _languageProvider])
          : widget.themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          
          backgroundColor: ThemeHelper.background,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  // const Spacer(),
              
                  // App logo
                  // Image.asset(
                  //   "assets/images/travy_logo.png",
                  //   width: 150,
                  //   height: 150,
                  // ),
              
                  // const SizedBox(height: 0),
              
                  // Title
                  // Text(
                  //   widget.isLogin ? "Welcome Back" : "Create Your Account",
                  //   style: ThemeHelper.textStyleWithColorAndSize(
                  //     ThemeHelper.headline,
                  //     ThemeHelper.textPrimary,
                  //     32,
                  //   )
                  //   //.copyWith(fontWeight: FontWeight.w800),
                  //   // textAlign: TextAlign.center,
                  // ),
              
                  // const SizedBox(height: 12),
              
                  // Subtitle
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 32),
                  //   child: Text(
                  //     "Join thousands of smart travelers who use Travy to plan their perfect trips",
                  //     style: ThemeHelper.textStyleWithColorAndSize(
                  //       ThemeHelper.body1,
                  //       ThemeHelper.textSecondary,
                  //       16,
                  //     )
                  //     // .copyWith(fontWeight: FontWeight.w400),
                  //     // textAlign: TextAlign.center,
                  //   ),
                  // ),
              
                  // const Spacer(),
              const SizedBox(height: 60),
                  // Apple Sign In Button
                  if (Platform.isIOS)
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color:
                          ThemeHelper.isLightMode
                              ? CupertinoColors.black
                              : CupertinoColors.white,
                      borderRadius: BorderRadius.circular(24),
                      onPressed: appleSignIn,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/icons/app_store.svg",
                            width: 20,
                            height: 20,
                            color:
                                ThemeHelper.isLightMode
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.continueWithApple,
                            style: ThemeHelper.textStyleWithColor(
                              ThemeHelper.body1,
                              ThemeHelper.isLightMode
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
                            )
                            //.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
              
                  const SizedBox(height: 16),
              
                  // Google Sign In Button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ThemeHelper.cardBackground,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              ThemeHelper.isLightMode
                                  ? CupertinoColors.black
                                  : CupertinoColors.white,
                          width: 1,
                        ),
                      ),
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(24),
                        onPressed:   Platform.isIOS ? googleSignIn : googleSignInAndroid,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/google_logo.svg",
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.continueWithGoogle,
                              style: ThemeHelper.textStyleWithColor(
                                ThemeHelper.body1,
                                ThemeHelper.textPrimary,
                              )
                              //.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              
                   const SizedBox(height: 12),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text(
                         l10n.wantToSignInLater,
                         style: ThemeHelper.textStyleWithColorAndSize(
                           ThemeHelper.caption1,
                           ThemeHelper.textSecondary,
                           12,
                         ),
                       ),
                       GestureDetector(
                         onTap: () {
                           // Navigate to home screen without authentication
                           _onboardingController.goToNextPage();

                           if (!widget.isLogin) {
                           Navigator.of(context).push(
                             CupertinoPageRoute(
                               builder: (context) => HowItWorksPage(themeProvider: widget.themeProvider, postSignUp: true),
                             ),
                           );
                           }
                         },
                         child: Text(
                           l10n.skip,
                           style: ThemeHelper.textStyleWithColorAndSize(
                             ThemeHelper.caption1,
                             ThemeHelper.textSecondary,
                             12,
                           ).copyWith(
                             decoration: TextDecoration.underline,
                           ),
                         ),
                       ),
                     ],
                   ),
          
                   const SizedBox(height: 24),
              
                  // Terms and Privacy
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.byContinuingAgree,
                      style: ThemeHelper.textStyleWithColorAndSize(
                        ThemeHelper.caption1,
                        ThemeHelper.textSecondary,
                        12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              
                  const SizedBox(height: 32),
                    ],
                  ),
                ),
                 // Language changer positioned in top-right
                 Positioned(
                   top: 20,
                   right: 20,
                   child: _buildLanguageChanger(),
                 ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future googleSignIn() async {
    // const webClientId =
    //     '70719570257-re7p2dpf84jr9ej2blpcls4d9hger7pl.apps.googleusercontent.com';
    const iosClientId =
        '726539598663-ihlddonmqbsh0dnr37ugfbpvjdaddvpf.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId:  iosClientId,
    );

    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    final signedInUser = await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    String? userId = signedInUser.session?.user.id;
    String? email = signedInUser.user?.email ?? '';
    // If email present but name missing, derive name from email local part
    String? name = signedInUser.user?.userMetadata?['full_name'] ?? '';
    if ((name == null || name.trim().isEmpty) && (email.isNotEmpty)) {
      name = email.split('@').first;
    }

    print('userId: $userId');
    print('email: $email');
    print('name: $name');

    final Map<String, dynamic> params = widget.isLogin 
        ? _collectLoginData(userId, email, name)
        : _collectOnboardingData(userId, email, name);
    params["provider"] = "google";
    
    print('Collected ${widget.isLogin ? "login" : "onboarding"} data: $params');
    if (!widget.isLogin) {
      print('firstName validation: "${params["firstName"]}" (length: ${params["firstName"].toString().length})');
      print('lastName validation: "${params["lastName"]}" (length: ${params["lastName"].toString().length})');
      print('hearAboutUs validation: "${params["hearAboutUs"]}"');
    }
    print('provider validation: "${params["provider"]}"');
    
    if (widget.isLogin) {
      await _userController.loginUser(params, context, widget.themeProvider, _languageProvider!);
    } else {
      await _userController.registerUser(params, context, widget.themeProvider, _languageProvider!);
    }
  }

  Future googleSignInByIdAndroid() async {
     print('webClientId: ');
    const webClientId =
        '70719570257-rcpn5agku035d2fv5tgoohgekh8pnrje.apps.googleusercontent.com';
    // const iosClientId =
        // '70719570257-4jc9hkfhdag3lrjp5p0vrae898379bus.apps.googleusercontent.com';

       

    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId:  webClientId,
    );

    print('webClientId: $webClientId');

    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    final signedInUser = await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    String? userId = signedInUser.session?.user.id;
    String? email = signedInUser.user?.email ?? '';
    // If email present but name missing, derive name from email local part
    String? name = signedInUser.user?.userMetadata?['full_name'] ?? '';
    if ((name == null || name.trim().isEmpty) && (email.isNotEmpty)) {
      name = email.split('@').first;
    }

    final Map<String, dynamic> params = widget.isLogin 
        ? _collectLoginData(userId, email, name)
        : _collectOnboardingData(userId, email, name);
    params["provider"] = "google";
    
    print('Collected ${widget.isLogin ? "login" : "onboarding"} data (Android): $params');
    if (!widget.isLogin) {
      print('firstName validation: "${params["firstName"]}" (length: ${params["firstName"].toString().length})');
      print('lastName validation: "${params["lastName"]}" (length: ${params["lastName"].toString().length})');
      print('hearAboutUs validation: "${params["hearAboutUs"]}"');
    }
    print('provider validation: "${params["provider"]}"');
    
    if (widget.isLogin) {
      await _userController.loginUser(params, context, widget.themeProvider, _languageProvider!);
    } else {
      await _userController.registerUser(params, context, widget.themeProvider, _languageProvider!);
    }
  }

  Future appleSignIn() async {
    final rawNonce = Supabase.instance.client.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException(
        'Could not find ID Token from generated credential.',
      );
    }
    final signedInUser = await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
    String? providerId = credential.userIdentifier;
    
    // Extract user info from Apple sign-in
    final session = Supabase.instance.client.auth.currentSession;
    final metaName = session?.user.userMetadata?['name'];
    String name = '';
    if (metaName != null && metaName.toString().trim().isNotEmpty) {
      name = metaName.toString();
    } else {
      final email = session?.user.email ?? '';
      if (email.isNotEmpty) {
        name = email.split('@').first;
      }
    }
    final email = session?.user.email ?? '';

    print('Apple Sign-in - providerId: $providerId');
    print('Apple Sign-in - name: $name');
    print('Apple Sign-in - email: $email');
    
    final Map<String, dynamic> params = widget.isLogin 
        ? _collectLoginData(providerId, email, name)
        : _collectOnboardingData(providerId, email, name);
    params["provider"] = "apple";
    
    print('Collected ${widget.isLogin ? "login" : "onboarding"} data (Apple): $params');
    if (!widget.isLogin) {
      print('firstName validation: "${params["firstName"]}" (length: ${params["firstName"].toString().length})');
      print('lastName validation: "${params["lastName"]}" (length: ${params["lastName"].toString().length})');
      print('hearAboutUs validation: "${params["hearAboutUs"]}"');
    }
    print('provider validation: "${params["provider"]}"');
    
    if (widget.isLogin) {
      await _userController.loginUser(params, context, widget.themeProvider, _languageProvider!);
    } else {
      await _userController.registerUser(params, context, widget.themeProvider, _languageProvider!);
    }
  }



    Future<void> googleSignInAndroid() async {
    final completer = Completer<void>();
    Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      if (session != null) {
        String? userId = Supabase.instance.client.auth.currentSession?.user.id;
        String? email =
            Supabase.instance.client.auth.currentSession?.user.email;
        String? name = Supabase.instance.client.auth.currentSession?.user
            .userMetadata?['full_name'];

        // Utils.logger.e('Signed In Google User -->> ${name}');

        final Map<String, dynamic> params = widget.isLogin 
            ? _collectLoginData(userId, email, name)
            : _collectOnboardingData(userId, email, name);
        params["provider"] = "google";
        
        print('Collected ${widget.isLogin ? "login" : "onboarding"} data (Android OAuth): $params');
        if (!widget.isLogin) {
          print('firstName validation: "${params["firstName"]}" (length: ${params["firstName"].toString().length})');
          print('lastName validation: "${params["lastName"]}" (length: ${params["lastName"].toString().length})');
        }
        
        if (widget.isLogin) {
          await _userController.loginUser(params, context, widget.themeProvider, _languageProvider!);
        } else {
          await _userController.registerUser(params, context, widget.themeProvider, _languageProvider!);
        }

      
        completer.complete(); // Complete the Future when sign-in is successful
      } else if (event.event == AuthChangeEvent.signedOut) {
        completer.completeError('User canceled or sign-out occurred.');
      }
    });

    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'travy://app',
    );

    await completer.future; // Wait for the sign-in to complete
  }
}

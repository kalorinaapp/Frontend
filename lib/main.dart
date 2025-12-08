
import 'package:calorie_ai_app/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'authentication/user.controller.dart' show UserController;
import 'l10n/app_localizations.dart' show AppLocalizations;
import 'onboarding_screen.dart' show OnboardingScreen;
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'utils/app.initilizations.dart' show AppInitializationMethods;
import 'utils/initial.bindings.dart' show InitialBindings;
import 'utils/theme_helper.dart';
import 'constants/app_constants.dart' show AppConstants;
import 'utils/user.prefs.dart' show UserPrefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize( 
    url: 'https://yfhumomhyxutkofmlalo.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmaHVtb21oeXh1dGtvZm1sYWxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2OTc1MDQsImV4cCI6MjA2NzI3MzUwNH0.QtQkjJVrSnKm81Fv3SD6QVGPs_ZnRTfRB_F7yKoFQNg'
  );

    final appInitializationMethods = AppInitializationMethods();
  await appInitializationMethods.initialize();
  runApp(const CalorieAIApp());
}

class CalorieAIApp extends StatefulWidget {
  const CalorieAIApp({super.key});

  @override
  State<CalorieAIApp> createState() => _CalorieAIAppState();
}

class _CalorieAIAppState extends State<CalorieAIApp> {
  late ThemeProvider themeProvider;
  late LanguageProvider languageProvider;
  bool _isInitialized = false;
  late final WidgetsBinding _binding;
  Map<String, dynamic>? _initialScreenData;

  @override
  void initState() {
    super.initState();
    _binding = WidgetsBinding.instance;
    _binding.deferFirstFrame();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    Map<String, dynamic> initialData = const {};

    try {
      themeProvider = ThemeProvider();
      languageProvider = LanguageProvider();

      // Wait for language to load from SharedPreferences
      await languageProvider.initialize();

      // Load persisted auth and user values and populate AppConstants
      try {
        final token = await UserPrefs.getToken();
        final refresh = await UserPrefs.getRefreshToken();
        final userId = await UserPrefs.getId();
        final email = await UserPrefs.getEmail();
        final name = await UserPrefs.getName();

        if (token != null && token.isNotEmpty) {
          AppConstants.authToken = token;
        }
        if (userId != null && userId.isNotEmpty) {
          AppConstants.userId = userId;
          final userCtrl = Get.isRegistered<UserController>()
              ? Get.find<UserController>()
              : Get.put(UserController(), permanent: true);
          await userCtrl.getUserData(AppConstants.userId);
        }
        // Optionally persist extra metadata for diagnostics
        if (email != null && email.isNotEmpty) {
          AppConstants.userEmail = email;
        }
        if (name != null && name.isNotEmpty) {
          AppConstants.userName = name;
        }
        if (refresh != null && refresh.isNotEmpty) {
          AppConstants.refreshToken = refresh;
        }
      } catch (_) {}

      // Register the same instances with GetX so both can use the same providers
      // Only register if not already registered (avoid duplicates from InitialBindings)
      if (!Get.isRegistered<ThemeProvider>()) {
        Get.put(themeProvider, permanent: true);
      } else {
        // If already registered, delete and re-register with our instance to ensure consistency
        Get.delete<ThemeProvider>(force: true);
        Get.put(themeProvider, permanent: true);
      }
      if (!Get.isRegistered<LanguageProvider>()) {
        Get.put(languageProvider, permanent: true);
      } else {
        Get.delete<LanguageProvider>(force: true);
        Get.put(languageProvider, permanent: true);
      }

      initialData = await getInitialScreenData();
    } finally {
      if (mounted) {
        setState(() {
          _initialScreenData = initialData;
          _isInitialized = true;
        });
      }
      _binding.allowFirstFrame();
    }
  }


  // Helper method to get initial screen data
  Future<Map<String, dynamic>> getInitialScreenData() async {
    try {
      final token = await UserPrefs.getToken();
      final userId = await UserPrefs.getId();
      final email = await UserPrefs.getEmail();
      final name = await UserPrefs.getName();
      print('token: $token');
      print('userId: $userId');
      print('email: $email');
      print('name: $name');
      return {
        'userId': userId ?? '',
        'email': email ?? '',
        'name': name ?? '',
        'isAuthenticated': token != null && token.isNotEmpty,
      };
    } catch (e) {
      return {
        'userId': '',
        'email': '',
        'name': '',
        'isAuthenticated': false,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep native launch screen visible while initialization runs
    if (!_isInitialized) {
      return const CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: SizedBox.shrink(),
      );
    }

    final Map<String, dynamic> data = _initialScreenData ?? const {};
    final String userId = (data['userId'] as String?) ?? '';
    final bool isAuthenticated = (data['isAuthenticated'] as bool?) ?? false;

    return ListenableBuilder(
      listenable: Listenable.merge([themeProvider, languageProvider]),
      builder: (context, child) {
        // Update ThemeHelper with current theme state
        ThemeHelper.setLightMode(themeProvider.isLightMode);

        return GetCupertinoApp(
          initialBinding: InitialBindings(),
          debugShowCheckedModeBanner: false,
          title: 'Cal AI - Scan & Log Meals',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: languageProvider.currentLocale,
          theme: CupertinoThemeData(
            primaryColor: CupertinoColors.systemGreen,
            brightness: themeProvider.isLightMode 
                ? Brightness.light 
                : Brightness.dark,
          ),
          home: isAuthenticated && userId.isNotEmpty
              ? HomeScreen(
                  themeProvider: themeProvider,
                  languageProvider: languageProvider,
                )
              : OnboardingScreen(
                  themeProvider: themeProvider,
                ),
          onUnknownRoute: (RouteSettings settings) {
            return CupertinoPageRoute(
              settings: settings,
              builder: (context) {
                if (isAuthenticated && userId.isNotEmpty) {
                  return HomeScreen(
                    themeProvider: themeProvider,
                    languageProvider: languageProvider,
                  );
                } else {
                  return OnboardingScreen(
                    themeProvider: themeProvider,
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}


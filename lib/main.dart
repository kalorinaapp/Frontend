
import 'package:calorie_ai_app/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'l10n/app_localizations.dart' show AppLocalizations;
import 'onboarding_screen.dart' show OnboardingScreen;
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'utils/initial.bindings.dart' show InitialBindings;
import 'utils/theme_helper.dart';
import 'constants/app_constants.dart' show AppConstants;
import 'utils/user.prefs.dart' show UserPrefs;

void main() async {
  await Supabase.initialize( 
    url: 'https://yfhumomhyxutkofmlalo.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmaHVtb21oeXh1dGtvZm1sYWxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2OTc1MDQsImV4cCI6MjA2NzI3MzUwNH0.QtQkjJVrSnKm81Fv3SD6QVGPs_ZnRTfRB_F7yKoFQNg'
  );
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

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
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
    Get.put(themeProvider, permanent: true);
    Get.put(languageProvider, permanent: true);
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  // Helper method to get initial screen data
  Future<Map<String, dynamic>> getInitialScreenData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      return {
        'userId': user?.id ?? '',
        'email': user?.email ?? '',
        'name': user?.userMetadata?['full_name'] ?? '',
        'isAuthenticated': user != null,
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
    // Show loading indicator while providers are initializing
    if (!_isInitialized) {
      return const CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: Center(child: CupertinoActivityIndicator()),
      );
    }
    
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
          home: FutureBuilder<Map<String, dynamic>>(
            future: getInitialScreenData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CupertinoActivityIndicator());
              }
              
              final Map<String, dynamic> data = snapshot.data ?? const {};
              final String userId = (data['userId'] as String?) ?? '';
              final bool isAuthenticated = (data['isAuthenticated'] as bool?) ?? false;

              // Navigation logic based on authentication state
              if (isAuthenticated && userId.isNotEmpty) {
                // User is authenticated, go to main app
                return HomeScreen(
                  themeProvider: themeProvider, languageProvider: languageProvider,
                  // isLogin: true,
                  //languageProvider: languageProvider,
                );
              } else {
                // User is not authenticated, go to create account
                return OnboardingScreen(
                  themeProvider: themeProvider,
                  // languageProvider: languageProvider,
                 // languageProvider: languageProvider,
                );
              }
            },
          ),
        );
      },
    );
  }
}


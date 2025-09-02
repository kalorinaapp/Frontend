import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'camera/scan_page.dart' show ScanPage;
import 'health/health_sync_page.dart' show HealthSyncPage;
import 'onboarding_screen.dart';
import 'providers/theme_provider.dart';

void main() async {


  // await Supabase.initialize(url: 'SUPABASE_URL', anonKey: 'SUPABASE_ANON_KEY');
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Cal AI - Scan & Log Meals',
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemGreen,
        brightness: Brightness.light,
      ),
      home: ScanPage(),
      //OnboardingScreen(themeProvider: ThemeProvider()),
    );
  }
}

class MainAppContent extends StatefulWidget {
  const MainAppContent({super.key});

  @override
  State<MainAppContent> createState() => _MainAppContentState();
}

class _MainAppContentState extends State<MainAppContent> {
  late ThemeProvider themeProvider;

  @override
  void initState() {
    super.initState();
    themeProvider = ThemeProvider();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, child) {
        return CupertinoApp(
          debugShowCheckedModeBanner: false,
          title: 'Cal AI - Scan & Log Meals',
          theme: CupertinoThemeData(
            primaryColor: CupertinoColors.systemGreen,
            brightness: themeProvider.isLightMode 
                ? Brightness.light 
                : Brightness.dark,
          ),
          home: OnboardingScreen(themeProvider: themeProvider),
        );
      },
    );
  }
}

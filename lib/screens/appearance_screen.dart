import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:get/get.dart';
import '../utils/theme_helper.dart' show ThemeHelper;
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  late ThemeProvider themeProvider;
  
  @override
  void initState() {
    super.initState();
    themeProvider = Get.find<ThemeProvider>();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: ThemeHelper.background,
            border: null,
            leading: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: SvgPicture.asset(
                colorFilter: ColorFilter.mode(
                  ThemeHelper.textPrimary,
                  BlendMode.srcIn,
                ),
                'assets/icons/back.svg',
                width: 20,
                height: 20,
              ),
            ),
          ),
          backgroundColor: ThemeHelper.background,
          child: Column(
            children: [
              // Header with back button and title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Spacer(),
                    
                    // Settings icon and title
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Settings gear icon
                        Image.asset(
                          'assets/icons/settings.png', 
                          width: 30, 
                          height: 30,
                          color: ThemeHelper.textPrimary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.appearance,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: ThemeHelper.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Theme options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Light theme option
                    _buildThemeOption(
                      title: l10n.light,
                      themeMode: ThemeMode.light,
                      isSelected: themeProvider.themeMode == ThemeMode.light,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Dark theme option
                    _buildThemeOption(
                      title: l10n.dark,
                      themeMode: ThemeMode.dark,
                      isSelected: themeProvider.themeMode == ThemeMode.dark,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Automatic theme option
                    _buildThemeOption(
                      title: l10n.automatic,
                      themeMode: ThemeMode.automatic,
                      isSelected: themeProvider.themeMode == ThemeMode.automatic,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required String title,
    required ThemeMode themeMode,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        await themeProvider.setThemeMode(themeMode);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? ThemeHelper.textPrimary 
              : ThemeHelper.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? ThemeHelper.textPrimary 
                : ThemeHelper.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.isLightMode
                  ? CupertinoColors.black.withOpacity(0.05)
                  : CupertinoColors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isSelected 
                ? ThemeHelper.background 
                : ThemeHelper.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

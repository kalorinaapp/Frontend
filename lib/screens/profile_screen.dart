import 'package:flutter/cupertino.dart';
import '../l10n/app_localizations.dart' show AppLocalizations;
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../utils/theme_helper.dart';
import 'health_consistency_screen.dart';

class ProfileScreen extends StatelessWidget {
  final ThemeProvider themeProvider;
  final LanguageProvider languageProvider;

  const ProfileScreen({
    super.key, 
    required this.themeProvider,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: Listenable.merge([themeProvider, languageProvider]),
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: ThemeHelper.background,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: ThemeHelper.background,
            border: Border(
              bottom: BorderSide(
                color: ThemeHelper.divider,
                width: 0.5,
              ),
            ),
            middle: Text(
              l10n.settings,
              style: ThemeHelper.textStyleWithColor(
                ThemeHelper.headline,
                ThemeHelper.textPrimary,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Language Section
                  Text(
                    'Language / Jezik',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Language Selection Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: LanguageProvider.supportedLanguages.entries
                          .map((entry) => _buildLanguageOption(
                                context,
                                entry.key,
                                entry.value,
                              ))
                          .toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Other Settings Section
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Settings Cards
                  _buildSettingsCard(
                    icon: CupertinoIcons.person,
                    title: 'Account',
                    subtitle: 'Manage your profile and account settings',
                    onTap: () {
                      // TODO: Navigate to account settings
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSettingsCard(
                    icon: CupertinoIcons.heart,
                    title: 'Health Tracking',
                    subtitle: 'View your health consistency and progress',
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => HealthConsistencyScreen(
                            themeProvider: themeProvider,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSettingsCard(
                    icon: CupertinoIcons.bell,
                    title: 'Notifications',
                    subtitle: 'Configure your notification preferences',
                    onTap: () {
                      // TODO: Navigate to notification settings
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSettingsCard(
                    icon: CupertinoIcons.info,
                    title: 'About',
                    subtitle: 'App version and information',
                    onTap: () {
                      // TODO: Navigate to about page
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String languageCode, String languageName) {
    final isSelected = languageProvider.currentLocale.languageCode == languageCode;
    
    return GestureDetector(
      onTap: () => languageProvider.changeLanguage(languageCode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
            ? CupertinoColors.systemBlue.withOpacity(0.1)
            : CupertinoColors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
            ? Border.all(color: CupertinoColors.systemBlue, width: 1)
            : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.black,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                CupertinoIcons.check_mark,
                color: CupertinoColors.systemBlue,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: CupertinoColors.systemGrey,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey3,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:get/get.dart';
import '../utils/theme_helper.dart' show ThemeHelper;
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  // Language mapping with codes and flags - names will come from localizations
  final List<Map<String, String>> languages = [
    {'code': 'en', 'flag': '🇬🇧'},
    {'code': 'bs', 'flag': '🇧🇦'},
    {'code': 'hr', 'flag': '🇭🇷'},
    {'code': 'sr', 'flag': '🇷🇸'},
  ];

  // Method to get localized language name
  String _getLanguageName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'en':
        return l10n.english;
      case 'hr':
        return l10n.hrvatski;
      case 'sr':
        return l10n.srpski;
      case 'bs':
        return l10n.bosanski;
      case 'sl':
        return l10n.slovenscina;
      case 'cg':
        return 'Crnogorski'; // Hardcoded for Montenegrin
      case 'mk':
        return 'Македонски'; // Hardcoded for Macedonian
      case 'bg':
        return l10n.bulgarski;
      case 'ro':
        return l10n.romana;
      case 'hu':
        return l10n.magyar;
      default:
        return code.toUpperCase();
    }
  }

  late LanguageProvider languageController;
  
  @override
  void initState() {
    super.initState();
    debugPrint('LanguageSelectionScreen initialized');
    languageController = Get.find<LanguageProvider>();
    debugPrint('LanguageProvider found: ${languageController.currentLocale}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: ThemeHelper.background,
        border: null,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: SvgPicture.asset(
            color: ThemeHelper.textPrimary,
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
                
                // Language icon and title
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Language translate icon
                    Image.asset('assets/icons/languages.png', width: 30, height: 30),
                    const SizedBox(width: 12),
                    Text(
                      l10n.language,
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
          
          // Language list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: languages.map((language) {
                  final isSelected = languageController.currentLocale.languageCode == language['code'];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        debugPrint('Language selected: ${language['code']}');
                        try {
                          // Use controller to change language and rebuild UI
                          await languageController.changeLanguage(language['code']!);
                          setState(() {}); // Trigger rebuild after language change
                          
                          debugPrint('Language changed successfully, returning to previous screen');
                          // Return the selected language code
                          Navigator.of(context).pop(language['code']);
                        } catch (e) {
                          debugPrint('Error changing language: $e');
                          Navigator.of(context).pop(language['code']);
                        }
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getLanguageName(language['code']!, l10n),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isSelected 
                                    ? ThemeHelper.background 
                                    : ThemeHelper.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              language['flag']!,
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../providers/theme_provider.dart' show ThemeProvider;
import '../controller/onboarding.controller.dart';
import '../../utils/theme_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/page_animations.dart';
import '../../providers/language_provider.dart';
import '../../screens/language_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalorieTrackingExperiencePage extends StatefulWidget {
  final ThemeProvider themeProvider;
  
  const CalorieTrackingExperiencePage({
    super.key,
    required this.themeProvider,
  });

  @override
  State<CalorieTrackingExperiencePage> createState() => _CalorieTrackingExperiencePageState();
}

class _CalorieTrackingExperiencePageState extends State<CalorieTrackingExperiencePage> 
    with SingleTickerProviderStateMixin {
  final OnboardingController _controller = Get.find<OnboardingController>();
  String? _selectedOption;
  
  late AnimationController _animationController;
  late Animation<double> _titleAnimation;
  late List<Animation<double>> _cardAnimations;
  
  // Language state
  LanguageProvider? _languageProvider;
  String _currentLanguageCode = 'en';
  String _currentLanguageFlag = '🇬🇧';

  List<Map<String, String>> _getOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'value': 'tried_stopped',
        'text': l10n.triedButStopped,
      },
      {
        'value': 'never_complex',
        'text': l10n.neverSeemComplex,
      },
      {
        'value': 'yes_still_doing',
        'text': l10n.yesStillDoing,
      },
    ];
  }

  @override
  void initState() {
    super.initState();

    // Load previously saved selection if any
    _selectedOption = _controller.getStringData('calorie_tracking_experience');
    
    // Load language provider and current language
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _languageProvider = Get.find<LanguageProvider>();
      } catch (e) {
        debugPrint('LanguageProvider not found: $e');
      }
      _loadCurrentLanguage();
    });
    
    // Setup animations using global animations helper
    _animationController = AnimationController(
      vsync: this,
      duration: PageAnimations.standardDuration,
    );
    
    _titleAnimation = PageAnimations.createTitleAnimation(_animationController);
    
    final cardAnimation = PageAnimations.createContentAnimation(_animationController);
    
    // Use the same animation for all cards
    _cardAnimations = List.generate(3, (index) => cardAnimation);
    
    // Start animations
    _animationController.forward();
  }
  
  // Load current language from shared preferences
  Future<void> _loadCurrentLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String savedLanguage = prefs.getString('selected_language') ?? 'hr';
      
      final languageInfo = _getLanguageInfo(savedLanguage);
      
      setState(() {
        _currentLanguageCode = savedLanguage;
        _currentLanguageFlag = languageInfo['flag'] ?? '🇬🇧';
      });
    } catch (e) {
      debugPrint('Error loading language: $e');
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
      'cg': {'code': 'cg', 'name': 'Crnogorski', 'flag': '🇲🇪'},
      'mk': {'code': 'mk', 'name': 'Македонски', 'flag': '🇲🇰'},
      'bg': {'code': 'bg', 'name': 'Български', 'flag': '🇧🇬'},
      'ro': {'code': 'ro', 'name': 'Română', 'flag': '🇷🇴'},
      'hu': {'code': 'hu', 'name': 'Magyar', 'flag': '🇭🇺'},
    };
    
    return languages[code] ?? {'code': 'en', 'name': 'English', 'flag': '🇬🇧'};
  }

  // Language changer widget
  Widget _buildLanguageChanger() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        try {
          final result = await Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => LanguageSelectionScreen()),
          );
          
          // Reload language after returning from selection screen
          if (result != null || mounted) {
            await _loadCurrentLanguage();
            _controller.validateCurrentPage();
          }
        } catch (e) {
          debugPrint('Error navigating to language selection: $e');
        }
      },
      child: Container(
        width: 64,
        height: 32,
        decoration: BoxDecoration(
          color: ThemeHelper.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeHelper.divider,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.isLightMode 
                  ? CupertinoColors.black.withOpacity(0.1)
                  : CupertinoColors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentLanguageFlag,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              _currentLanguageCode.toUpperCase(),
              style: ThemeHelper.textStyleWithColorAndSize(
                ThemeHelper.caption1,
                ThemeHelper.textPrimary,
                10,
              ).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectOption(String value) {
    setState(() {
      _selectedOption = value;
    });
    
    // Save to controller and log
    _controller.setStringData('calorie_tracking_experience', value);
    debugPrint('📊 Calorie tracking experience selected: $value');
    

  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = _getOptions(context);
    
    return ListenableBuilder(
      listenable: _languageProvider != null 
          ? Listenable.merge([widget.themeProvider, _languageProvider])
          : widget.themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: ThemeHelper.background,
          child: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 1),
                      
                      // Title with fade and gentle scale animation
                      PageAnimations.animatedTitle(
                        animation: _titleAnimation,
                        child: Text(
                          l10n.haveYouCountedCalories,
                          style: ThemeHelper.textStyleWithColorAndSize(
                            ThemeHelper.headline,
                            ThemeHelper.textPrimary,
                            28,
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Options with fade appear animations
                      ...List.generate(options.length, (index) {
                        final option = options[index];
                        final isSelected = _selectedOption == option['value'];
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: PageAnimations.animatedContent(
                            animation: _cardAnimations[index],
                            child: _buildOptionCard(
                              text: option['text']!,
                              value: option['value']!,
                              isSelected: isSelected,
                            ),
                          ),
                        );
                      }),
                      
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
              // Language changer positioned in top-right
              Positioned(
                top: 20,
                right: 16,
                child: _buildLanguageChanger(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionCard({
    required String text,
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectOption(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
            if (isSelected)
              BoxShadow(
                color: ThemeHelper.textPrimary.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            else
              BoxShadow(
                color: ThemeHelper.isLightMode 
                    ? CupertinoColors.black.withOpacity(0.04)
                    : CupertinoColors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          style: ThemeHelper.textStyleWithColorAndSize(
            ThemeHelper.body1,
            isSelected 
                ? ThemeHelper.background
                : ThemeHelper.textPrimary,
            16,
          ).copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}


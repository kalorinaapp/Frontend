import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../providers/theme_provider.dart' show ThemeProvider;
import '../controller/onboarding.controller.dart';
import '../../utils/theme_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/page_animations.dart';

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
    
    return CupertinoPageScaffold(
      backgroundColor: ThemeHelper.background,
      child: SafeArea(
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


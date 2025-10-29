import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;
import '../../../utils/page_animations.dart';

class HearAboutUsPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const HearAboutUsPage({super.key, required this.themeProvider});

  @override
  State<HearAboutUsPage> createState() => _HearAboutUsPageState();
}

class _HearAboutUsPageState extends State<HearAboutUsPage> 
    with SingleTickerProviderStateMixin {
  late OnboardingController _controller;
  late AnimationController _animationController;
  late Animation<double> _titleAnimation;
  late List<Animation<double>> _optionAnimations;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _titleAnimation = PageAnimations.createTitleAnimation(_animationController);
    
    // Staggered animations for 7 options
    _optionAnimations = List.generate(7, (index) {
      final startInterval = 0.25 + (index * 0.09);
      final endInterval = (startInterval + 0.25).clamp(0.0, 1.0);
      
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
        ),
      );
    });
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Title with animation
            PageAnimations.animatedTitle(
              animation: _titleAnimation,
              child: Center(
                child: Text(
                  localizations.whereDidYouHearAboutUs,
                  style: ThemeHelper.title3.copyWith(
                    color: ThemeHelper.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Selection options
            Column(
              children: [
                // Option 1: Google Play
                _buildAnimatedOption(
                  index: 0,
                  value: 'google_play',
                  imagePath: 'assets/images/PlayStore.png',
                  label: localizations.googlePlay,
                ),
                
                // Option 2: YouTube
                _buildAnimatedOption(
                  index: 1,
                  value: 'youtube',
                  imagePath: 'assets/images/Youtube.png',
                  label: localizations.youtube,
                ),
                
                // Option 3: TikTok
                _buildAnimatedOption(
                  index: 2,
                  value: 'tiktok',
                  imagePath: 'assets/images/Tiktok.png',
                  label: localizations.tiktok,
                ),
                
                // Option 4: Instagram
                _buildAnimatedOption(
                  index: 3,
                  value: 'instagram',
                  imagePath: 'assets/images/Instagram.png',
                  label: localizations.instagram,
                ),
                
                // Option 5: Influencer
                _buildAnimatedOption(
                  index: 4,
                  value: 'influencer',
                  imagePath: 'assets/images/Influencer.png',
                  label: localizations.influencer,
                ),
                
                // Option 6: Friends or Family
                _buildAnimatedOption(
                  index: 5,
                  value: 'friends_family',
                  imagePath: 'assets/images/Friends.png',
                  label: localizations.friendsOrFamily,
                ),
                
                // Option 7: Other
                _buildAnimatedOption(
                  index: 6,
                  value: 'other',
                  imagePath: 'assets/images/Other.png',
                  label: localizations.other,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedOption({
    required int index,
    required String value,
    required String imagePath,
    required String label,
  }) {
    return PageAnimations.animatedContent(
      animation: _optionAnimations[index],
      child: Obx(() {
        final isSelected = _controller.getStringData('hear_about_us') == value;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: PageAnimations.animatedSelectionCard(
            isSelected: isSelected,
            onTap: () {
              _controller.setStringData('hear_about_us', value);
            },
            selectedColor: ThemeHelper.textPrimary,
            unselectedColor: ThemeHelper.cardBackground,
            selectedBorderColor: ThemeHelper.textPrimary,
            unselectedBorderColor: ThemeHelper.divider,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Image.asset(imagePath, width: 48, height: 48),
                  const SizedBox(width: 12),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    style: ThemeHelper.headline.copyWith(
                      color: isSelected ? ThemeHelper.background : ThemeHelper.textPrimary,
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

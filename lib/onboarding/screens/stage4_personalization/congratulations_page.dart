import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;
import '../../../utils/page_animations.dart';

class CongratulationsPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const CongratulationsPage({super.key, required this.themeProvider});

  @override
  State<CongratulationsPage> createState() => _CongratulationsPageState();
}

class _CongratulationsPageState extends State<CongratulationsPage> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _withKalorinaAnim;
  late Animation<double> _withoutKalorinaAnim;
  
  late AnimationController _entranceController;
  late Animation<double> _titleAnimation;
  late Animation<double> _descriptionAnimation;
  late Animation<double> _progressLabelAnimation;
  late Animation<double> _progressCardAnimation;

  @override
  void initState() {
    super.initState();
    Get.find<OnboardingController>();

    // Progress bar animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _withKalorinaAnim = Tween<double>(begin: 0.0, end: 0.72).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _withoutKalorinaAnim = Tween<double>(begin: 0.0, end: 0.18).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    // Entrance animations
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _titleAnimation = PageAnimations.createTitleAnimation(_entranceController);
    
    _descriptionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _progressLabelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    
    _progressCardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    // Start entrance animations first
    _entranceController.forward();
    
    // Kick off progress animation slightly delayed
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(color: ThemeHelper.background),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Big left-aligned title with animation
              PageAnimations.animatedTitle(
                animation: _titleAnimation,
                child: Text(
                  localizations.wellDoneBigStep,
                  style: ThemeHelper.title1.copyWith(
                    fontSize: 34,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: ThemeHelper.textPrimary,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),

              const SizedBox(height: 28),

              // Rich paragraph with bold spans with animation
              PageAnimations.animatedContent(
                animation: _descriptionAnimation,
                child: RichText(
                  text: TextSpan(
                    style: ThemeHelper.body1.copyWith(
                      color: ThemeHelper.textPrimary,
                      height: 1.4,
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(text: localizations.calorieTrackingPart1),
                      TextSpan(text: localizations.scientificallyProvenMethod, style: const TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: localizations.calorieTrackingPart2),
                      TextSpan(text: localizations.twiceFaster, style: const TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: localizations.calorieTrackingPart3),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Section title with animation
              PageAnimations.animatedContent(
                animation: _progressLabelAnimation,
                child: Text(
                  localizations.yourProgress,
                  style: ThemeHelper.title2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ThemeHelper.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Progress card with animated bars
              PageAnimations.animatedContent(
                animation: _progressCardAnimation,
                child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeHelper.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _ProgressRow(
                          leadingImagePath: 'assets/icons/app_logo.png', // replace with your PNG
                          title: localizations.withKalorina,
                          progress: _withKalorinaAnim.value,
                          gradientColors: const [Color(0xFFEE2E5A), Color(0xFFF29F05)],
                          trailingWidth: 56,
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/icons/check.png', width: 24, height: 24, errorBuilder: (_, ___, __) => Icon(CupertinoIcons.check_mark_circled_solid, size: 20, color: ThemeHelper.textPrimary)),
                              const SizedBox(height: 6),
                              Text(
                                localizations.twiceMultiplier,
                                style: ThemeHelper.subhead.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: ThemeHelper.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        _ProgressRow(
                          leadingImagePath: null, // provide hourglass PNG later
                          leadingFallbackIcon: CupertinoIcons.hourglass,
                          title: localizations.withoutKalorina,
                          progress: _withoutKalorinaAnim.value,
                          gradientColors: const [Color(0xFFEE2E5A), Color(0xFFF29F05)],
                          trailingWidth: 56,
                        ),
                      ],
                    ),
                  );
                },
              ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String? leadingImagePath;
  final IconData? leadingFallbackIcon;
  final String title;
  final double progress; // 0..1
  final List<Color> gradientColors;
  final Widget? trailing;
  final double? trailingWidth;

  const _ProgressRow({
    required this.leadingImagePath,
    this.leadingFallbackIcon,
    required this.title,
    required this.progress,
    required this.gradientColors,
    this.trailing,
    this.trailingWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Leading icon/image (fixed width so text/progress don't shift when asset size changes)
        Padding(
          padding: const EdgeInsets.only(left: 0.0, right: 10.0),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: leadingImagePath != null
                  ? Image.asset(
                      leadingImagePath!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      color: ThemeHelper.isLightMode ? null : ThemeHelper.textPrimary,
                      errorBuilder: (_, __, ___) => Icon(
                        leadingFallbackIcon ?? CupertinoIcons.circle,
                        size: 22,
                        color: ThemeHelper.textPrimary,
                      ),
                    )
                  : Icon(
                      leadingFallbackIcon ?? CupertinoIcons.circle,
                      size: 24,
                      color: ThemeHelper.textPrimary,
                    ),
            ),
          ),
        ),

        // Title and bar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ThemeHelper.subhead.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ThemeHelper.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              // Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  final double full = constraints.maxWidth;
                  final double filled = (progress.clamp(0, 1)) * full;
                  return Stack(
                    children: [
                      Container(
                        width: full,
                        height: 10,
                        decoration: BoxDecoration(
                          color: ThemeHelper.divider,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        width: filled,
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),
        SizedBox(
          width: trailingWidth ?? 0,
          child: Center(child: trailing ?? const SizedBox.shrink()),
        ),
      ],
    );
  }
}

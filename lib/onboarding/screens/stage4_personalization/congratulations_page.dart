import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

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

  @override
  void initState() {
    super.initState();
    Get.find<OnboardingController>();

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

    // Kick off animation slightly delayed to feel responsive
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: CupertinoColors.white),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Big left-aligned title (2 lines)
              Text(
                'Well done! You just took\na big step.',
                style: ThemeHelper.title1.copyWith(
                  fontSize: 34,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1822),
                ),
                textAlign: TextAlign.left,
              ),

              const SizedBox(height: 28),

              // Rich paragraph (Croatian copy with bold spans)
              RichText(
                text: TextSpan(
                  style: ThemeHelper.body1.copyWith(
                    color: const Color(0xFF1E1822),
                    height: 1.4,
                    fontSize: 16,
                  ),
                  children: const [
                    TextSpan(text: 'Jeste li znali da je praćenje kalorija '),
                    TextSpan(text: 'znanstveno dokazana metoda', style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: ' ostvarivanja vaših ciljeva – i to i do '),
                    TextSpan(text: 'dvostruko brže', style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: '?'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Section title
              Text(
                'Your progress',
                style: ThemeHelper.title2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1822),
                ),
              ),

              const SizedBox(height: 16),

              // Progress card with animated bars
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _ProgressRow(
                          leadingImagePath: 'assets/icons/apple.png', // replace with your PNG
                          title: 'With Kalorina',
                          progress: _withKalorinaAnim.value,
                          gradientColors: const [Color(0xFFEE2E5A), Color(0xFFF29F05)],
                          trailingWidth: 56,
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/icons/check.png', width: 24, height: 24, errorBuilder: (_, __, ___) => const Icon(CupertinoIcons.check_mark_circled_solid, size: 20)),
                              const SizedBox(height: 6),
                              Text(
                                '+2x',
                                style: ThemeHelper.subhead.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E1822),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        _ProgressRow(
                          leadingImagePath: null, // provide hourglass PNG later
                          leadingFallbackIcon: CupertinoIcons.hourglass,
                          title: 'Without Kalorina',
                          progress: _withoutKalorinaAnim.value,
                          gradientColors: const [Color(0xFFEE2E5A), Color(0xFFF29F05)],
                          trailingWidth: 56,
                        ),
                      ],
                    ),
                  );
                },
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
        // Leading icon/image
        Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 10.0),
          child: leadingImagePath != null
              ? Image.asset(
                  leadingImagePath!,
                  width: 22,
                  height: 22,
                  errorBuilder: (_, __, ___) => Icon(leadingFallbackIcon ?? CupertinoIcons.circle, size: 22, color: const Color(0xFF1E1822)),
                )
              : Icon(leadingFallbackIcon ?? CupertinoIcons.circle, size: 24, color: const Color(0xFF1E1822)),
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
                  color: const Color(0xFF1E1822),
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
                          color: const Color(0xFFD7D4DB),
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

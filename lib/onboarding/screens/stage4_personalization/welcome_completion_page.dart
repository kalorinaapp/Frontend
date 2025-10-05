import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import '../../../providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;
import '../../../utils/theme_helper.dart' show ThemeHelper;
import 'subscription_page.dart';

class WelcomeCompletionPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  final String userName;

  const WelcomeCompletionPage({
    super.key,
    required this.themeProvider,
    required this.userName,
  });

  @override
  State<WelcomeCompletionPage> createState() => _WelcomeCompletionPageState();
}

class _WelcomeCompletionPageState extends State<WelcomeCompletionPage>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _navigateToSubscription() {
    // Navigate to subscription page
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => SubscriptionPage(
          themeProvider: widget.themeProvider,
          userName: widget.userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemBackground,
          navigationBar: CupertinoNavigationBar(
            leading: GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                // _previousPage();
                              },
                              child: SvgPicture.asset(
                                color: ThemeHelper.textPrimary,
                                'assets/icons/back.svg',
                                width: 20,
                                height: 20,
                              ),
                            ),
            backgroundColor: CupertinoColors.systemBackground,
            border: null,
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Title
                      Text(
                        l10n.startTrackingToday,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Feature cards
                      _buildFeatureCard(
                        image: 'assets/images/completion_assets.png',
                        title: l10n.photoYourMeal,
                        subtitle: l10n.photoYourMealDesc,
                        hasCorners: true,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildFeatureCard(
                        icon: CupertinoIcons.flame,
                        title: l10n.totalCalories,
                        subtitle: l10n.controlCaloriesEffortlessly,
                        iconBackground: CupertinoColors.white,
                        showCalorieInfo: true,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildFeatureCard(
                        icon: CupertinoIcons.chart_bar,
                        title: l10n.achieveGoalsFaster,
                        subtitle: l10n.achieveGoalsDesc,
                        customIcon: _buildProgressIcon(),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Notification permission section
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Icon(
                                      CupertinoIcons.bell,
                                      color: CupertinoColors.systemGrey,
                                      size: 20,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemRed,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                l10n.notificationReminder,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.systemGrey,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Continue button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: CupertinoColors.black,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _navigateToSubscription,
                          child: Text(
                            l10n.tryForFree,
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Free trial info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.freeTrialInfo,
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey2,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard({
    String? image,
    IconData? icon,
    Widget? customIcon,
    required String title,
    required String subtitle,
    bool hasCorners = false,
    Color? iconBackground,
    bool showCalorieInfo = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CupertinoColors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Icon or Image section
          if (image != null)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
              child: hasCorners
                ? Stack(
                    children: [
                      // Corner brackets
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _buildCornerBracket(true, true),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: _buildCornerBracket(true, false),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: _buildCornerBracket(false, true),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: _buildCornerBracket(false, false),
                      ),
                    ],
                  )
                : null,
            )
          else if (showCalorieInfo)
            Container(
              width: 160,
              height: 80,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconBackground ?? CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
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
                      icon!,
                      color: CupertinoColors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ukupno',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.black,
                          ),
                        ),
                        Text(
                          '670 Kalorija',
                          style: TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.systemGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else if (customIcon != null)
            Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: iconBackground ?? CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
              ),
              child: customIcon,
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconBackground ?? CupertinoColors.systemGrey6,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon!,
                color: CupertinoColors.black,
                size: 24,
              ),
            ),
          
          const SizedBox(height: 20),
          
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.white.withOpacity(0.8),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBracket(bool isTop, bool isLeft) {
    return Container(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: CornerBracketPainter(
          isTop: isTop,
          isLeft: isLeft,
          color: CupertinoColors.white,
          strokeWidth: 2.0,
        ),
      ),
    );
  }

  Widget _buildProgressIcon() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildProgressBar(20, false),
          const SizedBox(width: 4),
          _buildProgressBar(35, false),
          const SizedBox(width: 4),
          _buildProgressBar(50, false),
          const SizedBox(width: 4),
          _buildProgressBar(65, true),
          const SizedBox(width: 8),
          Icon(
            CupertinoIcons.flag_fill,
            color: CupertinoColors.black,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double height, bool isActive) {
    return Container(
      width: 12,
      height: height,
      decoration: BoxDecoration(
        color: isActive ? CupertinoColors.black : CupertinoColors.systemGrey4,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class CornerBracketPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final Color color;
  final double strokeWidth;

  CornerBracketPainter({
    required this.isTop,
    required this.isLeft,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    if (isTop && isLeft) {
      // Top-left corner
      path.moveTo(size.width * 0.7, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height * 0.7);
    } else if (isTop && !isLeft) {
      // Top-right corner
      path.moveTo(size.width * 0.3, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height * 0.7);
    } else if (!isTop && isLeft) {
      // Bottom-left corner
      path.moveTo(0, size.height * 0.3);
      path.lineTo(0, size.height);
      path.lineTo(size.width * 0.7, size.height);
    } else {
      // Bottom-right corner
      path.moveTo(size.width, size.height * 0.3);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width * 0.3, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

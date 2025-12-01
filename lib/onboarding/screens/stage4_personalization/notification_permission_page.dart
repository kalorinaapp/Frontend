import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart'
    show OneSignal, OSLogLevel;
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../../utils/page_animations.dart';
import '../../../l10n/app_localizations.dart';
import '../../controller/onboarding.controller.dart';

class NotificationPermissionPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const NotificationPermissionPage({super.key, required this.themeProvider});

  @override
  State<NotificationPermissionPage> createState() => _NotificationPermissionPageState();
}

class _NotificationPermissionPageState extends State<NotificationPermissionPage>
    with TickerProviderStateMixin {
  late OnboardingController _controller;
  late AnimationController _fingerAnimationController;
  late Animation<double> _fingerAnimation;
  late AnimationController _pageAnimationController;
  late Animation<double> _titleAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _buttonsAnimation;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.isDualButtonMode.value = false;
    });

    
    // Initialize finger animation (existing)
    _fingerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fingerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fingerAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize page entrance animations (new)
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _titleAnimation = PageAnimations.createTitleAnimation(_pageAnimationController);
    
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageAnimationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    
    _buttonsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageAnimationController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );
    
    // Start the animations
    _startFingerAnimation();
    _pageAnimationController.forward();
  }

  void _startFingerAnimation() {
    _fingerAnimationController.repeat(reverse: true);
  }

  Future<void> _requestNotificationPermission() async {
    try {
      // iOS push notifications: initialize OneSignal before requesting permission
      if (Platform.isIOS) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
        OneSignal.Debug.setAlertLevel(OSLogLevel.none);
        OneSignal.consentRequired(true);
        // Initialize OneSignal with your App ID (must be set for permissions prompt to show)
        OneSignal.initialize(
            'c5fb6b72-40ad-4062-82ec-c576bd7709c8'); // TODO: replace with your real OneSignal App ID
        OneSignal.consentGiven(true);
        await OneSignal.Notifications.requestPermission(true);
      }
    } catch (e) {
      debugPrint('OneSignal initialization/permission error: $e');
    }
  }

  void _onAllowPressed() async {
    try {
      // Request notification permission when Allow is pressed
      await _requestNotificationPermission();
      
      // Move to next page
      _controller.goToNextPage();
    } catch (e) {
      print('Error handling allow button: $e');
      // Still move to next page even if there's an error
      _controller.goToNextPage();
    }
  }

  void _onDontAllowPressed() {
    // Move to next page without requesting permission
    _controller.goToNextPage();
  }

  @override
  void dispose() {
    _fingerAnimationController.dispose();
    _pageAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: 393,
      height: 852,
      decoration: BoxDecoration(color: ThemeHelper.background),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            
            // Title
            PageAnimations.animatedTitle(
              animation: _titleAnimation,
              child: Column(
                children: [
                  SizedBox(
                    width: 301,
                    child: Text(
                      l10n.enableNotificationsForBetterResults,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ThemeHelper.textPrimary,
                        fontSize: 30,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  SizedBox(
                    width: 311,
                    child: Text(
                      l10n.recommended,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ThemeHelper.textPrimary,
                        fontSize: 20,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Main notification card
            PageAnimations.animatedContent(
              animation: _cardAnimation,
              child: Container(
              width: 290,
              height: 197,
              decoration: ShapeDecoration(
                color: ThemeHelper.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bell icon with notification badge
                  Image.asset('assets/images/notifications.png', width: 100, height: 100,),
                  
                  const SizedBox(height: 20),
                  
                  // Description text
                  SizedBox(
                    width: 257,
                    child: Text(
                      l10n.kalorinaHelpsYouKeepTrack,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ThemeHelper.textPrimary,
                        fontSize: 18,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Buttons row
            PageAnimations.animatedContent(
              animation: _buttonsAnimation,
              child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Don't Allow button
                    GestureDetector(
                      onTap: _onDontAllowPressed,
                      child: Container(
                        width: 127,
                        height: 48,
                        decoration: ShapeDecoration(
                          color: ThemeHelper.cardBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            l10n.dontAllow,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ThemeHelper.textSecondary,
                              fontSize: 15,
                              fontFamily: 'Instrument Sans',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Allow button
                    GestureDetector(
                      onTap: _onAllowPressed,
                      child: Container(
                        width: 150,
                        height: 60,
                        decoration: const ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.50, 1.00),
                            end: Alignment(0.50, 0.00),
                            colors: [Color(0xFF7D7D7D), Color(0xFF1E1822)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            l10n.allow,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Instrument Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Animated finger emoji below Allow button
                AnimatedBuilder(
                  animation: _fingerAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(80, _fingerAnimation.value * 10 - 5),
                      child: Text(
                        '👆',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ],
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

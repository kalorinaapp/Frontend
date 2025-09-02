import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
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
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    
    // Initialize finger animation
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
    
    // Start the animation loop
    _startFingerAnimation();
    
    // Request notification permission on initialization
    _requestNotificationPermission();
  }

  void _startFingerAnimation() {
    _fingerAnimationController.repeat(reverse: true);
  }

  Future<void> _requestNotificationPermission() async {
    try {
      // Initialize notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
          print('Notification tapped: ${response.payload}');
        },
      );
      
      // Request permission on iOS
      final bool? result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      
      print('Notification permission result: $result');
    } catch (e) {
      print('Error requesting notification permission: $e');
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // Title
          Center(
            child: Text(
              'Ostvarite svoje ciljeve\nuz notifikacije',
              style: ThemeHelper.title2.copyWith(
                color: CupertinoColors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 120),
          
          // Notification permission text container
          Center(
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CupertinoColors.systemGrey6,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Kalorina would like to send you Notifications',
                style: ThemeHelper.body1.copyWith(
                  color: CupertinoColors.black,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Buttons row
          Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                // Don't Allow button
                GestureDetector(
                  onTap: _onDontAllowPressed,
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Don\'t Allow',
                      style: ThemeHelper.body1.copyWith(
                        color: CupertinoColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                const SizedBox(width: 48),
                
                // Allow button with finger emoji below
                Column(
                  children: [
                    GestureDetector(
                      onTap: _onAllowPressed,
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Allow',
                          style: ThemeHelper.body1.copyWith(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Animated finger emoji below Allow button
                    AnimatedBuilder(
                      animation: _fingerAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _fingerAnimation.value * 10 - 5),
                          child: const Text(
                            '👆',
                            style: TextStyle(fontSize: 36),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }
}

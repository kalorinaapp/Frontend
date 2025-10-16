import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../providers/theme_provider.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.isDualButtonMode.value = false;
    });

    
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
      width: 393,
      height: 852,
      decoration: const BoxDecoration(color: Colors.white),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            
            // Title
            SizedBox(
              width: 301,
              child: Text(
                'Enable notifications for better results',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF1E1822),
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
                '(Recommended)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF1E1822),
                  fontSize: 20,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Main notification card
            Container(
              width: 290,
              height: 197,
              decoration: const ShapeDecoration(
                color: Color(0xFFF8F7FC),
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
                      'Kalorina helps you keep track — Get daily reminders',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1E1822),
                        fontSize: 18,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Buttons row
            Column(
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
                        decoration: const ShapeDecoration(
                          color: Color(0xFFF8F7FC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Don\'t Allow',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0x7F1E1822),
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
                            'Allow',
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
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

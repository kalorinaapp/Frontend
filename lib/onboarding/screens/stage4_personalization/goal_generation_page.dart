// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class GoalGenerationPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  final String userName;

  const GoalGenerationPage({
    super.key,
    required this.themeProvider,
    required this.userName,
  });

  @override
  State<GoalGenerationPage> createState() => _GoalGenerationPageState();
}

class _GoalGenerationPageState extends State<GoalGenerationPage>
    with TickerProviderStateMixin {
  
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    // Hide navigation buttons
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.showNavigation.value = false;
    });

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      _progressController.forward();
    });

    // Navigate to next screen after completion
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _controller.showNavigation.value = true;
        _controller.goToNextPage();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    // Ensure navigation is restored if user leaves early
    _controller.showNavigation.value = true;
    super.dispose();
  }

  // void _navigateToNextScreen() {
  //   // Navigate to the next onboarding screen or dashboard
  //   Navigator.of(context).pop(); // For now, just go back
  // }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: ThemeHelper.background,
          // navigationBar: CupertinoNavigationBar(
          //   backgroundColor: CupertinoColors.systemBackground,
          //   border: null,
          //   leading: GestureDetector(
          //     onTap: () => Navigator.of(context).pop(),
          //     child: Container(
          //       width: 40,
          //       height: 40,
          //       decoration: BoxDecoration(
          //         color: CupertinoColors.white,
          //         shape: BoxShape.circle,
          //         boxShadow: [
          //           BoxShadow(
          //             color: CupertinoColors.black.withOpacity(0.1),
          //             blurRadius: 8,
          //             offset: const Offset(0, 2),
          //           ),
          //         ],
          //       ),
          //       child: const Icon(
          //         CupertinoIcons.back,
          //         color: CupertinoColors.black,
          //         size: 20,
          //       ),
          //     ),
          //   ),
          // ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    // Progress percentage
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Text(
                          "${(_progressAnimation.value * 100).round()}%",
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: ThemeHelper.textPrimary,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      l10n.generatingYourPlan,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelper.textPrimary,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Progress bar
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: ThemeHelper.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: constraints.maxWidth * _progressAnimation.value,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.shade700,
                                        Colors.red.shade400,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    
                    // Preparation list
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ThemeHelper.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: ThemeHelper.divider,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeHelper.isLightMode
                                ? CupertinoColors.black.withOpacity(0.05)
                                : CupertinoColors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.preparingFor,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: ThemeHelper.textPrimary,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildPreparationItem(l10n.calories),
                          const SizedBox(height: 12),
                          _buildPreparationItem(l10n.carbs),
                          const SizedBox(height: 12),
                          _buildPreparationItem(l10n.protein),
                          const SizedBox(height: 12),
                          _buildPreparationItem(l10n.fats),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Continue button

                    
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreparationItem(String title) {
    return Row(
      children: [
        Image.asset("assets/icons/check.png", width: 15, height: 15),
        const SizedBox(width: 8.0),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: ThemeHelper.textPrimary,
          ),
        ),
      ],
    );
  }
}

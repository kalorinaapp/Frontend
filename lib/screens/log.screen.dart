import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'dart:math' as math;

import '../constants/app_constants.dart';
import '../providers/theme_provider.dart' show ThemeProvider;
import '../utils/theme_helper.dart' show ThemeHelper;
import '../l10n/app_localizations.dart';
import 'log_food_screen.dart';
import 'log_exercise_screen.dart';

class LogScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  final VoidCallback? onExerciseLogged;
  const LogScreen({super.key, required this.themeProvider, this.onExerciseLogged});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  
  // Helper method to determine meal type based on current time
  String _getCurrentMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'breakfast';
    } else if (hour >= 11 && hour < 16) {
      return 'lunch';
    } else if (hour >= 16 && hour < 21) {
      return 'dinner';
    } else {
      return 'snacks';
    }
  }
  
  void _navigateToCardio() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => LogExerciseScreen(
          themeProvider: widget.themeProvider,
          onExerciseLogged: widget.onExerciseLogged,
        ),
      ),
    );
  }

  void _navigateToWeightTraining() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => LogExerciseScreen(
          themeProvider: widget.themeProvider,
          initialTabIndex: 1,
          onExerciseLogged: widget.onExerciseLogged,
        ),
      ),
    );
  }

  void _navigateToDescribeExercise() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => LogExerciseScreen(
          themeProvider: widget.themeProvider,
          initialTabIndex: 2,
          onExerciseLogged: widget.onExerciseLogged,
        ),
      ),
    );
  }

  void _navigateToDirectInputExercise() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => LogExerciseScreen(
          themeProvider: widget.themeProvider,
          initialTabIndex: 3,
          onExerciseLogged: widget.onExerciseLogged,
        ),
      ),
    );
  }

  void _navigateToMyMeals(int initialTabIndex) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => LogFoodScreen(
          themeProvider: widget.themeProvider,
          userId: AppConstants.userId,
          mealType: _getCurrentMealType(),
          initialTabIndex: initialTabIndex,
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return CupertinoPageScaffold(
      backgroundColor: ThemeHelper.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Log Title
                Text(
                  l10n.log,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ThemeHelper.textPrimary,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Exercise Section
                Text(
                  l10n.exercise,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.textSecondary,
                  ),
                ),
              const SizedBox(height: 16),
              
              // Exercise Cards
              _buildLogCard(
                iconAsset: 'assets/icons/heartbeat.png',
                // icon: CupertinoIcons.heart_fill,
                title: l10n.cardio,
                subtitle: l10n.cardioSubtitle,
                onTap: _navigateToCardio,
              ),
              const SizedBox(height: 12),
              
              _buildLogCard(
                iconAsset: 'assets/icons/weights.png',
                title: l10n.weightTraining,
                subtitle: l10n.weightTrainingSubtitle,
                onTap: _navigateToWeightTraining,
              ),
              const SizedBox(height: 12),
              
              _buildLogCard(
               iconAsset: 'assets/icons/stats.png',
                title: l10n.describeExercise,
                subtitle: l10n.describeExerciseSubtitle,
                onTap: _navigateToDescribeExercise,
              ),
              const SizedBox(height: 12),
              
              _buildLogCard(
                iconAsset: 'assets/icons/input.png',
                title: l10n.directInput,
                subtitle: l10n.directInputSubtitle,
                onTap: _navigateToDirectInputExercise,
              ),
              const SizedBox(height: 30),
              
              // Food Section
              Text(
                l10n.food,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: ThemeHelper.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Food Cards
              _buildLogCard(
                iconAsset: 'assets/icons/meat.png',
                title: l10n.myMeals,
                subtitle: l10n.myMealsSubtitle,
                onTap: () => _navigateToMyMeals(0),
              ),
      
              const SizedBox(height: 12),
              
              _buildLogCard(
                iconAsset: 'assets/icons/foods.png',
                title: l10n.myFoods,
                subtitle: l10n.myFoodsSubtitle,
                onTap: () => _navigateToMyMeals(1),
              ),
              const SizedBox(height: 12),
              
              _buildLogCard(
                iconAsset: 'assets/icons/bookmark.png',
                title: l10n.savedScans,
                subtitle: l10n.savedScansSubtitle,
                onTap: () => _navigateToMyMeals(3),
              ),
              const SizedBox(height: 12),
              
              _buildLogCard(
                iconAsset: 'assets/icons/input.png',
                title: l10n.directInputFood,
                subtitle: l10n.directInputFoodSubtitle,
                onTap: () => _navigateToMyMeals(4),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildLogCard({
    IconData? icon,
    String? iconAsset,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeHelper.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeHelper.divider,
            width: 1,
          ),
          boxShadow: CupertinoTheme.of(context).brightness == Brightness.dark
              ? []
              : [
                  BoxShadow(
                    color: ThemeHelper.textPrimary.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: ThemeHelper.textPrimary.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon
            Center(
              child: iconAsset != null
                  ? Image.asset(
                      iconAsset,
                      width: 24,
                      height: 24,
                      color: ThemeHelper.textPrimary,
                    )
                  : Icon(
                      icon,
                      color: ThemeHelper.textPrimary,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 16),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeHelper.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow
              Transform.rotate(
                angle: math.pi,
                child: SvgPicture.asset(
                  'assets/icons/back.svg',
                  color: ThemeHelper.textPrimary,
                  width: 12,
                  height: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
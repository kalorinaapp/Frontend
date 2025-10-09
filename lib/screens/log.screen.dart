import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'dart:math' as math;

import '../constants/app_constants.dart';
import '../providers/theme_provider.dart' show ThemeProvider;
import '../utils/theme_helper.dart' show ThemeHelper;
import 'log_food_screen.dart';
import 'log_exercise_screen.dart';

class LogScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  const LogScreen({super.key, required this.themeProvider});

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
        builder: (context) => LogExerciseScreen(themeProvider: widget.themeProvider),
      ),
    );
  }

  void _navigateToWeightTraining() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => LogExerciseScreen(
          themeProvider: widget.themeProvider,
          initialTabIndex: 1,
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
        ),
      ),
    );
  }

  void _navigateToMyMeals() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => LogFoodScreen(
          themeProvider: widget.themeProvider,
          userId: AppConstants.userId,
          mealType: _getCurrentMealType(),
        ),
      ),
    );
  }

  void _navigateToMyFoods() {
    // TODO: Implement my foods navigation
    print('Navigate to My Foods');
  }

  void _navigateToSavedScans() {
    // TODO: Implement saved scans navigation
    print('Navigate to Saved Scans');
  }

  void _navigateToDirectInputFood() {
    // TODO: Implement direct input food navigation
    print('Navigate to Direct Input Food');
  }

  @override
  Widget build(BuildContext context) {
    
    return CupertinoPageScaffold(
      backgroundColor: widget.themeProvider.isLightMode ? CupertinoColors.white : CupertinoColors.black,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Log Title
                const Text(
                  'Log',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Exercise Section
                const Text(
                  'Exercise',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Exercise Cards
                _buildLogCard(
                  iconAsset: 'assets/icons/heartbeat.png',
                  // icon: CupertinoIcons.heart_fill,
                  title: 'Cardio',
                  subtitle: 'Log runs, cycling, HIIT, or any endurance activity',
                  onTap: _navigateToCardio,
                ),
                const SizedBox(height: 12),
                
                _buildLogCard(
                  iconAsset: 'assets/icons/weights.png',
                  title: 'Weight Training',
                  subtitle: 'Track gym sessions, sets, and strength exercises',
                  onTap: _navigateToWeightTraining,
                ),
                const SizedBox(height: 12),
                
                _buildLogCard(
                 iconAsset: 'assets/icons/stats.png',
                  title: 'Describe Exercise',
                  subtitle: 'Let AI calculate calories burned',
                  onTap: _navigateToDescribeExercise,
                ),
                const SizedBox(height: 12),
                
                _buildLogCard(
                  iconAsset: 'assets/icons/input.png',
                  title: 'Direct Input',
                  subtitle: 'Type in calories burned yourself',
                  onTap: _navigateToDirectInputExercise,
                ),
                const SizedBox(height: 30),
                
                // Food Section
                const Text(
                  'Food',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Food Cards
                _buildLogCard(
                  iconAsset: 'assets/icons/meat.png',
                  title: 'My Meals',
                  subtitle: 'Track gym sessions, sets, and strength exercises',
                  onTap: _navigateToMyMeals,
                ),
                const SizedBox(height: 12),
                
                _buildLogCard(
                  iconAsset: 'assets/icons/foods.png',
                  title: 'My Foods',
                  subtitle: 'Let AI calculate calories burned',
                  onTap: _navigateToMyFoods,
                ),
                const SizedBox(height: 12),
                
                _buildLogCard(
                  iconAsset: 'assets/icons/bookmark.png',
                  title: 'Saved Scans',
                  subtitle: 'Type in calories burned yourself',
                  onTap: _navigateToSavedScans,
                ),
                const SizedBox(height: 12),
                
                _buildLogCard(
                  iconAsset: 'assets/icons/input.png',
                  title: 'Direct Input',
                  subtitle: 'Type in what you ate yourself',
                  onTap: _navigateToDirectInputFood,
                ),
                const SizedBox(height: 20),
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
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5E5E5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.04),
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
                    )
                  : Icon(
                      icon,
                      color: CupertinoColors.white,
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
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
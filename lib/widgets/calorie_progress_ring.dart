import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';

class CalorieProgressRing extends StatelessWidget {
  final int consumedCalories;
  final int dailyGoal;
  final int remainingCalories;

  const CalorieProgressRing({
    super.key,
    required this.consumedCalories,
    required this.dailyGoal,
    required this.remainingCalories,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = consumedCalories / dailyGoal;
    final double normalizedProgress = progress.clamp(0.0, 1.0);
    
    return Container(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ThemeHelper.cardBackground,
              border: Border.all(
                color: ThemeHelper.divider,
                width: 2,
              ),
            ),
          ),
          
          // Progress circle
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: normalizedProgress,
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(progress),
              ),
            ),
          ),
          
          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$consumedCalories',
                style: ThemeHelper.textStyleWithColorAndSize(
                  ThemeHelper.title1,
                  ThemeHelper.textPrimary,
                  36,
                ),
              ),
              Text(
                'calories',
                style: ThemeHelper.textStyleWithColor(
                  ThemeHelper.caption1,
                  ThemeHelper.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Goal: $dailyGoal',
                style: ThemeHelper.textStyleWithColor(
                  ThemeHelper.caption1,
                  ThemeHelper.textSecondary,
                ),
              ),
              if (remainingCalories > 0)
                Text(
                  '$remainingCalories left',
                  style: ThemeHelper.textStyleWithColor(
                    ThemeHelper.caption1,
                    CupertinoColors.systemGreen,
                  ),
                )
              else
                Text(
                  'Goal reached!',
                  style: ThemeHelper.textStyleWithColor(
                    ThemeHelper.caption1,
                    CupertinoColors.systemGreen,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) {
      return CupertinoColors.systemRed;
    } else if (progress < 0.8) {
      return CupertinoColors.systemOrange;
    } else if (progress < 1.0) {
      return CupertinoColors.systemYellow;
    } else {
      return CupertinoColors.systemGreen;
    }
  }
}

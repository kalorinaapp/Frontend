import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';

class NutritionSummary extends StatelessWidget {
  final int calories;
  final int goal;
  final int carbs;
  final int protein;
  final int fat;

  const NutritionSummary({
    super.key,
    required this.calories,
    required this.goal,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeHelper.divider,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Calories row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calories',
                style: ThemeHelper.textStyleWithColor(
                  ThemeHelper.headline,
                  ThemeHelper.textPrimary,
                ),
              ),
              Text(
                '$calories / $goal',
                style: ThemeHelper.textStyleWithColor(
                  ThemeHelper.headline,
                  ThemeHelper.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Calories progress bar
          LinearProgressIndicator(
            value: calories / goal,
            backgroundColor: ThemeHelper.divider,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getCalorieColor(calories / goal),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Macros row
          Row(
            children: [
              Expanded(
                child: _buildMacroItem(
                  'Carbs',
                  carbs,
                  CupertinoColors.systemOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMacroItem(
                  'Protein',
                  protein,
                  CupertinoColors.systemBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMacroItem(
                  'Fat',
                  fat,
                  CupertinoColors.systemYellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: ThemeHelper.textStyleWithColor(
            ThemeHelper.caption1,
            ThemeHelper.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${value}g',
          style: ThemeHelper.textStyleWithColor(
            ThemeHelper.caption1,
            ThemeHelper.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _getCalorieColor(double progress) {
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

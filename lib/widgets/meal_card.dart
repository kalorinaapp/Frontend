import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';

class MealCard extends StatelessWidget {
  final String mealType;
  final String time;
  final int calories;
  final List<String> items;

  const MealCard({
    super.key,
    required this.mealType,
    required this.time,
    required this.calories,
    required this.items,
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
      child: Row(
        children: [
          // Meal type icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getMealColor(mealType).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getMealIcon(mealType),
              color: _getMealColor(mealType),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Meal details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: ThemeHelper.textStyleWithColor(
                    ThemeHelper.headline,
                    ThemeHelper.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: ThemeHelper.textStyleWithColor(
                    ThemeHelper.caption1,
                    ThemeHelper.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  items.join(', '),
                  style: ThemeHelper.textStyleWithColor(
                    ThemeHelper.caption1,
                    ThemeHelper.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Calories
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$calories',
                style: ThemeHelper.textStyleWithColor(
                  ThemeHelper.headline,
                  ThemeHelper.textPrimary,
                ),
              ),
              Text(
                'cal',
                style: ThemeHelper.textStyleWithColor(
                  ThemeHelper.caption1,
                  ThemeHelper.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return CupertinoIcons.sunrise;
      case 'lunch':
        return CupertinoIcons.sun_max;
      case 'dinner':
        return CupertinoIcons.moon;
      case 'snacks':
        return CupertinoIcons.heart;
      default:
        return CupertinoIcons.circle;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return CupertinoColors.systemOrange;
      case 'lunch':
        return CupertinoColors.systemYellow;
      case 'dinner':
        return CupertinoColors.systemBlue;
      case 'snacks':
        return CupertinoColors.systemPurple;
      default:
        return CupertinoColors.systemGrey;
    }
  }
}

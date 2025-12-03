import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;

class FoodDetailScreen extends StatefulWidget {
  final String foodName;
  final int calories;
  final int carbs;
  final int protein;
  final int fats;

  const FoodDetailScreen({
    super.key,
    required this.foodName,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fats,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _selectedMeasurementIndex = 0;
  int _servings = 1;
  
  final List<String> _measurements = ['G', 'Small Breast', 'Oz', 'Medium Breast', 'Cup'];
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header with just back button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      'assets/icons/back.svg',
                      width: 24,
                      height: 24,
                      color: CupertinoColors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title in body
                      Center(
                        child: Text(
                          widget.foodName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Calories Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE8E8E8),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Flame icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5F5F5),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/icons/apple.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Calories',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF999999),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.calories}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Macros Row
                      Row(
                        children: [
                          // Carbohydrates
                          Expanded(
                            child: _buildMacroCard(
                              'Carbohydrates',
                              '${widget.carbs} g',
                              'assets/icons/carbs.png',
                              CupertinoColors.systemOrange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Protein
                          Expanded(
                            child: _buildMacroCard(
                              'Protein',
                              '${widget.protein} g',
                              'assets/icons/drumstick.png',
                              CupertinoColors.systemBlue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Fats
                          Expanded(
                            child: _buildMacroCard(
                              'Fats',
                              '${widget.fats} g',
                              'assets/icons/fat.png',
                              CupertinoColors.systemRed,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Measurement Section
                      const Text(
                        'Measurement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.black,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Measurement Pills
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _measurements.asMap().entries.map((entry) {
                            final index = entry.key;
                            final measurement = entry.value;
                            final isSelected = index == _selectedMeasurementIndex;
                            
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedMeasurementIndex = index;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? CupertinoColors.black : CupertinoColors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: const Color(0xFFE8E8E8),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    measurement,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? CupertinoColors.white : CupertinoColors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Slider Section - Full Width
                      Container(
                        width: double.infinity,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Stack(
                          children: [
                            // Progress
                            FractionallySizedBox(
                              widthFactor: 0.3, // 30% filled
                              child: Container(
                                decoration: BoxDecoration(
                                  color: CupertinoColors.black,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Number of servings
                      const Text(
                        'Number of servings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.black,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Servings Input
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Open number input for servings
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: const Color(0xFFE8E8E8),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$_servings',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: CupertinoColors.black,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  CupertinoIcons.pencil,
                                  size: 16,
                                  color: Color(0xFF666666),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Done Button
            Container(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () {
                  // TODO: Save food entry and navigate back
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.black,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    'Done',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCard(String label, String amount, String iconAsset, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Label as header with colored background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Image.asset(
                  iconAsset,
                  width: 16,
                  height: 16,
                  color: color,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Amount
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

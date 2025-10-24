import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../constants/app_constants.dart' show AppConstants;
import '../services/meals_service.dart';
import 'ingredient_details_screen.dart';
import 'edit_meal_name_screen.dart';
import 'edit_macro_screen.dart';
import '../utils/theme_helper.dart';

class MealDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> mealData;
  
  const MealDetailsScreen({
    super.key,
    required this.mealData,
  });

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  final MealsService _mealsService = const MealsService();
  late Map<String, dynamic> _currentMealData;
  int _servingAmount = 1;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentMealData = Map<String, dynamic>.from(widget.mealData);
  }

  Future<Map<String, dynamic>?> _saveScannedMeal() async {
    if (_isSaving) return null; // Prevent multiple saves
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      final userId = AppConstants.userId;
      final date = _currentMealData['date'] ?? '';
      final mealType = _currentMealData['mealType'] ?? '';
      final mealName = _currentMealData['mealName'] ?? '';
      
      // Clean up entries data - remove MongoDB-specific fields and internal IDs
      // Include userId and mealType in each entry (required by API)
      final rawEntries = (_currentMealData['entries'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      final entries = rawEntries.map((entry) {
        return {
          'userId': userId,
          'mealType': mealType,
          'foodName': entry['foodName'] ?? '',
          'quantity': entry['quantity'] ?? 1,
          'unit': entry['unit'] ?? 'g',
          'calories': entry['calories'] ?? 0,
          'protein': entry['protein'] ?? 0,
          'carbs': entry['carbs'] ?? 0,
          'fat': entry['fat'] ?? 0,
          'fiber': entry['fiber'] ?? 0,
          'sugar': entry['sugar'] ?? 0,
          'sodium': entry['sodium'] ?? 0,
          'servingSize': entry['servingSize'] ?? 1,
          'servingUnit': entry['servingUnit'] ?? 'serving',
        };
      }).toList();

      debugPrint('MealDetailsScreen: Saving scanned meal');
      debugPrint('MealDetailsScreen: userId=$userId, date=$date, mealType=$mealType');
      debugPrint('MealDetailsScreen: mealName=$mealName');
      debugPrint('MealDetailsScreen: entries count=${entries.length}');
      debugPrint('MealDetailsScreen: entries=$entries');
      
      final response = await _mealsService.saveCompleteMeal(
        userId: userId,
        date: date,
        mealType: mealType,
        mealName: mealName,
        entries: entries,
        notes: _currentMealData['notes'] ?? '',
        mealImage: _currentMealData['mealImage'],
      );
      
      if (response != null && response['success'] == true) {
        debugPrint('MealDetailsScreen: Scanned meal saved successfully - Response: $response');
        
        // Update local meal data with the response from server
        if (response['meal'] != null) {
          setState(() {
            _currentMealData = Map<String, dynamic>.from(response['meal'] as Map<String, dynamic>);
          });
        }
        
        // Return the saved meal data for optimistic update
        return response['meal'] as Map<String, dynamic>?;
      } else {
        debugPrint('MealDetailsScreen: Failed to save scanned meal - Response: $response');
        return null;
      }
    } catch (e) {
      debugPrint('MealDetailsScreen: Error saving scanned meal: $e');
      return null;
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _updateMeal() async {
    try {
      final mealId = _currentMealData['id'] ?? _currentMealData['_id'];
      final userId = AppConstants.userId;
      final date = _currentMealData['date'] ?? '';
      final mealType = _currentMealData['mealType'] ?? '';
      final mealName = _currentMealData['mealName'] ?? '';
      final isScanned = _currentMealData['isScanned'] ?? false;
      
      // For scanned meals, only save when explicitly requested (Save button pressed)
      if (isScanned && mealId == null) {
        debugPrint('MealDetailsScreen: Skipping automatic save for scanned meal - waiting for Save button');
        return;
      }
      
      // Clean up entries data - remove MongoDB-specific fields and internal IDs
      // Include userId and mealType in each entry (required by API)
      final rawEntries = (_currentMealData['entries'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      final entries = rawEntries.map((entry) {
        return {
          'userId': userId,
          'mealType': mealType,
          'foodName': entry['foodName'] ?? '',
          'quantity': entry['quantity'] ?? 1,
          'unit': entry['unit'] ?? 'g',
          'calories': entry['calories'] ?? 0,
          'protein': entry['protein'] ?? 0,
          'carbs': entry['carbs'] ?? 0,
          'fat': entry['fat'] ?? 0,
          'fiber': entry['fiber'] ?? 0,
          'sugar': entry['sugar'] ?? 0,
          'sodium': entry['sodium'] ?? 0,
          'servingSize': entry['servingSize'] ?? 1,
          'servingUnit': entry['servingUnit'] ?? 'serving',
        };
      }).toList();

      Map<String, dynamic>? response;
      
      if (mealId == null) {
        // Create new meal
        debugPrint('MealDetailsScreen: Creating new meal');
        debugPrint('MealDetailsScreen: userId=$userId, date=$date, mealType=$mealType');
        debugPrint('MealDetailsScreen: mealName=$mealName');
        debugPrint('MealDetailsScreen: entries count=${entries.length}');
        debugPrint('MealDetailsScreen: entries=$entries');
        
        response = await _mealsService.saveCompleteMeal(
          userId: userId,
          date: date,
          mealType: mealType,
          mealName: mealName,
          entries: entries,
          notes: _currentMealData['notes'] ?? '',
        );
        
        if (response != null && response['success'] == true) {
          debugPrint('MealDetailsScreen: Meal created successfully - Response: $response');
          
          // Update local meal data with the response from server
          if (response['meal'] != null) {
            setState(() {
              _currentMealData = Map<String, dynamic>.from(response!['meal'] as Map<String, dynamic>);
            });
          }
        } else {
          debugPrint('MealDetailsScreen: Failed to create meal - Response: $response');
        }
      } else {
        // Update existing meal
        debugPrint('MealDetailsScreen: Updating meal $mealId');
        debugPrint('MealDetailsScreen: userId=$userId, date=$date, mealType=$mealType');
        debugPrint('MealDetailsScreen: mealName=$mealName');
        debugPrint('MealDetailsScreen: entries count=${entries.length}');
        debugPrint('MealDetailsScreen: entries=$entries');
        
        response = await _mealsService.updateMeal(
          mealId: mealId.toString(),
          userId: userId,
          date: date,
          mealType: mealType,
          mealName: mealName,
          entries: entries,
          notes: _currentMealData['notes'] ?? '',
          isScanned: isScanned,
        );

        if (response != null && response['success'] == true) {
          debugPrint('MealDetailsScreen: Meal updated successfully - Response: $response');
          
          // Update local meal data with the response from server to stay in sync
          if (response['meal'] != null) {
            setState(() {
              _currentMealData = Map<String, dynamic>.from(response!['meal'] as Map<String, dynamic>);
            });
          }
        } else {
          debugPrint('MealDetailsScreen: Failed to update meal - Response: $response');
        }
      }
    } catch (e) {
      debugPrint('MealDetailsScreen: Error updating meal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealName = (_currentMealData['mealName'] as String?)?.trim() ?? 'Meal Details';
    final imageUrl = (_currentMealData['mealImage'] as String?)?.trim();
    final calories = (_currentMealData['totalCalories'] as num?)?.toInt() ?? 0;
    final protein = (_currentMealData['totalProtein'] as num?)?.toInt() ?? 0;
    final carbs = (_currentMealData['totalCarbs'] as num?)?.toInt() ?? 0;
    final fat = (_currentMealData['totalFat'] as num?)?.toInt() ?? 0;
    final entries = (_currentMealData['entries'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    return CupertinoPageScaffold(
      backgroundColor: ThemeHelper.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
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
                      color: ThemeHelper.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _navigateToEditMealName(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mealName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: ThemeHelper.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 8.0),
                          Icon(CupertinoIcons.pencil, size: 14, color: ThemeHelper.textPrimary),
                        ],
                      ),
                    ),
                  const SizedBox(width: 60), 
                    
                    // Meal Image with Amount Badge
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 106,
                              decoration: BoxDecoration(
                                color: ThemeHelper.cardBackground,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: ThemeHelper.textPrimary.withOpacity(0.2),
                                    blurRadius: 3,
                                    offset: Offset(0, 0),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  // Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Container(
                                      width: 91,
                                      height: 91,
                                      color: ThemeHelper.background,
                                      child: _buildImageWidget(imageUrl),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Amount badge
                                  GestureDetector(
                                    onTap: () => _showEditAmountSheet(context),
                                    child: Container(
                                      height: 30,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: ThemeHelper.background,
                                        borderRadius: BorderRadius.circular(13),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ThemeHelper.textPrimary.withOpacity(0.25),
                                            blurRadius: 5,
                                            offset: Offset(0, 0),
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$_servingAmount',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: ThemeHelper.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            CupertinoIcons.pencil,
                                            size: 14,
                                            color: ThemeHelper.textPrimary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Macros Row (3 cards)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMacroCard(
                              context,
                              'Carbs',
                              '$carbs g',
                              'assets/icons/carbs.png',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMacroCard(
                              context,
                              'Protein',
                              '$protein g',
                              'assets/icons/drumstick.png',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMacroCard(
                              context,
                              'Fats',
                              '$fat g',
                              'assets/icons/fat.png',
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Calories Card
                    GestureDetector(
                      onTap: () => _showEditCaloriesSheet(context),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ThemeHelper.cardBackground,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeHelper.textPrimary.withOpacity(0.25),
                              blurRadius: 5,
                              offset: Offset(0, 0),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset('assets/icons/flame_black.png', width: 28, height: 28, color: ThemeHelper.textPrimary),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Calories',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: ThemeHelper.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$calories',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: ThemeHelper.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Ingredients Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ThemeHelper.cardBackground,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeHelper.textPrimary.withOpacity(0.25),
                            blurRadius: 5,
                            offset: Offset(0, 0),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row with title and buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ingredients',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeHelper.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  // Fix Issue button
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: ThemeHelper.background,
                                      borderRadius: BorderRadius.circular(13),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ThemeHelper.textPrimary.withOpacity(0.25),
                                          blurRadius: 5,
                                          offset: Offset(0, 0),
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                        'assets/icons/Spark.svg',
                        width: 16,
                        height: 16,
                        color: ThemeHelper.textPrimary,
                      ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Fix Issue',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: ThemeHelper.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Add More button
                                  GestureDetector(
                                    onTap: () => _showAddIngredientSheet(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: ThemeHelper.background,
                                        borderRadius: BorderRadius.circular(13),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ThemeHelper.textPrimary.withOpacity(0.25),
                                            blurRadius: 5,
                                            offset: Offset(0, 0),
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Add More',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: ThemeHelper.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(CupertinoIcons.pencil, size: 14, color: ThemeHelper.textPrimary),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Ingredients list
                          if (entries.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'No ingredients available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ThemeHelper.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...entries.asMap().entries.map((entry) {
                              final index = entry.key;
                              final ingredient = entry.value;
                              final showDivider = index < entries.length - 1;
                              
                              return Column(
                                children: [
                                  _buildIngredientRow(ingredient),
                                  if (showDivider) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      height: 1.47,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 1,
                                            color: ThemeHelper.divider,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ],
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
            
            // Bottom Save/Done Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeHelper.cardBackground,
                boxShadow: [
                  BoxShadow(
                    color: ThemeHelper.textPrimary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: _isSaving ? null : () async {
                  // Check if this is a new scanned meal that needs to be saved
                  final mealId = _currentMealData['id'] ?? _currentMealData['_id'];
                  final isScanned = _currentMealData['isScanned'] ?? false;
                  
                  if (mealId == null && isScanned) {
                    // This is a new scanned meal - save it first
                    final savedMeal = await _saveScannedMeal();
                    if (savedMeal != null) {
                      // Return the saved meal data for optimistic update
                      Navigator.of(context).pop(savedMeal);
                      return;
                    }
                  }
                  
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 250,
                  height: 45,
                  decoration: BoxDecoration(
                    color: ThemeHelper.textPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: _isSaving 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CupertinoActivityIndicator(
                            color: ThemeHelper.background,
                          ),
                        )
                      : Text(
                          _getButtonText(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ThemeHelper.background,
                          ),
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

  String _getButtonText() {
    final mealId = _currentMealData['id'] ?? _currentMealData['_id'];
    final isScanned = _currentMealData['isScanned'] ?? false;
    
    // If it's a new scanned meal (no ID and isScanned is true), show "Save"
    if (mealId == null && isScanned) {
      return 'Save';
    }
    
    // Otherwise show "Done" for existing meals
    return 'Done';
  }

  Widget _buildImageWidget(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Center(
        child: Image.asset('assets/icons/apple.png', width: 24, height: 24),
      );
    }
    
    // Check if it's a local file path
    if (imageUrl.startsWith('/') || imageUrl.startsWith('file://')) {
      try {
        final file = File(imageUrl);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Image.asset('assets/icons/apple.png', width: 24, height: 24),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error loading local image: $e');
      }
    }
    
    // Check if it's a network URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CupertinoActivityIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Center(
          child: Image.asset('assets/icons/apple.png', width: 24, height: 24),
        ),
      );
    }
    
    // Fallback to default icon
    return Center(
      child: Image.asset('assets/icons/apple.png', width: 24, height: 24),
    );
  }

  Widget _buildMacroCard(BuildContext context, String label, String value, String iconAsset) {
    return GestureDetector(
      onTap: () => _navigateToEditMacro(context, label, value, iconAsset),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeHelper.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeHelper.divider,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.textPrimary.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: ThemeHelper.textPrimary.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Label as table header with gray background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: ThemeHelper.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(iconAsset, width: 12, height: 12, color: ThemeHelper.textPrimary),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.textSecondary,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
            // Amount as table content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeHelper.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientRow(Map<String, dynamic> ingredient) {
    final foodName = ingredient['foodName'] ?? '';
    final calories = (ingredient['calories'] as num?)?.toInt() ?? 0;
    
    // Debug logging to see what's in the ingredient
    debugPrint('Ingredient: $foodName, Calories: $calories');
    debugPrint('Full ingredient data: $ingredient');
    
    return GestureDetector(
      onTap: () => _navigateToIngredientDetails(ingredient),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 180,
                child: Text(
                  foodName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: ThemeHelper.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '$calories cal',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: ThemeHelper.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.pencil,
                size: 12,
                color: ThemeHelper.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToIngredientDetails(Map<String, dynamic> ingredient) async {
    final updatedIngredient = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => IngredientDetailsScreen(
          ingredientData: ingredient,
        ),
      ),
    );
    
    if (updatedIngredient != null) {
      // Find and update the ingredient in the entries list
      final entries = (_currentMealData['entries'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      final index = entries.indexWhere((e) => e['foodName'] == ingredient['foodName']);
      
      if (index != -1) {
        setState(() {
          entries[index] = updatedIngredient;
          _currentMealData['entries'] = entries;
          
          // Recalculate totals
          int totalCalories = 0;
          int totalProtein = 0;
          int totalCarbs = 0;
          int totalFat = 0;
          
          for (var entry in entries) {
            totalCalories += (entry['calories'] as num?)?.toInt() ?? 0;
            totalProtein += (entry['protein'] as num?)?.toInt() ?? 0;
            totalCarbs += (entry['carbs'] as num?)?.toInt() ?? 0;
            totalFat += (entry['fat'] as num?)?.toInt() ?? 0;
          }
          
          _currentMealData['totalCalories'] = totalCalories;
          _currentMealData['totalProtein'] = totalProtein;
          _currentMealData['totalCarbs'] = totalCarbs;
          _currentMealData['totalFat'] = totalFat;
        });
        
        // Update meal on server (skip for scanned meals)
        final isScanned = _currentMealData['isScanned'] ?? false;
        final mealId = _currentMealData['id'] ?? _currentMealData['_id'];
        if (!isScanned || mealId != null) {
          await _updateMeal();
        }
      }
    }
  }

  void _showEditAmountSheet(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: '$_servingAmount');
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeHelper.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            Text(
              'Enter Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeHelper.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            
            CupertinoTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              placeholder: 'Enter amount',
              style: TextStyle(fontSize: 16, color: ThemeHelper.textPrimary),
              decoration: BoxDecoration(
                border: Border.all(
                  color: ThemeHelper.divider,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              autofocus: true,
            ),
            
            const Spacer(),
            
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: ThemeHelper.textSecondary),
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    color: ThemeHelper.textPrimary,
                    onPressed: () {
                      final newAmount = int.tryParse(controller.text) ?? 1;
                      setState(() {
                        _servingAmount = newAmount;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(color: ThemeHelper.background),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCaloriesSheet(BuildContext context) {
    final calories = (_currentMealData['totalCalories'] as num?)?.toInt() ?? 0;
    final TextEditingController controller = TextEditingController(text: calories.toString());
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeHelper.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            Text(
              'Enter Calories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeHelper.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            
            CupertinoTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              placeholder: 'Enter calories',
              style: TextStyle(fontSize: 16, color: ThemeHelper.textPrimary),
              decoration: BoxDecoration(
                border: Border.all(
                  color: ThemeHelper.divider,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              autofocus: true,
            ),
            
            const Spacer(),
            
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: ThemeHelper.textSecondary),
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    color: ThemeHelper.textPrimary,
                    onPressed: () async {
                      final newCalories = int.tryParse(controller.text) ?? 0;
                      setState(() {
                        _currentMealData['totalCalories'] = newCalories;
                      });
                      Navigator.of(context).pop();
                      // Skip auto-save for scanned meals
                      final isScanned = _currentMealData['isScanned'] ?? false;
                      final mealId = _currentMealData['id'] ?? _currentMealData['_id'];
                      if (!isScanned || mealId != null) {
                        await _updateMeal();
                      }
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(color: ThemeHelper.background),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditMacro(BuildContext context, String label, String currentValue, String iconAsset) {
    final int initialValue = int.tryParse(currentValue.replaceAll(' g', '')) ?? 0;
    
    // Determine color based on macro type
    Color color;
    if (label == 'Carbs') {
      color = CupertinoColors.systemOrange;
    } else if (label == 'Protein') {
      color = CupertinoColors.systemBlue;
    } else if (label == 'Fats') {
      color = CupertinoColors.systemRed;
    } else {
      color = CupertinoColors.systemGrey;
    }
    
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => EditMacroScreen(
          macroName: label,
          iconAsset: iconAsset,
          color: color,
          initialValue: initialValue,
          onValueChanged: (newValue) async {
            setState(() {
              if (label == 'Carbs') {
                _currentMealData['totalCarbs'] = newValue;
              } else if (label == 'Protein') {
                _currentMealData['totalProtein'] = newValue;
              } else if (label == 'Fats') {
                _currentMealData['totalFat'] = newValue;
              }
            });
            // Skip auto-save for scanned meals
            final isScanned = _currentMealData['isScanned'] ?? false;
            final mealId = _currentMealData['id'] ?? _currentMealData['_id'];
            if (!isScanned || mealId != null) {
              await _updateMeal();
            }
          },
        ),
      ),
    );
  }

  Future<void> _navigateToEditMealName(BuildContext context) async {
    final mealName = (_currentMealData['mealName'] as String?)?.trim() ?? '';
    
    final newName = await Navigator.push<String>(
      context,
      CupertinoPageRoute(
        builder: (context) => EditMealNameScreen(currentName: mealName),
      ),
    );
    
    if (newName != null && newName.isNotEmpty) {
      setState(() {
        _currentMealData['mealName'] = newName;
      });
      // Skip auto-save for scanned meals
      final isScanned = _currentMealData['isScanned'] ?? false;
      final mealId = _currentMealData['id'] ?? _currentMealData['_id'];
      if (!isScanned || mealId != null) {
        await _updateMeal();
      }
    }
  }

  void _showAddIngredientSheet(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: ThemeHelper.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ThemeHelper.divider,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeHelper.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Add Ingredient',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      final name = nameController.text.trim();
                      final caloriesText = caloriesController.text.trim();
                      
                      if (name.isEmpty) {
                        // Show error - name is required
                        return;
                      }
                      
                      final calories = int.tryParse(caloriesText) ?? 0;
                      
                      // Get current userId and mealType for the new entry
                      final userId = _currentMealData['userId'] ?? '';
                      final mealType = _currentMealData['mealType'] ?? '';
                      
                      // Create new entry
                      final newEntry = {
                        'userId': userId,
                        'mealType': mealType,
                        'foodName': name,
                        'quantity': 1,
                        'unit': 'g',
                        'calories': calories,
                        'protein': 0,
                        'carbs': 0,
                        'fat': 0,
                        'fiber': 0,
                        'sugar': 0,
                        'sodium': 0,
                        'servingSize': 1,
                        'servingUnit': 'serving',
                      };
                      
                      // Add to entries list
                      final currentEntries = (_currentMealData['entries'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
                      currentEntries.add(newEntry);
                      
                      // Update total calories
                      final currentCalories = (_currentMealData['totalCalories'] as num?)?.toInt() ?? 0;
                      
                      setState(() {
                        _currentMealData['entries'] = currentEntries;
                        _currentMealData['totalCalories'] = currentCalories + calories;
                      });
                      
                      Navigator.of(context).pop();
                      
                      // Skip auto-save for scanned meals
                      final isScanned = _currentMealData['isScanned'] ?? false;
                      final mealId = _currentMealData['id'] ?? _currentMealData['_id'];
                      if (!isScanned || mealId != null) {
                        await _updateMeal();
                      }
                    },
                    child: Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field (Required)
                    Text(
                      'Ingredient Name *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: nameController,
                      placeholder: 'Enter ingredient name',
                      placeholderStyle: TextStyle(
                        color: ThemeHelper.textSecondary,
                        fontSize: 16,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeHelper.textPrimary,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeHelper.background,
                        border: Border.all(
                          color: ThemeHelper.divider,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      autofocus: true,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Calories Field
                    Text(
                      'Calories',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: caloriesController,
                      placeholder: 'Enter calories',
                      keyboardType: TextInputType.number,
                      placeholderStyle: TextStyle(
                        color: ThemeHelper.textSecondary,
                        fontSize: 16,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeHelper.textPrimary,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeHelper.background,
                        border: Border.all(
                          color: ThemeHelper.divider,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


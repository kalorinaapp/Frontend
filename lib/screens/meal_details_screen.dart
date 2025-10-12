import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart' show AppConstants;
import '../services/meals_service.dart';
import 'ingredient_details_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _currentMealData = Map<String, dynamic>.from(widget.mealData);
  }

  Future<void> _updateMeal() async {
    try {
      final mealId = _currentMealData['id'] ?? _currentMealData['_id'];
      if (mealId == null) {
        debugPrint('MealDetailsScreen: No meal ID found');
        return;
      }

      final userId = AppConstants.userId;
      final date = _currentMealData['date'] ?? '';
      final mealType = _currentMealData['mealType'] ?? '';
      final mealName = _currentMealData['mealName'] ?? '';
      final isScanned = _currentMealData['isScanned'] ?? false;
      
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

      debugPrint('MealDetailsScreen: Updating meal $mealId');
      debugPrint('MealDetailsScreen: userId=$userId, date=$date, mealType=$mealType');
      debugPrint('MealDetailsScreen: mealName=$mealName');
      debugPrint('MealDetailsScreen: entries count=${entries.length}');
      debugPrint('MealDetailsScreen: entries=$entries');
      
      final response = await _mealsService.updateMeal(
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
            _currentMealData = Map<String, dynamic>.from(response['meal'] as Map<String, dynamic>);
          });
        }
      } else {
        debugPrint('MealDetailsScreen: Failed to update meal - Response: $response');
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
      backgroundColor: CupertinoColors.white,
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
                      color: CupertinoColors.black,
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
                      onTap: () => _showEditMealNameSheet(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mealName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E1822),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 8.0),
                          const Icon(CupertinoIcons.pencil, size: 14, color: CupertinoColors.black),
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
                                color: const Color(0xFFF8F7FC),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
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
                                      color: CupertinoColors.white,
                                      child: CachedNetworkImage(
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
                                      ),
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
                                        color: CupertinoColors.white,
                                        borderRadius: BorderRadius.circular(13),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x3F000000),
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
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF1E1822),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            CupertinoIcons.pencil,
                                            size: 14,
                                            color: Color(0xFF1E1822),
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
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 5,
                              offset: Offset(0, 0),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset('assets/icons/flame_black.png', width: 28, height: 28),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Calories',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xB21E1822),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$calories',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xE61E1822),
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
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3F000000),
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
                              const Text(
                                'Ingredients',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E1822),
                                ),
                              ),
                              Row(
                                children: [
                                  // Fix Issue button
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.white,
                                      borderRadius: BorderRadius.circular(13),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x3F000000),
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
                        color: CupertinoColors.black,
                      ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Fix Issue',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1E1822),
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
                                        color: CupertinoColors.white,
                                        borderRadius: BorderRadius.circular(13),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x3F000000),
                                            blurRadius: 5,
                                            offset: Offset(0, 0),
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Add More',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1E1822),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(CupertinoIcons.pencil, size: 14, color: CupertinoColors.black),
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
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'No ingredients available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0x991E1822),
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
                                            color: CupertinoColors.black.withOpacity(0.15),
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
            
            // Bottom Done Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: ()  {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 250,
                  height: 45,
                  decoration: BoxDecoration(
                    color: CupertinoColors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'Done',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
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

  Widget _buildMacroCard(BuildContext context, String label, String value, String iconAsset) {
    return GestureDetector(
      onTap: () => _showEditMacroSheet(context, label, value),
      child: Container(
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
            // Label as table header with gray background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(iconAsset, width: 12, height: 12),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemGrey,
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
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
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.black,
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
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Color(0x991E1822),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                CupertinoIcons.pencil,
                size: 12,
                color: Color(0x991E1822),
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
        
        // Update meal on server
        await _updateMeal();
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
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Enter Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            CupertinoTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              placeholder: 'Enter amount',
              style: const TextStyle(fontSize: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFE8E8E8),
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
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    color: CupertinoColors.black,
                    onPressed: () {
                      final newAmount = int.tryParse(controller.text) ?? 1;
                      setState(() {
                        _servingAmount = newAmount;
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(color: CupertinoColors.white),
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
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Enter Calories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            CupertinoTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              placeholder: 'Enter calories',
              style: const TextStyle(fontSize: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFE8E8E8),
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
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    color: CupertinoColors.black,
                    onPressed: () async {
                      final newCalories = int.tryParse(controller.text) ?? 0;
                      setState(() {
                        _currentMealData['totalCalories'] = newCalories;
                      });
                      Navigator.of(context).pop();
                      await _updateMeal();
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(color: CupertinoColors.white),
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

  void _showEditMacroSheet(BuildContext context, String label, String currentValue) {
    final TextEditingController controller = TextEditingController(text: currentValue.replaceAll(' g', ''));
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            Text(
              'Enter $label',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            CupertinoTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              placeholder: 'Enter $label',
              style: const TextStyle(fontSize: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFE8E8E8),
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
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    color: CupertinoColors.black,
                    onPressed: () async {
                      final newValue = int.tryParse(controller.text) ?? 0;
                      setState(() {
                        if (label == 'Carbs') {
                          _currentMealData['totalCarbs'] = newValue;
                        } else if (label == 'Protein') {
                          _currentMealData['totalProtein'] = newValue;
                        } else if (label == 'Fats') {
                          _currentMealData['totalFat'] = newValue;
                        }
                      });
                      Navigator.of(context).pop();
                      await _updateMeal();
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(color: CupertinoColors.white),
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

  void _showEditMealNameSheet(BuildContext context) {
    final mealName = (_currentMealData['mealName'] as String?)?.trim() ?? '';
    final TextEditingController controller = TextEditingController(text: mealName);
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Enter Meal Name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            CupertinoTextField(
              controller: controller,
              placeholder: 'Enter meal name',
              style: const TextStyle(fontSize: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFE8E8E8),
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
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    color: CupertinoColors.black,
                    onPressed: () async {
                      final newMealName = controller.text.trim();
                      if (newMealName.isNotEmpty) {
                        setState(() {
                          _currentMealData['mealName'] = newMealName;
                        });
                        Navigator.of(context).pop();
                        await _updateMeal();
                      }
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(color: CupertinoColors.white),
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

  void _showAddIngredientSheet(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
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
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE8E8E8),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Add Ingredient',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
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
                      
                      // Save to server
                      await _updateMeal();
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
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
                    const Text(
                      'Ingredient Name *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: nameController,
                      placeholder: 'Enter ingredient name',
                      placeholderStyle: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 16,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.black,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        border: Border.all(
                          color: const Color(0xFFE8E8E8),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      autofocus: true,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Calories Field
                    const Text(
                      'Calories',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: caloriesController,
                      placeholder: 'Enter calories',
                      keyboardType: TextInputType.number,
                      placeholderStyle: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 16,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.black,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        border: Border.all(
                          color: const Color(0xFFE8E8E8),
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


import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/theme_provider.dart' show ThemeProvider;
import '../services/food_service.dart';
import '../services/meals_service.dart';
import '../constants/app_constants.dart';
import 'create_meal_screen.dart';
import 'create_food_screen.dart';
import 'edit_macro_screen.dart';

class LogFoodScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  final String? userId;
  final String? mealType;
  
  const LogFoodScreen({
    super.key, 
    required this.themeProvider,
    this.userId,
    this.mealType,
  });

  @override
  State<LogFoodScreen> createState() => _LogFoodScreenState();
}

class _LogFoodScreenState extends State<LogFoodScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _foodNameController = TextEditingController();
  int _selectedTabIndex = 0;
  
  final List<String> _tabs = ['All', 'My Meals', 'My Foods', 'Saved Scans', 'Direct Input'];
  
  // Macro values
  int _carbsValue = 10;
  int _proteinValue = 41;
  int _fatsValue = 16;
  
  // Amount value
  int _amountValue = 1;
  
  // Direct Input ingredients
  List<dynamic> _directInputIngredients = [];
  
  // Food suggestions from API
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoadingSuggestions = false;
  
  // My meals from API
  List<Map<String, dynamic>> _myMeals = [];
  bool _isLoadingMyMeals = false;
  
  // My foods from API
  List<Map<String, dynamic>> _myFoods = [];
  bool _isLoadingMyFoods = false;
  
  // Scanned meals from API
  List<Map<String, dynamic>> _scannedMeals = [];
  bool _isLoadingScannedMeals = false;
  
  // Direct Input saving state
  bool _isSavingDirectInput = false;

  @override
  void initState() {
    super.initState();
    _fetchFoodSuggestions();
    _fetchMyMeals();
    _fetchMyFoods();
    _fetchScannedMeals();
  }

  Future<void> _fetchFoodSuggestions() async {
    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      final service = FoodService();
      final response = await service.getFoodSuggestions();
      
      if (response != null && response['success'] == true) {
        final suggestions = response['suggestions'] as List<dynamic>?;
        if (suggestions != null && mounted) {
          setState(() {
            _suggestions = suggestions.map((item) {
              return {
                'name': item['name'] ?? '',
                'calories': item['calories'] ?? 0,
                'protein': item['protein'] ?? 0,
                'carbohydrates': item['carbohydrates'] ?? 0,
                'fat': item['fat'] ?? 0,
                'fiber': item['fiber'] ?? 0,
                'sugar': item['sugar'] ?? 0,
                'sodium': item['sodium'] ?? 0,
                'servingSize': item['servingSize'] ?? '1',
                'servingUnit': item['servingUnit'] ?? 'serving',
                'rationale': item['rationale'] ?? '',
                'items': item['items'] ?? [],
              };
            }).toList();
          });
        }
      }
    } catch (e) {
      // Handle error silently or show error message
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSuggestions = false;
        });
      }
    }
  }

  Future<void> _fetchMyMeals() async {
    if (widget.userId == null || widget.userId!.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingMyMeals = true;
    });

    try {
      final service = MealsService();
      final response = await service.fetchAllMeals(
        userId: widget.userId!,
        page: 1,
        limit: 20,
      );

      if (response != null && response['success'] == true) {
        final meals = response['meals'] as List<dynamic>?;
        if (meals != null && mounted) {
          setState(() {
            _myMeals = meals.map((item) {
              return {
                'id': item['id'] ?? '',
                'mealName': item['mealName'] ?? '',
                'totalCalories': item['totalCalories'] ?? 0,
                'totalProtein': item['totalProtein'] ?? 0,
                'totalCarbs': item['totalCarbs'] ?? 0,
                'totalFat': item['totalFat'] ?? 0,
                'entriesCount': item['entriesCount'] ?? 0,
                'mealType': item['mealType'] ?? '',
                'date': item['date'] ?? '',
                'notes': item['notes'] ?? '',
                'entries': item['entries'] ?? [], // Store the complete entries data
              };
            }).toList();
          });
        }
      }
    } catch (e) {
      // Handle error silently or show error message
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMyMeals = false;
        });
      }
    }
  }

  Future<void> _fetchMyFoods() async {
    setState(() {
      _isLoadingMyFoods = true;
    });

    try {
      final service = FoodService();
      final response = await service.fetchAllFoods(
        page: 1,
        limit: 20,
      );
 
      if (response != null && response['success'] == true) {
        final foods = response['foods'] as List<dynamic>?;
        if (foods != null && mounted) {
          setState(() {
            _myFoods = foods.map((item) {
              return {
                '_id': item['_id'] ?? '',
                'name': item['name'] ?? '',
                'calories': item['calories'] ?? 0,
                'description': item['description'] ?? '',
                'servingSize': item['servingSize'] ?? '',
                'servingPerContainer': item['servingPerContainer'] ?? '',
                'protein': item['protein'] ?? 0,
                'carbohydrates': item['carbohydrates'] ?? 0,
                'totalFat': item['totalFat'] ?? 0,
                'createdBy': item['createdBy'] ?? '',
                'createdAt': item['createdAt'] ?? '',
              };
            }).toList();
          });
        }
      }
    } catch (e) {
      // Handle error silently or show error message
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMyFoods = false;
        });
      }
    }
  }

  Future<void> _saveDirectInputFood() async {
    // Validate required fields
    if (_foodNameController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a food name');
      return;
    }

    if (_caloriesController.text.trim().isEmpty) {
      _showErrorDialog('Please enter calories');
      return;
    }

    final calories = int.tryParse(_caloriesController.text.trim());
    if (calories == null || calories < 0) {
      _showErrorDialog('Please enter a valid calories value');
      return;
    }

    setState(() {
      _isSavingDirectInput = true;
    });

    try {
      final service = FoodService();
      final response = await service.saveFood(
        name: _foodNameController.text.trim(),
        calories: calories,
        protein: _proteinValue.toDouble(),
        carbohydrates: _carbsValue.toDouble(),
        totalFat: _fatsValue.toDouble(),
        servingSize: '$_amountValue serving',
        isCustom: true,
        createdBy: AppConstants.userId,
      );

      if (response != null && response['food'] != null) {
        // Refresh my foods list
        await _fetchMyFoods();
        
        // Clear the form
        _foodNameController.clear();
        _caloriesController.clear();
        setState(() {
          _carbsValue = 10;
          _proteinValue = 41;
          _fatsValue = 16;
          _amountValue = 1;
          _directInputIngredients = [];
        });
        
        // Switch to My Foods tab
        if (mounted) {
          setState(() {
            _selectedTabIndex = 2;
          });
        }
      } else {
        _showErrorDialog('Failed to save food');
      }
    } catch (e) {
      _showErrorDialog('Error saving food: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSavingDirectInput = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchScannedMeals() async {
    if (widget.userId == null || widget.userId!.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingScannedMeals = true;
    });

    try {
      final service = MealsService();
      final response = await service.fetchScannedMeals(
        userId: widget.userId!,
        page: 1,
        limit: 20,
      );

      if (response != null && response['success'] == true) {
        final meals = response['meals'] as List<dynamic>?;
        if (meals != null && mounted) {
          setState(() {
            _scannedMeals = meals.map((item) {
              return {
                'id': item['id'] ?? '',
                'mealName': item['mealName'] ?? '',
                'mealImage': item['mealImage'] ?? '',
                'totalCalories': item['totalCalories'] ?? 0,
                'totalProtein': item['totalProtein'] ?? 0,
                'totalCarbs': item['totalCarbs'] ?? 0,
                'totalFat': item['totalFat'] ?? 0,
                'entriesCount': item['entriesCount'] ?? 0,
                'mealType': item['mealType'] ?? '',
                'date': item['date'] ?? '',
                'createdAt': item['createdAt'] ?? '',
                'entries': item['entries'] ?? [],
              };
            }).toList();
          });
        }
      }
    } catch (e) {
      // Handle error silently or show error message
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingScannedMeals = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _caloriesController.dispose();
    _foodNameController.dispose();
    super.dispose();
  }

  void _onAddFood(int index) async {
    // Navigate to create meal screen with meal data
    final suggestion = _suggestions[index];
    final result = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => CreateMealScreen(
          mealData: suggestion,
          userId: widget.userId,
          mealType: widget.mealType,
        ),
      ),
    );
    
    // Optimistically add the new meal if result contains meal data
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _myMeals.insert(0, {
          'id': result['id'] ?? '',
          'mealName': result['mealName'] ?? '',
          'totalCalories': result['totalCalories'] ?? 0,
          'totalProtein': result['totalProtein'] ?? 0,
          'totalCarbs': result['totalCarbs'] ?? 0,
          'totalFat': result['totalFat'] ?? 0,
          'entriesCount': result['entriesCount'] ?? 0,
          'mealType': result['mealType'] ?? '',
          'date': result['date'] ?? '',
          'notes': result['notes'] ?? '',
          'entries': result['entries'] ?? [],
        });
      });
    } else if (result == true) {
      // Fallback: Refresh if result is just true
      _fetchMyMeals();
    }
  }

  void _onEditMeal(Map<String, dynamic> meal) async {
    // Parse entries from the meal data
    final entries = meal['entries'] as List<dynamic>? ?? [];
    final items = entries.map((entry) {
      return {
        'name': entry['foodName'] ?? '',
        'quantity': entry['quantity'] ?? 0,
        'unit': entry['unit'] ?? '',
        'calories': entry['calories'] ?? 0,
        'protein': entry['protein'] ?? 0,
        'carbohydrates': entry['carbs'] ?? 0, // Map 'carbs' to 'carbohydrates'
        'fat': entry['fat'] ?? 0,
      };
    }).toList();
    
    // Convert meal data to match CreateMealScreen expected format
    final mealData = {
      'name': meal['mealName'] ?? '',
      'calories': meal['totalCalories'] ?? 0,
      'protein': meal['totalProtein'] ?? 0,
      'carbohydrates': meal['totalCarbs'] ?? 0,
      'fat': meal['totalFat'] ?? 0,
      'servingSize': '1',
      'items': items,
    };
    
    final result = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => CreateMealScreen(
          mealData: mealData,
          userId: widget.userId,
          mealType: meal['mealType'] ?? widget.mealType,
          isEdit: true,
          mealId: meal['id'],
        ),
      ),
    );
    
    // Optimistically update the meal if result contains updated meal data
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final index = _myMeals.indexWhere((m) => m['id'] == meal['id']);
        if (index != -1) {
          _myMeals[index] = {
            'id': result['id'] ?? '',
            'mealName': result['mealName'] ?? '',
            'totalCalories': result['totalCalories'] ?? 0,
            'totalProtein': result['totalProtein'] ?? 0,
            'totalCarbs': result['totalCarbs'] ?? 0,
            'totalFat': result['totalFat'] ?? 0,
            'entriesCount': result['entriesCount'] ?? 0,
            'mealType': result['mealType'] ?? '',
            'date': result['date'] ?? '',
            'notes': result['notes'] ?? '',
            'entries': result['entries'] ?? [],
          };
        }
      });
    } else if (result == true) {
      // Fallback: Refresh if result is just true
      _fetchMyMeals();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const Spacer(),
                  const Text(
                    'Log Food',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24), // Balance the back button
                ],
              ),
            ),
            
            // Custom Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  _buildCustomTabBar(),
                  // Full horizontal line below all tabs
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: const Color(0xFFE8E8E8),
                  ),
                ],
              ),
            ),
            
            // Search Bar (only show for non-Direct Input tabs)
            if (_selectedTabIndex != 4) ...[
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE8E8E8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.03),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _searchController,
                        placeholder: 'Chicken br',
                        placeholderStyle: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 16,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.black,
                        ),
                        decoration: const BoxDecoration(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              const SizedBox(height: 20),
            
            // Tab Content
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTab() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Suggestions Container
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggestions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Suggestions List
                  Expanded(
                    child: _isLoadingSuggestions
                        ? ListView.separated(
                            itemCount: 8,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) => _buildShimmerItem(),
                          )
                        : _suggestions.isEmpty
                            ? const Center(
                                child: Text(
                                  'No suggestions available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: _suggestions.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final suggestion = _suggestions[index];
                                  return GestureDetector(
                                    onTap: () => _onAddFood(index),
                                    child: _buildSuggestionItem(
                                      title: suggestion['name'],
                                      calories: suggestion['calories'],
                                      onAdd: () => _onAddFood(index),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyMealsTab() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Meals List
              Expanded(
                child: _isLoadingMyMeals
                    ? ListView.separated(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: 8,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => _buildShimmerItem(),
                      )
                    : _myMeals.isEmpty
                        ? const Center(
                            child: Text(
                              'No meals saved yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF999999),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: _myMeals.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final meal = _myMeals[index];
                              return _buildMealItem(
                                title: meal['mealName'],
                                calories: (meal['totalCalories'] as num).toInt(),
                                onTap: () => _onEditMeal(meal),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
        
        // Bottom Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomBar(),
        ),
      ],
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Row(
        children: [
          // Flame icon placeholder
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          
          // Content placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Add button placeholder
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: CupertinoColors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealItem({
    required String title,
    required int calories,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Flame icon
            Image.asset('assets/icons/flame_black.png', width: 16, height: 16),
            const SizedBox(width: 8),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$calories calories',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Color(0xFF999999),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItem({
    required String title,
    required int calories,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Flame icon
          Image.asset('assets/icons/flame_black.png', width: 16, height: 16),
          const SizedBox(width: 8),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$calories calories',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem({
    required String title,
    required int calories,
    required VoidCallback onAdd,
  }) {
    return Row(
      children: [
        // Flame icon
        Image.asset('assets/icons/flame_black.png', width: 16, height: 16),
        const SizedBox(width: 8),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$calories calories',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
        
        // Add button
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.08),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.add,
              color: CupertinoColors.black,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == _selectedTabIndex;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? CupertinoColors.black : const Color(0x00000000),
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? CupertinoColors.black : const Color(0xFF999999),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildAllTab();
      case 1:
        return _buildMyMealsTab();
      case 2:
        return _buildMyFoodsTab();
      case 3:
        return _buildEmptyTab('Saved Scans');
      case 4:
        return _buildDirectInputTab();
      default:
        return _buildAllTab();
    }
  }

  Widget _buildMyFoodsTab() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Foods List
              Expanded(
                child: _isLoadingMyFoods
                    ? ListView.separated(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: 8,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => _buildShimmerItem(),
                      )
                    : _myFoods.isEmpty
                        ? const Center(
                            child: Text(
                              'No foods created yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF999999),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: _myFoods.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final food = _myFoods[index];
                              return _buildFoodItem(
                                title: food['name'],
                                calories: (food['calories'] as num).toInt(),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
        
        // Bottom Bar with Create Food button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              border: const Border(
                top: BorderSide(
                  color: Color(0xFFE8E8E8),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.02),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const CreateFoodScreen(),
                  ),
                );
                
                // Refresh my foods if a food was saved
                if (result == true) {
                  _fetchMyFoods();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.black,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFFE8E8E8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Text(
                  'Create Food',
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
        ),
      ],
    );
  }

  Widget _buildEmptyTab(String tabName) {
    // Special handling for Saved Scans
    if (tabName == 'Saved Scans') {
      if (_isLoadingScannedMeals) {
        // Loading state
        return Container(
          margin: const EdgeInsets.all(20),
          child: ListView.separated(
            itemCount: 4,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildShimmerMealCard(),
          ),
        );
      } else if (_scannedMeals.isEmpty) {
        // Empty state
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            const SizedBox(
              width: 242,
              child: Text(
                'Your saved scans will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xB21E1822),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.asset(
                'assets/images/saved_scans_empty.png',
                width: 285,
                height: 133,
                fit: BoxFit.cover,
              ),
            ),
            const Spacer(flex: 3),
          ],
        );
      } else {
        // Display scanned meals
        return Container(
          margin: const EdgeInsets.all(20),
          child: ListView.separated(
            itemCount: _scannedMeals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final meal = _scannedMeals[index];
              return _buildScannedMealCard(meal);
            },
          ),
        );
      }
    }
    
    // Default empty state for other tabs
    return Stack(
      children: [
        Center(
          child: Text(
            '$tabName content coming soon',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
            ),
          ),
        ),
        // Bottom Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomBar(),
        ),
      ],
    );
  }

  Widget _buildDirectInputTab() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bookmark icon
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Icon(
                    CupertinoIcons.bookmark,
                    size: 24,
                    color: CupertinoColors.black,
                  ),
                ),
                
                // Edit Name Field
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  child: CupertinoTextField(
                    controller: _foodNameController,
                    placeholder: 'Edit Name',
                    placeholderStyle: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.black,
                    ),
                    decoration: const BoxDecoration(),
                    padding: EdgeInsets.zero,
                    suffix: Icon(
                      CupertinoIcons.pencil,
                      size: 20,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                
                // Calories Card
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
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
                  child: Row(
                    children: [
                      Image.asset('assets/icons/flame_black.png', width: 28, height: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Calories',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 4),
                            CupertinoTextField(
                              controller: _caloriesController,
                              placeholder: '512',
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.black,
                              ),
                              placeholderStyle: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF999999),
                              ),
                              decoration: const BoxDecoration(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Macros Row
                Row(
                  children: [
                    // Carbohydrates
                    Expanded(
                      child: _buildMacroCard('Carbs', _carbsValue, 'assets/icons/carbs.png', CupertinoColors.systemOrange, () {
                        _editMacro('Carbs', 'assets/icons/carbs.png', CupertinoColors.systemOrange, _carbsValue, (value) {
                          setState(() {
                            _carbsValue = value;
                          });
                        });
                      }),
                    ),
                    const SizedBox(width: 12),
                    // Protein
                    Expanded(
                      child: _buildMacroCard('Protein', _proteinValue, 'assets/icons/drumstick.png', CupertinoColors.systemBlue, () {
                        _editMacro('Protein', 'assets/icons/drumstick.png', CupertinoColors.systemBlue, _proteinValue, (value) {
                          setState(() {
                            _proteinValue = value;
                          });
                        });
                      }),
                    ),
                    const SizedBox(width: 12),
                    // Fats
                    Expanded(
                      child: _buildMacroCard('Fats', _fatsValue, 'assets/icons/fat.png', CupertinoColors.systemRed, () {
                        _editMacro('Fats', 'assets/icons/fat.png', CupertinoColors.systemRed, _fatsValue, (value) {
                          setState(() {
                            _fatsValue = value;
                          });
                        });
                      }),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Ingredients Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showAddDirectInputIngredientDialog();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE8E8E8),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Add More',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: CupertinoColors.black,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.pencil,
                              size: 14,
                              color: CupertinoColors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Ingredients List
                if (_directInputIngredients.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ..._directInputIngredients.map((ingredient) => _buildDirectInputIngredientCard(ingredient)).toList(),
                ],
                
                const SizedBox(height: 16),
                
                // Amount Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showAmountInputSheet();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE8E8E8),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_amountValue',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: CupertinoColors.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.pencil,
                              size: 14,
                              color: CupertinoColors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
        ),
        
        // Bottom Save Food Button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: _isSavingDirectInput ? null : _saveDirectInputFood,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _isSavingDirectInput ? CupertinoColors.systemGrey : CupertinoColors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: _isSavingDirectInput
                    ? const Center(
                        child: CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        ),
                      )
                    : const Text(
                        'Save Food',
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
        ),
      ],
    );
  }

  void _editMacro(String name, String iconAsset, Color color, int currentValue, Function(int) onChanged) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => EditMacroScreen(
          macroName: name,
          iconAsset: iconAsset,
          color: color,
          initialValue: currentValue,
          onValueChanged: onChanged,
        ),
      ),
    );
  }

  void _showAmountInputSheet() {
    final TextEditingController controller = TextEditingController(text: _amountValue.toString());
    
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
            // Title
            const Text(
              'Enter Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            // Text Field
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
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
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
                      final value = int.tryParse(controller.text);
                      if (value != null && value > 0) {
                        setState(() {
                          _amountValue = value;
                        });
                      }
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

  Widget _buildMacroCard(String label, int amount, String icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(icon, width: 12, height: 12),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
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
                '$amount g',
                style: TextStyle(
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

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, -1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => CreateMealScreen(
                userId: widget.userId,
                mealType: widget.mealType,
              ),
            ),
          );
          
          // Optimistically add the new meal if result contains meal data
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              _myMeals.insert(0, {
                'id': result['id'] ?? '',
                'mealName': result['mealName'] ?? '',
                'totalCalories': result['totalCalories'] ?? 0,
                'totalProtein': result['totalProtein'] ?? 0,
                'totalCarbs': result['totalCarbs'] ?? 0,
                'totalFat': result['totalFat'] ?? 0,
                'entriesCount': result['entriesCount'] ?? 0,
                'mealType': result['mealType'] ?? '',
                'date': result['date'] ?? '',
                'notes': result['notes'] ?? '',
                'entries': result['entries'] ?? [],
              });
            });
          } else if (result == true) {
            // Fallback: Refresh if result is just true
            _fetchMyMeals();
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.black,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: const Color(0xFFE8E8E8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Text(
            'Create a Meal',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerMealCard() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildScannedMealCard(Map<String, dynamic> meal) {
    final calories = (meal['totalCalories'] as num).toInt();
    final protein = (meal['totalProtein'] as num).toInt();
    final fat = (meal['totalFat'] as num).toInt();
    final carbs = (meal['totalCarbs'] as num).toInt();
    final mealName = (meal['mealName'] as String?)?.trim();
    final imageUrl = (meal['mealImage'] as String?)?.trim();
    
    String timeString = '';
    final createdAtStr = meal['createdAt'] as String?;
    if (createdAtStr != null) {
      try {
        final createdAt = DateTime.parse(createdAtStr);
        timeString = '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      height: 120,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F7FC),
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 3,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Meal image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 96,
                height: 96,
                color: CupertinoColors.white,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
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
                      )
                    : Center(
                        child: Image.asset('assets/icons/apple.png', width: 24, height: 24),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Meal details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mealName != null && mealName.isNotEmpty ? mealName : 'Scanned Meal',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1E1822),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (timeString.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 3,
                                offset: Offset(0, 0),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            timeString,
                            style: const TextStyle(
                              color: Color(0xFF1E1822),
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Nutrition cards in 2x2 grid
                  Row(
                    children: [
                      Column(
                        children: [
                          _buildNutritionBadge(calories.toString(), 'Calories', 'assets/icons/carbs.png'),
                          const SizedBox(height: 4),
                          _buildNutritionBadge(protein.toString(), 'Protein', 'assets/icons/drumstick.png'),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          _buildNutritionBadge(fat.toString(), 'Fat', 'assets/icons/fat.png'),
                          const SizedBox(height: 4),
                          _buildNutritionBadge(carbs.toString(), 'Carbs', 'assets/icons/carbs.png'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow icon
            const SizedBox(
              width: 20,
              height: 20,
              child: Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionBadge(String value, String label, String iconPath) {
    return Container(
      width: 70,
      height: 30,
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.all(Radius.circular(6)),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 5,
            offset: Offset(0, 0),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              iconPath,
              width: 12,
              height: 12,
            ),
            const SizedBox(width: 4),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value g',
                  style: const TextStyle(
                    color: Color(0xE61E1822),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xB21E1822),
                    fontSize: 7,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectInputIngredientCard(dynamic ingredient) {
    final name = ingredient['name'] ?? '';
    final quantity = ingredient['quantity']?.toString() ?? '';
    final unit = ingredient['unit'] ?? '';
    final calories = ingredient['calories']?.toString() ?? '0';
    final protein = ingredient['protein']?.toString() ?? '0';
    final carbs = ingredient['carbohydrates']?.toString() ?? '0';
    final fat = ingredient['fat']?.toString() ?? '0';
    
    return GestureDetector(
      onTap: () {
        _showAddDirectInputIngredientDialog(existingIngredient: ingredient);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                ),
                if (quantity.isNotEmpty && unit.isNotEmpty)
                  Text(
                    '$quantity $unit',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _directInputIngredients.remove(ingredient);
                    });
                  },
                  child: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 20,
                    color: CupertinoColors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (calories != '0')
                  _buildDirectInputNutrientBadge('$calories kcal'),
                if (protein != '0')
                  _buildDirectInputNutrientBadge('P: ${protein}g'),
                if (carbs != '0')
                  _buildDirectInputNutrientBadge('C: ${carbs}g'),
                if (fat != '0')
                  _buildDirectInputNutrientBadge('F: ${fat}g'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectInputNutrientBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: CupertinoColors.black,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.black,
        ),
      ),
    );
  }

  void _showAddDirectInputIngredientDialog({dynamic existingIngredient}) {
    final bool isEditing = existingIngredient != null;
    
    final TextEditingController nameController = TextEditingController(
      text: existingIngredient?['name'] ?? '',
    );
    final TextEditingController quantityController = TextEditingController(
      text: existingIngredient != null && existingIngredient['quantity'] != 0
          ? existingIngredient['quantity'].toString()
          : '',
    );
    final TextEditingController unitController = TextEditingController(
      text: existingIngredient?['unit'] ?? '',
    );
    final TextEditingController caloriesController = TextEditingController(
      text: existingIngredient != null && existingIngredient['calories'] != 0
          ? existingIngredient['calories'].toString()
          : '',
    );
    final TextEditingController proteinController = TextEditingController(
      text: existingIngredient != null && existingIngredient['protein'] != 0
          ? existingIngredient['protein'].toString()
          : '',
    );
    final TextEditingController carbsController = TextEditingController(
      text: existingIngredient != null && existingIngredient['carbohydrates'] != 0
          ? existingIngredient['carbohydrates'].toString()
          : '',
    );
    final TextEditingController fatController = TextEditingController(
      text: existingIngredient != null && existingIngredient['fat'] != 0
          ? existingIngredient['fat'].toString()
          : '',
    );

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
                  Text(
                    isEditing ? 'Edit Ingredient' : 'Add Ingredient',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        return;
                      }

                      final ingredientData = {
                        'name': name,
                        'quantity': quantityController.text.trim().isNotEmpty 
                            ? double.tryParse(quantityController.text.trim()) ?? 0 
                            : 0,
                        'unit': unitController.text.trim(),
                        'calories': caloriesController.text.trim().isNotEmpty 
                            ? int.tryParse(caloriesController.text.trim()) ?? 0 
                            : 0,
                        'protein': proteinController.text.trim().isNotEmpty 
                            ? int.tryParse(proteinController.text.trim()) ?? 0 
                            : 0,
                        'carbohydrates': carbsController.text.trim().isNotEmpty 
                            ? int.tryParse(carbsController.text.trim()) ?? 0 
                            : 0,
                        'fat': fatController.text.trim().isNotEmpty 
                            ? int.tryParse(fatController.text.trim()) ?? 0 
                            : 0,
                      };

                      setState(() {
                        if (isEditing) {
                          // Find and update the existing ingredient
                          final index = _directInputIngredients.indexOf(existingIngredient);
                          if (index != -1) {
                            _directInputIngredients[index] = ingredientData;
                          }
                        } else {
                          // Add new ingredient
                          _directInputIngredients.add(ingredientData);
                        }
                      });

                      Navigator.of(context).pop();
                    },
                    child: Text(
                      isEditing ? 'Save' : 'Add',
                      style: const TextStyle(
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
                    // Name Field (Mandatory)
                    const Text(
                      'Name *',
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
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quantity Section
                    const Text(
                      'Quantity & Unit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CupertinoTextField(
                            controller: quantityController,
                            placeholder: 'Amount',
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: CupertinoTextField(
                            controller: unitController,
                            placeholder: 'Unit (g, cup, tbsp)',
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
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Nutrition Information
                    const Text(
                      'Nutrition (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Calories
                    CupertinoTextField(
                      controller: caloriesController,
                      placeholder: 'Calories',
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
                    
                    const SizedBox(height: 12),
                    
                    // Protein and Carbs
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            controller: proteinController,
                            placeholder: 'Protein (g)',
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CupertinoTextField(
                            controller: carbsController,
                            placeholder: 'Carbs (g)',
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
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Fat
                    CupertinoTextField(
                      controller: fatController,
                      placeholder: 'Fat (g)',
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

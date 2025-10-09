import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:shimmer/shimmer.dart';
import '../providers/theme_provider.dart' show ThemeProvider;
import '../services/food_service.dart';
import '../services/meals_service.dart';
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
  int _selectedTabIndex = 0;
  
  final List<String> _tabs = ['All', 'My Meals', 'My Foods', 'Saved Scans', 'Direct Input'];
  
  // Macro values
  int _carbsValue = 10;
  int _proteinValue = 41;
  int _fatsValue = 16;
  
  // Amount value
  int _amountValue = 1;
  
  // Food suggestions from API
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoadingSuggestions = false;
  
  // My meals from API
  List<Map<String, dynamic>> _myMeals = [];
  bool _isLoadingMyMeals = false;

  @override
  void initState() {
    super.initState();
    _fetchFoodSuggestions();
    _fetchMyMeals();
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

  @override
  void dispose() {
    _searchController.dispose();
    _caloriesController.dispose();
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
    
    // Refresh my meals if a meal was saved
    if (result == true) {
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
        Center(
          child: Text(
            'My Foods content coming soon',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
            ),
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
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const CreateFoodScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
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
                    color: CupertinoColors.black,
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
                    Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print('Add More tapped');
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
                              'Add More',
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
        
        // Bottom Add Button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                print('Add food tapped');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  'Add',
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
          
          // Refresh my meals if a meal was saved
          if (result == true) {
            _fetchMyMeals();
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
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
              color: CupertinoColors.black,
            ),
          ),
        ),
      ),
    );
  }
}

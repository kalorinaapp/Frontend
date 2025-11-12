// ignore_for_file: unused_local_variable

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../providers/theme_provider.dart' show ThemeProvider;
import '../controllers/log_food_controller.dart';
import 'create_meal_screen.dart';
import 'create_food_screen.dart';
import 'edit_macro_screen.dart';
import 'meal_details_screen.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme_helper.dart';

class LogFoodScreen extends StatelessWidget {
  final ThemeProvider themeProvider;
  final String? userId;
  final String? mealType;
  final int initialTabIndex;
  
  const LogFoodScreen({
    super.key, 
    required this.themeProvider,
    this.userId,
    this.mealType,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(
      LogFoodController(
        userId: userId,
        mealType: mealType,
        initialTabIndex: initialTabIndex,
      ),
      tag: userId, // Use tag to allow multiple instances
    );

    return _LogFoodView(controller: controller);
  }
}

class _LogFoodView extends StatelessWidget {
  final LogFoodController controller;
  
  const _LogFoodView({required this.controller});
  
  List<String> _getTabs(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [l10n.all, l10n.myMeals, l10n.myFoods, l10n.savedScans, l10n.directInput];
  }

  void _onAddFood(BuildContext context, int index) async {
    // Navigate to create meal screen with meal data
    final suggestion = controller.suggestions[index];
    final result = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => CreateMealScreen(
          mealData: suggestion,
          userId: controller.userId,
          mealType: controller.mealType,
        ),
      ),
    );
    
    // Optimistically add the new meal if result contains meal data
    if (result != null && result is Map<String, dynamic>) {
      controller.addOrUpdateMeal({
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
    } else if (result == true) {
      // Fallback: Refresh if result is just true
      controller.fetchMyMeals();
    }
  }

  void _onEditMeal(BuildContext context, Map<String, dynamic> meal) async {
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
          userId: controller.userId,
          mealType: meal['mealType'] ?? controller.mealType,
          isEdit: true,
          mealId: meal['id'],
        ),
      ),
    );
    
    // Handle result
    if (result == 'deleted') {
      // Meal was deleted, remove from list
      controller.removeMeal(meal['id']);
    } else if (result != null && result is Map<String, dynamic>) {
      // Optimistically update the meal if result contains updated meal data
      controller.addOrUpdateMeal({
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
    } else if (result == true) {
      // Fallback: Refresh if result is just true
      controller.fetchMyMeals();
    }
  }

  void _onEditFood(BuildContext context, Map<String, dynamic> food) async {
    final result = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => CreateFoodScreen(
          isEditing: true,
          foodData: food,
        ),
      ),
    );
    
    // Handle deletion
    if (result == 'deleted') {
      controller.removeFood(food['_id'] ?? '');
      return;
    }
    
    // Optimistically update the food if result contains updated food data
    if (result != null && result is Map<String, dynamic>) {
      controller.addOrUpdateFood({
        '_id': result['_id'] ?? '',
        'name': result['name'] ?? '',
        'calories': result['calories'] ?? 0,
        'description': result['description'] ?? '',
        'servingSize': result['servingSize'] ?? '',
        'servingPerContainer': result['servingPerContainer'] ?? '',
        'protein': result['protein'] ?? 0,
        'carbohydrates': result['carbohydrates'] ?? 0,
        'totalFat': result['totalFat'] ?? 0,
        'createdBy': result['createdBy'] ?? '',
        'createdAt': result['createdAt'] ?? '',
      });
    } else if (result == true) {
      // Fallback: Refresh if result is just true
      controller.fetchMyFoods();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
                  const Spacer(),
                  Text(
                    l10n.logFood,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.textPrimary,
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
                  _buildCustomTabBar(context),
                  // Full horizontal line below all tabs
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: ThemeHelper.divider,
                  ),
                ],
              ),
            ),
            
            // Search Bar (only show for non-Direct Input tabs)
            Obx(() {
              final currentTab = controller.selectedTabIndex.value;
              if (currentTab == 4) {
                return const SizedBox(height: 20);
              }
              
              // Use different controller based on tab
              final isMyMealsTab = currentTab == 1;
              final isMyFoodsTab = currentTab == 2;
              final isSavedScansTab = currentTab == 3;
              
              final searchCtrl = isMyMealsTab 
                  ? controller.mealsSearchController 
                  : isMyFoodsTab 
                      ? controller.foodsSearchController 
                      : isSavedScansTab
                          ? controller.scannedMealsSearchController
                          : controller.searchController;
              
              final placeholder = isMyMealsTab 
                  ? l10n.searchMeals 
                  : isMyFoodsTab 
                      ? l10n.searchFoods 
                      : isSavedScansTab
                          ? l10n.searchScannedMeals
                          : l10n.chickenBr;
              
              final showClearButton = isMyMealsTab || isMyFoodsTab || isSavedScansTab;
              
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                    color: ThemeHelper.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ThemeHelper.divider,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeHelper.textPrimary.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: ThemeHelper.textPrimary.withOpacity(0.03),
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.search,
                          size: 20,
                          color: ThemeHelper.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CupertinoTextField(
                            controller: searchCtrl,
                            placeholder: placeholder,
                            placeholderStyle: TextStyle(
                              color: ThemeHelper.textSecondary,
                              fontSize: 16,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: ThemeHelper.textPrimary,
                            ),
                            decoration: const BoxDecoration(),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        if (showClearButton)
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: searchCtrl,
                            builder: (context, value, child) {
                              if (value.text.isEmpty) return const SizedBox.shrink();
                              return GestureDetector(
                                onTap: () {
                                  searchCtrl.clear();
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(
                                    CupertinoIcons.clear_circled_solid,
                                    size: 20,
                                    color: ThemeHelper.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            
            // Tab Content
            Expanded(
              child: _buildTabContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTab(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Suggestions Container
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.suggestions,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ThemeHelper.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Suggestions List
                  Expanded(
                    child: Obx(() => controller.isLoadingSuggestions.value
                        ? ListView.separated(
                            itemCount: 8,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) => _buildShimmerItem(),
                          )
                        : controller.suggestions.isEmpty
                            ? Center(
                                child: Text(
                                  l10n.noSuggestionsAvailable,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ThemeHelper.textSecondary,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: controller.suggestions.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final suggestion = controller.suggestions[index];
                                  return GestureDetector(
                                    onTap: () => _onAddFood(context, index),
                                    child: _buildSuggestionItem(
                                      context: context,
                                      title: suggestion['name'],
                                      calories: suggestion['calories'],
                                      onAdd: () => _onAddFood(context, index),
                                    ),
                                  );
                                },
                              ),
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

  Widget _buildMyMealsTab(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Meals List
              Expanded(
                child: Obx(() => controller.isLoadingMyMeals.value
                    ? ListView.separated(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: 8,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => _buildShimmerItem(),
                      )
                    : controller.myMeals.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noMealsSavedYet,
                              style: TextStyle(
                                fontSize: 16,
                                color: ThemeHelper.textSecondary,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: controller.myMeals.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final meal = controller.myMeals[index];
                              return _buildMealItem(
                                context: context,
                                title: meal['mealName'],
                                calories: (meal['totalCalories'] as num).toInt(),
                                onTap: () => _onEditMeal(context, meal),
                              );
                            },
                          ),
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
          child: Builder(
            builder: (context) => _buildBottomBar(context),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: ThemeHelper.divider,
      highlightColor: ThemeHelper.cardBackground,
      child: Row(
        children: [
          // Flame icon placeholder
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: ThemeHelper.background,
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
    required BuildContext context,
    required String title,
    required int calories,
    VoidCallback? onTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeHelper.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeHelper.divider,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.textPrimary.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: ThemeHelper.textPrimary.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Flame icon
            Image.asset('assets/icons/flame_black.png', width: 16, height: 16, color: ThemeHelper.isLightMode ? null : CupertinoColors.white),
            const SizedBox(width: 8),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ThemeHelper.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$calories ${l10n.calories}',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeHelper.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: ThemeHelper.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItem({
    required BuildContext context,
    required String title,
    required int calories,
    VoidCallback? onTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeHelper.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeHelper.divider,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.textPrimary.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: ThemeHelper.textPrimary.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Flame icon
            Image.asset('assets/icons/flame_black.png', width: 16, height: 16, color: ThemeHelper.isLightMode ? null : CupertinoColors.white),
            const SizedBox(width: 8),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ThemeHelper.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$calories ${l10n.calories}',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeHelper.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: ThemeHelper.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem({
    required BuildContext context,
    required String title,
    required int calories,
    required VoidCallback onAdd,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        // Flame icon
        Image.asset('assets/icons/flame_black.png', width: 16, height: 16, color: ThemeHelper.isLightMode ? null : CupertinoColors.white),
        const SizedBox(width: 8),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ThemeHelper.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$calories calories',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeHelper.textSecondary,
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
              color: ThemeHelper.cardBackground,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ThemeHelper.textPrimary.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: ThemeHelper.textPrimary.withOpacity(0.08),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.add,
              color: ThemeHelper.textPrimary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTabBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = _getTabs(context);
    
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == controller.selectedTabIndex.value;
          
          return GestureDetector(
            onTap: () {
              controller.selectedTabIndex.value = index;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? ThemeHelper.textPrimary : const Color(0x00000000),
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? ThemeHelper.textPrimary : ThemeHelper.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }

  Widget _buildTabContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Obx(() {
      switch (controller.selectedTabIndex.value) {
        case 0:
          return _buildAllTab(context);
        case 1:
          return _buildMyMealsTab(context);
        case 2:
          return _buildMyFoodsTab(context);
        case 3:
          return Builder(
            builder: (context) => _buildEmptyTab(context, l10n.savedScans),
          );
        case 4:
          return _buildDirectInputTab(context);
        default:
          return _buildAllTab(context);
      }
    });
  }

  Widget _buildMyFoodsTab(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Foods List
              Expanded(
                child: Obx(() => controller.isLoadingMyFoods.value
                    ? ListView.separated(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: 8,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => _buildShimmerItem(),
                      )
                    : controller.myFoods.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noFoodsCreatedYet,
                              style: TextStyle(
                                fontSize: 16,
                                color: ThemeHelper.textSecondary,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: controller.myFoods.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final food = controller.myFoods[index];
                              return _buildFoodItem(
                                context: context,
                                title: food['name'],
                                calories: (food['calories'] as num).toInt(),
                                onTap: () => _onEditFood(context, food),
                              );
                            },
                          ),
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
              color: ThemeHelper.background,
              border: Border(
                top: BorderSide(
                  color: ThemeHelper.divider,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeHelper.textPrimary.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: ThemeHelper.textPrimary.withOpacity(0.02),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const CreateFoodScreen(),
                    ),
                  );
                  
                  // Optimistically add the new food if result contains food data
                  if (result != null && result is Map<String, dynamic>) {
                    controller.addOrUpdateFood({
                      '_id': result['_id'] ?? '',
                      'name': result['name'] ?? '',
                      'calories': result['calories'] ?? 0,
                      'description': result['description'] ?? '',
                      'servingSize': result['servingSize'] ?? '',
                      'servingPerContainer': result['servingPerContainer'] ?? '',
                      'protein': result['protein'] ?? 0,
                      'carbohydrates': result['carbohydrates'] ?? 0,
                      'totalFat': result['totalFat'] ?? 0,
                      'createdBy': result['createdBy'] ?? '',
                      'createdAt': result['createdAt'] ?? '',
                    });
                  } else if (result == true) {
                    // Fallback: Refresh if result is just true
                    controller.fetchMyFoods();
                  }
                },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: ThemeHelper.textPrimary,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: ThemeHelper.divider,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeHelper.textPrimary.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: ThemeHelper.textPrimary.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  l10n.createFood,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.background,
                  ),
                ),
              ), // Close inner Container
              ), // Close GestureDetector
            ), // Close Builder
          ), // Close outer Container
        ), // Close Positioned
      ],
    );
  }

  Widget _buildEmptyTab(BuildContext context, String tabName) {
    final l10n = AppLocalizations.of(context)!;
    
    // Special handling for Saved Scans
    if (tabName == l10n.savedScans) {
      return Obx(() {
        if (controller.isLoadingScannedMeals.value) {
          // Loading state
          return Container(
            margin: const EdgeInsets.all(20),
            child: ListView.separated(
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildShimmerMealCard(),
            ),
          );
        } else if (controller.scannedMeals.isEmpty) {
          // Empty state
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              SizedBox(
                width: 242,
                child: Text(
                  l10n.yourSavedScansWillAppearHere,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemeHelper.textPrimary,
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
              itemCount: controller.scannedMeals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final meal = controller.scannedMeals[index];
                return Builder(
                  builder: (context) => _buildScannedMealCard(context, meal),
                );
              },
            ),
          );
        }
      });
    }
    
    // Default empty state for other tabs
    return Stack(
      children: [
        Center(
          child: Text(
            l10n.savedScansContentComingSoon,
            style: TextStyle(
              fontSize: 16,
              color: ThemeHelper.textSecondary,
            ),
          ),
        ),
        // Bottom Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomBar(context),
        ),
      ],
    );
  }

  Widget _buildDirectInputTab(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
                    color: ThemeHelper.textPrimary,
                  ),
                ),
                
                // Edit Name Field
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  child: CupertinoTextField(
                    controller: controller.foodNameController,
                    placeholder: l10n.editName,
                    placeholderStyle: TextStyle(
                      color: ThemeHelper.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ThemeHelper.textPrimary,
                    ),
                    decoration: const BoxDecoration(),
                    padding: EdgeInsets.zero,
                    suffix: Icon(
                      CupertinoIcons.pencil,
                      size: 20,
                      color: ThemeHelper.textSecondary,
                    ),
                  ),
                ),
                
                // Calories Card
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
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
                  child: Row(
                    children: [
                      Image.asset('assets/icons/flame_black.png', width: 28, height: 28, color: ThemeHelper.isLightMode ? null : CupertinoColors.white),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.caloriesLabel,
                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeHelper.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            CupertinoTextField(
                              controller: controller.caloriesController,
                              placeholder: l10n.caloriesPlaceholder,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ThemeHelper.textPrimary,
                              ),
                              placeholderStyle: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ThemeHelper.textSecondary,
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
                Obx(() {
                  // Access observables directly in Obx scope
                  final carbs = controller.carbsValue.value;
                  final protein = controller.proteinValue.value;
                  final fats = controller.fatsValue.value;
                  
                  return Builder(
                    builder: (context) => Row(
                      children: [
                        // Carbohydrates
                        Expanded(
                          child: _buildMacroCard(context, l10n.carbs, carbs, 'assets/icons/carbs.png', CupertinoColors.systemOrange, () {
                            _editMacro(context, l10n.carbs, 'assets/icons/carbs.png', CupertinoColors.systemOrange, carbs, (value) {
                              controller.carbsValue.value = value;
                            });
                          }),
                        ),
                        const SizedBox(width: 12),
                        // Protein
                        Expanded(
                          child: _buildMacroCard(context, l10n.protein, protein, 'assets/icons/drumstick.png', CupertinoColors.systemBlue, () {
                            _editMacro(context, l10n.protein, 'assets/icons/drumstick.png', CupertinoColors.systemBlue, protein, (value) {
                              controller.proteinValue.value = value;
                            });
                          }),
                        ),
                        const SizedBox(width: 12),
                        // Fats
                        Expanded(
                          child: _buildMacroCard(context, l10n.fats, fats, 'assets/icons/fat.png', CupertinoColors.systemRed, () {
                            _editMacro(context, l10n.fats, 'assets/icons/fat.png', CupertinoColors.systemRed, fats, (value) {
                              controller.fatsValue.value = value;
                            });
                          }),
                        ),
                      ],
                    ),
                  );
                }),
                
                const SizedBox(height: 24),
                
                // Ingredients Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.ingredients,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelper.textPrimary,
                      ),
                    ),
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          _showAddDirectInputIngredientDialog(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: ThemeHelper.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: ThemeHelper.divider,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeHelper.textPrimary.withOpacity(0.06),
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
                                l10n.addMore,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeHelper.textPrimary,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.pencil,
                                size: 14,
                                color: ThemeHelper.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Ingredients List
                Obx(() {
                  // Access observable's length to trigger reactivity
                  final hasIngredients = controller.directInputIngredients.isNotEmpty;
                  final ingredientsList = controller.directInputIngredients.toList();
                  
                  return Builder(
                    builder: (context) => hasIngredients
                        ? Column(
                            children: [
                              const SizedBox(height: 16),
                              ...ingredientsList.map((ingredient) => _buildDirectInputIngredientCard(context, ingredient)).toList(),
                            ],
                          )
                        : const SizedBox.shrink(),
                  );
                }),
                
                const SizedBox(height: 16),
                
                // Amount Section
                Obx(() {
                  // Access observable directly in Obx scope
                  final amount = controller.amountValue.value;
                  
                  return Builder(
                    builder: (context) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.amount,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ThemeHelper.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showAmountInputSheet(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: ThemeHelper.cardBackground,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: ThemeHelper.divider,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeHelper.textPrimary.withOpacity(0.06),
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
                                  '$amount',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: ThemeHelper.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  CupertinoIcons.pencil,
                                  size: 14,
                                  color: ThemeHelper.textPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
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
            child: Obx(() => GestureDetector(
              onTap: controller.isSavingDirectInput.value ? null : controller.saveDirectInputFood,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: controller.isSavingDirectInput.value ? CupertinoColors.systemGrey : ThemeHelper.textPrimary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: controller.isSavingDirectInput.value
                    ? Center(
                        child: CupertinoActivityIndicator(
                          color: ThemeHelper.background,
                        ),
                      )
                    : Text(
                        l10n.saveFood,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.background,
                        ),
                      ),
              ),
            )),
          ),
        ),
      ],
    );
  }

  void _editMacro(BuildContext context, String name, String iconAsset, Color color, int currentValue, Function(int) onChanged) {
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

  void _showAmountInputSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController amountController = TextEditingController(text: controller.amountValue.value.toString());
    
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
            // Title
            Text(
              l10n.enterAmount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeHelper.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Text Field
            CupertinoTextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              placeholder: l10n.enterAmountPlaceholder,
              style: const TextStyle(fontSize: 16),
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
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    color: ThemeHelper.textPrimary,
                    onPressed: () {
                      final value = int.tryParse(amountController.text);
                      if (value != null && value > 0) {
                        controller.amountValue.value = value;
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      l10n.save,
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

  Widget _buildMacroCard(BuildContext context, String label, int amount, String icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
                  color: ThemeHelper.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeHelper.background,
        border: Border(
          top: BorderSide(
            color: ThemeHelper.divider,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: ThemeHelper.textPrimary.withOpacity(0.02),
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
                userId: controller.userId,
                mealType: controller.mealType,
              ),
            ),
          );
          
          // Optimistically add the new meal if result contains meal data
          if (result != null && result is Map<String, dynamic>) {
            controller.addOrUpdateMeal({
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
          } else if (result == true) {
            // Fallback: Refresh if result is just true
            controller.fetchMyMeals();
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
                color: ThemeHelper.textPrimary.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: ThemeHelper.textPrimary.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Text(
            l10n.createAMeal,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
      baseColor: ThemeHelper.divider,
      highlightColor: ThemeHelper.cardBackground,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: ThemeHelper.background,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildScannedMealCard(BuildContext context, Map<String, dynamic> meal) {
    final l10n = AppLocalizations.of(context)!;
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

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => MealDetailsScreen(mealData: meal),
          ),
        );
        
        // Optimistically update the scanned meal if result contains updated meal data
        if (result != null && result is Map<String, dynamic>) {
          controller.addOrUpdateScannedMeal({
            'id': result['id'] ?? result['_id'] ?? meal['id'] ?? meal['_id'],
            'mealName': result['mealName'] ?? meal['mealName'],
            'mealImage': result['mealImage'] ?? meal['mealImage'],
            'totalCalories': result['totalCalories'] ?? meal['totalCalories'],
            'totalProtein': result['totalProtein'] ?? meal['totalProtein'],
            'totalCarbs': result['totalCarbs'] ?? meal['totalCarbs'],
            'totalFat': result['totalFat'] ?? meal['totalFat'],
            'entriesCount': result['entriesCount'] ?? meal['entriesCount'],
            'mealType': result['mealType'] ?? meal['mealType'],
            'date': result['date'] ?? meal['date'],
            'createdAt': result['createdAt'] ?? meal['createdAt'],
            'entries': result['entries'] ?? meal['entries'],
          });
        }
      },
      child: Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.textPrimary.withOpacity(0.2),
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
                color: ThemeHelper.background,
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
                          mealName != null && mealName.isNotEmpty ? mealName : l10n.scannedMeal,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ThemeHelper.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (timeString.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ThemeHelper.background,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeHelper.textPrimary.withOpacity(0.2),
                                blurRadius: 3,
                                offset: Offset(0, 0),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            timeString,
                            style: TextStyle(
                              color: ThemeHelper.textPrimary,
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
                          _buildNutritionBadge(context, calories.toString(), l10n.caloriesLabel, 'assets/icons/carbs.png'),
                          const SizedBox(height: 4),
                          _buildNutritionBadge(context, protein.toString(), l10n.protein, 'assets/icons/drumstick.png'),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          _buildNutritionBadge(context, fat.toString(), l10n.fats, 'assets/icons/fat.png'),
                          const SizedBox(height: 4),
                          _buildNutritionBadge(context, carbs.toString(), l10n.carbs, 'assets/icons/carbs.png'),
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
      ),
    );
  }

  Widget _buildNutritionBadge(BuildContext context, String value, String label, String iconPath) {
    return Container(
      width: 70,
      height: 30,
      decoration: BoxDecoration(
        color: ThemeHelper.background,
        borderRadius: BorderRadius.all(Radius.circular(6)),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.textPrimary.withOpacity(0.25),
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
                  style: TextStyle(
                    color: ThemeHelper.textPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: ThemeHelper.textPrimary,
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

  Widget _buildDirectInputIngredientCard(BuildContext context, dynamic ingredient) {
    final l10n = AppLocalizations.of(context)!;
    final name = ingredient['name'] ?? '';
    final quantity = ingredient['quantity']?.toString() ?? '';
    final unit = ingredient['unit'] ?? '';
    final calories = ingredient['calories']?.toString() ?? '0';
    final protein = ingredient['protein']?.toString() ?? '0';
    final carbs = ingredient['carbohydrates']?.toString() ?? '0';
    final fat = ingredient['fat']?.toString() ?? '0';
    
    return GestureDetector(
      onTap: () {
        _showAddDirectInputIngredientDialog(context, existingIngredient: ingredient);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeHelper.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeHelper.divider,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.textPrimary.withOpacity(0.04),
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.textPrimary,
                    ),
                  ),
                ),
                if (quantity.isNotEmpty && unit.isNotEmpty)
                  Text(
                    '$quantity $unit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ThemeHelper.textSecondary,
                    ),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    controller.removeDirectInputIngredient(ingredient);
                  },
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 20,
                    color: ThemeHelper.textPrimary,
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
                  _buildDirectInputNutrientBadge(context, '$calories kcal'),
                if (protein != '0')
                  _buildDirectInputNutrientBadge(context, 'P: ${protein}g'),
                if (carbs != '0')
                  _buildDirectInputNutrientBadge(context, 'C: ${carbs}g'),
                if (fat != '0')
                  _buildDirectInputNutrientBadge(context, 'F: ${fat}g'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectInputNutrientBadge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ThemeHelper.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: ThemeHelper.textPrimary,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: ThemeHelper.textPrimary,
        ),
      ),
    );
  }

  void _showAddDirectInputIngredientDialog(BuildContext context, {dynamic existingIngredient}) {
    final l10n = AppLocalizations.of(context)!;
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
                      l10n.cancel,
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isEditing ? l10n.editIngredient : l10n.addIngredient,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.textPrimary,
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

                      if (isEditing) {
                        // Find and update the existing ingredient
                        controller.updateDirectInputIngredient(existingIngredient, ingredientData);
                      } else {
                        // Add new ingredient
                        controller.addDirectInputIngredient(ingredientData);
                      }

                      Navigator.of(context).pop();
                    },
                    child: Text(
                      isEditing ? l10n.save : l10n.add,
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
                    // Name Field (Mandatory)
                    Text(
                      l10n.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: nameController,
                      placeholder: l10n.enterIngredientName,
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
                    
                    const SizedBox(height: 24),
                    
                    // Quantity Section
                    Text(
                      l10n.quantityUnit,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CupertinoTextField(
                            controller: quantityController,
                            placeholder: l10n.amountPlaceholder,
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
                              color: CupertinoColors.white,
                              border: Border.all(
                                color: ThemeHelper.divider,
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
                            placeholder: l10n.unitPlaceholder,
                            placeholderStyle: TextStyle(
                              color: ThemeHelper.textSecondary,
                              fontSize: 16,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: ThemeHelper.textPrimary,
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              border: Border.all(
                                color: ThemeHelper.divider,
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
                    Text(
                      l10n.nutritionOptional,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Calories
                    CupertinoTextField(
                      controller: caloriesController,
                      placeholder: l10n.caloriesPlaceholder2,
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
                    
                    const SizedBox(height: 12),
                    
                    // Protein and Carbs
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            controller: proteinController,
                            placeholder: l10n.proteinG,
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
                              color: CupertinoColors.white,
                              border: Border.all(
                                color: ThemeHelper.divider,
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
                            placeholder: l10n.carbsG,
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
                              color: CupertinoColors.white,
                              border: Border.all(
                                color: ThemeHelper.divider,
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
                      placeholder: l10n.fatG,
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

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
    return [l10n.savedScans, l10n.directInput];
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
      child: Column(
        children: [
          const SizedBox(height: 60),
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
          
          // Spacing
          // const SizedBox(height: 20),
          
          // Tab Content
          Expanded(
            child: _buildTabContent(context),
          ),
        ],
      ),
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
            Image.asset('assets/icons/apple.png', width: 16, height: 16, color: ThemeHelper.isLightMode ? null : CupertinoColors.white),
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

  Widget _buildCustomTabBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = _getTabs(context);
    
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 20), // Left padding to start from beginning
          ...tabs.asMap().entries.map((entry) {
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
        ],
      ),
    ));
  }

  Widget _buildTabContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Obx(() {
      switch (controller.selectedTabIndex.value) {
        case 0:
          return Builder(
            builder: (context) => _buildEmptyTab(context, l10n.savedScans),
          );
        case 1:
          return _buildDirectInputTab(context);
        default:
          return Builder(
            builder: (context) => _buildEmptyTab(context, l10n.savedScans),
          );
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: controller.scannedMeals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final meal = controller.scannedMeals[index];
              return Builder(
                builder: (context) => _buildScannedMealCard(context, meal),
              );
            },
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
                      Image.asset('assets/icons/apple.png', width: 28, height: 28, color: ThemeHelper.isLightMode ? null : CupertinoColors.white),
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
    final mealId = (meal['id'] ?? meal['_id'])?.toString() ?? '';
    
    String timeString = '';
    final createdAtStr = meal['createdAt'] as String?;
    if (createdAtStr != null) {
      try {
        final createdAt = DateTime.parse(createdAtStr).toLocal();
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
        
        // Check if meal was deleted
        if (result != null && result is Map<String, dynamic> && result['deleted'] == true) {
          controller.removeScannedMeal(meal);
        } else if (result != null && result is Map<String, dynamic>) {
          // Optimistically update the scanned meal if result contains updated meal data
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
            // Meal image (hide entirely if missing)
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 96,
                  height: 96,
                  color: ThemeHelper.background,
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
                    errorWidget: (context, url, error) => const SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
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
            // Add-to-dashboard (+) circular button (always visible)
            Obx(() {
              final isAdding = controller.addingToDashboardMealIds.contains(mealId);
              return GestureDetector(
                onTap: isAdding
                    ? null
                    : () async {
                        final ok = await controller.addSavedScanToDashboard(meal);
                        if (ok) {
                          Get.snackbar(l10n.success, l10n.successfullyAddedToDashboard);
                        } else {
                          Get.snackbar(l10n.error, l10n.unexpectedErrorDescription);
                        }
                      },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isAdding
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CupertinoActivityIndicator(),
                          )
                        : const Icon(
                            CupertinoIcons.add,
                            size: 18,
                            color: CupertinoColors.black,
                          ),
                  ),
                ),
              );
            }),
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

}

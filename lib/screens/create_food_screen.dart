import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:get/get.dart';
import '../controllers/create_food_controller.dart';
import '../utils/theme_helper.dart';
import '../l10n/app_localizations.dart';
import '../services/food_service.dart';
import 'edit_macro_screen.dart';

class CreateFoodScreen extends StatelessWidget {
  final bool isEditing;
  final Map<String, dynamic>? foodData;
  
  const CreateFoodScreen({
    super.key,
    this.isEditing = false,
    this.foodData,
  });

  @override
  Widget build(BuildContext context) {
    // Delete existing controller to ensure fresh state
    if (Get.isRegistered<CreateFoodController>()) {
      Get.delete<CreateFoodController>();
    }
    
    final controller = Get.put(CreateFoodController());
    
    // Reset controller if creating new food (not editing)
    if (!isEditing) {
      controller.reset();
    }
    
    // Initialize with food data if editing
    if (isEditing && foodData != null) {
      controller.initializeWithFoodData(foodData!, isEditing);
    }
    
    return _CreateFoodView(controller: controller);
  }
}

class _CreateFoodView extends StatelessWidget {
  final CreateFoodController controller;
  
  const _CreateFoodView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ThemeHelper.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header with back button and delete button (if editing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal:  20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (controller.currentPage.value == 1) {
                        controller.goToPreviousPage();
                      } else {
                        Get.back();
                      }
                    },
                    child: SvgPicture.asset(
                      'assets/icons/back.svg',
                      width: 24,
                      height: 24,
                      color: ThemeHelper.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Obx(() => controller.isEditing.value
                      ? GestureDetector(
                          onTap: () {
                            _showDeleteFoodConfirmation(context);
                          },
                          child: Image.asset(
                            'assets/icons/trash.png',
                            width: 20,
                            height: 20,
                            color: ThemeHelper.textPrimary,
                          ),
                        )
                      : const SizedBox(width: 24)), // Balance when not editing
                ],
              ),
            ),

            // Content - Show different pages based on currentPage
            Expanded(
              child: Obx(() => controller.currentPage.value == 0 ? _buildPage1(context) : _buildPage2()),
            ),
          ],
        ),
      ),
    );
  }

  // Page 1: Basic Information
  Widget _buildPage1(BuildContext context) {
    final bool isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Food Name Input Field with Bookmark
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showEditNameSheet(context);
                      },
                      child: Container(
                        width: double.infinity,
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
                        child: Row(
                          children: [
                            Expanded(
                              child: CupertinoTextField(
                                controller: controller.nameController,
                                placeholder: 'Protein bar',
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
                                readOnly: true,
                                enabled: false,
                              ),
                            ),
                            Icon(
                              CupertinoIcons.pencil,
                              size: 20,
                              color: ThemeHelper.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bookmark icon positioned below and to the right
                    Padding(
                      padding: const EdgeInsets.only(top: 16, right: 20),
                      child: Icon(
                        CupertinoIcons.bookmark,
                        size: 24,
                        color: ThemeHelper.textPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Measurement Section (smaller width)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Measurement',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ThemeHelper.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        controller.showEditDialog(
                          label: 'Measurement',
                          controller: controller.servingSizeController,
                          placeholder: '0',
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ThemeHelper.cardBackground,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: ThemeHelper.divider,
                            width: 1.5,
                          ),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: ThemeHelper.textPrimary.withOpacity(0.25),
                                    blurRadius: 5,
                                    offset: Offset(0, 0),
                                    spreadRadius: 1,
                                  ),
                                ],
                        ),
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller.servingSizeController,
                          builder: (context, value, child) => Center(
                            child: Text(
                              value.text.isEmpty 
                                  ? '0' 
                                  : value.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ThemeHelper.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Number of Servings Section (in a row with label and field)
                Row(
                  children: [
                    Text(
                      'Number of servings',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ThemeHelper.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        controller.showEditDialog(
                          label: 'Number of servings',
                          controller: controller.servingPerContainerController,
                          placeholder: '1',
                        );
                      },
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ThemeHelper.cardBackground,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: ThemeHelper.divider,
                            width: 1.5,
                          ),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: ThemeHelper.textPrimary.withOpacity(0.25),
                                    blurRadius: 5,
                                    offset: Offset(0, 0),
                                    spreadRadius: 1,
                                  ),
                                ],
                        ),
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller.servingPerContainerController,
                          builder: (context, value, child) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                value.text.isEmpty 
                                    ? '1' 
                                    : value.text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeHelper.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '/',
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
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Calories Card
                GestureDetector(
                  onTap: () {
                    final currentCalories = int.tryParse(controller.caloriesController.text) ?? 0;
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => EditMacroScreen(
                          macroName: 'Calories',
                          iconAsset: 'assets/icons/apple.png',
                          color: ThemeHelper.textPrimary,
                          initialValue: currentCalories,
                          onValueChanged: (newValue) {
                            controller.updateControllerText(controller.caloriesController, newValue.toString());
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
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
                        Image.asset(
                          'assets/icons/apple.png',
                          width: 28,
                          height: 28,
                          color: ThemeHelper.isLightMode ? null : CupertinoColors.white,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
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
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: controller.caloriesController,
                                builder: (context, value, child) => Text(
                                  value.text.isEmpty 
                                      ? '0' 
                                      : value.text,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: ThemeHelper.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Macros Row (Carbs, Protein, Fats)
                Row(
                  children: [
                    Expanded(
                      child: _buildMacroCard(
                        context,
                        l10n.carbs,
                        controller.carbsController,
                        'assets/icons/carbs.png',
                        CupertinoColors.systemOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMacroCard(
                        context,
                        'Protein',
                        controller.proteinController,
                        'assets/icons/drumstick.png',
                        CupertinoColors.systemBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMacroCard(
                        context,
                        'Fats',
                        controller.totalFatController,
                        'assets/icons/fat.png',
                        CupertinoColors.systemRed,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
        ),

        // Bottom Next Button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                controller.goToNextPage();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: ThemeHelper.textPrimary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Next',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.background,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Page 2: Nutrition Information
  Widget _buildPage2() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Nutrition Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ThemeHelper.divider,
                      width: 1,
                    ),
                    color: ThemeHelper.cardBackground,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeHelper.textPrimary.withOpacity(0.25),
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNutritionFieldRow('Protein',controller.proteinController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Carbs',controller.carbsController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Total fat',controller.totalFatController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Saturated fat',  controller.saturatedFatController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Polyunsaturated fat',controller.polyunsaturatedFatController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Monounsaturated fat', controller.monounsaturatedFatController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Trans fat', controller.transFatController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Cholesterol', controller.cholesterolController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Sodium',  controller.sodiumController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Potassium', controller.potassiumController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Sugar', controller.sugarController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Fiber',  controller.fiberController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Vitamin A', controller.vitaminAController, hasUnit: false),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Vitamin C',  controller.vitaminCController, hasUnit: false),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Calcium',  controller.calciumController, hasUnit: false),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Iron',  controller.ironController, hasUnit: false),
                    ],
                  ),
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
            child: Obx(() => GestureDetector(
              onTap: controller.isSaving.value ? null : controller.saveFood,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: controller.isSaving.value ? CupertinoColors.systemGrey : ThemeHelper.textPrimary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: controller.isSaving.value
                    ? Center(
                        child: CupertinoActivityIndicator(
                          color: ThemeHelper.background,
                        ),
                      )
                    : Obx(() => Text(
                        controller.currentPage.value == 0 ? 'Next' : 'Save Food',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.background,
                        ),
                      )),
              ),
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionFieldRow(String label, TextEditingController textController, {required bool hasUnit}) {
    return GestureDetector(
      onTap: () {
        controller.showEditDialog(
          label: label,
          controller: textController,
          placeholder: '',
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label
          Text(
            label,
            style: TextStyle(
              color: ThemeHelper.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Value and Edit Icon
          GetBuilder<CreateFoodController>(
            builder: (_) => Row(
              children: [
                if (textController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      textController.text,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: ThemeHelper.textSecondary,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (hasUnit)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      'g',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: ThemeHelper.textSecondary,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Icon(
                  CupertinoIcons.pencil,
                  size: 8,
                  color: ThemeHelper.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameSheet(BuildContext context) {
    final TextEditingController tempController = TextEditingController(text: controller.nameController.text);
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
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
                'Edit Name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ThemeHelper.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              
              CupertinoTextField(
                controller: tempController,
                placeholder: 'Enter food name',
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
                        controller.updateControllerText(controller.nameController, tempController.text);
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
      ),
    );
  }

  void _showDeleteFoodConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Show confirmation dialog
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 320,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: ThemeHelper.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Header with title and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.deleteMealTitle, // Reusing meal deletion title
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.textPrimary,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Icon(
                          CupertinoIcons.xmark_circle,
                          color: ThemeHelper.textPrimary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    l10n.mealWillBePermanentlyDeleted, // Reusing meal deletion message
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ThemeHelper.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Buttons
                  Row(
                    children: [
                      // No button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: ThemeHelper.cardBackground,
                              border: Border.all(
                                color: ThemeHelper.divider,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                l10n.no,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeHelper.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Yes button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Close the dialog
                            Navigator.of(context).pop();
                            // Immediately navigate back with deleted flag (optimistic)
                            if (context.mounted) {
                              Navigator.of(context).pop({'deleted': true});
                            }
                            // Make API call in background (fire and forget)
                            _handleDeleteFoodInBackground();
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCD5C5C), // Matching the red color from delete meal dialog
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                l10n.yes,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleDeleteFoodInBackground() async {
    final foodId = controller.foodId;
    if (foodId != null && foodId.isNotEmpty) {
      // Make API call in background - fire and forget
      try {
        const service = FoodService();
        await service.deleteFood(foodId: foodId).catchError((error) {
          debugPrint('CreateFoodScreen: Failed to delete food $foodId - $error');
          // Note: We don't show error to user since we've already optimistically removed it
          // The food will be removed from UI immediately, and if API fails,
          // it might reappear on next refresh, but that's acceptable for optimistic UI
          return null;
        });
      } catch (e) {
        debugPrint('CreateFoodScreen: Error deleting food: $e');
      }
    }
  }

  Widget _buildDivider() {
    return Container(
      height: 1.47,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: ThemeHelper.divider,
          ),
        ),
      ),
    );
  }

  Widget _buildMacroCard(
    BuildContext context,
    String label,
    TextEditingController textController,
    String iconAsset,
    Color color,
  ) {
    final bool isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        final currentValue = int.tryParse(textController.text) ?? 0;
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => EditMacroScreen(
              macroName: label,
              iconAsset: iconAsset,
              color: color,
              initialValue: currentValue,
              onValueChanged: (newValue) {
                controller.updateControllerText(textController, newValue.toString());
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: ThemeHelper.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeHelper.divider,
            width: 1.5,
          ),
          boxShadow: isDark
              ? []
              : [
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
                color: ThemeHelper.cardBackground,
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
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.systemGrey,
                        letterSpacing: 0.1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Amount as table content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: textController,
                builder: (context, value, child) => Text(
                  value.text.isEmpty 
                      ? '0 g' 
                      : '${value.text} g',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeHelper.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


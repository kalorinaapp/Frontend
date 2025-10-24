import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../services/food_service.dart';
import '../constants/app_constants.dart';
import '../utils/theme_helper.dart';

class CreateFoodController extends GetxController {
  // Page control
  final currentPage = 0.obs;
  
  // Loading state
  final isSaving = false.obs;
  
  // Edit mode
  final isEditing = false.obs;
  String? foodId;

  // Basic info controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final servingSizeController = TextEditingController(text: '1tbsp');
  final servingPerContainerController = TextEditingController(text: '1');
  final caloriesController = TextEditingController();

  // Nutrition controllers
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final totalFatController = TextEditingController();
  final saturatedFatController = TextEditingController();
  final polyunsaturatedFatController = TextEditingController();
  final monounsaturatedFatController = TextEditingController();
  final transFatController = TextEditingController();
  final cholesterolController = TextEditingController();
  final sodiumController = TextEditingController();
  final potassiumController = TextEditingController();
  final sugarController = TextEditingController();
  final fiberController = TextEditingController();
  final vitaminAController = TextEditingController();
  final vitaminCController = TextEditingController();
  final calciumController = TextEditingController();
  final ironController = TextEditingController();
  
  // Initialize with food data for editing
  void initializeWithFoodData(Map<String, dynamic> foodData, bool editing) {
    isEditing.value = editing;
    foodId = foodData['_id'];
    
    nameController.text = foodData['name'] ?? '';
    descriptionController.text = foodData['description'] ?? '';
    servingSizeController.text = foodData['servingSize'] ?? '1tbsp';
    servingPerContainerController.text = foodData['servingPerContainer'] ?? '1';
    
    if (foodData['calories'] != null) {
      caloriesController.text = foodData['calories'].toString();
    }
    
    if (foodData['protein'] != null) {
      proteinController.text = foodData['protein'].toString();
    }
    
    if (foodData['carbohydrates'] != null) {
      carbsController.text = foodData['carbohydrates'].toString();
    }
    
    if (foodData['totalFat'] != null) {
      totalFatController.text = foodData['totalFat'].toString();
    }
    
    if (foodData['saturatedFat'] != null) {
      saturatedFatController.text = foodData['saturatedFat'].toString();
    }
    
    if (foodData['polyunsaturatedFat'] != null) {
      polyunsaturatedFatController.text = foodData['polyunsaturatedFat'].toString();
    }
    
    if (foodData['monounsaturatedFat'] != null) {
      monounsaturatedFatController.text = foodData['monounsaturatedFat'].toString();
    }
    
    if (foodData['transFat'] != null) {
      transFatController.text = foodData['transFat'].toString();
    }
    
    if (foodData['cholesterol'] != null) {
      cholesterolController.text = foodData['cholesterol'].toString();
    }
    
    if (foodData['sodium'] != null) {
      sodiumController.text = foodData['sodium'].toString();
    }
    
    if (foodData['potassium'] != null) {
      potassiumController.text = foodData['potassium'].toString();
    }
    
    if (foodData['sugar'] != null) {
      sugarController.text = foodData['sugar'].toString();
    }
    
    if (foodData['fiber'] != null) {
      fiberController.text = foodData['fiber'].toString();
    }
    
    if (foodData['vitaminA'] != null) {
      vitaminAController.text = foodData['vitaminA'].toString();
    }
    
    if (foodData['vitaminC'] != null) {
      vitaminCController.text = foodData['vitaminC'].toString();
    }
    
    if (foodData['calcium'] != null) {
      calciumController.text = foodData['calcium'].toString();
    }
    
    if (foodData['iron'] != null) {
      ironController.text = foodData['iron'].toString();
    }
    
    update(); // Force UI update
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    servingSizeController.dispose();
    servingPerContainerController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    totalFatController.dispose();
    saturatedFatController.dispose();
    polyunsaturatedFatController.dispose();
    monounsaturatedFatController.dispose();
    transFatController.dispose();
    cholesterolController.dispose();
    sodiumController.dispose();
    potassiumController.dispose();
    sugarController.dispose();
    fiberController.dispose();
    vitaminAController.dispose();
    vitaminCController.dispose();
    calciumController.dispose();
    ironController.dispose();
    super.onClose();
  }

  void goToNextPage() {
    currentPage.value = 1;
  }

  void goToPreviousPage() {
    currentPage.value = 0;
  }

  void updateControllerText(TextEditingController controller, String text) {
    controller.text = text;
    update(); // Force UI update
  }

  Future<void> saveFood() async {
    // Validate required fields
    if (nameController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a food name');
      return;
    }

    isSaving.value = true;

    try {
      final service = FoodService();
      Map<String, dynamic>? response;
      
      if (isEditing.value && foodId != null) {
        // Update existing food
        response = await service.updateFood(
          foodId: foodId!,
          name: nameController.text.trim().isNotEmpty 
              ? nameController.text.trim() 
              : null,
          calories: caloriesController.text.trim().isNotEmpty 
              ? int.tryParse(caloriesController.text.trim()) 
              : null,
          description: descriptionController.text.trim().isNotEmpty 
              ? descriptionController.text.trim() 
              : null,
          servingSize: servingSizeController.text.trim().isNotEmpty 
              ? servingSizeController.text.trim() 
              : null,
          servingPerContainer: servingPerContainerController.text.trim().isNotEmpty 
              ? servingPerContainerController.text.trim() 
              : null,
          protein: proteinController.text.trim().isNotEmpty 
              ? double.tryParse(proteinController.text.trim()) 
              : null,
          carbohydrates: carbsController.text.trim().isNotEmpty 
              ? double.tryParse(carbsController.text.trim()) 
              : null,
          totalFat: totalFatController.text.trim().isNotEmpty 
              ? double.tryParse(totalFatController.text.trim()) 
              : null,
          saturatedFat: saturatedFatController.text.trim().isNotEmpty 
              ? double.tryParse(saturatedFatController.text.trim()) 
              : null,
          polyunsaturatedFat: polyunsaturatedFatController.text.trim().isNotEmpty 
              ? double.tryParse(polyunsaturatedFatController.text.trim()) 
              : null,
          monounsaturatedFat: monounsaturatedFatController.text.trim().isNotEmpty 
              ? double.tryParse(monounsaturatedFatController.text.trim()) 
              : null,
          transFat: transFatController.text.trim().isNotEmpty 
              ? double.tryParse(transFatController.text.trim()) 
              : null,
          cholesterol: cholesterolController.text.trim().isNotEmpty 
              ? double.tryParse(cholesterolController.text.trim()) 
              : null,
          sodium: sodiumController.text.trim().isNotEmpty 
              ? double.tryParse(sodiumController.text.trim()) 
              : null,
          potassium: potassiumController.text.trim().isNotEmpty 
              ? double.tryParse(potassiumController.text.trim()) 
              : null,
          sugar: sugarController.text.trim().isNotEmpty 
              ? double.tryParse(sugarController.text.trim()) 
              : null,
          fiber: fiberController.text.trim().isNotEmpty 
              ? double.tryParse(fiberController.text.trim()) 
              : null,
          vitaminA: vitaminAController.text.trim().isNotEmpty 
              ? double.tryParse(vitaminAController.text.trim()) 
              : null,
          vitaminC: vitaminCController.text.trim().isNotEmpty 
              ? double.tryParse(vitaminCController.text.trim()) 
              : null,
          calcium: calciumController.text.trim().isNotEmpty 
              ? double.tryParse(calciumController.text.trim()) 
              : null,
          iron: ironController.text.trim().isNotEmpty 
              ? double.tryParse(ironController.text.trim()) 
              : null,
        );
      } else {
        // Create new food
        response = await service.saveFood(
          name: nameController.text.trim(),
          calories: caloriesController.text.trim().isNotEmpty 
              ? int.tryParse(caloriesController.text.trim()) 
              : null,
          description: descriptionController.text.trim().isNotEmpty 
              ? descriptionController.text.trim() 
              : null,
          servingSize: servingSizeController.text.trim().isNotEmpty 
              ? servingSizeController.text.trim() 
              : null,
          servingPerContainer: servingPerContainerController.text.trim().isNotEmpty 
              ? servingPerContainerController.text.trim() 
              : null,
          protein: proteinController.text.trim().isNotEmpty 
              ? double.tryParse(proteinController.text.trim()) 
              : null,
          carbohydrates: carbsController.text.trim().isNotEmpty 
              ? double.tryParse(carbsController.text.trim()) 
              : null,
          totalFat: totalFatController.text.trim().isNotEmpty 
              ? double.tryParse(totalFatController.text.trim()) 
              : null,
          saturatedFat: saturatedFatController.text.trim().isNotEmpty 
              ? double.tryParse(saturatedFatController.text.trim()) 
              : null,
          polyunsaturatedFat: polyunsaturatedFatController.text.trim().isNotEmpty 
              ? double.tryParse(polyunsaturatedFatController.text.trim()) 
              : null,
          monounsaturatedFat: monounsaturatedFatController.text.trim().isNotEmpty 
              ? double.tryParse(monounsaturatedFatController.text.trim()) 
              : null,
          transFat: transFatController.text.trim().isNotEmpty 
              ? double.tryParse(transFatController.text.trim()) 
              : null,
          cholesterol: cholesterolController.text.trim().isNotEmpty 
              ? double.tryParse(cholesterolController.text.trim()) 
              : null,
          sodium: sodiumController.text.trim().isNotEmpty 
              ? double.tryParse(sodiumController.text.trim()) 
              : null,
          potassium: potassiumController.text.trim().isNotEmpty 
              ? double.tryParse(potassiumController.text.trim()) 
              : null,
          sugar: sugarController.text.trim().isNotEmpty 
              ? double.tryParse(sugarController.text.trim()) 
              : null,
          fiber: fiberController.text.trim().isNotEmpty 
              ? double.tryParse(fiberController.text.trim()) 
              : null,
          vitaminA: vitaminAController.text.trim().isNotEmpty 
              ? double.tryParse(vitaminAController.text.trim()) 
              : null,
          vitaminC: vitaminCController.text.trim().isNotEmpty 
              ? double.tryParse(vitaminCController.text.trim()) 
              : null,
          calcium: calciumController.text.trim().isNotEmpty 
              ? double.tryParse(calciumController.text.trim()) 
              : null,
          iron: ironController.text.trim().isNotEmpty 
              ? double.tryParse(ironController.text.trim()) 
              : null,
          isCustom: true,
          createdBy: AppConstants.userId,
        );
      }

      isSaving.value = false;

      if (response != null && (response['food'] != null || response['message'] != null)) {
        // Return the updated/created food data
        final foodData = response['food'];
        _showSuccessDialog(
          isEditing.value ? 'Food updated successfully!' : 'Food saved successfully!',
          foodData,
        );
      } else {
        _showErrorDialog(isEditing.value ? 'Failed to update food' : 'Failed to save food');
      }
    } catch (e) {
      isSaving.value = false;
      _showErrorDialog('Error ${isEditing.value ? 'updating' : 'saving'} food: $e');
    }
  }

  void _showSuccessDialog(String message, dynamic foodData) {
    Get.dialog(
      CupertinoAlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(result: foodData); // Go back with the food data
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  void showEditDialog({
    required String label,
    required TextEditingController controller,
    String? placeholder,
  }) {
    final TextEditingController tempController = TextEditingController(text: controller.text);

    Get.bottomSheet(
      Container(
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
              'Edit $label',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeHelper.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Text Field
            CupertinoTextField(
              controller: tempController,
              placeholder: placeholder ?? 'Enter $label',
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

            // Buttons
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: () {
                      Get.back();
                    },
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
                      updateControllerText(controller, tempController.text);
                      Get.back();
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
      isDismissible: true,
      enableDrag: true,
    );
  }

  void showOptionsMenu() {
    Get.bottomSheet(
      CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              showDeleteFoodConfirmation();
            },
            isDestructiveAction: true,
            child: const Text('Delete Food'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Get.back();
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: ThemeHelper.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void showDeleteFoodConfirmation() {
    Get.dialog(
      Center(
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
                      'Delete Food?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.textPrimary,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Get.back(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: ThemeHelper.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.xmark_circle,
                          color: ThemeHelper.textPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'This food will be permanently deleted',
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
                        onTap: () => Get.back(),
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
                              'No',
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
                          Get.back();
                          deleteFood();
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCD5C5C),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Center(
                            child: Text(
                              'Yes',
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
      ),
      barrierDismissible: true,
    );
  }

  Future<void> deleteFood() async {
    if (foodId == null || foodId!.isEmpty) {
      _showErrorDialog('Missing food ID');
      return;
    }

    isSaving.value = true;

    try {
      final service = FoodService();
      final response = await service.deleteFood(foodId: foodId!);

      isSaving.value = false;

      if (response != null && response['message'] != null) {
        // Show success and navigate back with delete flag
        Get.back(result: 'deleted');
      } else {
        _showErrorDialog('Failed to delete food');
      }
    } catch (e) {
      isSaving.value = false;
      _showErrorDialog('Error deleting food: $e');
    }
  }
}


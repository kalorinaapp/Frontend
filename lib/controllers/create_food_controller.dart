import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../services/food_service.dart';
import '../constants/app_constants.dart';

class CreateFoodController extends GetxController {
  // Page control
  final currentPage = 0.obs;
  
  // Loading state
  final isSaving = false.obs;

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

    // if (caloriesController.text.trim().isEmpty) {
    //   _showErrorDialog('Please enter calories');
    //   return;
    // }

    // final calories = int.tryParse(caloriesController.text.trim());
    // if (calories == null || calories < 0) {
    //   _showErrorDialog('Please enter a valid calories value');
    //   return;
    // }

    isSaving.value = true;

    try {
      final service = FoodService();
      final response = await service.saveFood(
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

      isSaving.value = false;

      if (response != null && response['food'] != null) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('Failed to save food');
      }
    } catch (e) {
      isSaving.value = false;
      _showErrorDialog('Error saving food: $e');
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      CupertinoAlertDialog(
        title: const Text('Success'),
        content: const Text('Food saved successfully!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(result: true); // Go back with success flag
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
            Text(
              'Edit $label',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Text Field
            CupertinoTextField(
              controller: tempController,
              placeholder: placeholder ?? 'Enter $label',
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
                      Get.back();
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
                      updateControllerText(controller, tempController.text);
                      Get.back();
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
      isDismissible: true,
      enableDrag: true,
    );
  }
}


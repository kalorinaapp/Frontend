import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:get/get.dart';
import '../controllers/create_food_controller.dart';

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
    final controller = Get.put(CreateFoodController());
    
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
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
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
                      color: CupertinoColors.black,
                    ),
                  ),
                  const Spacer(),
                  Obx(() => Text(
                    controller.isEditing.value 
                        ? (controller.currentPage.value == 0 ? 'Edit Food' : 'Edit Food') 
                        : (controller.currentPage.value == 0 ? 'Create Food' : 'Add Food'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  )),
                  const Spacer(),
                  Obx(() => controller.isEditing.value
                      ? GestureDetector(
                          onTap: () {
                            controller.showOptionsMenu();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              CupertinoIcons.ellipsis_vertical,
                              size: 24,
                              color: CupertinoColors.black,
                            ),
                          ),
                        )
                      : const SizedBox(width: 24)), // Balance the back button
                ],
              ),
            ),

            // Content - Show different pages based on currentPage
            Expanded(
              child: Obx(() => controller.currentPage.value == 0 ? _buildPage1() : _buildPage2()),
            ),
          ],
        ),
      ),
    );
  }

  // Page 1: Basic Information
  Widget _buildPage1() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Food Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.25),
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field (Required)
                      _buildFieldRow(
                        label: 'Name *',
                        textController: controller.nameController,
                        placeholder: '',
                      ),
                      
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      // Description Field
                      _buildFieldRow(
                        label: 'Description',
                        textController: controller.descriptionController,
                        placeholder: '',
                      ),

                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      // Serving size Field
                      _buildFieldRow(
                        label: 'Serving size',
                        textController: controller.servingSizeController,
                        placeholder: '',
                      ),

                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      // Serving per container Field
                      _buildFieldRow(
                        label: 'Serving per container',
                        textController: controller.servingPerContainerController,
                        placeholder: '',
                      ),
                      
                    ],
                  ),
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
                  color: CupertinoColors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  'Next',
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
                      color: CupertinoColors.black.withOpacity(0.3),
                      width: 1,
                    ),
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.25),
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
                  color: controller.isSaving.value ? CupertinoColors.systemGrey : CupertinoColors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: controller.isSaving.value
                    ? const Center(
                        child: CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        ),
                      )
                    : Obx(() => Text(
                        controller.currentPage.value == 0 ? 'Next' : 'Save Food',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
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
            style: const TextStyle(
              color: CupertinoColors.black,
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
                        color: CupertinoColors.black.withOpacity(0.6),
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
                        color: CupertinoColors.black.withOpacity(0.6),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Icon(
                  CupertinoIcons.pencil,
                  size: 8,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow({
    required String label,
    required TextEditingController textController,
    String? placeholder,
  }) {
    return GestureDetector(
      onTap: () {
        controller.showEditDialog(
          label: label,
          controller: textController,
          placeholder: placeholder,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label
          Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.black,
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
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      textController.text,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: CupertinoColors.black.withOpacity(0.6),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Icon(
                  CupertinoIcons.pencil,
                  size: 8,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1.47,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: CupertinoColors.black.withOpacity(0.15),
          ),
        ),
      ),
    );
  }
}


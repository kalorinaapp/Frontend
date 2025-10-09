import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;

class CreateFoodScreen extends StatefulWidget {
  const CreateFoodScreen({super.key});

  @override
  State<CreateFoodScreen> createState() => _CreateFoodScreenState();
}

class _CreateFoodScreenState extends State<CreateFoodScreen> {
  // Page control
  int _currentPage = 0;

  // Basic info controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _servingSizeController = TextEditingController(text: '1tbsp');
  final TextEditingController _servingPerContainerController = TextEditingController(text: '1');

  // Nutrition controllers
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _totalFatController = TextEditingController();
  final TextEditingController _saturatedFatController = TextEditingController();
  final TextEditingController _polyunsaturatedFatController = TextEditingController();
  final TextEditingController _monounsaturatedFatController = TextEditingController();
  final TextEditingController _transFatController = TextEditingController();
  final TextEditingController _cholesterolController = TextEditingController();
  final TextEditingController _sodiumController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _fiberController = TextEditingController();
  final TextEditingController _vitaminAController = TextEditingController();
  final TextEditingController _vitaminCController = TextEditingController();
  final TextEditingController _calciumController = TextEditingController();
  final TextEditingController _ironController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _servingSizeController.dispose();
    _servingPerContainerController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _totalFatController.dispose();
    _saturatedFatController.dispose();
    _polyunsaturatedFatController.dispose();
    _monounsaturatedFatController.dispose();
    _transFatController.dispose();
    _cholesterolController.dispose();
    _sodiumController.dispose();
    _potassiumController.dispose();
    _sugarController.dispose();
    _fiberController.dispose();
    _vitaminAController.dispose();
    _vitaminCController.dispose();
    _calciumController.dispose();
    _ironController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal:  20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_currentPage == 1) {
                        setState(() {
                          _currentPage = 0;
                        });
                      } else {
                        Navigator.of(context).pop();
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
                  Text(
                    _currentPage == 0 ? 'Create Food' : 'Add Food',
                    style: const TextStyle(
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

            // Content - Show different pages based on _currentPage
            Expanded(
              child: _currentPage == 0 ? _buildPage1() : _buildPage2(),
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
                      // Name Field
                      _buildFieldRow(
                        label: 'Name',
                        controller: _nameController,
                        placeholder: '',
                        showValue: false,
                      ),
                      
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      // Description Field
                      _buildFieldRow(
                        label: 'Description',
                        controller: _descriptionController,
                        placeholder: '',
                        showValue: false,
                      ),

                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      // Serving size Field
                      _buildFieldRow(
                        label: 'Serving size',
                        controller: _servingSizeController,
                        value: _servingSizeController.text,
                        showValue: true,
                      ),

                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      // Serving per container Field
                      _buildFieldRow(
                        label: 'Serving per container',
                        controller: _servingPerContainerController,
                        value: _servingPerContainerController.text,
                        showValue: true,
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
                setState(() {
                  _currentPage = 1;
                });
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
                      _buildNutritionFieldRow('Protein', _proteinController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Carbs', _carbsController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Total fat', _totalFatController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Saturated fat', _saturatedFatController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Polyunsaturated fat', _polyunsaturatedFatController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Monounsaturated fat', _monounsaturatedFatController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Trans fat', _transFatController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Cholesterol', _cholesterolController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Sodium', _sodiumController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Potassium', _potassiumController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Sugar', _sugarController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Fiber', _fiberController, hasUnit: true),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Vitamin A', _vitaminAController, hasUnit: false),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Vitamin C', _vitaminCController, hasUnit: false),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Calcium', _calciumController, hasUnit: false),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 16),

                      _buildNutritionFieldRow('Iron', _ironController, hasUnit: false),
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
            child: GestureDetector(
              onTap: () {
                // TODO: Save food functionality
                Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child:  Text(
                  _currentPage == 0 ? 'Next' : 'Save Food',
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

  Widget _buildNutritionFieldRow(String label, TextEditingController controller, {required bool hasUnit}) {
    return Row(
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
        Row(
          children: [
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
            GestureDetector(
              onTap: () {
                _showEditDialog(
                  label: label,
                  controller: controller,
                  placeholder: '',
                );
              },
              child: const Icon(
                CupertinoIcons.pencil,
                size: 8,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldRow({
    required String label,
    required TextEditingController controller,
    String? value,
    String? placeholder,
    bool showValue = false,
  }) {
    return Row(
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
        Row(
          children: [
            if (showValue && value != null && value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: CupertinoColors.black.withOpacity(0.6),
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            GestureDetector(
              onTap: () {
                _showEditDialog(
                  label: label,
                  controller: controller,
                  placeholder: placeholder,
                );
              },
              child: const Icon(
                CupertinoIcons.pencil,
                size: 8,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ],
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

  void _showEditDialog({
    required String label,
    required TextEditingController controller,
    String? placeholder,
  }) {
    final TextEditingController tempController = TextEditingController(text: controller.text);

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
                      setState(() {
                        controller.text = tempController.text;
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
}


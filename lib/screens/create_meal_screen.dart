import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import '../services/meals_service.dart';
import 'edit_macro_screen.dart';

class CreateMealScreen extends StatefulWidget {
  final Map<String, dynamic>? mealData;
  final String? userId;
  final String? mealType;
  
  const CreateMealScreen({
    super.key,
    this.mealData,
    this.userId,
    this.mealType,
  });

  @override
  State<CreateMealScreen> createState() => _CreateMealScreenState();
}

class _CreateMealScreenState extends State<CreateMealScreen> {
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  // Macro values
  int _carbsValue = 10;
  int _proteinValue = 41;
  int _fatsValue = 16;
  
  // Amount value
  double _amountValue = 1.0;
  
  // Meal data
  List<dynamic> _ingredients = [];
  
  // Loading state
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadMealData();
  }

  void _loadMealData() {
    if (widget.mealData != null) {
      final data = widget.mealData!;
      _nameController.text = data['name'] ?? '';
      _caloriesController.text = (data['calories'] ?? 0).toString();
      _carbsValue = data['carbohydrates'] ?? 10;
      _proteinValue = data['protein'] ?? 41;
      _fatsValue = data['fat'] ?? 16;
      _ingredients = data['items'] ?? [];
      
      // Set amount from serving size if available
      final servingSize = data['servingSize'];
      if (servingSize != null) {
        final parsedAmount = double.tryParse(servingSize.toString());
        if (parsedAmount != null) {
          _amountValue = parsedAmount;
        }
      }
    }
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _nameController.dispose();
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
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Stack(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      const Text(
                        'Create a Meal',
                        style: TextStyle(
                          
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.black,
                          
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          // Bookmark icon
                          // Container(
                          //   margin: const EdgeInsets.only(bottom: 20),
                          //   child: const Icon(
                          //     CupertinoIcons.bookmark,
                          //     size: 24,
                          //     color: CupertinoColors.black,
                          //   ),
                          // ),
                          
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
                              controller: _nameController,
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
                              suffix: const Icon(
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
                                      const Text(
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
                                'Meal Items',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showAddIngredientDialog();
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
                                    children: const [
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
                          if (_ingredients.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ..._ingredients.map((ingredient) => _buildIngredientCard(ingredient)).toList(),
                          ],
                          
                          const SizedBox(height: 16),
                          
                          // Amount Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
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
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: CupertinoColors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
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
                          
                          // const SizedBox(height: 100), // Space for bottom button
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Add Button
                  Positioned(
                    bottom: -12,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: GestureDetector(
                        onTap: _isSaving ? null : _saveMeal,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _isSaving 
                                ? CupertinoColors.systemGrey 
                                : CupertinoColors.black,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: _isSaving
                              ? const Center(
                                  child: CupertinoActivityIndicator(
                                    color: CupertinoColors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Meal',
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMeal() async {
    // Validate meal name
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a meal name');
      return;
    }

    // Validate that we have required parameters
    if (widget.userId == null || widget.mealType == null) {
      _showErrorDialog('Missing user or meal type information');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Prepare entries data
      final entries = _ingredients.map((ingredient) {
        return {
          'userId': widget.userId!,
          'mealType': widget.mealType!,
          'foodName': ingredient['name'] ?? '',
          'quantity': ingredient['quantity'] ?? 0,
          'unit': ingredient['unit'] ?? '',
          'calories': ingredient['calories'] ?? 0,
          'protein': ingredient['protein'] ?? 0,
          'carbs': ingredient['carbohydrates'] ?? 0,
          'fat': ingredient['fat'] ?? 0,
        };
      }).toList();

      // Get current date in ISO format
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day).toIso8601String();

      // Call API
      final service = MealsService();
      final response = await service.saveCompleteMeal(
        userId: widget.userId!,
        date: date,
        mealType: widget.mealType!,
        mealName: _nameController.text.trim(),
        entries: entries,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        if (response != null && response['success'] == true) {
          // Show success and navigate back
          _showSuccessDialog();
        } else {
          _showErrorDialog('Failed to save meal');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        _showErrorDialog('Error saving meal: $e');
      }
    }
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: const Text('Meal saved successfully!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Go back with success flag
            },
          ),
        ],
      ),
    );
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
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
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
                          _amountValue = double.parse(value.toString());
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
                  Image.asset(icon, width: 12, height: 12),
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
                '$amount g',
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

  Widget _buildIngredientCard(dynamic ingredient) {
    final name = ingredient['name'] ?? '';
    final quantity = ingredient['quantity']?.toString() ?? '';
    final unit = ingredient['unit'] ?? '';
    final calories = ingredient['calories']?.toString() ?? '0';
    final protein = ingredient['protein']?.toString() ?? '0';
    final carbs = ingredient['carbohydrates']?.toString() ?? '0';
    final fat = ingredient['fat']?.toString() ?? '0';
    
    return GestureDetector(
      onTap: () {
        _showAddIngredientDialog(existingIngredient: ingredient);
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
                      _ingredients.remove(ingredient);
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
                  _buildNutrientBadge('$calories kcal'),
                if (protein != '0')
                  _buildNutrientBadge('P: ${protein}g'),
                if (carbs != '0')
                  _buildNutrientBadge('C: ${carbs}g'),
                if (fat != '0')
                  _buildNutrientBadge('F: ${fat}g'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientBadge(String text) {
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

  void _showAddIngredientDialog({dynamic existingIngredient}) {
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
                           final index = _ingredients.indexOf(existingIngredient);
                           if (index != -1) {
                             _ingredients[index] = ingredientData;
                           }
                         } else {
                           // Add new ingredient
                           _ingredients.add(ingredientData);
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


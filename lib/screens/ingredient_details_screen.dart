import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Slider, SliderTheme, SliderThemeData, RoundSliderThumbShape, RoundSliderOverlayShape, Material;
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;

class IngredientDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> ingredientData;
  
  const IngredientDetailsScreen({
    super.key,
    required this.ingredientData,
  });

  @override
  State<IngredientDetailsScreen> createState() => _IngredientDetailsScreenState();
}

class _IngredientDetailsScreenState extends State<IngredientDetailsScreen> {
  late Map<String, dynamic> _currentIngredient;
  double _servingAmount = 1.0;
  String _selectedUnit = 'g';
  
  // Store original base values
  late int _baseCalories;
  late int _baseProtein;
  late int _baseCarbs;
  late int _baseFat;
  late int _baseFiber;
  late int _baseSugar;
  late int _baseSodium;
  
  // Available size options
  final List<String> _sizeOptions = ['G', 'Oz', 'Serving', 'Cup', 'Tbsp', 'Tsp', 'ml'];

  @override
  void initState() {
    super.initState();
    _currentIngredient = Map<String, dynamic>.from(widget.ingredientData);
    _servingAmount = (_currentIngredient['quantity'] as num?)?.toDouble() ?? 1.0;
    _selectedUnit = _currentIngredient['unit'] ?? 'g';
    
    // Store original base values (normalized to quantity of 1)
    final currentQuantity = (_currentIngredient['quantity'] as num?)?.toDouble() ?? 1.0;
    _baseCalories = (((_currentIngredient['calories'] as num?)?.toInt() ?? 0) / currentQuantity).round();
    _baseProtein = (((_currentIngredient['protein'] as num?)?.toInt() ?? 0) / currentQuantity).round();
    _baseCarbs = (((_currentIngredient['carbs'] as num?)?.toInt() ?? 0) / currentQuantity).round();
    _baseFat = (((_currentIngredient['fat'] as num?)?.toInt() ?? 0) / currentQuantity).round();
    _baseFiber = (((_currentIngredient['fiber'] as num?)?.toInt() ?? 0) / currentQuantity).round();
    _baseSugar = (((_currentIngredient['sugar'] as num?)?.toInt() ?? 0) / currentQuantity).round();
    _baseSodium = (((_currentIngredient['sodium'] as num?)?.toInt() ?? 0) / currentQuantity).round();
  }

  // Calculate scaled macros based on serving amount
  int _getScaledValue(String key) {
    switch (key) {
      case 'calories':
        return (_baseCalories * _servingAmount).round();
      case 'protein':
        return (_baseProtein * _servingAmount).round();
      case 'carbs':
        return (_baseCarbs * _servingAmount).round();
      case 'fat':
        return (_baseFat * _servingAmount).round();
      case 'fiber':
        return (_baseFiber * _servingAmount).round();
      case 'sugar':
        return (_baseSugar * _servingAmount).round();
      case 'sodium':
        return (_baseSodium * _servingAmount).round();
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodName = (_currentIngredient['foodName'] as String?)?.trim() ?? 'Food Details';
    final calories = _getScaledValue('calories');
    final protein = _getScaledValue('protein');
    final carbs = _getScaledValue('carbs');
    final fat = _getScaledValue('fat');

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header with back button
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
                  SizedBox(
                    width: 274,
                    child: Text(
                      foodName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: CupertinoColors.black,
                        fontSize: 20,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24), // Balance the back button
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      
                      // Calories Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 5,
                              offset: Offset(0, 0),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset('assets/icons/flame_black.png', width: 28, height: 28),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Calories',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xB21E1822),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$calories',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xE61E1822),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Macros Row (3 cards)
                      Row(
                        children: [
                          Expanded(
                            child: _buildMacroCard(
                              'Carbs',
                              '$carbs g',
                              'assets/icons/carbs.png',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMacroCard(
                              'Protein',
                              '$protein g',
                              'assets/icons/drumstick.png',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMacroCard(
                              'Fats',
                              '$fat g',
                              'assets/icons/fat.png',
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Size Section
                      const Text(
                        'Size',
                        style: TextStyle(
                          color: Color(0xFF1E1822),
                          fontSize: 12,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Size Options - Multiple rows
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _sizeOptions.map((size) {
                          final normalizedSelected = _selectedUnit.toLowerCase();
                          final normalizedSize = size.toLowerCase();
                          final isSelected = normalizedSelected == normalizedSize;
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedUnit = size.toLowerCase();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? CupertinoColors.black : CupertinoColors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 3,
                                    offset: Offset(0, 0),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                size,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? CupertinoColors.white : CupertinoColors.black,
                                  fontSize: 10,
                                  fontFamily: 'Instrument Sans',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Slider
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Material(
                          color: CupertinoColors.white,
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                              activeTrackColor: CupertinoColors.black,
                              inactiveTrackColor: CupertinoColors.black.withOpacity(0.20),
                            ),
                            child: Slider(
                              value: _servingAmount,
                              min: 0.25,
                              max: 10,
                              divisions: 39,
                              onChanged: (value) {
                                setState(() {
                                  _servingAmount = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Number of servings Section
                      const Text(
                        'Number of servings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1E1822),
                          fontSize: 12,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Serving Amount Display
                      Center(
                        child: GestureDetector(
                          onTap: () => _showEditServingSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 5,
                                  offset: Offset(0, 0),
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _servingAmount.toStringAsFixed(_servingAmount.truncateToDouble() == _servingAmount ? 0 : 1),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF1E1822),
                                    fontSize: 14,
                                    fontFamily: 'Instrument Sans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  CupertinoIcons.pencil,
                                  size: 14,
                                  color: Color(0xFF1E1822),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Done Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  // Update ingredient data before returning
                  _currentIngredient['quantity'] = _servingAmount;
                  _currentIngredient['unit'] = _selectedUnit;
                  
                  // Scale the macros based on serving amount using stored base values
                  _currentIngredient['calories'] = (_baseCalories * _servingAmount).round();
                  _currentIngredient['protein'] = (_baseProtein * _servingAmount).round();
                  _currentIngredient['carbs'] = (_baseCarbs * _servingAmount).round();
                  _currentIngredient['fat'] = (_baseFat * _servingAmount).round();
                  _currentIngredient['fiber'] = (_baseFiber * _servingAmount).round();
                  _currentIngredient['sugar'] = (_baseSugar * _servingAmount).round();
                  _currentIngredient['sodium'] = (_baseSodium * _servingAmount).round();
                  
                  Navigator.of(context).pop(_currentIngredient);
                },
                child: Container(
                  width: 250,
                  height: 45,
                  decoration: BoxDecoration(
                    color: CupertinoColors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'Done',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Instrument Sans',
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
    );
  }

  Widget _buildMacroCard(String label, String value, String iconAsset) {
    return Container(
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
                Image.asset(iconAsset, width: 12, height: 12),
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
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditServingSheet(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: _servingAmount.toStringAsFixed(_servingAmount.truncateToDouble() == _servingAmount ? 0 : 1),
    );
    
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
            const Text(
              'Enter Serving Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            CupertinoTextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
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
                      final newAmount = double.tryParse(controller.text) ?? 1.0;
                      setState(() {
                        _servingAmount = newAmount.clamp(0.25, 10.0);
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


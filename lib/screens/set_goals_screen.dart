import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import '../utils/theme_helper.dart' show ThemeHelper;

class SetGoalsScreen extends StatefulWidget {
  // final ThemeProvider themeProvider;

  const SetGoalsScreen({
    super.key,
    // required this.themeProvider,
  });

  @override
  State<SetGoalsScreen> createState() => _SetGoalsScreenState();
}

class _SetGoalsScreenState extends State<SetGoalsScreen> {
  final TextEditingController _caloriesController = TextEditingController(text: '75');
  final TextEditingController _carbsController = TextEditingController(text: '75');
  final TextEditingController _proteinController = TextEditingController(text: '75');
  final TextEditingController _fatsController = TextEditingController(text: '75');

  @override
  void dispose() {
    _caloriesController.dispose();
    _carbsController.dispose();
    _proteinController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          // Custom header with back button and title
           Padding(
             padding: const EdgeInsets.all(24.0),
             child: GestureDetector(
                                onTap: () {
                                 Navigator.of(context).pop();
                                },
                                child: SvgPicture.asset(
                                  color: ThemeHelper.textPrimary,
                                  'assets/icons/back.svg',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
           ),
          
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  
                  // Title
                  Text(
                    'Postavi Svoje Ciljeve',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Kalorije Goal Card
                  _buildMacroCard(
                    'Kalorije',
                    _caloriesController,
                    'flame', // Your asset placeholder
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Ugljikohidrati Goal Card
                  _buildMacroCard(
                    'Ugljikohidrati',
                    _carbsController,
                    'wheat', // Your asset placeholder
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Proteini Goal Card
                  _buildMacroCard(
                    'Proteini',
                    _proteinController,
                    'protein', // Your asset placeholder
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Masti Goal Card
                  _buildMacroCard(
                    'Masti',
                    _fatsController,
                    'fat', // Your asset placeholder
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Auto Generation Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // AI Icon placeholder - you will replace with your asset
                        Image.asset('assets/images/AI_Slides.png'),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          'Automatski generiraj ciljeve uz pomoć\nstručnih nutricionističkih algoritama',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey2,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Generate Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(width: 0.5, color: CupertinoColors.black),
                    ),
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(16),
                      onPressed: () {
                        // Handle AI generation
                      },
                      child: Text(
                        'Automatska Generacija',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.black,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(String label, TextEditingController controller, String assetName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.systemGrey2,
              ),
            ),
          ),
        Container(
          width: MediaQuery.of(context).size.width * 0.55,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              
              // Value and icon section
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    // Value input
                    Expanded(
                      child: CupertinoTextField(
                        controller: controller,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.normal,
                          color: CupertinoColors.black,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    
                    // Icon placeholder - you will replace with your assets
                    Center(
                      child: Text(
                        _getIconPlaceholder(assetName),
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getIconPlaceholder(String assetName) {
    switch (assetName) {
      case 'flame':
        return '🔥';
      case 'wheat':
        return '🌾';
      case 'protein':
        return '💧';
      case 'fat':
        return '🔴';
      default:
        return '📊';
    }
  }
}

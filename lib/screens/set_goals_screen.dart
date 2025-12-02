import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../automatic_generation_pageview.dart' show AutomaticGenerationPageview;
import '../utils/theme_helper.dart' show ThemeHelper;
import '../providers/theme_provider.dart' show ThemeProvider;
import '../services/progress_service.dart' show ProgressService;
import '../l10n/app_localizations.dart' show AppLocalizations;
import 'edit_macro_screen.dart' show EditMacroScreen;

class SetGoalsScreen extends StatefulWidget {
  final Map<String, dynamic>? dailyProgress;
  // final ThemeProvider themeProvider;

  const SetGoalsScreen({
    this.dailyProgress,
    super.key,
    // required this.themeProvider,
  });

  @override
  State<SetGoalsScreen> createState() => _SetGoalsScreenState();
}

class _SetGoalsScreenState extends State<SetGoalsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkProgressData();
  }

  void _checkProgressData() {
    // Check if we have progress data, if not show loading
    final progressService = Get.find<ProgressService>();
    if (progressService.dailyProgressData != null) {
      setState(() {
        _isLoading = false;
      });
    } else {
      // Listen for progress data updates
      progressService.addListener(() {
        if (mounted && progressService.dailyProgressData != null) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
 
    return CupertinoPageScaffold(
      backgroundColor: ThemeHelper.background,
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
                    AppLocalizations.of(context)!.setYourGoals,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ThemeHelper.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Kalorije Goal Card
                  _isLoading 
                    ? _buildShimmerCard(AppLocalizations.of(context)!.caloriesLabel, 'assets/icons/apple.png')
                    : _buildMacroCard(
                        AppLocalizations.of(context)!.caloriesLabel,
                        'assets/icons/apple.png',
                        'calories',
                        CupertinoColors.systemGrey2,
                      ),
                  
                  const SizedBox(height: 16),
                  
                  // Ugljikohidrati Goal Card
                  _isLoading 
                    ? _buildShimmerCard(AppLocalizations.of(context)!.carbs, 'assets/icons/carbs.png')
                    : _buildMacroCard(
                        AppLocalizations.of(context)!.carbs,
                        'assets/icons/carbs.png',
                        'carbs',
                        CupertinoColors.systemOrange,
                      ),
                  
                  const SizedBox(height: 16),
                  
                  // Proteini Goal Card
                  _isLoading 
                    ? _buildShimmerCard(AppLocalizations.of(context)!.protein, 'assets/icons/drumstick.png')
                    : _buildMacroCard(
                        AppLocalizations.of(context)!.protein,
                        'assets/icons/drumstick.png',
                        'protein',
                        CupertinoColors.systemBlue,
                      ),
                  
                  const SizedBox(height: 16),
                  
                  // Masti Goal Card
                  _isLoading 
                    ? _buildShimmerCard(AppLocalizations.of(context)!.fats, 'assets/icons/fat.png')
                    : _buildMacroCard(
                        AppLocalizations.of(context)!.fats,
                        'assets/icons/fat.png',
                        'fat',
                        CupertinoColors.systemRed,
                      ),
                  
                  const SizedBox(height: 60),
                  
                  // Auto Generation Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ThemeHelper.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // AI Icon placeholder - you will replace with your asset
                        Image.asset('assets/images/AI_Slides.png'),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          AppLocalizations.of(context)!.autoGenerateDescription,
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeHelper.textSecondary,
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
                      border: Border.all(width: 0.5, color: ThemeHelper.textPrimary),
                    ),
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: ThemeHelper.background,
                      borderRadius: BorderRadius.circular(16),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AutomaticGenerationPageview(themeProvider: Get.find<ThemeProvider>())),
                        );
                        // Handle AI generation
                      },
                      child: Text(
                        AppLocalizations.of(context)!.autoGenerate,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.textPrimary,
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

  Widget _buildShimmerCard(String label, String assetName) {
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
              color: ThemeHelper.textSecondary,
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.55,
          decoration: BoxDecoration(
            color: ThemeHelper.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Shimmer.fromColors(
            baseColor: ThemeHelper.divider,
            highlightColor: ThemeHelper.cardBackground,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  // Shimmer placeholder for value
                  Expanded(
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: ThemeHelper.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  
                  // Icon (not shimmered)
                  Center(
                    child: Image.asset(
                      assetName, 
                      width: assetName == 'assets/icons/apple.png' ? 25 : 24, 
                      height: assetName == 'assets/icons/apple.png' ? 25 : 24,
                      color: assetName == 'assets/icons/apple.png' ? ThemeHelper.textPrimary : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard(String label, String assetName, String dataKey, Color color) {
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
                color: ThemeHelper.textSecondary,
              ),
            ),
          ),
        GestureDetector(
          onTap: () => _navigateToEditMacro(label, assetName, dataKey, color),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.55,
            decoration: BoxDecoration(
              color: ThemeHelper.cardBackground,
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
                      // Value display using GetBuilder with null safety
                      Expanded(
                        child: GetBuilder<ProgressService>(
                          builder: (progressService) {
                            final progressData = progressService.dailyProgressData;
                            int value = 0;
                            
                            debugPrint('ProgressService data for $dataKey: $progressData');
                            
                            if (progressData != null && progressData['progress'] != null) {
                              final progress = progressData['progress'] as Map<String, dynamic>;
                              
                              if (dataKey == 'calories') {
                                value = progress['calories']?['goal'] ?? 0;
                              } else if (progress['macros'] != null) {
                                final macros = progress['macros'] as Map<String, dynamic>;
                                value = macros[dataKey]?['goal'] ?? 0;
                              }
                            }
                            
                            debugPrint('Value for $dataKey: $value');
                            
                            return Text(
                              value.toString(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.normal,
                                color: ThemeHelper.textPrimary,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Icon
                      Center(
                        child: Image.asset(assetName, width: assetName == 'assets/icons/apple.png' ? 25 : 24, height: assetName == 'assets/icons/apple.png' ? 25 : 24, color: assetName == 'assets/icons/apple.png' ? ThemeHelper.textPrimary : null),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToEditMacro(String label, String assetName, String dataKey, Color color) {
    final progressService = Get.find<ProgressService>();
    final progressData = progressService.dailyProgressData;
    int initialValue = 0;
    
    if (progressData != null && progressData['progress'] != null) {
      final progress = progressData['progress'] as Map<String, dynamic>;
      
      if (dataKey == 'calories') {
        initialValue = progress['calories']?['goal'] ?? 0;
      } else if (progress['macros'] != null) {
        final macros = progress['macros'] as Map<String, dynamic>;
        initialValue = macros[dataKey]?['goal'] ?? 0;
      }
    }
    
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EditMacroScreen(
          macroName: label,
          iconAsset: assetName,
          color: color,
          initialValue: initialValue,
          onValueChanged: (newValue) => _updateMacroGoal(dataKey, newValue),
        ),
      ),
    );
  }

  Future<void> _updateMacroGoal(String dataKey, int newValue) async {
    final progressService = Get.find<ProgressService>();
    final progressData = progressService.dailyProgressData;
    
    if (progressData == null || progressData['progress'] == null) {
      debugPrint('Cannot update macro goal: progress data is null');
      return;
    }
    
    // Deep clone the progress data to update it optimistically
    final updatedProgress = Map<String, dynamic>.from(progressData);
    final progress = Map<String, dynamic>.from(updatedProgress['progress'] as Map<String, dynamic>);
    
    // Update the specific goal value in the progress map
    if (dataKey == 'calories') {
      if (progress['calories'] != null) {
        final calories = Map<String, dynamic>.from(progress['calories'] as Map<String, dynamic>);
        final consumed = (calories['consumed'] as num?)?.toInt() ?? 0;
        calories['goal'] = newValue;
        calories['remaining'] = newValue - consumed;
        progress['calories'] = calories;
        debugPrint('Updated calories goal in progress map: $newValue (remaining: ${calories['remaining']})');
      } else {
        // Create calories entry if it doesn't exist
        progress['calories'] = {
          'goal': newValue,
          'consumed': 0,
          'remaining': newValue,
        };
        debugPrint('Created calories entry in progress map: $newValue');
      }
    } else {
      // Handle macros (carbs, protein, fat)
      if (progress['macros'] == null) {
        progress['macros'] = <String, dynamic>{};
      }
      
      final macros = Map<String, dynamic>.from(progress['macros'] as Map<String, dynamic>);
      
      if (macros[dataKey] != null) {
        final macro = Map<String, dynamic>.from(macros[dataKey] as Map<String, dynamic>);
        final consumed = (macro['consumed'] as num?)?.toInt() ?? 0;
        macro['goal'] = newValue;
        macro['remaining'] = newValue - consumed;
        macros[dataKey] = macro;
        debugPrint('Updated $dataKey goal in progress map: $newValue (remaining: ${macro['remaining']})');
      } else {
        // Create macro entry if it doesn't exist
        macros[dataKey] = {
          'goal': newValue,
          'consumed': 0,
          'remaining': newValue,
        };
        debugPrint('Created $dataKey entry in progress map: $newValue');
      }
      
      progress['macros'] = macros;
    }
    
    // Update the progress in the main data structure
    updatedProgress['progress'] = progress;
    
    // Update progress data optimistically - this triggers UI refresh
    progressService.updateProgressData(updatedProgress);
    debugPrint('Progress map updated successfully');
    
    // Update via API using adjustments endpoint
    try {
      // Get current date in YYYY-MM-DD format
      final now = DateTime.now();
      final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      // Map dataKey to API parameters
      int? calories;
      int? protein;
      int? carbs;
      int? fat;
      
      if (dataKey == 'calories') {
        calories = newValue;
      } else if (dataKey == 'protein') {
        protein = newValue;
      } else if (dataKey == 'carbs') {
        carbs = newValue;
      } else if (dataKey == 'fat') {
        fat = newValue;
      }
      
      debugPrint('Updating manual progress via API: date=$dateStr, calories=$calories, protein=$protein, carbs=$carbs, fat=$fat');
      
      final result = await progressService.updateManualProgress(
        dateYYYYMMDD: dateStr,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );
      
      if (result != null && (result['success'] == true || result['success'] == null)) {
        debugPrint('Manual progress updated successfully, refreshing progress data');
        // Refresh progress data to get updated values from server
        await progressService.fetchDailyProgress(dateYYYYMMDD: dateStr);
      } else {
        debugPrint('Manual progress update failed, keeping optimistic update');
        debugPrint('Response: $result');
      }
    } catch (e) {
      debugPrint('Error updating manual progress via API: $e');
      // Keep the optimistic update even if API call fails
    }
  }

}

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
                      ),
                  
                  const SizedBox(height: 16),
                  
                  // Ugljikohidrati Goal Card
                  _isLoading 
                    ? _buildShimmerCard(AppLocalizations.of(context)!.carbs, 'assets/icons/carbs.png')
                    : _buildMacroCard(
                        AppLocalizations.of(context)!.carbs,
                        'assets/icons/carbs.png',
                        'carbs',
                      ),
                  
                  const SizedBox(height: 16),
                  
                  // Proteini Goal Card
                  _isLoading 
                    ? _buildShimmerCard(AppLocalizations.of(context)!.protein, 'assets/icons/drumstick.png')
                    : _buildMacroCard(
                        AppLocalizations.of(context)!.protein,
                        'assets/icons/drumstick.png',
                        'protein',
                      ),
                  
                  const SizedBox(height: 16),
                  
                  // Masti Goal Card
                  _isLoading 
                    ? _buildShimmerCard(AppLocalizations.of(context)!.fats, 'assets/icons/fat.png')
                    : _buildMacroCard(
                        AppLocalizations.of(context)!.fats,
                        'assets/icons/fat.png',
                        'fat',
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
                      width: assetName == 'assets/icons/apple.png' ? 36 : 24, 
                      height: assetName == 'assets/icons/apple.png' ? 36 : 24,
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

  Widget _buildMacroCard(String label, String assetName, String dataKey) {
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
                      child: Image.asset(assetName, width: assetName == 'assets/icons/apple.png' ? 36 : 24, height: assetName == 'assets/icons/apple.png' ? 36 : 24, color: assetName == 'assets/icons/apple.png' ? ThemeHelper.textPrimary : null),
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

}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../l10n/app_localizations.dart' show AppLocalizations;
import '../onboarding/screens/stage4_personalization/settings_page.dart' show SettingsPage;
import '../providers/health_provider.dart' show HealthProvider;
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../utils/theme_helper.dart' show ThemeHelper;
import 'dashboard_screen.dart';
import 'log.screen.dart' show LogScreen;
import 'progress_screen.dart';
import '../camera/scan_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../constants/app_constants.dart';
import '../network/http_helper.dart';
import '../services/meals_service.dart';
import '../services/progress_service.dart';
import '../services/streak_service.dart';
import '../utils/user.prefs.dart' show UserPrefs;
import 'meal_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  final LanguageProvider languageProvider;

  const HomeScreen({
    super.key, 
    required this.themeProvider,
    required this.languageProvider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HealthProvider healthProvider = HealthProvider();
  final List<Widget> _screens = [];
  bool _showAddModal = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isAnalyzing = false;
  bool _hasScanError = false;
  bool _isLoadingInitialData = true;
  Map<String, dynamic>? _scanResult;
  Map<String, int>? _todayTotals; // calories, protein, fats, carbs
  String? _todayCreatedAt;
  List<Map<String, dynamic>> _todayEntries = const [];
  List<Map<String, dynamic>> _todayMeals = const [];
  List<Map<String, dynamic>> _todayExercises = const [];
  Map<String, dynamic>? _dailyProgress;
  Map<String, dynamic>? _dailySummary; // Combined summary with calories consumed/burned
  bool _isWeighInDueToday = false;

  @override
  void initState() {
    super.initState();
    // Initialize ProgressService as singleton
    Get.put(ProgressService());
    _updateScreens();
    _loadInitialData();
    _checkWeighInDue();
  }

  // Helper method to check if weigh-in is due today
  Future<void> _checkWeighInDue() async {
    final DateTime? lastWeighIn = await UserPrefs.getLastWeighInDate();
    if (lastWeighIn == null) {
      // If no previous weigh-in, suggest weighing in
      if (mounted) {
        setState(() {
          _isWeighInDueToday = true;
        });
      }
      return;
    }
    
    final DateTime now = DateTime.now();
    final int daysSince = now.difference(lastWeighIn).inDays;
    
    // Dynamic cadence based on user's weigh-in pattern
    int suggestedCadence;
    if (daysSince <= 3) {
      suggestedCadence = 3; // Frequent weighers
    } else if (daysSince <= 7) {
      suggestedCadence = 7; // Regular weighers
    } else {
      suggestedCadence = 14; // Less frequent weighers
    }
    
    final int remaining = suggestedCadence - daysSince;
    if (mounted) {
      setState(() {
        _isWeighInDueToday = remaining >= 0; // Due today or overdue
      });
    }
  }

  // Method to refresh weigh-in status (can be called when user logs new weight)
  void refreshWeighInStatus() {
    _checkWeighInDue();
  }

  void _updateScreens() {
    _screens.clear();
    _screens.addAll([
      DashboardScreen(
        themeProvider: widget.themeProvider,
        selectedImage: _selectedImage,
        isAnalyzing: _isAnalyzing,
        hasScanError: _hasScanError,
        isLoadingInitialData: _isLoadingInitialData,
        scanResult: _scanResult,
        todayTotals: _todayTotals,
        todayCreatedAt: _todayCreatedAt,
        todayEntries: _todayEntries,
        todayMeals: _todayMeals,
        todayExercises: _todayExercises,
        dailyProgress: _dailyProgress,
        dailySummary: _dailySummary,
        onRetryScan: _retryScan,
        onCloseError: _closeErrorCard,
      ),
      LogScreen(themeProvider: widget.themeProvider),
      ProgressScreen(
        themeProvider: widget.themeProvider, 
        healthProvider: healthProvider,
        onWeightLogged: refreshWeighInStatus,
      ), // Analytics
      SettingsPage(
        themeProvider: widget.themeProvider,
      ), // Settings
    ]);
  }

  void _showAddOptions() {
    setState(() {
      _showAddModal = true;
    });
  }

  void _hideAddOptions() {
    setState(() {
      _showAddModal = false;
    });
  }

  void _navigateToScan() {
    _hideAddOptions();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const ScanPage(),
      ),
    );
  }

  void _retryScan() {
    if (_selectedImage != null) {
      setState(() {
        _hasScanError = false;
        _isAnalyzing = true;
      });
      _updateScreens();
      _analyzeImage(_selectedImage!.path);
    }
  }

  void _closeErrorCard() {
    setState(() {
      _hasScanError = false;
      _selectedImage = null;
      _scanResult = null;
    });
    _updateScreens();
  }

  Future<void> _loadInitialData() async {
    try {
      final now = DateTime.now();
      final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final userId = AppConstants.userId;
      
      // Get the singleton ProgressService instance
      final progressService = Get.find<ProgressService>();
      
      // Initialize StreakService
      final streakService = Get.put(StreakService());
      
      // Run all API calls in parallel for faster loading
      final results = await Future.wait([
        MealsService().fetchDailyMeals(userId: userId, dateYYYYMMDD: dateStr),
        progressService.fetchDailyProgress(dateYYYYMMDD: dateStr),
        streakService.getStreakHistory(),
      ]);
      
      final mealsData = results[0];
      final progressData = results[1];
      // results[2] is streak history - no need to process as it's handled by StreakService
      
      // Process meals data
      if (mealsData != null && mealsData['success'] == true) {
        final data = mealsData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final meals = ((data['meals'] as List?) ?? []).whereType<Map<String, dynamic>>().toList();
          final exercises = ((data['exercises'] as List?) ?? []).whereType<Map<String, dynamic>>().toList();
          final summary = data['summary'] as Map<String, dynamic>?;
          
          setState(() {
            if (meals.isNotEmpty) {
              final first = meals.first;
              _todayTotals = {
                'totalCalories': ((first['totalCalories'] ?? 0) as num).toInt(),
                'totalProtein': ((first['totalProtein'] ?? 0) as num).toInt(),
                'totalCarbs': ((first['totalCarbs'] ?? 0) as num).toInt(),
                'totalFat': ((first['totalFat'] ?? 0) as num).toInt(),
              };
              _todayCreatedAt = first['createdAt'] as String?;
              _todayEntries = ((first['entries'] as List?) ?? [])
                  .whereType<Map<String, dynamic>>()
                  .toList();
              _todayMeals = meals;
            } else {
              _todayTotals = null;
              _todayCreatedAt = null;
              _todayEntries = const [];
              _todayMeals = const [];
            }
            
            _todayExercises = exercises;
            _dailySummary = summary;
          });
        }
      }
      
      // Process progress data
      if (progressData != null) {
        setState(() {
          _dailyProgress = progressData['progress'] as Map<String, dynamic>?;
        });
      }
      
      _updateScreens();
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      setState(() {
        _isLoadingInitialData = false;
      });
      _updateScreens();
    }
  }

  void _navigateToGallery() async {
    _hideAddOptions();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isAnalyzing = true;
        });
        _updateScreens();
        // Refresh today totals after logging from gallery
        _fetchTodayTotals();
        
        // Send to backend for analysis
        await _analyzeImage(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _analyzeImage(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Data = base64Encode(bytes);
      final payload = {
        'imageData': 'data:image/jpeg;base64,$base64Data',
        'mealType': 'lunch',
        'userId': AppConstants.userId,
      };
      
      await multiPostAPINew(
        methodName: 'api/scanning/scan-image',
        param: payload,
        callback: (resp) async {
          Map<String, dynamic> result;
          try {
            result = jsonDecode(resp.response) as Map<String, dynamic>;

            debugPrint('Scan result: $result');
          } catch (_) {
            result = {'message': resp.response, 'status': resp.code};
          }
          
          if (!mounted) return;
          
          // Wait for percentage animation to complete (3 seconds)
          await Future.delayed(const Duration(seconds: 3));
          
            // Stop analyzing animation and store result
            setState(() {
              _isAnalyzing = false;
              _scanResult = result; // Store the scan result
              // Check if scan failed
              _hasScanError = result['scanResult'] == null;
            });
            _updateScreens();
            // Refresh today totals after scanning
            _fetchTodayTotals();
          
          // Navigate to meal details screen with scan result data
          debugPrint('Message: ${result['message']}');
          debugPrint('Scan result data: ${result['scanResult']}');
          
          if (result['scanResult'] != null) {
            final scanData = result['scanResult'] as Map<String, dynamic>;
            final items = (scanData['items'] as List?) ?? [];
            debugPrint('Scan data: $scanData');
            debugPrint('Items count: ${items.length}');
            
            // Calculate total macros from items
            int totalProtein = 0;
            int totalCarbs = 0;
            int totalFat = 0;
            
            for (var item in items) {
              final macros = item['macros'] as Map<String, dynamic>? ?? {};
              totalProtein += ((macros['protein'] ?? 0) as num).toInt();
              totalCarbs += ((macros['carbs'] ?? 0) as num).toInt();
              totalFat += ((macros['fat'] ?? 0) as num).toInt();
            }
            
            // Create meal data structure from scan result
            final mealData = {
              'id': null, // New meal, no ID yet
              'userId': AppConstants.userId,
              'date': DateTime.now().toIso8601String(),
              'mealType': 'lunch',
              'mealName': scanData['mealName'] ?? 'Scanned Meal',
              'mealImage': imagePath, // Use local file path for base64 encoding
              'totalCalories': scanData['totalCalories'] ?? 0,
              'totalProtein': totalProtein,
              'totalCarbs': totalCarbs,
              'totalFat': totalFat,
              'isScanned': true,
              'entries': items.map((item) => {
                'userId': AppConstants.userId,
                'mealType': 'lunch',
                'foodName': item['name'] ?? 'Unknown Food',
                'quantity': 1,
                'unit': 'g',
                'calories': item['calories'] ?? 0,
                'protein': item['macros']?['protein'] ?? 0,
                'carbs': item['macros']?['carbs'] ?? 0,
                'fat': item['macros']?['fat'] ?? 0,
                'fiber': item['macros']?['fiber'] ?? 0,
                'sugar': item['macros']?['sugar'] ?? 0,
                'sodium': item['macros']?['sodium'] ?? 0,
                'servingSize': 1,
                'servingUnit': 'serving',
                'imageUrl': imagePath, // Use local file path for base64 encoding
                'notes': 'AI detected: ${item['name'] ?? 'Unknown'}',
              }).toList(),
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            };
            
            debugPrint('Created meal data: $mealData');
            debugPrint('Navigating to MealDetailsScreen');
            
            final savedMeal = await Navigator.of(context).push<Map<String, dynamic>>(
              CupertinoPageRoute(
                builder: (_) => MealDetailsScreen(
                  mealData: mealData,
                ),
              ),
            );
            
            // If meal was saved, add it optimistically to the dashboard
            if (savedMeal != null) {
              setState(() {
                _todayMeals = [..._todayMeals, savedMeal];
              });
              // Refresh today totals to get updated data
              _fetchTodayTotals();
            }
          } else {
            debugPrint('Scan failed or no scan result, taking fallback path');
            debugPrint('Result message: ${result['message']}');
            debugPrint('Scan result: ${result['scanResult']}');
            // Fallback to scan result page if scan failed
            // Navigator.of(context).push(
            //   CupertinoPageRoute(
            //     builder: (_) => ScanResultPage(
            //       result: result,
            //       imagePath: imagePath,
            //       rawResponse: resp.response,
            //       statusCode: resp.code,
            //       requestInfo: reqInfo,
            //     ),
            //   ),
            // );
          }
        },
      );
    } catch (e) {
      debugPrint('Analysis error: $e');
      setState(() {
        _isAnalyzing = false;
      });
      _updateScreens();
    }
  }

  Future<void> _fetchTodayTotals() async {
    // Skip if already loading initial data to avoid duplicate calls
    if (_isLoadingInitialData) return;
    
    try {
      final now = DateTime.now();
      final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final userId = AppConstants.userId;
      final service = MealsService();
      
      // Use the new combined daily endpoint
      final decoded = await service.fetchDailyMeals(userId: userId, dateYYYYMMDD: dateStr);
      if (decoded != null && decoded['success'] == true) {
        debugPrint('GET daily data response: $decoded');
        final data = decoded['data'] as Map<String, dynamic>?;
        
        if (data != null) {
          final meals = ((data['meals'] as List?) ?? []).whereType<Map<String, dynamic>>().toList();
          final exercises = ((data['exercises'] as List?) ?? []).whereType<Map<String, dynamic>>().toList();
          final summary = data['summary'] as Map<String, dynamic>?;
          
          setState(() {
            if (meals.isNotEmpty) {
              final first = meals.first;
              _todayTotals = {
                'totalCalories': ((first['totalCalories'] ?? 0) as num).toInt(),
                'totalProtein': ((first['totalProtein'] ?? 0) as num).toInt(),
                'totalCarbs': ((first['totalCarbs'] ?? 0) as num).toInt(),
                'totalFat': ((first['totalFat'] ?? 0) as num).toInt(),
              };
              _todayCreatedAt = first['createdAt'] as String?;
              _todayEntries = ((first['entries'] as List?) ?? [])
                  .whereType<Map<String, dynamic>>()
                  .toList();
              _todayMeals = meals;
            } else {
              _todayTotals = null;
              _todayCreatedAt = null;
              _todayEntries = const [];
              _todayMeals = const [];
            }
            
            _todayExercises = exercises;
            _dailySummary = summary;
          });
          _updateScreens();
        } else {
          setState(() {
            _todayTotals = null;
            _todayCreatedAt = null;
            _todayEntries = const [];
            _todayMeals = const [];
            _todayExercises = const [];
            _dailySummary = null;
          });
          _updateScreens();
        }
      }
    } catch (e) {
      debugPrint('Error fetching daily data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
        return Stack(
          children: [
            CupertinoTabScaffold(
          backgroundColor: ThemeHelper.background,
          tabBar: CupertinoTabBar(
            height: 60,
            backgroundColor: ThemeHelper.cardBackground.withOpacity(0.95),
            activeColor: ThemeHelper.textPrimary,
            inactiveColor: ThemeHelper.textSecondary,
            border: Border(
              top: BorderSide(
                color: ThemeHelper.divider,
                width: 0.5,
              ),
            ),
            items: [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: l10n.home,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.pencil),
                label: l10n.log,
              ),
              BottomNavigationBarItem(
                icon: _isWeighInDueToday 
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(CupertinoIcons.chart_bar),
                        Positioned(
                          right: -10,
                          top: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Icon(CupertinoIcons.chart_bar),
                label: l10n.analytics,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                label: l10n.settings,
              ),
            ],
          ),
          tabBuilder: (context, index) {
            return Stack(
              children: [
                _screens[index],
                // Floating Action Button
                if (index == 0) // Only show on Home tab
                  Positioned(
                    right: 20,
                    bottom: 100, // Above the tab bar
                    child: GestureDetector(
                      onTap: _showAddOptions,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: ThemeHelper.textPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ThemeHelper.textPrimary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          CupertinoIcons.add,
                          color: ThemeHelper.background,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
            ),
            // Add Options Modal
            if (_showAddModal) _buildAddOptionsModal(),
          ],
        );
      },
    );
  }

  Widget _buildAddOptionsModal() {
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: _hideAddOptions,
      child: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: CupertinoColors.black.withOpacity(0.6),
              ),
            ),
          ),
          // Modal content
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // Prevent tap from bubbling up
              child: Container(
                margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                // 2x2 Grid of options
                Row(
                  children: [
                    // Top Left - Database
                    // Expanded(
                    //   child: _buildOptionCard(
                    //     imageAsset: "assets/icons/bookmark.png",
                    //     title: l10n.database,
                    //     onTap: _navigateToDatabase,
                    //   ),
                    // ),
                    
                    // Top Right - Gallery
                    Expanded(
                      child: _buildOptionCard(
                        imageAsset: "assets/icons/gallery.png",
                        title: l10n.gallery,
                        onTap: _navigateToGallery,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildOptionCard(
                        imageAsset: "assets/icons/camera.png",
                        title: l10n.scanFood,
                        onTap: _navigateToScan,
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 12),
                // Row(
                //   children: [
                //     // Bottom Left - Health
                //     Expanded(
                //       child: _buildOptionCard(
                //         imageAsset: "assets/icons/workout.png",
                //         title: l10n.workout,
                //         onTap: _navigateToHealth,
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     // Bottom Right - Scan Food
                //     Expanded(
                //       child: _buildOptionCard(
                //         imageAsset: "assets/icons/camera.png",
                //         title: l10n.scanFood,
                //         onTap: _navigateToScan,
                //       ),
                //     ),
                //   ],
                // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String imageAsset,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: ThemeHelper.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.textPrimary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imageAsset,
                width: 24,
                height: 24,
              ),
              if (title.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeHelper.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

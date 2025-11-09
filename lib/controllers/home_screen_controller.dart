import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../network/http_helper.dart';
import '../services/meals_service.dart';
import '../services/progress_service.dart';
import '../services/streak_service.dart';
import '../utils/user.prefs.dart' show UserPrefs;
import '../authentication/user.controller.dart' show UserController;
import '../providers/health_provider.dart' show HealthProvider;
import '../screens/meal_details_screen.dart' show MealDetailsScreen;



class HomeScreenController extends GetxController {
  final HealthProvider healthProvider = HealthProvider();
  final ImagePicker _picker = ImagePicker();
  


  // Observable state
  final currentIndex = 0.obs;
  final showAddModal = false.obs;
  final selectedImage = Rxn<File>();
  final isAnalyzing = false.obs;
  final hasScanError = false.obs;
  final isLoadingInitialData = false.obs;
  final hasLoadedInitialData = false.obs;
  final lastLoadedDate = Rxn<String>();
  final scanResult = Rxn<Map<String, dynamic>>();
  final todayTotals = Rxn<Map<String, int>>();
  final todayCreatedAt = Rxn<String>();
  final todayEntries = <Map<String, dynamic>>[].obs;
  final todayMeals = <Map<String, dynamic>>[].obs;
  final todayExercises = <Map<String, dynamic>>[].obs;
  final dailyProgress = Rxn<Map<String, dynamic>>();
  final dailySummary = Rxn<Map<String, dynamic>>();
  final isWeighInDueToday = false.obs;
  final pendingMealData = Rxn<Map<String, dynamic>>();
  
  // Services
  final ProgressService progressService = Get.put(ProgressService());
  StreakService? streakService;
  
  ImagePicker get picker => _picker;
  
  @override
  void onInit() {
    super.onInit();
    streakService = Get.put(StreakService());
    loadInitialData();
    checkWeighInDue();
  }
  
  Future<void> checkWeighInDue() async {
    final DateTime? lastWeighIn = await UserPrefs.getLastWeighInDate();
    if (lastWeighIn == null) {
      isWeighInDueToday.value = true;
      return;
    }
    
    final DateTime now = DateTime.now();
    final int daysSince = now.difference(lastWeighIn).inDays;
    
    int suggestedCadence;
    if (daysSince <= 3) {
      suggestedCadence = 3;
    } else if (daysSince <= 7) {
      suggestedCadence = 7;
    } else {
      suggestedCadence = 14;
    }
    
    final int remaining = suggestedCadence - daysSince;
    isWeighInDueToday.value = remaining <= 0;
  }
  
  void refreshWeighInStatus() {
    checkWeighInDue();
  }
  
  void showAddOptions() {
    showAddModal.value = true;
  }
  
  void hideAddOptions() {
    showAddModal.value = false;
  }
  
  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }
  
  void setSelectedImage(File? image) {
    selectedImage.value = image;
  }
  
  void setIsAnalyzing(bool value) {
    isAnalyzing.value = value;
  }
  
  void setHasScanError(bool value) {
    hasScanError.value = value;
  }
  
  void setScanResult(Map<String, dynamic>? result) {
    scanResult.value = result;
  }
  
  Future<void> loadInitialData() async {
    final now = DateTime.now().toLocal();
    final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // Only load if date changed or hasn't loaded yet
    if (hasLoadedInitialData.value && lastLoadedDate.value == dateStr && !isLoadingInitialData.value) return;
    if (isLoadingInitialData.value) return;
    
    isLoadingInitialData.value = true;
    
    try {
      final userId = AppConstants.userId;
      
      // Get steps from Apple Health if includeStepCaloriesInGoal is true
      int? steps;
      try {
        final userController = Get.find<UserController>();
        final includeStepCalories = userController.userData['includeStepCaloriesInGoal'] ?? false;
        if (includeStepCalories && healthProvider.hasPermissions) {
          steps = healthProvider.stepsToday;
        }
      } catch (_) {
        // Silently handle if UserController not available
      }
      
      // Run all API calls in parallel for faster loading
      final results = await Future.wait([
        MealsService().fetchDailyMeals(userId: userId, dateYYYYMMDD: dateStr, steps: steps),
        progressService.fetchDailyProgress(dateYYYYMMDD: dateStr, steps: steps),
        streakService!.getStreakHistory(),
      ]);
      
      final mealsData = results[0];
      final progressData = results[1];
      
      // Process meals data
      if (mealsData != null && mealsData['success'] == true) {
        final data = mealsData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final meals = ((data['meals'] as List?) ?? []).whereType<Map<String, dynamic>>().toList();
          final exercises = ((data['exercises'] as List?) ?? []).whereType<Map<String, dynamic>>().toList();
          final summary = data['summary'] as Map<String, dynamic>?;
          
          if (meals.isNotEmpty) {
            final first = meals.first;
            todayTotals.value = {
              'totalCalories': ((first['totalCalories'] ?? 0) as num).toInt(),
              'totalProtein': ((first['totalProtein'] ?? 0) as num).toInt(),
              'totalCarbs': ((first['totalCarbs'] ?? 0) as num).toInt(),
              'totalFat': ((first['totalFat'] ?? 0) as num).toInt(),
            };
            todayCreatedAt.value = first['createdAt'] as String?;
            todayEntries.value = ((first['entries'] as List?) ?? [])
                .whereType<Map<String, dynamic>>()
                .toList();
            todayMeals.value = meals;
          } else {
            todayTotals.value = null;
            todayCreatedAt.value = null;
            todayEntries.value = [];
            todayMeals.value = [];
          }
          
          todayExercises.value = exercises;
          dailySummary.value = summary;
        }
      }
      
      // Process progress data
      if (progressData != null) {
        dailyProgress.value = progressData['progress'] as Map<String, dynamic>?;
      }
      
      hasLoadedInitialData.value = true;
      lastLoadedDate.value = dateStr;
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      isLoadingInitialData.value = false;
    }
  }
  
  Future<void> fetchTodayTotals() async {
    // Skip if already loading initial data to avoid duplicate calls
    if (isLoadingInitialData.value) return;
    
    try {
      final now = DateTime.now();
      final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final userId = AppConstants.userId;
      final service = MealsService();
      
      // Get steps from Apple Health if includeStepCaloriesInGoal is true
      int? steps;
      try {
        final userController = Get.find<UserController>();
        final includeStepCalories = userController.userData['includeStepCaloriesInGoal'] ?? false;
        if (includeStepCalories && healthProvider.hasPermissions) {
          steps = healthProvider.stepsToday;
        }
      } catch (_) {
        // Silently handle if UserController not available
      }
      
      // Use the new combined daily endpoint
      final decoded = await service.fetchDailyMeals(userId: userId, dateYYYYMMDD: dateStr, steps: steps);
      if (decoded != null && decoded['success'] == true) {
        debugPrint('GET daily data response: $decoded');
        final data = decoded['data'] as Map<String, dynamic>?;
        
        if (data != null) {
          final meals = ((data['meals'] as List?) ?? []).whereType<Map<String, dynamic>>().toList();
          final exercises = ((data['exercises'] as List?) ?? []).whereType<Map<String, dynamic>>().toList();
          final summary = data['summary'] as Map<String, dynamic>?;
          
          if (meals.isNotEmpty) {
            final first = meals.first;
            todayTotals.value = {
              'totalCalories': ((first['totalCalories'] ?? 0) as num).toInt(),
              'totalProtein': ((first['totalProtein'] ?? 0) as num).toInt(),
              'totalCarbs': ((first['totalCarbs'] ?? 0) as num).toInt(),
              'totalFat': ((first['totalFat'] ?? 0) as num).toInt(),
            };
            todayCreatedAt.value = first['createdAt'] as String?;
            todayEntries.value = ((first['entries'] as List?) ?? [])
                .whereType<Map<String, dynamic>>()
                .toList();
            todayMeals.value = meals;
          } else {
            todayTotals.value = null;
            todayCreatedAt.value = null;
            todayEntries.value = [];
            todayMeals.value = [];
          }
          
          todayExercises.value = exercises;
          dailySummary.value = summary;
        } else {
          todayTotals.value = null;
          todayCreatedAt.value = null;
          todayEntries.value = [];
          todayMeals.value = [];
          todayExercises.value = [];
          dailySummary.value = null;
        }
      }
    } catch (e) {
      debugPrint('Error fetching daily data: $e');
    }
  }
  
  void retryScan(BuildContext? context) {
    if (selectedImage.value != null) {
      hasScanError.value = false;
      isAnalyzing.value = true;
      analyzeImage(selectedImage.value!.path, context);
    }
  }
  
  void closeErrorCard() {
    hasScanError.value = false;
    selectedImage.value = null;
    scanResult.value = null;
  }
  
  Future<void> analyzeImage(String imagePath, BuildContext? context) async {
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
          
          // Wait for percentage animation to complete (3 seconds)
          await Future.delayed(const Duration(seconds: 3));
          
          // Stop analyzing animation and store result
          isAnalyzing.value = false;
          scanResult.value = result;
          hasScanError.value = result['scanResult'] == null;
          
          // Refresh today totals after scanning
          fetchTodayTotals();
          
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
              'id': null,
              'userId': AppConstants.userId,
              'date': DateTime.now().toIso8601String(),
              'mealType': 'lunch',
              'mealName': scanData['mealName'] ?? 'Scanned Meal',
              'mealImage': imagePath,
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
                'imageUrl': imagePath,
                'notes': 'AI detected: ${item['name'] ?? 'Unknown'}',
              }).toList(),
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            };
            
            debugPrint('Created meal data: $mealData');
            debugPrint('Navigating to MealDetailsScreen');
            
            // Clear selected image before navigating
            selectedImage.value = null;
            
            // Navigate if context is available
            if (context != null && context.mounted) {
              final savedMeal = await Navigator.of(context).push<Map<String, dynamic>>(
                CupertinoPageRoute(
                  builder: (_) => MealDetailsScreen(
                    mealData: mealData,
                  ),
                ),
              );
              
              // If meal was saved, add it optimistically
              if (savedMeal != null) {
                addMealOptimistically(savedMeal);
              } else {
                // User backed out without saving: revert scan state
                revertScanState();
              }
            }
          } else {
            debugPrint('Scan failed or no scan result');
            debugPrint('Result message: ${result['message']}');
            debugPrint('Scan result: ${result['scanResult']}');
          }
        },
      );
    } catch (e) {
      debugPrint('Analysis error: $e');
      isAnalyzing.value = false;
    }
  }
  
  void addMealOptimistically(Map<String, dynamic> savedMeal) {
    todayMeals.add(savedMeal);
    
    // Optimistically update progress data immediately
    _updateProgressOptimistically(savedMeal);
    
    // Also fetch from server to ensure consistency (this will update progress too)
    fetchTodayTotals();
    
    // Refresh progress data to sync with server
    final now = DateTime.now();
    final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // Get steps from Apple Health if includeStepCaloriesInGoal is true
    int? steps;
    try {
      final userController = Get.find<UserController>();
      final includeStepCalories = userController.userData['includeStepCaloriesInGoal'] ?? false;
      if (includeStepCalories && healthProvider.hasPermissions) {
        steps = healthProvider.stepsToday;
      }
    } catch (_) {
      // Silently handle if UserController not available
    }
    
    // Fetch progress data to sync with server (runs in background)
    progressService.fetchDailyProgress(dateYYYYMMDD: dateStr, steps: steps);
  }
  
  void _updateProgressOptimistically(Map<String, dynamic> meal) {
    try {
      final progressService = Get.find<ProgressService>();
      final currentProgress = progressService.dailyProgressData;
      
      if (currentProgress == null) {
        // If no progress data exists, fetch it first
        final now = DateTime.now();
        final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        progressService.fetchDailyProgress(dateYYYYMMDD: dateStr);
        return;
      }
      
      // Extract meal values (handle both int and double)
      final mealCalories = ((meal['totalCalories'] ?? 0) as num).toInt();
      final mealProtein = ((meal['totalProtein'] ?? 0) as num).toInt();
      final mealCarbs = ((meal['totalCarbs'] ?? 0) as num).toInt();
      final mealFat = ((meal['totalFat'] ?? 0) as num).toInt();
      
      // Clone the current progress data
      final updatedProgress = Map<String, dynamic>.from(currentProgress);
      
      if (updatedProgress['progress'] != null) {
        final progress = Map<String, dynamic>.from(updatedProgress['progress'] as Map<String, dynamic>);
        
        // Update calories
        if (progress['calories'] != null) {
          final calories = Map<String, dynamic>.from(progress['calories'] as Map<String, dynamic>);
          // Handle both int and double types safely
          final currentConsumed = ((calories['consumed'] ?? 0) as num).toInt();
          final goal = ((calories['goal'] ?? 0) as num).toInt();
          
          calories['consumed'] = currentConsumed + mealCalories;
          calories['remaining'] = goal - (currentConsumed + mealCalories);
          progress['calories'] = calories;
        }
        
        // Update macros
        if (progress['macros'] != null) {
          final macros = Map<String, dynamic>.from(progress['macros'] as Map<String, dynamic>);
          
          // Update protein
          if (macros['protein'] != null) {
            final protein = Map<String, dynamic>.from(macros['protein'] as Map<String, dynamic>);
            final currentConsumed = ((protein['consumed'] ?? 0) as num).toInt();
            protein['consumed'] = currentConsumed + mealProtein;
            macros['protein'] = protein;
          }
          
          // Update carbs
          if (macros['carbs'] != null) {
            final carbs = Map<String, dynamic>.from(macros['carbs'] as Map<String, dynamic>);
            final currentConsumed = ((carbs['consumed'] ?? 0) as num).toInt();
            carbs['consumed'] = currentConsumed + mealCarbs;
            macros['carbs'] = carbs;
          }
          
          // Update fat
          if (macros['fat'] != null) {
            final fat = Map<String, dynamic>.from(macros['fat'] as Map<String, dynamic>);
            final currentConsumed = ((fat['consumed'] ?? 0) as num).toInt();
            fat['consumed'] = currentConsumed + mealFat;
            macros['fat'] = fat;
          }
          
          progress['macros'] = macros;
        }
        
        updatedProgress['progress'] = progress;
      }
      
      // Update the progress service with optimistic data
      progressService.updateProgressData(updatedProgress);
    } catch (e) {
      debugPrint('Error updating progress optimistically: $e');
    }
  }
  
  void revertScanState() {
    selectedImage.value = null;
    scanResult.value = null;
    hasScanError.value = false;
    isAnalyzing.value = false;
  }
}


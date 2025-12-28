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
import '../camera/scan_page.dart' show ScanPage;
import '../l10n/app_localizations.dart' show AppLocalizations;



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
  final isLoadingMeals = false.obs;
  final isLoadingProgress = false.obs;
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
  
  // Services - will be initialized in onInit to avoid issues
  late final ProgressService progressService;
  StreakService? streakService;
  
  ImagePicker get picker => _picker;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize ProgressService
    if (!Get.isRegistered<ProgressService>()) {
      progressService = Get.put(ProgressService(), permanent: true);
    } else {
      progressService = Get.find<ProgressService>();
    }
    
    // Register StreakService only if not already registered
    if (!Get.isRegistered<StreakService>()) {
      streakService = Get.put(StreakService(), permanent: true);
    } else {
      streakService = Get.find<StreakService>();
    }
    
    // Delay initialization to ensure app is fully ready and user is authenticated
    // This prevents race conditions and UI freezing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        if (AppConstants.userId.isNotEmpty && AppConstants.authToken.isNotEmpty) {
          loadInitialData();
          checkWeighInDue();
        } else {
          debugPrint('⚠️ HomeScreenController: Skipping data load - user not authenticated');
        }
      });
    });
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
    // Guard: Don't load if user is not authenticated
    if (AppConstants.userId.isEmpty || AppConstants.authToken.isEmpty) {
      debugPrint('⚠️ HomeScreenController: Cannot load data - user not authenticated');
      isLoadingInitialData.value = false;
      isLoadingMeals.value = false;
      isLoadingProgress.value = false;
      return;
    }
    
    final now = DateTime.now().toLocal();
    final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // Only load if date changed or hasn't loaded yet
    if (hasLoadedInitialData.value && lastLoadedDate.value == dateStr && !isLoadingInitialData.value) return;
    if (isLoadingInitialData.value) return;
    
    isLoadingInitialData.value = true;
    isLoadingMeals.value = true;
    isLoadingProgress.value = true;
    
    try {
      final userId = AppConstants.userId;
      
      // Get steps from Apple Health if includeStepCaloriesInGoal is true
      int? steps;
      try {
        if (Get.isRegistered<UserController>()) {
          final userController = Get.find<UserController>();
          final includeStepCalories = userController.userData['includeStepCaloriesInGoal'] ?? false;
          if (includeStepCalories && healthProvider.hasPermissions) {
            steps = healthProvider.stepsToday;
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error getting steps from UserController: $e');
      }
      
      // Start streak history in background (doesn't block UI)
      if (streakService != null) {
        streakService!.getStreakHistory().catchError((e) {
          debugPrint('Error loading streak history: $e');
          return null;
        });
      }
      
      // Process meals data as soon as it's available
      MealsService().fetchDailyMeals(userId: userId, dateYYYYMMDD: dateStr, steps: steps)
        .then((mealsData) {
          isLoadingMeals.value = false;
          
          // Process meals data immediately when available
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
          
          // Check if both are done
          _checkIfInitialDataLoaded();
        })
        .catchError((e) {
          isLoadingMeals.value = false;
          debugPrint('Error loading meals data: $e');
          _checkIfInitialDataLoaded();
        });
      
      // Process progress data as soon as it's available
      progressService.fetchDailyProgress(dateYYYYMMDD: dateStr, steps: steps)
        .then((progressData) {
          isLoadingProgress.value = false;
          
          // Process progress data immediately when available
          if (progressData != null) {
            dailyProgress.value = progressData['progress'] as Map<String, dynamic>?;
          }
          
          // Check if both are done
          _checkIfInitialDataLoaded();
        })
        .catchError((e) {
          isLoadingProgress.value = false;
          debugPrint('Error loading progress data: $e');
          _checkIfInitialDataLoaded();
        });
      
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      isLoadingMeals.value = false;
      isLoadingProgress.value = false;
      isLoadingInitialData.value = false;
    }
  }
  
  void _checkIfInitialDataLoaded() {
    // Only mark as fully loaded when both API calls are complete
    if (!isLoadingMeals.value && !isLoadingProgress.value) {
      final now = DateTime.now().toLocal();
      final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      hasLoadedInitialData.value = true;
      lastLoadedDate.value = dateStr;
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
            
            // Preserve optimistic meals (meals without IDs) when merging with server data
            final optimisticMeals = todayMeals.where((m) {
              final mId = m['id'] ?? m['_id'];
              return mId == null;
            }).toList();
            
            // Merge server meals with optimistic meals
            final mergedMeals = <Map<String, dynamic>>[];
            mergedMeals.addAll(meals);
            mergedMeals.addAll(optimisticMeals);
            
            todayMeals.value = mergedMeals;
          } else {
            // Even if server returns no meals, preserve optimistic meals
            final optimisticMeals = todayMeals.where((m) {
              final mId = m['id'] ?? m['_id'];
              return mId == null;
            }).toList();
            
            if (optimisticMeals.isEmpty) {
              todayTotals.value = null;
              todayCreatedAt.value = null;
              todayEntries.value = [];
              todayMeals.value = [];
            } else {
              // Keep optimistic meals even if server has no meals
              todayMeals.value = optimisticMeals;
            }
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
  
  Future<void> retryScan(BuildContext? context) async {
    if (context == null) return;
    
    // Close error card first
    hasScanError.value = false;
    
    // Get localized strings
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    
    // Show picker dialog (camera/gallery)
    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('Select Image Source'), // TODO: Use l10n.selectImageSource after regenerating localization
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Navigate to camera
              final result = await Navigator.of(context).push<Map<String, dynamic>>(
                CupertinoPageRoute(
                  builder: (context) => const ScanPage(),
                ),
              );
              
              if (result != null && result['imagePath'] != null) {
                final imagePath = result['imagePath'] as String;
                setSelectedImage(File(imagePath));
                setIsAnalyzing(true);
                fetchTodayTotals();
                await analyzeImage(imagePath, context);
              }
            },
            child: Text(l10n.camera),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Pick from gallery
              try {
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1920,
                  maxHeight: 1080,
                  imageQuality: 85,
                );
                
                if (image != null) {
                  setSelectedImage(File(image.path));
                  setIsAnalyzing(true);
                  fetchTodayTotals();
                  await analyzeImage(image.path, context);
                }
              } catch (e) {
                debugPrint('Error picking image: $e');
              }
            },
            child: Text(l10n.gallery),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.cancel),
        ),
      ),
    );
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
          
          // Don't call fetchTodayTotals() here - we'll add the meal directly from scan data
          // This avoids waiting for API call when we already have all the data
          
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
              'isBookmarked': false, // Default to false, user can bookmark in MealDetailsScreen
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
            
            // Optimistically add meal to dashboard immediately from scan result
            // Use local data directly without waiting for API call
            _addMealDirectly(Map<String, dynamic>.from(mealData));
            
            debugPrint('Optimistically added meal to dashboard');
            
            // Clear selected image before navigating
            selectedImage.value = null;
            
            // Use microtask to ensure observable update propagates before navigation
            // This ensures the dashboard rebuilds with the new meal immediately
            await Future.microtask(() {});
            
            debugPrint('Navigating to MealDetailsScreen');
            
            // Navigate if context is available
            if (context != null && context.mounted) {
              final savedMeal = await Navigator.of(context).push<Map<String, dynamic>>(
                CupertinoPageRoute(
                  builder: (_) => MealDetailsScreen(
                    mealData: mealData,
                  ),
                ),
              );
              
              // Check if meal was deleted
              if (savedMeal != null && savedMeal['deleted'] == true) {
                removeMeal(mealData);
                // User backed out without saving: revert scan state
                revertScanState();
              } else if (savedMeal != null) {
                // Meal was saved - use addMealOptimistically which handles updates correctly
                // (it will find the existing optimistic meal and update it with delta calculation)
                addMealOptimistically(savedMeal);
              } else {
                // User backed out without saving: remove optimistic meal and revert scan state
                // Match by createdAt and mealName to find the specific optimistic meal
                final mealCreatedAt = mealData['createdAt'] as String?;
                final mealName = (mealData['mealName'] as String?)?.trim();
                
                todayMeals.removeWhere((m) {
                  final mId = m['id'] ?? m['_id'];
                  if (mId != null) return false; // Skip meals that have IDs
                  
                  final mCreatedAt = m['createdAt'] as String?;
                  final mName = (m['mealName'] as String?)?.trim();
                  return mCreatedAt == mealCreatedAt && mName == mealName;
                });
                
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
  
  // Add meal directly using local data without API call (for scan results)
  void _addMealDirectly(Map<String, dynamic> meal) {
    // Insert at the beginning (most recent first) for immediate visibility
    todayMeals.insert(0, meal);
    
    // Explicitly refresh the observable to trigger immediate UI update
    todayMeals.refresh();
    
    // Optimistically update progress data immediately
    _updateProgressOptimistically(meal);
    
    // Don't call fetchTodayTotals() - we already have all the data locally
    debugPrint('✅ Added meal directly to dashboard: ${meal['mealName']}');
  }

  void addMealOptimistically(Map<String, dynamic> savedMeal) {
    // Check if meal already exists to avoid duplicates
    final savedMealId = savedMeal['id'] ?? savedMeal['_id'];
    final mealCreatedAt = savedMeal['createdAt'] as String?;
    final mealName = (savedMeal['mealName'] as String?)?.trim();
    
    // Check if meal already exists (by ID or by createdAt + mealName for optimistic meals)
    final exists = todayMeals.any((m) {
      final mId = m['id'] ?? m['_id'];
      if (savedMealId != null && mId != null && mId.toString() == savedMealId.toString()) {
        return true; // Same ID
      }
      // For meals without IDs, match by createdAt and mealName
      if (savedMealId == null && mId == null && mealCreatedAt != null && mealName != null) {
        final mCreatedAt = m['createdAt'] as String?;
        final mName = (m['mealName'] as String?)?.trim();
        return mCreatedAt == mealCreatedAt && mName == mealName;
      }
      return false;
    });
    
    if (!exists) {
      todayMeals.add(savedMeal);
      
      // Optimistically update progress data immediately (only if meal is new)
      _updateProgressOptimistically(savedMeal);
    } else {
      // Meal already exists - just update it without double-counting progress
      final index = todayMeals.indexWhere((m) {
        final mId = m['id'] ?? m['_id'];
        if (savedMealId != null && mId != null && mId.toString() == savedMealId.toString()) {
          return true;
        }
        if (savedMealId == null && mId == null && mealCreatedAt != null && mealName != null) {
          final mCreatedAt = m['createdAt'] as String?;
          final mName = (m['mealName'] as String?)?.trim();
          return mCreatedAt == mealCreatedAt && mName == mealName;
        }
        return false;
      });
      
      if (index >= 0) {
        // Get old meal values to subtract before adding new ones
        final oldMeal = todayMeals[index];
        final oldCalories = ((oldMeal['totalCalories'] ?? 0) as num).toInt();
        final oldProtein = ((oldMeal['totalProtein'] ?? 0) as num).toInt();
        final oldCarbs = ((oldMeal['totalCarbs'] ?? 0) as num).toInt();
        final oldFat = ((oldMeal['totalFat'] ?? 0) as num).toInt();
        
        // Get new meal values
        final newCalories = ((savedMeal['totalCalories'] ?? 0) as num).toInt();
        final newProtein = ((savedMeal['totalProtein'] ?? 0) as num).toInt();
        final newCarbs = ((savedMeal['totalCarbs'] ?? 0) as num).toInt();
        final newFat = ((savedMeal['totalFat'] ?? 0) as num).toInt();
        
        // Calculate delta (difference)
        final deltaCalories = newCalories - oldCalories;
        final deltaProtein = newProtein - oldProtein;
        final deltaCarbs = newCarbs - oldCarbs;
        final deltaFat = newFat - oldFat;
        
        // Update the meal in the list
        todayMeals[index] = Map<String, dynamic>.from(savedMeal);
        
        // Update progress with delta only (not full values)
        if (deltaCalories != 0 || deltaProtein != 0 || deltaCarbs != 0 || deltaFat != 0) {
          _updateProgressWithDelta(deltaCalories, deltaProtein, deltaCarbs, deltaFat);
        }
      }
    }
    
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

  void removeMeal(Map<String, dynamic> mealToRemove) {
    // Extract meal values BEFORE removing (so we can subtract from progress)
    final mealCalories = ((mealToRemove['totalCalories'] ?? 0) as num).toInt();
    final mealProtein = ((mealToRemove['totalProtein'] ?? 0) as num).toInt();
    final mealCarbs = ((mealToRemove['totalCarbs'] ?? 0) as num).toInt();
    final mealFat = ((mealToRemove['totalFat'] ?? 0) as num).toInt();
    
    // Optimistically subtract meal values from progress immediately
    _updateProgressWithDelta(-mealCalories, -mealProtein, -mealCarbs, -mealFat);
    
    // Remove meal from list
    final mealId = mealToRemove['id'] ?? mealToRemove['_id'];
    if (mealId != null && mealId.toString().isNotEmpty) {
      todayMeals.removeWhere((m) {
        final mId = m['id'] ?? m['_id'];
        return mId != null && mId.toString() == mealId.toString();
      });
    } else {
      // Fallback: try to match by other criteria if ID is not available
      final mealName = (mealToRemove['mealName'] as String?)?.trim();
      final totalCalories = ((mealToRemove['totalCalories'] ?? 0) as num).toInt();
      final createdAt = mealToRemove['createdAt'] as String?;
      
      todayMeals.removeWhere((m) {
        final mName = (m['mealName'] as String?)?.trim();
        final mCalories = ((m['totalCalories'] ?? 0) as num).toInt();
        final mCreatedAt = m['createdAt'] as String?;
        
        return mName == mealName && 
               mCalories == totalCalories && 
               mCreatedAt == createdAt;
      });
    }
    
    // Refresh the observable to trigger UI update
    todayMeals.refresh();
    
    // Store the optimistic progress values before server fetch
    final progressService = Get.find<ProgressService>();
    final currentProgress = progressService.dailyProgressData;
    int? optimisticCalories;
    int? optimisticProtein;
    int? optimisticCarbs;
    int? optimisticFat;
    
    if (currentProgress != null && currentProgress['progress'] != null) {
      final progress = currentProgress['progress'] as Map<String, dynamic>;
      if (progress['calories'] != null) {
        optimisticCalories = ((progress['calories']?['consumed'] ?? 0) as num).toInt();
      }
      if (progress['macros'] != null) {
        final macros = progress['macros'] as Map<String, dynamic>;
        optimisticProtein = ((macros['protein']?['consumed'] ?? 0) as num).toInt();
        optimisticCarbs = ((macros['carbs']?['consumed'] ?? 0) as num).toInt();
        optimisticFat = ((macros['fat']?['consumed'] ?? 0) as num).toInt();
      }
    }
    
    // Delay server fetch to allow deletion API to complete first
    // This prevents stale server data from overwriting our optimistic update
    Future.delayed(const Duration(milliseconds: 2500), () {
      // Fetch from server to sync (runs in background)
      fetchTodayTotals();
      
      // Also refresh progress data to sync with server
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
      // After fetch completes, check if server data matches our optimistic update
      // If server still has old data (higher values), don't overwrite our optimistic update
      progressService.fetchDailyProgress(dateYYYYMMDD: dateStr, steps: steps).then((_) {
        // Check if server returned stale data (still has the deleted meal)
        final updatedProgress = progressService.dailyProgressData;
        if (updatedProgress != null && updatedProgress['progress'] != null && 
            optimisticCalories != null && optimisticProtein != null && 
            optimisticCarbs != null && optimisticFat != null) {
          final progress = updatedProgress['progress'] as Map<String, dynamic>;
          if (progress['calories'] != null) {
            final serverCalories = ((progress['calories']?['consumed'] ?? 0) as num).toInt();
            // If server calories are higher than our optimistic (deleted) value,
            // it means server hasn't processed deletion yet - restore optimistic value
            if (serverCalories > optimisticCalories) {
              debugPrint('⚠️ Server still has deleted meal, restoring optimistic update');
              final serverProtein = progress['macros']?['protein'] != null
                  ? ((progress['macros']?['protein']?['consumed'] ?? 0) as num).toInt()
                  : 0;
              final serverCarbs = progress['macros']?['carbs'] != null
                  ? ((progress['macros']?['carbs']?['consumed'] ?? 0) as num).toInt()
                  : 0;
              final serverFat = progress['macros']?['fat'] != null
                  ? ((progress['macros']?['fat']?['consumed'] ?? 0) as num).toInt()
                  : 0;
              
              _updateProgressWithDelta(
                optimisticCalories - serverCalories,
                optimisticProtein - serverProtein,
                optimisticCarbs - serverCarbs,
                optimisticFat - serverFat,
              );
            }
          }
        }
      });
    });
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
      
      // Update progress with these values
      _updateProgressWithDelta(mealCalories, mealProtein, mealCarbs, mealFat);
    } catch (e) {
      debugPrint('Error updating progress optimistically: $e');
    }
  }
  
  void _updateProgressWithDelta(int deltaCalories, int deltaProtein, int deltaCarbs, int deltaFat) {
    try {
      final progressService = Get.find<ProgressService>();
      final currentProgress = progressService.dailyProgressData;
      
      if (currentProgress == null) {
        return;
      }
      
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
          
          // Calculate new consumed value (clamp to 0 minimum to prevent negative values)
          final newConsumed = (currentConsumed + deltaCalories).clamp(0, double.infinity).toInt();
          calories['consumed'] = newConsumed;
          calories['remaining'] = (goal - newConsumed).clamp(0, goal);
          progress['calories'] = calories;
        }
        
        // Update macros
        if (progress['macros'] != null) {
          final macros = Map<String, dynamic>.from(progress['macros'] as Map<String, dynamic>);
          
          // Update protein
          if (macros['protein'] != null) {
            final protein = Map<String, dynamic>.from(macros['protein'] as Map<String, dynamic>);
            final currentConsumed = ((protein['consumed'] ?? 0) as num).toInt();
            // Clamp to 0 minimum to prevent negative values
            protein['consumed'] = (currentConsumed + deltaProtein).clamp(0, double.infinity).toInt();
            macros['protein'] = protein;
          }
          
          // Update carbs
          if (macros['carbs'] != null) {
            final carbs = Map<String, dynamic>.from(macros['carbs'] as Map<String, dynamic>);
            final currentConsumed = ((carbs['consumed'] ?? 0) as num).toInt();
            // Clamp to 0 minimum to prevent negative values
            carbs['consumed'] = (currentConsumed + deltaCarbs).clamp(0, double.infinity).toInt();
            macros['carbs'] = carbs;
          }
          
          // Update fat
          if (macros['fat'] != null) {
            final fat = Map<String, dynamic>.from(macros['fat'] as Map<String, dynamic>);
            final currentConsumed = ((fat['consumed'] ?? 0) as num).toInt();
            // Clamp to 0 minimum to prevent negative values
            fat['consumed'] = (currentConsumed + deltaFat).clamp(0, double.infinity).toInt();
            macros['fat'] = fat;
          }
          
          progress['macros'] = macros;
        }
        
        updatedProgress['progress'] = progress;
      }
      
      // Update the progress service with optimistic data
      progressService.updateProgressData(updatedProgress);
    } catch (e) {
      debugPrint('Error updating progress with delta: $e');
    }
  }
  
  void revertScanState() {
    selectedImage.value = null;
    scanResult.value = null;
    hasScanError.value = false;
    isAnalyzing.value = false;
  }
}


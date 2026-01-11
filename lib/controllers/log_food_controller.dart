import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../services/food_service.dart';
import '../services/meals_service.dart';
import '../controllers/home_screen_controller.dart';
import '../constants/app_constants.dart';

class LogFoodController extends GetxController {
  final String? userId;
  final String? mealType;
  final int initialTabIndex;

  LogFoodController({
    this.userId,
    this.mealType,
    this.initialTabIndex = 0,
  });

  // Controllers
  final searchController = TextEditingController();
  final mealsSearchController = TextEditingController();
  final foodsSearchController = TextEditingController();
  final scannedMealsSearchController = TextEditingController();
  final caloriesController = TextEditingController();
  final foodNameController = TextEditingController();

  // Debounce timers
  Timer? _mealsDebounceTimer;
  Timer? _foodsDebounceTimer;
  Timer? _scannedMealsDebounceTimer;

  // Flag to prevent search triggers during initialization
  bool _isInitializing = true;
  
  // Track previous search terms to avoid unnecessary refreshes
  String _previousMealsSearch = '';
  String _previousFoodsSearch = '';
  String _previousScannedMealsSearch = '';

  // Observable state
  final selectedTabIndex = 0.obs;
  final carbsValue = 10.obs;
  final proteinValue = 41.obs;
  final fatsValue = 16.obs;
  final amountValue = 1.obs;
  final isSearchingMeals = false.obs;
  final isSearchingFoods = false.obs;
  final isSearchingScannedMeals = false.obs;

  // Lists
  final directInputIngredients = <dynamic>[].obs;
  final suggestions = <Map<String, dynamic>>[].obs;
  final myMeals = <Map<String, dynamic>>[].obs;
  final myFoods = <Map<String, dynamic>>[].obs;
  final scannedMeals = <Map<String, dynamic>>[].obs;

  // Loading states
  final isLoadingSuggestions = false.obs;
  final isLoadingMyMeals = false.obs;
  final isLoadingMyFoods = false.obs;
  final isLoadingScannedMeals = false.obs;
  final isSavingDirectInput = false.obs;
  final addingToDashboardMealIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    selectedTabIndex.value = initialTabIndex;
    _isInitializing = true;
    
    // Fetch initial data first
    fetchFoodSuggestions();
    fetchMyMeals();
    fetchMyFoods();
    fetchScannedMeals();
    
    // Setup search listeners with debouncing after initial fetch
    // Use a small delay to ensure initial fetches complete before listeners are active
    Future.microtask(() {
      _isInitializing = false;
      mealsSearchController.addListener(_onMealsSearchChanged);
      foodsSearchController.addListener(_onFoodsSearchChanged);
      scannedMealsSearchController.addListener(_onScannedMealsSearchChanged);
    });
  }

  @override
  void onClose() {
    _mealsDebounceTimer?.cancel();
    _foodsDebounceTimer?.cancel();
    _scannedMealsDebounceTimer?.cancel();
    searchController.dispose();
    mealsSearchController.dispose();
    foodsSearchController.dispose();
    scannedMealsSearchController.dispose();
    caloriesController.dispose();
    foodNameController.dispose();
    super.onClose();
  }

  void _onMealsSearchChanged() {
    // Skip if still initializing
    if (_isInitializing) return;
    
    final currentSearch = mealsSearchController.text.trim();
    
    // Skip if search term hasn't actually changed
    if (currentSearch == _previousMealsSearch) return;
    
    // Cancel previous timer
    _mealsDebounceTimer?.cancel();
    
    // Create new timer
    _mealsDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      final searchTerm = mealsSearchController.text.trim();
      // Update previous search term
      _previousMealsSearch = searchTerm;
      
      if (searchTerm.isEmpty) {
        // If search is empty, fetch all meals
        fetchMyMeals();
      } else {
        // Otherwise, search meals
        searchMyMeals(searchTerm);
      }
    });
  }

  void _onFoodsSearchChanged() {
    // Skip if still initializing
    if (_isInitializing) return;
    
    final currentSearch = foodsSearchController.text.trim();
    
    // Skip if search term hasn't actually changed
    if (currentSearch == _previousFoodsSearch) return;
    
    // Cancel previous timer
    _foodsDebounceTimer?.cancel();
    
    // Create new timer
    _foodsDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      final searchTerm = foodsSearchController.text.trim();
      // Update previous search term
      _previousFoodsSearch = searchTerm;
      
      if (searchTerm.isEmpty) {
        // If search is empty, fetch all foods
        fetchMyFoods();
      } else {
        // Otherwise, search foods
        searchMyFoods(searchTerm);
      }
    });
  }

  void _onScannedMealsSearchChanged() {
    // Skip if still initializing
    if (_isInitializing) return;
    
    final currentSearch = scannedMealsSearchController.text.trim();
    
    // Skip if search term hasn't actually changed
    if (currentSearch == _previousScannedMealsSearch) return;
    
    // Cancel previous timer
    _scannedMealsDebounceTimer?.cancel();
    
    // Create new timer
    _scannedMealsDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      final searchTerm = scannedMealsSearchController.text.trim();
      // Update previous search term
      _previousScannedMealsSearch = searchTerm;
      
      if (searchTerm.isEmpty) {
        // If search is empty, fetch all scanned meals
        fetchScannedMeals();
      } else {
        // Otherwise, search scanned meals
        searchScannedMeals(searchTerm);
      }
    });
  }

  Future<void> fetchFoodSuggestions() async {
    isLoadingSuggestions.value = true;

    try {
      final service = FoodService();
      final response = await service.getFoodSuggestions();

      if (response != null && response['success'] == true) {
        final suggestionsList = response['suggestions'] as List<dynamic>?;
        if (suggestionsList != null) {
          suggestions.value = suggestionsList.map((item) {
            return {
              'name': item['name'] ?? '',
              'calories': item['calories'] ?? 0,
              'protein': item['protein'] ?? 0,
              'carbohydrates': item['carbohydrates'] ?? 0,
              'fat': item['fat'] ?? 0,
              'fiber': item['fiber'] ?? 0,
              'sugar': item['sugar'] ?? 0,
              'sodium': item['sodium'] ?? 0,
              'servingSize': item['servingSize'] ?? '1',
              'servingUnit': item['servingUnit'] ?? 'serving',
              'rationale': item['rationale'] ?? '',
              'items': item['items'] ?? [],
            };
          }).toList();
        }
      }
    } catch (e) {
      // Handle error silently
    } finally {
      isLoadingSuggestions.value = false;
    }
  }

  Future<void> fetchMyMeals() async {
    if (userId == null || userId!.isEmpty) {
      return;
    }

    isLoadingMyMeals.value = true;
    isSearchingMeals.value = false;

    try {
      final service = MealsService();
      final response = await service.fetchAllMeals(
        userId: userId!,
        page: 1,
        limit: 20,
      );

      if (response != null && response['success'] == true) {
        final mealsList = response['meals'] as List<dynamic>?;
        if (mealsList != null) {
          myMeals.value = mealsList.map((item) {
            return {
              'id': item['id'] ?? '',
              'mealName': item['mealName'] ?? '',
              'totalCalories': item['totalCalories'] ?? 0,
              'totalProtein': item['totalProtein'] ?? 0,
              'totalCarbs': item['totalCarbs'] ?? 0,
              'totalFat': item['totalFat'] ?? 0,
              'entriesCount': item['entriesCount'] ?? 0,
              'mealType': item['mealType'] ?? '',
              'date': item['date'] ?? '',
              'notes': item['notes'] ?? '',
              'entries': item['entries'] ?? [],
            };
          }).toList();
        }
      }
    } catch (e) {
      // Handle error silently
    } finally {
      isLoadingMyMeals.value = false;
    }
  }

  Future<void> searchMyMeals(String searchTerm) async {
    if (userId == null || userId!.isEmpty || searchTerm.isEmpty) {
      return;
    }

    isLoadingMyMeals.value = true;
    isSearchingMeals.value = true;

    try {
      final service = MealsService();
      final response = await service.searchMeals(
        userId: userId!,
        searchTerm: searchTerm,
        page: 1,
        limit: 20,
      );

      if (response != null && response['success'] == true) {
        final mealsList = response['meals'] as List<dynamic>?;
        if (mealsList != null) {
          myMeals.value = mealsList.map((item) {
            return {
              'id': item['id'] ?? '',
              'mealName': item['mealName'] ?? '',
              'totalCalories': item['totalCalories'] ?? 0,
              'totalProtein': item['totalProtein'] ?? 0,
              'totalCarbs': item['totalCarbs'] ?? 0,
              'totalFat': item['totalFat'] ?? 0,
              'entriesCount': item['entriesCount'] ?? 0,
              'mealType': item['mealType'] ?? '',
              'date': item['date'] ?? '',
              'notes': item['notes'] ?? '',
              'entries': item['entries'] ?? [],
            };
          }).toList();
        } else {
          myMeals.value = [];
        }
      } else {
        myMeals.value = [];
      }
    } catch (e) {
      // Handle error silently
      myMeals.value = [];
    } finally {
      isLoadingMyMeals.value = false;
    }
  }

  Future<void> fetchMyFoods() async {
    isLoadingMyFoods.value = true;
    isSearchingFoods.value = false;

    try {
      final service = FoodService();
      final response = await service.fetchAllFoods(
        page: 1,
        limit: 20,
      );

      if (response != null && response['success'] == true) {
        final foodsList = response['foods'] as List<dynamic>?;
        if (foodsList != null) {
          myFoods.value = foodsList.map((item) {
            return {
              '_id': item['_id'] ?? '',
              'name': item['name'] ?? '',
              'calories': item['calories'] ?? 0,
              'description': item['description'] ?? '',
              'servingSize': item['servingSize'] ?? '',
              'servingPerContainer': item['servingPerContainer'] ?? '',
              'protein': item['protein'] ?? 0,
              'carbohydrates': item['carbohydrates'] ?? 0,
              'totalFat': item['totalFat'] ?? 0,
              'createdBy': item['createdBy'] ?? '',
              'createdAt': item['createdAt'] ?? '',
            };
          }).toList();
        }
      }
    } catch (e) {
      // Handle error silently
    } finally {
      isLoadingMyFoods.value = false;
    }
  }

  Future<void> searchMyFoods(String searchTerm) async {
    if (searchTerm.isEmpty) {
      return;
    }

    isLoadingMyFoods.value = true;
    isSearchingFoods.value = true;

    try {
      final service = FoodService();
      final response = await service.searchFoods(
        searchTerm: searchTerm,
        page: 1,
        limit: 20,
      );

      if (response != null && response['success'] == true) {
        final foodsList = response['foods'] as List<dynamic>?;
        if (foodsList != null) {
          myFoods.value = foodsList.map((item) {
            return {
              '_id': item['_id'] ?? '',
              'name': item['name'] ?? '',
              'calories': item['calories'] ?? 0,
              'description': item['description'] ?? '',
              'servingSize': item['servingSize'] ?? '',
              'servingPerContainer': item['servingPerContainer'] ?? '',
              'protein': item['protein'] ?? 0,
              'carbohydrates': item['carbohydrates'] ?? 0,
              'totalFat': item['totalFat'] ?? 0,
              'createdBy': item['createdBy'] ?? '',
              'createdAt': item['createdAt'] ?? '',
            };
          }).toList();
        } else {
          myFoods.value = [];
        }
      } else {
        myFoods.value = [];
      }
    } catch (e) {
      // Handle error silently
      myFoods.value = [];
    } finally {
      isLoadingMyFoods.value = false;
    }
  }

  Future<void> fetchScannedMeals() async {
    if (userId == null || userId!.isEmpty) {
      return;
    }

    isLoadingScannedMeals.value = true;
    isSearchingScannedMeals.value = false;

    try {
      final service = MealsService();
      final response = await service.fetchScannedMeals(
        userId: userId!,
        page: 1,
        limit: 20,
      );

      if (response != null && response['success'] == true) {
        final mealsList = response['meals'] as List<dynamic>?;
        if (mealsList != null) {
          scannedMeals.value = mealsList.map((item) {
            return {
              'id': item['id'] ?? '',
              'mealName': item['mealName'] ?? '',
              'mealImage': item['mealImage'] ?? '',
              'totalCalories': item['totalCalories'] ?? 0,
              'totalProtein': item['totalProtein'] ?? 0,
              'totalCarbs': item['totalCarbs'] ?? 0,
              'totalFat': item['totalFat'] ?? 0,
              'entriesCount': item['entriesCount'] ?? 0,
              'mealType': item['mealType'] ?? '',
              'date': item['date'] ?? '',
              'createdAt': item['createdAt'] ?? '',
              'entries': item['entries'] ?? [],
              'renderOnDashboard': item['renderOnDashboard'] ?? false,
            };
          }).toList();
        }
      }
    } catch (e) {
      // Handle error silently
    } finally {
      isLoadingScannedMeals.value = false;
    }
  }

  Future<void> searchScannedMeals(String searchTerm) async {
    if (userId == null || userId!.isEmpty || searchTerm.isEmpty) {
      return;
    }

    isLoadingScannedMeals.value = true;
    isSearchingScannedMeals.value = true;

    try {
      final service = MealsService();
      final response = await service.searchScannedMeals(
        userId: userId!,
        searchTerm: searchTerm,
        page: 1,
        limit: 20,
      );

      if (response != null && response['success'] == true) {
        final mealsList = response['meals'] as List<dynamic>?;
        if (mealsList != null) {
          scannedMeals.value = mealsList.map((item) {
            return {
              'id': item['id'] ?? '',
              'mealName': item['mealName'] ?? '',
              'mealImage': item['mealImage'] ?? '',
              'totalCalories': item['totalCalories'] ?? 0,
              'totalProtein': item['totalProtein'] ?? 0,
              'totalCarbs': item['totalCarbs'] ?? 0,
              'totalFat': item['totalFat'] ?? 0,
              'entriesCount': item['entriesCount'] ?? 0,
              'mealType': item['mealType'] ?? '',
              'date': item['date'] ?? '',
              'createdAt': item['createdAt'] ?? '',
              'entries': item['entries'] ?? [],
              'renderOnDashboard': item['renderOnDashboard'] ?? false,
            };
          }).toList();
        } else {
          scannedMeals.value = [];
        }
      } else {
        scannedMeals.value = [];
      }
    } catch (e) {
      // Handle error silently
      scannedMeals.value = [];
    } finally {
      isLoadingScannedMeals.value = false;
    }
  }

  Future<void> saveDirectInputFood() async {
    debugPrint('🍔 saveDirectInputFood: Method called (saving as meal)');
    
    // Validate required fields
    final mealName = foodNameController.text.trim();
    final caloriesText = caloriesController.text.trim();
    
    debugPrint('🍔 saveDirectInputFood: Validation - mealName: "$mealName", caloriesText: "$caloriesText"');
    
    if (mealName.isEmpty) {
      debugPrint('❌ saveDirectInputFood: Validation failed - meal name is empty');
      showErrorDialog('Please enter a meal name');
      return;
    }

    if (caloriesText.isEmpty) {
      debugPrint('❌ saveDirectInputFood: Validation failed - calories is empty');
      showErrorDialog('Please enter calories');
      return;
    }

    final calories = int.tryParse(caloriesText);
    if (calories == null || calories < 0) {
      debugPrint('❌ saveDirectInputFood: Validation failed - invalid calories value: $caloriesText');
      showErrorDialog('Please enter a valid calories value');
      return;
    }

    debugPrint('✅ saveDirectInputFood: Validation passed');
    
    // Get userId and mealType
    final userId = AppConstants.userId;
    final currentMealType =  'breakfast'; // Default to breakfast if not provided
    
    // Get current date in ISO format
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day).toIso8601String();
    
    // Create entry from direct input data
    final entry = {
      'userId': userId,
      'mealType': currentMealType,
      'foodName': mealName,
      'quantity': amountValue.value,
      'unit': 'serving',
      'calories': calories,
      'protein': proteinValue.value,
      'carbs': carbsValue.value,
      'fat': fatsValue.value,
      'fiber': 0,
      'sugar': 0,
      'sodium': 0,
      'isScanned': true,
      'servingSize': amountValue.value,
      'servingUnit': 'serving',
    };
    
    final entries = [entry];
    
    debugPrint('🍔 saveDirectInputFood: Meal data - name: $mealName, date: $date, mealType: $currentMealType');
    debugPrint('🍔 saveDirectInputFood: Totals - calories: $calories, protein: ${proteinValue.value}, carbs: ${carbsValue.value}, fat: ${fatsValue.value}');
    debugPrint('🍔 saveDirectInputFood: Entry: $entry');

    isSavingDirectInput.value = true;

    try {
      // Optimistically add to Saved Scans tab immediately (no waiting for API).
      // Use a local temp id so we can update/replace it after the API returns.
      final optimisticId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final optimisticMeal = <String, dynamic>{
        'id': optimisticId,
        'mealName': mealName,
        'mealImage': null,
        'totalCalories': calories,
        'totalProtein': proteinValue.value,
        'totalCarbs': carbsValue.value,
        'totalFat': fatsValue.value,
        'entriesCount': entries.length,
        'mealType': currentMealType,
        'date': date,
        'createdAt': DateTime.now().toIso8601String(),
        'entries': entries,
        // Helpful flags (safe even if backend ignores)
        'isScanned': true,
        'isBookmarked': false,
        'isOptimistic': true,
      };

      // Insert at top for instant visibility
      scannedMeals.insert(0, optimisticMeal);
      debugPrint('✅ saveDirectInputFood: Optimistically added meal to Saved Scans with id=$optimisticId');

      // Clear and switch tab immediately (user sees it right away)
      debugPrint('✅ saveDirectInputFood: Clearing form + switching to Saved Scans tab');
      foodNameController.clear();
      caloriesController.clear();
      carbsValue.value = 10;
      proteinValue.value = 41;
      fatsValue.value = 16;
      amountValue.value = 1;
      directInputIngredients.clear();
      selectedTabIndex.value = 1;

      // Also optimistically add to Dashboard immediately (HomeScreenController.todayMeals)
      HomeScreenController? homeController;
      if (Get.isRegistered<HomeScreenController>()) {
        homeController = Get.find<HomeScreenController>();
        homeController.todayMeals.insert(0, Map<String, dynamic>.from(optimisticMeal));
        homeController.todayMeals.refresh();
        debugPrint('✅ saveDirectInputFood: Optimistically added meal to Dashboard todayMeals');
      }

      final service = MealsService();
      debugPrint('🌐 saveDirectInputFood: Calling MealsService.saveCompleteMeal...');
      
      final response = await service.saveCompleteMeal(
        userId: userId,
        date: date,
        mealType: currentMealType,
        mealName: mealName,
        entries: entries,
        notes: '',
        totalCalories: calories,
        totalProtein: proteinValue.value,
        totalCarbs: carbsValue.value,
        totalFat: fatsValue.value,
        isScanned: true, // Direct input is not a scanned meal
      );

      debugPrint('📥 saveDirectInputFood: API response received');
      debugPrint('📥 saveDirectInputFood: Response: $response');
      debugPrint('📥 saveDirectInputFood: Response type: ${response.runtimeType}');
      debugPrint('📥 saveDirectInputFood: Response is null: ${response == null}');
      
      if (response != null) {
        debugPrint('📥 saveDirectInputFood: Response keys: ${response.keys}');
        debugPrint('📥 saveDirectInputFood: Response has "meal": ${response.containsKey('meal')}');
        debugPrint('📥 saveDirectInputFood: Response has "success": ${response.containsKey('success')}');
        debugPrint('📥 saveDirectInputFood: Response["meal"]: ${response['meal']}');
      }

      if (response != null && response['success'] == true && response['meal'] != null) {
        debugPrint('✅ saveDirectInputFood: Success - meal data received');
        // Optimistically add to scanned meals list
        final mealData = response['meal'] as Map<String, dynamic>;
        debugPrint('✅ saveDirectInputFood: Meal data: $mealData');
        
        // Replace the optimistic card with the real saved meal (preserve ordering).
        final savedId = (mealData['id'] ?? mealData['_id'])?.toString() ?? '';
        final serverMeal = <String, dynamic>{
          'id': savedId,
          'mealName': mealData['mealName'] ?? mealName,
          'mealImage': mealData['mealImage'],
          'totalCalories': mealData['totalCalories'] ?? calories,
          'totalProtein': mealData['totalProtein'] ?? proteinValue.value,
          'totalCarbs': mealData['totalCarbs'] ?? carbsValue.value,
          'totalFat': mealData['totalFat'] ?? fatsValue.value,
          'entriesCount': mealData['entriesCount'] ?? entries.length,
          'mealType': mealData['mealType'] ?? currentMealType,
          'date': mealData['date'] ?? date,
          'createdAt': mealData['createdAt'] ?? DateTime.now().toIso8601String(),
          'entries': mealData['entries'] ?? entries,
          'isScanned': mealData['isScanned'] ?? true,
          'isBookmarked': mealData['isBookmarked'] ?? false,
        };

        final idx = scannedMeals.indexWhere((m) => (m['id']?.toString() ?? '') == optimisticId);
        if (idx >= 0) {
          scannedMeals[idx] = serverMeal;
          debugPrint('✅ saveDirectInputFood: Replaced optimistic meal with server meal id=$savedId');
        } else {
          // Fallback: just add/update by server id
          addOrUpdateScannedMeal(serverMeal);
          debugPrint('✅ saveDirectInputFood: Optimistic meal not found; added/updated by server id');
        }

        // Update Dashboard optimistic meal too
        if (homeController != null) {
          final dashIdx = homeController.todayMeals.indexWhere((m) => (m['id']?.toString() ?? '') == optimisticId);
          if (dashIdx >= 0) {
            homeController.todayMeals[dashIdx] = Map<String, dynamic>.from(serverMeal);
            homeController.todayMeals.refresh();
            debugPrint('✅ saveDirectInputFood: Replaced optimistic meal on Dashboard with server meal');
          } else {
            // If not found, insert server meal at top
            homeController.todayMeals.insert(0, Map<String, dynamic>.from(serverMeal));
            homeController.todayMeals.refresh();
            debugPrint('✅ saveDirectInputFood: Inserted server meal on Dashboard (optimistic missing)');
          }
        }

        debugPrint('✅ saveDirectInputFood: Meal added to scanned meals list');
        debugPrint('✅ saveDirectInputFood: Successfully completed');
      } else {
        debugPrint('❌ saveDirectInputFood: Failed - response is null or missing meal data');
        debugPrint('❌ saveDirectInputFood: Response: $response');
        // Remove optimistic card if server save failed
        scannedMeals.removeWhere((m) => (m['id']?.toString() ?? '') == optimisticId);
        if (homeController != null) {
          homeController.todayMeals.removeWhere((m) => (m['id']?.toString() ?? '') == optimisticId);
          homeController.todayMeals.refresh();
        }
        showErrorDialog('Failed to save meal');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ saveDirectInputFood: Exception caught');
      debugPrint('❌ saveDirectInputFood: Error: $e');
      debugPrint('❌ saveDirectInputFood: Stack trace: $stackTrace');
      // Remove optimistic card if we errored
      // (search by local id prefix and current meal name/date as a best-effort)
      scannedMeals.removeWhere((m) {
        final id = (m['id']?.toString() ?? '');
        if (!id.startsWith('local_')) return false;
        final n = (m['mealName'] as String?)?.trim();
        final d = (m['date'] as String?)?.trim();
        return n == mealName && d == date;
      });
      if (Get.isRegistered<HomeScreenController>()) {
        final homeController = Get.find<HomeScreenController>();
        homeController.todayMeals.removeWhere((m) {
          final id = (m['id']?.toString() ?? '');
          if (!id.startsWith('local_')) return false;
          final n = (m['mealName'] as String?)?.trim();
          final d = (m['date'] as String?)?.trim();
          return n == mealName && d == date;
        });
        homeController.todayMeals.refresh();
      }
      showErrorDialog('Error saving meal: $e');
    } finally {
      isSavingDirectInput.value = false;
      debugPrint('🏁 saveDirectInputFood: Method completed, isSavingDirectInput set to false');
    }
  }

  void addOrUpdateMeal(Map<String, dynamic> mealData) {
    final index = myMeals.indexWhere((m) => m['id'] == mealData['id']);
    if (index != -1) {
      // Update existing meal
      myMeals[index] = mealData;
    } else {
      // Add new meal
      myMeals.insert(0, mealData);
    }
  }

  void addOrUpdateFood(Map<String, dynamic> foodData) {
    final index = myFoods.indexWhere((f) => f['_id'] == foodData['_id']);
    if (index != -1) {
      // Update existing food
      myFoods[index] = foodData;
    } else {
      // Add new food
      myFoods.insert(0, foodData);
    }
  }

  void removeMeal(String mealId) {
    myMeals.removeWhere((m) => m['id'] == mealId);
  }

  void removeFood(String foodId) {
    myFoods.removeWhere((f) => f['_id'] == foodId);
  }

  void addOrUpdateScannedMeal(Map<String, dynamic> mealData) {
    final mealId = mealData['id'] ?? mealData['_id'];
    if (mealId == null || mealId.toString().isEmpty) return;
    
    final index = scannedMeals.indexWhere((m) {
      final mId = m['id'] ?? m['_id'];
      return mId != null && mId.toString() == mealId.toString();
    });
    
    if (index != -1) {
      // Update existing scanned meal with new data, preserving existing values as fallback
      final existingMeal = scannedMeals[index];
      scannedMeals[index] = {
        'id': mealData['id'] ?? mealData['_id'] ?? existingMeal['id'] ?? existingMeal['_id'],
        'mealName': mealData['mealName'] ?? existingMeal['mealName'] ?? '',
        'mealImage': mealData['mealImage'] ?? existingMeal['mealImage'] ?? '',
        'totalCalories': mealData['totalCalories'] ?? existingMeal['totalCalories'] ?? 0,
        'totalProtein': mealData['totalProtein'] ?? existingMeal['totalProtein'] ?? 0,
        'totalCarbs': mealData['totalCarbs'] ?? existingMeal['totalCarbs'] ?? 0,
        'totalFat': mealData['totalFat'] ?? existingMeal['totalFat'] ?? 0,
        'entriesCount': mealData['entriesCount'] ?? existingMeal['entriesCount'] ?? 0,
        'mealType': mealData['mealType'] ?? existingMeal['mealType'] ?? '',
        'date': mealData['date'] ?? existingMeal['date'] ?? '',
        'createdAt': mealData['createdAt'] ?? existingMeal['createdAt'] ?? '',
        'entries': mealData['entries'] ?? existingMeal['entries'] ?? [],
        'renderOnDashboard': mealData['renderOnDashboard'] ?? existingMeal['renderOnDashboard'] ?? false,
      };
    } else {
      // Add new scanned meal (shouldn't happen often, but handle it)
      scannedMeals.insert(0, {
        'id': mealData['id'] ?? mealData['_id'] ?? '',
        'mealName': mealData['mealName'] ?? '',
        'mealImage': mealData['mealImage'] ?? '',
        'totalCalories': mealData['totalCalories'] ?? 0,
        'totalProtein': mealData['totalProtein'] ?? 0,
        'totalCarbs': mealData['totalCarbs'] ?? 0,
        'totalFat': mealData['totalFat'] ?? 0,
        'entriesCount': mealData['entriesCount'] ?? 0,
        'mealType': mealData['mealType'] ?? '',
        'date': mealData['date'] ?? '',
        'createdAt': mealData['createdAt'] ?? '',
        'entries': mealData['entries'] ?? [],
        'renderOnDashboard': mealData['renderOnDashboard'] ?? false,
      });
    }
  }

  void removeScannedMeal(Map<String, dynamic> mealToRemove) {
    final mealId = mealToRemove['id'] ?? mealToRemove['_id'];
    if (mealId != null && mealId.toString().isNotEmpty) {
      scannedMeals.removeWhere((m) {
        final mId = m['id'] ?? m['_id'];
        return mId != null && mId.toString() == mealId.toString();
      });
    } else {
      // Fallback: try to match by other criteria if ID is not available
      final mealName = (mealToRemove['mealName'] as String?)?.trim();
      final totalCalories = ((mealToRemove['totalCalories'] ?? 0) as num).toInt();
      final createdAt = mealToRemove['createdAt'] as String?;
      
      scannedMeals.removeWhere((m) {
        final mName = (m['mealName'] as String?)?.trim();
        final mCalories = ((m['totalCalories'] ?? 0) as num).toInt();
        final mCreatedAt = m['createdAt'] as String?;
        
        return mName == mealName && 
               mCalories == totalCalories && 
               mCreatedAt == createdAt;
      });
    }
  }

  void addDirectInputIngredient(Map<String, dynamic> ingredient) {
    directInputIngredients.add(ingredient);
  }

  void updateDirectInputIngredient(dynamic oldIngredient, Map<String, dynamic> newIngredient) {
    final index = directInputIngredients.indexOf(oldIngredient);
    if (index != -1) {
      directInputIngredients[index] = newIngredient;
    }
  }

  void removeDirectInputIngredient(dynamic ingredient) {
    directInputIngredients.remove(ingredient);
  }

  void showErrorDialog(String message) {
    Get.dialog(
      CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Future<bool> addSavedScanToDashboard(Map<String, dynamic> meal) async {
    final mealId = (meal['id'] ?? meal['_id'])?.toString() ?? '';
    if (mealId.isEmpty) return false;

    if (userId == null || userId!.isEmpty) return false;

    // prevent double taps
    if (addingToDashboardMealIds.contains(mealId)) return false;
    addingToDashboardMealIds.add(mealId);

    // Optimistically add to Dashboard immediately (like Direct Input does)
    HomeScreenController? homeController;
    bool addedToDashboardOptimistically = false;
    if (Get.isRegistered<HomeScreenController>()) {
      homeController = Get.find<HomeScreenController>();
      final alreadyOnDashboard = homeController.todayMeals.any((m) {
        final id = (m['id'] ?? m['_id'])?.toString() ?? '';
        return id == mealId;
      });
      if (!alreadyOnDashboard) {
        final optimisticMeal = Map<String, dynamic>.from(meal);
        optimisticMeal['renderOnDashboard'] = true;
        // Use current local datetime for optimistic addition
        final now = DateTime.now().toLocal();
        optimisticMeal['date'] = DateTime(now.year, now.month, now.day).toIso8601String();
        optimisticMeal['createdAt'] = now.toIso8601String();
        homeController.todayMeals.insert(0, optimisticMeal);
        homeController.todayMeals.refresh();
        addedToDashboardOptimistically = true;
      }
    }

    try {
      final service = MealsService();

      final date = (meal['date'] as String?)?.trim() ?? '';
      final mealType = (meal['mealType'] as String?)?.trim() ?? '';
      final mealName = (meal['mealName'] as String?)?.trim() ?? '';

      final rawEntries = meal['entries'];
      final entries = (rawEntries is List)
          ? rawEntries
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      final response = await service.updateMeal(
        mealId: mealId,
        userId: userId!,
        date: date,
        mealType: mealType,
        mealName: mealName,
        entries: entries,
        renderOnDashboard: true,
        mealDate: DateTime.now().toLocal().toIso8601String(),
      );

      final ok = response != null && response['success'] == true;
      if (!ok && addedToDashboardOptimistically && homeController != null) {
        homeController.todayMeals.removeWhere((m) {
          final id = (m['id'] ?? m['_id'])?.toString() ?? '';
          return id == mealId;
        });
        homeController.todayMeals.refresh();
      }

      // If backend returns updated meal payload, reconcile local copies.
      final mealData = (response != null && response['meal'] is Map)
          ? Map<String, dynamic>.from(response['meal'] as Map)
          : null;
      if (ok && mealData != null) {
        final updatedId = (mealData['id'] ?? mealData['_id'])?.toString() ?? mealId;
        // Update dashboard item
        if (homeController != null) {
          final idx = homeController.todayMeals.indexWhere((m) {
            final id = (m['id'] ?? m['_id'])?.toString() ?? '';
            return id == updatedId;
          });
          if (idx >= 0) {
            final merged = Map<String, dynamic>.from(homeController.todayMeals[idx]);
            merged.addAll(mealData);
            merged['renderOnDashboard'] = true;
            homeController.todayMeals[idx] = merged;
            homeController.todayMeals.refresh();
          }
        }
        // Update scanned meals item (so list reflects the new flag too)
        final sIdx = scannedMeals.indexWhere((m) {
          final id = (m['id'] ?? m['_id'])?.toString() ?? '';
          return id == updatedId;
        });
        if (sIdx >= 0) {
          final merged = Map<String, dynamic>.from(scannedMeals[sIdx]);
          merged.addAll(mealData);
          merged['renderOnDashboard'] = true;
          scannedMeals[sIdx] = merged;
        }
      }

      return ok;
    } catch (_) {
      if (addedToDashboardOptimistically && homeController != null) {
        homeController.todayMeals.removeWhere((m) {
          final id = (m['id'] ?? m['_id'])?.toString() ?? '';
          return id == mealId;
        });
        homeController.todayMeals.refresh();
      }
      return false;
    } finally {
      addingToDashboardMealIds.remove(mealId);
    }
  }
}


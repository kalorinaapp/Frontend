import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../services/food_service.dart';
import '../services/meals_service.dart';
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
    // Validate required fields
    if (foodNameController.text.trim().isEmpty) {
      showErrorDialog('Please enter a food name');
      return;
    }

    if (caloriesController.text.trim().isEmpty) {
      showErrorDialog('Please enter calories');
      return;
    }

    final calories = int.tryParse(caloriesController.text.trim());
    if (calories == null || calories < 0) {
      showErrorDialog('Please enter a valid calories value');
      return;
    }

    isSavingDirectInput.value = true;

    try {
      final service = FoodService();
      final response = await service.saveFood(
        name: foodNameController.text.trim(),
        calories: calories,
        protein: proteinValue.value.toDouble(),
        carbohydrates: carbsValue.value.toDouble(),
        totalFat: fatsValue.value.toDouble(),
        servingSize: '${amountValue.value} serving',
        isCustom: true,
        createdBy: AppConstants.userId,
      );

      if (response != null && response['food'] != null) {
        // Optimistically add to my foods
        final foodData = response['food'];
        myFoods.insert(0, {
          '_id': foodData['_id'] ?? '',
          'name': foodData['name'] ?? '',
          'calories': foodData['calories'] ?? 0,
          'description': foodData['description'] ?? '',
          'servingSize': foodData['servingSize'] ?? '',
          'servingPerContainer': foodData['servingPerContainer'] ?? '',
          'protein': foodData['protein'] ?? 0,
          'carbohydrates': foodData['carbohydrates'] ?? 0,
          'totalFat': foodData['totalFat'] ?? 0,
          'createdBy': foodData['createdBy'] ?? '',
          'createdAt': foodData['createdAt'] ?? '',
        });

        // Clear the form
        foodNameController.clear();
        caloriesController.clear();
        carbsValue.value = 10;
        proteinValue.value = 41;
        fatsValue.value = 16;
        amountValue.value = 1;
        directInputIngredients.clear();

        // Switch to My Foods tab
        selectedTabIndex.value = 2;
      } else {
        showErrorDialog('Failed to save food');
      }
    } catch (e) {
      showErrorDialog('Error saving food: $e');
    } finally {
      isSavingDirectInput.value = false;
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
}


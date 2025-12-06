import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../network/http_helper.dart' show multiGetAPINew, multiDeleteAPINew;
import '../utils/network.dart' show multiPostAPINew, putAPI;

class ProgressService extends GetxController {
  // Store daily progress data as reactive
  final Rx<Map<String, dynamic>?> _dailyProgressData = Rx<Map<String, dynamic>?>(null);
  
  // Store optimistic foods (foods added before API confirms them)
  final Map<String, Map<String, dynamic>> _optimisticFoods = {};
  
  // Getter to access stored daily progress data
  Map<String, dynamic>? get dailyProgressData => _dailyProgressData.value;
  
  // Expose reactive value for Obx usage
  Rx<Map<String, dynamic>?> get dailyProgressDataRx => _dailyProgressData;
  
  // Method to update data and trigger UI refresh
  void updateProgressData(Map<String, dynamic>? data) {
    _dailyProgressData.value = data;
    update();
  }
  
  // Add an optimistic food (will be merged into progress data)
  void addOptimisticFood(Map<String, dynamic> food) {
    final foodId = food['id']?.toString() ?? food['_id']?.toString() ?? '';
    if (foodId.isNotEmpty) {
      _optimisticFoods[foodId] = Map<String, dynamic>.from(food);
      _mergeOptimisticFoods();
    }
  }
  
  // Merge optimistic foods into current progress data
  void _mergeOptimisticFoods() {
    if (_optimisticFoods.isEmpty) return;
    
    final currentData = _dailyProgressData.value;
    if (currentData != null && currentData['progress'] != null) {
      final progress = Map<String, dynamic>.from(currentData['progress'] as Map<String, dynamic>);
      final foodsList = (progress['foods'] as List<dynamic>? ?? []).toList();
      
      // Get IDs of existing foods
      final existingIds = foodsList.map((f) {
        return f['id']?.toString() ?? f['_id']?.toString() ?? '';
      }).where((id) => id.isNotEmpty).toSet();
      
      // Add optimistic foods that don't exist yet
      bool addedAny = false;
      for (final optimisticFood in _optimisticFoods.values) {
        final foodId = optimisticFood['id']?.toString() ?? optimisticFood['_id']?.toString() ?? '';
        if (foodId.isNotEmpty && !existingIds.contains(foodId)) {
          foodsList.insert(0, optimisticFood); // Add at beginning
          addedAny = true;
        }
      }
      
      if (addedAny) {
        progress['foods'] = foodsList;
        final updatedData = Map<String, dynamic>.from(currentData)
          ..['progress'] = progress;
        _dailyProgressData.value = updatedData;
        update();
      }
    }
  }
  
  // Remove an optimistic food (when API confirms it or it's no longer needed)
  void removeOptimisticFood(String foodId) {
    _optimisticFoods.remove(foodId);
  }
  
  // Clear all optimistic foods
  void clearOptimisticFoods() {
    _optimisticFoods.clear();
  }

  Future<Map<String, dynamic>?> uploadProgressPhotos({
    required List<String> base64Images,
    double? weight,
    String unit = 'kg',
    String? notes,
    String? takenAtIsoLocal,
  }) async {
    Map<String, dynamic>? parsed;

    final Map<String, dynamic> body = {
      'imageData': base64Images, // backend can accept list; if single, server can handle first
    };
    if (weight != null) body['weight'] = weight;
    if (unit.isNotEmpty) body['unit'] = unit;
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;
    if (takenAtIsoLocal != null && takenAtIsoLocal.isNotEmpty) body['takenAt'] = takenAtIsoLocal;

    await multiPostAPINew(
      methodName: 'api/progress/photos',
      param: body,
      callback: (resp) async {
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('ProgressService upload parse error: $e');
          parsed = null;
        }
      },
    );

    return parsed;
  }
  Future<Map<String, dynamic>?> fetchDailyProgress({
    required String dateYYYYMMDD,
    int? steps,
  }) async {
    final startTime = DateTime.now();
    Map<String, dynamic>? parsed;
    final Map<String, String> queryParams = {
      'date': dateYYYYMMDD,
    };
    
    // Add steps to query if provided
    if (steps != null) {
      queryParams['steps'] = steps.toString();
    }
    
    await multiGetAPINew(
      methodName: 'api/progress/daily',
      query: queryParams,
      callback: (resp) async {
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        print('date: $dateYYYYMMDD');
        print('ProgressService fetchDailyProgress response time: ${duration.inMilliseconds}ms');
        try {
          final decoded = jsonDecode(resp.response);
          if (decoded is Map<String, dynamic>) {
            parsed = decoded;
            
            // Merge with existing data to preserve meals and other fields
            final existingData = _dailyProgressData.value;
            if (existingData != null && parsed != null) {
              // Merge existing progress with new API response
              final existingProgress = existingData['progress'] as Map<String, dynamic>?;
              final newProgress = parsed!['progress'] as Map<String, dynamic>?;
              
              if (existingProgress != null && newProgress != null) {
                // Preserve existing fields like meals, macros, etc. that might not be in new response
                final mergedProgress = Map<String, dynamic>.from(newProgress);
                
                // Preserve meals if they exist in old data but not in new
                if (existingProgress['meals'] != null && newProgress['meals'] == null) {
                  mergedProgress['meals'] = existingProgress['meals'];
                }
                
                // Merge foods: combine existing, new API, and optimistic
                final existingFoods = (existingProgress['foods'] as List<dynamic>? ?? []).toList();
                final newFoods = (newProgress['foods'] as List<dynamic>? ?? []).toList();
                
                // Combine existing and new foods, avoiding duplicates
                final allFoodIds = <String>{};
                final mergedFoods = <dynamic>[];
                
                // Add new API foods first
                for (final food in newFoods) {
                  final foodId = food['id']?.toString() ?? food['_id']?.toString() ?? '';
                  if (foodId.isNotEmpty && !allFoodIds.contains(foodId)) {
                    mergedFoods.add(food);
                    allFoodIds.add(foodId);
                  }
                }
                
                // Add existing foods that aren't in new response
                for (final food in existingFoods) {
                  final foodId = food['id']?.toString() ?? food['_id']?.toString() ?? '';
                  if (foodId.isNotEmpty && !allFoodIds.contains(foodId)) {
                    mergedFoods.add(food);
                    allFoodIds.add(foodId);
                  }
                }
                
                // Merge optimistic foods
                if (_optimisticFoods.isNotEmpty) {
                  for (final optimisticFood in _optimisticFoods.values) {
                    final foodId = optimisticFood['id']?.toString() ?? optimisticFood['_id']?.toString() ?? '';
                    if (foodId.isNotEmpty && !allFoodIds.contains(foodId)) {
                      mergedFoods.insert(0, optimisticFood); // Add at beginning
                      debugPrint('✅ Keeping optimistic food: ${optimisticFood['name']}');
                    } else if (foodId.isNotEmpty && allFoodIds.contains(foodId)) {
                      // API now has this food, remove from optimistic list
                      _optimisticFoods.remove(foodId);
                      debugPrint('✅ API confirmed optimistic food, removing from optimistic list: ${optimisticFood['name']}');
                    }
                  }
                }
                
                mergedProgress['foods'] = mergedFoods;
                parsed!['progress'] = mergedProgress;
                
                debugPrint('✅ Merged progress data. Foods: ${mergedFoods.length}, Optimistic: ${_optimisticFoods.length}');
              } else if (_optimisticFoods.isNotEmpty && newProgress != null) {
                // No existing progress but have optimistic foods - ensure foods array exists
                if (newProgress['foods'] == null) {
                  newProgress['foods'] = <dynamic>[];
                }
                
                final foodsList = (newProgress['foods'] as List<dynamic>).toList();
                final apiFoodIds = foodsList.map((f) {
                  return f['id']?.toString() ?? f['_id']?.toString() ?? '';
                }).where((id) => id.isNotEmpty).toSet();
                
                // Add optimistic foods
                for (final optimisticFood in _optimisticFoods.values) {
                  final foodId = optimisticFood['id']?.toString() ?? optimisticFood['_id']?.toString() ?? '';
                  if (foodId.isNotEmpty && !apiFoodIds.contains(foodId)) {
                    foodsList.insert(0, optimisticFood);
                  } else if (foodId.isNotEmpty && apiFoodIds.contains(foodId)) {
                    _optimisticFoods.remove(foodId);
                  }
                }
                
                newProgress['foods'] = foodsList;
                parsed!['progress'] = newProgress;
              }
            } else if (_optimisticFoods.isNotEmpty && parsed != null) {
              // New response but have optimistic foods
              if (parsed!['progress'] == null) {
                parsed!['progress'] = <String, dynamic>{};
              }
              
              final progressData = parsed!['progress'] as Map<String, dynamic>;
              if (progressData['foods'] == null) {
                progressData['foods'] = <dynamic>[];
              }
              
              final foodsList = (progressData['foods'] as List<dynamic>).toList();
              final apiFoodIds = foodsList.map((f) {
                return f['id']?.toString() ?? f['_id']?.toString() ?? '';
              }).where((id) => id.isNotEmpty).toSet();
              
              for (final optimisticFood in _optimisticFoods.values) {
                final foodId = optimisticFood['id']?.toString() ?? optimisticFood['_id']?.toString() ?? '';
                if (foodId.isNotEmpty && !apiFoodIds.contains(foodId)) {
                  foodsList.insert(0, optimisticFood);
                } else if (foodId.isNotEmpty && apiFoodIds.contains(foodId)) {
                  _optimisticFoods.remove(foodId);
                }
              }
              
              progressData['foods'] = foodsList;
              parsed!['progress'] = progressData;
            }
          } else {
            parsed = null;
          }
          
          // Only update if we got valid data, otherwise preserve existing data if we have optimistic foods
          if (parsed != null) {
            // Create a deep copy to ensure GetX detects the change
            final parsedMap = parsed as Map<String, dynamic>;
            final newData = Map<String, dynamic>.from(parsedMap);
            if (newData['progress'] != null) {
              final progressMap = newData['progress'] as Map<String, dynamic>;
              newData['progress'] = Map<String, dynamic>.from(progressMap);
              final progress = newData['progress'] as Map<String, dynamic>;
              if (progress['foods'] != null) {
                progress['foods'] = List.from(progress['foods'] as List);
              }
            }
            
            // Update reactive value first to trigger Obx rebuilds
            _dailyProgressData.value = newData;
            
            debugPrint('🔔 ProgressService: Setting dailyProgressData and calling update()');
            debugPrint('🔔 ProgressService: Foods in newData: ${(newData['progress']?['foods'] as List?)?.length ?? 0}');
            
            // Trigger UI update for GetBuilder
            update();
            
            // Force another update after a microtask to ensure GetBuilder rebuilds
            Future.microtask(() {
              if (Get.isRegistered<ProgressService>()) {
                update();
                debugPrint('🔔 ProgressService: Called update() again after microtask');
              }
            });
          } else if (_optimisticFoods.isNotEmpty && _dailyProgressData.value != null) {
            // Don't clear data if we have optimistic foods - preserve existing data
            debugPrint('⚠️ API response was null but have optimistic foods, preserving existing data');
            // Still trigger update to ensure UI reflects optimistic data
            update();
            return parsed;
          } else {
            _dailyProgressData.value = parsed;
            update();
          }

          print('dailyProgressData: ${_dailyProgressData.value}');
        } catch (e) {
          debugPrint('ProgressService parse error: $e');
          // Don't clear data if we have optimistic foods
          if (_optimisticFoods.isEmpty) {
            parsed = null;
            _dailyProgressData.value = null;
            update();
          } else {
            debugPrint('⚠️ Parse error but have optimistic foods, preserving existing data');
          }
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> fetchProgressPhotos({
    int page = 1,
    int limit = 20,
  }) async {
    Map<String, dynamic>? parsed;
    await multiGetAPINew(
      methodName: 'api/progress/photos',
      query: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      callback: (resp) async {
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('ProgressService fetch photos parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> fetchWeightHistory({
    int page = 1,
    int limit = 30,
  }) async {
    Map<String, dynamic>? parsed;
    await multiGetAPINew(
      methodName: 'api/progress/weight/history',
      query: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      callback: (resp) async {
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('ProgressService history parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> fetchWeightSummary() async {
    Map<String, dynamic>? parsed;
    await multiGetAPINew(
      methodName: 'api/progress/weight/summary',
      callback: (resp) async {
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('ProgressService summary parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> logDailySteps({
    required int steps,
    required String dateYYYYMMDD,
  }) async {
    Map<String, dynamic>? parsed;
    await multiPostAPINew(
      methodName: 'api/progress/steps/exercise',
      param: {
        'steps': steps,
        'loggedAt': dateYYYYMMDD,
      },
      callback: (resp) async {
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('ProgressService steps parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> deleteProgressPhoto({
    required String photoId,
  }) async {
    Map<String, dynamic>? parsed;
    await multiDeleteAPINew(
      methodName: 'api/progress/photos/$photoId',
      callback: (resp) async {
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('ProgressService delete photo parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> updateManualProgress({
    required String dateYYYYMMDD,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    String? notes,
  }) async {
    Map<String, dynamic>? parsed;
    
    final Map<String, dynamic> body = {
      'date': dateYYYYMMDD,
    };
    
    if (calories != null) body['calorieGoal'] = calories;
    if (protein != null) body['proteinGoal'] = protein;
    if (carbs != null) body['carbsGoal'] = carbs;
    if (fat != null) body['fatGoal'] = fat;
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;
    
    await putAPI(
      methodName: 'api/progress/adjustments',
      param: body,
      callback: (resp) async {
        try {
          if (resp.response.isNotEmpty) {
            parsed = jsonDecode(resp.response) as Map<String, dynamic>;
          } else {
            parsed = const {'success': true};
          }
        } catch (e) {
          debugPrint('ProgressService updateManualProgress parse error: $e');
          parsed = null;
        }
      },
    );
    
    return parsed;
  }
}





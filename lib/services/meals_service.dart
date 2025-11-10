import 'dart:convert';
import 'dart:io';
import 'package:calorie_ai_app/utils/network.dart';
import 'package:flutter/foundation.dart';
import '../network/http_helper.dart' hide multiPostAPINew;


class MealsService {
  const MealsService();
  Future<Map<String, dynamic>?> fetchTodayMeals({
    required String userId,
    required String dateYYYYMMDD,
    required String mealType,
  }) async {
    Map<String, dynamic>? parsed;
    await multiGetAPINew(
      methodName: 'api/meals/entries/$userId',
      query: {
        'date': dateYYYYMMDD,
        'mealType': mealType,
      },
      callback: (resp) async {
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('MealsService parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> fetchDailyMeals({
    required String userId,
    required String dateYYYYMMDD,
    int? steps,
  }) async {
    Map<String, dynamic>? parsed;
    final Map<String, String> queryParams = {
      'date': dateYYYYMMDD,
    };
    
    // Add steps to query if provided
    if (steps != null) {
      queryParams['steps'] = steps.toString();
    }
    
    await multiGetAPINew(
      methodName: 'api/meals/daily/$userId',
      query: queryParams,
      callback: (resp) async {
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
          debugPrint('MealsService fetchDailyMeals response: $parsed');
        } catch (e) {
          debugPrint('MealsService fetchDailyMeals parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> saveCompleteMeal({
    required String userId,
    required String date,
    required String mealType,
    required String mealName,
    required List<Map<String, dynamic>> entries,
    String? notes,
    String? mealImage,
    int? totalCalories,
    int? totalProtein,
    int? totalCarbs,
    int? totalFat,
  }) async {
    Map<String, dynamic>? parsed;
    
    final body = {
      'userId': userId,
      'date': date,
      'mealType': mealType,
      'mealName': mealName,
      'entries': entries,
      'notes': notes ?? '',
      'isCompleted': true,
    };

    if (totalCalories != null) {
      body['totalCalories'] = totalCalories;
    }
    if (totalProtein != null) {
      body['totalProtein'] = totalProtein;
    }
    if (totalCarbs != null) {
      body['totalCarbs'] = totalCarbs;
    }
    if (totalFat != null) {
      body['totalFat'] = totalFat;
    }
    
    // Add base64 image if provided
    if (mealImage != null && mealImage.isNotEmpty) {
      try {
        final file = File(mealImage);
        if (file.existsSync()) {
          final bytes = await file.readAsBytes();
          final base64Data = base64Encode(bytes);
          body['mealImage'] = 'data:image/jpeg;base64,$base64Data';
        }
      } catch (e) {
        debugPrint('MealsService: Error encoding image: $e');
      }
    }

    await multiPostAPINew(
      methodName: 'api/meals/complete',
      param: body,
      callback: (resp) async {
        try {
          // Try to parse the response regardless of isError flag
          // since 201 Created is a success status for POST requests
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
          
          // If parsing succeeded but response indicates failure, set to null
          if (parsed != null && parsed!['success'] == false) {
            debugPrint('MealsService save error: ${resp.response}');
            parsed = null;
          }
        } catch (e) {
          debugPrint('MealsService save parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> fetchAllMeals({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    Map<String, dynamic>? parsed;
    await multiGetAPINew(
      methodName: 'api/meals/all/$userId',
      query: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      callback: (resp) async {
        try {
          if (resp.isError == true) {
            debugPrint('MealsService fetchAllMeals error: ${resp.response}');
            parsed = null;
            return;
          }
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('MealsService fetchAllMeals parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> fetchScannedMeals({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    Map<String, dynamic>? parsed;
    await multiGetAPINew(
      methodName: 'api/meals/scanned/$userId',
      query: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      callback: (resp) async {
        try {
          if (resp.isError == true) {
            debugPrint('MealsService fetchScannedMeals error: ${resp.response}');
            parsed = null;
            return;
          }
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('MealsService fetchScannedMeals parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> updateMeal({
    required String mealId,
    required String userId,
    required String date,
    required String mealType,
    required String mealName,
    required List<Map<String, dynamic>> entries,
    String? notes,
    bool? isScanned,
    int? totalCalories,
    int? totalProtein,
    int? totalCarbs,
    int? totalFat,
  }) async {
    Map<String, dynamic>? parsed;
    
    final body = {
      'userId': userId,
      'date': date,
      'mealType': mealType,
      'mealName': mealName,
      'entries': entries,
      'notes': notes ?? '',
      'isCompleted': true,
      if (isScanned != null) 'isScanned': isScanned,
      if (totalCalories != null) 'totalCalories': totalCalories,
      if (totalProtein != null) 'totalProtein': totalProtein,
      if (totalCarbs != null) 'totalCarbs': totalCarbs,
      if (totalFat != null) 'totalFat': totalFat,
    };

    await putAPI(
      methodName: 'api/meals/$mealId',
      param: body,
      callback: (resp) async {
        try {
          // Try to parse the response regardless of isError flag
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
          
          // If parsing succeeded but response indicates failure, set to null
          if (parsed != null && parsed!['success'] == false) {
            debugPrint('MealsService update error: ${resp.response}');
            parsed = null;
          }
        } catch (e) {
          debugPrint('MealsService update parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> searchMeals({
    required String userId,
    required String searchTerm,
    int page = 1,
    int limit = 20,
  }) async {
    Map<String, dynamic>? parsed;
    await multiGetAPINew(
      methodName: 'api/meals/search/$userId',
      query: {
        'search': searchTerm,
        'page': page.toString(),
        'limit': limit.toString(),
      },
      callback: (resp) async {
        try {
          if (resp.isError == true) {
            debugPrint('MealsService searchMeals error: ${resp.response}');
            parsed = null;
            return;
          }
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('MealsService searchMeals parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> searchScannedMeals({
    required String userId,
    required String searchTerm,
    int page = 1,
    int limit = 20,
  }) async {
    Map<String, dynamic>? parsed;
    await multiGetAPINew(
      methodName: 'api/meals/scanned/$userId',
      query: {
        'search': searchTerm,
        'page': page.toString(),
        'limit': limit.toString(),
      },
      callback: (resp) async {
        try {
          if (resp.isError == true) {
            debugPrint('MealsService searchScannedMeals error: ${resp.response}');
            parsed = null;
            return;
          }
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('MealsService searchScannedMeals parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> deleteMeal({
    required String mealId,
  }) async {
    Map<String, dynamic>? parsed;

    await deleteAPI(
      methodName: 'api/meals/$mealId',
      param: {},
      callback: (resp) async {
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
          
          // If parsing succeeded but response indicates failure, set to null
          if (parsed != null && parsed!['success'] == false) {
            debugPrint('MealsService delete error: ${resp.response}');
            parsed = null;
          }
        } catch (e) {
          debugPrint('MealsService delete parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }
}



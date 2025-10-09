import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../network/http_helper.dart';

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

  Future<Map<String, dynamic>?> saveCompleteMeal({
    required String userId,
    required String date,
    required String mealType,
    required String mealName,
    required List<Map<String, dynamic>> entries,
    String? notes,
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

    await multiPostAPINew(
      methodName: 'api/meals/complete',
      param: body,
      callback: (resp) async {
        try {
          if (resp.isError == true) {
            debugPrint('MealsService save error: ${resp.response}');
            parsed = null;
            return;
          }
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
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
}



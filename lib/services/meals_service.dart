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
}



import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../network/http_helper.dart';

class FoodService {
  const FoodService();

  Future<Map<String, dynamic>?> getFoodSuggestions() async {
    Map<String, dynamic>? parsed;
    await multiGetAPINew(
      methodName: 'api/foods/ai/suggestions',
      callback: (resp) async {
        try {
          if (resp.isError == true) {
            debugPrint('FoodService error: ${resp.response}');
            parsed = null;
            return;
          }
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('FoodService parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }
}


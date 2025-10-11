import 'dart:convert';
import 'package:calorie_ai_app/utils/network.dart';
import 'package:flutter/foundation.dart';
import '../network/http_helper.dart' hide multiPostAPINew;

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

  Future<Map<String, dynamic>?> saveFood({
    required String name,
    int? calories,
    String? description,
    String? servingSize,
    String? servingPerContainer,
    double? protein,
    double? carbohydrates,
    double? totalFat,
    double? saturatedFat,
    double? polyunsaturatedFat,
    double? monounsaturatedFat,
    double? transFat,
    double? cholesterol,
    double? sodium,
    double? potassium,
    double? sugar,
    double? fiber,
    double? vitaminA,
    double? vitaminC,
    double? calcium,
    double? iron,
    String? category,
    bool isCustom = true,
    String? createdBy,
  }) async {
    Map<String, dynamic>? parsed;

    final body = <String, dynamic>{
      'name': name,
      'isCustom': isCustom,
    };

    // Add optional fields only if they have values
    if (calories != null) body['calories'] = calories;
    if (description != null && description.isNotEmpty) body['description'] = description;
    if (servingSize != null && servingSize.isNotEmpty) body['servingSize'] = servingSize;
    if (servingPerContainer != null && servingPerContainer.isNotEmpty) body['servingPerContainer'] = servingPerContainer;
    if (protein != null) body['protein'] = protein;
    if (carbohydrates != null) body['carbohydrates'] = carbohydrates;
    if (totalFat != null) body['totalFat'] = totalFat;
    if (saturatedFat != null) body['saturatedFat'] = saturatedFat;
    if (polyunsaturatedFat != null) body['polyunsaturatedFat'] = polyunsaturatedFat;
    if (monounsaturatedFat != null) body['monounsaturatedFat'] = monounsaturatedFat;
    if (transFat != null) body['transFat'] = transFat;
    if (cholesterol != null) body['cholesterol'] = cholesterol;
    if (sodium != null) body['sodium'] = sodium;
    if (potassium != null) body['potassium'] = potassium;
    if (sugar != null) body['sugar'] = sugar;
    if (fiber != null) body['fiber'] = fiber;
    if (vitaminA != null) body['vitaminA'] = vitaminA;
    if (vitaminC != null) body['vitaminC'] = vitaminC;
    if (calcium != null) body['calcium'] = calcium;
    if (iron != null) body['iron'] = iron;
    if (category != null && category.isNotEmpty) body['category'] = category;
    if (createdBy != null && createdBy.isNotEmpty) body['createdBy'] = createdBy;

    await multiPostAPINew(
      methodName: 'api/foods',
      param: body,
      callback: (resp) async {
        try {
          // Try to parse the response regardless of isError flag
          // since 201 Created is a success status for POST requests
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
          
          // Check if response has food data (indicates success)
          if (parsed != null && parsed!['food'] == null && parsed!['message'] == null) {
            debugPrint('FoodService save error: ${resp.response}');
            parsed = null;
          }
        } catch (e) {
          debugPrint('FoodService save parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> fetchAllFoods({
    int page = 1,
    int limit = 20,
  }) async {
    Map<String, dynamic>? parsed;
    await multiGetAPINew(
      methodName: 'api/foods/all',
      query: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      callback: (resp) async {
        try {
          if (resp.isError == true) {
            debugPrint('FoodService fetchAllFoods error: ${resp.response}');
            parsed = null;
            return;
          }
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('FoodService fetchAllFoods parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> updateFood({
    required String foodId,
    String? name,
    int? calories,
    String? description,
    String? servingSize,
    String? servingPerContainer,
    double? protein,
    double? carbohydrates,
    double? totalFat,
    double? saturatedFat,
    double? polyunsaturatedFat,
    double? monounsaturatedFat,
    double? transFat,
    double? cholesterol,
    double? sodium,
    double? potassium,
    double? sugar,
    double? fiber,
    double? vitaminA,
    double? vitaminC,
    double? calcium,
    double? iron,
    String? category,
  }) async {
    Map<String, dynamic>? parsed;

    final body = <String, dynamic>{};

    // Add fields only if they have values
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (calories != null) body['calories'] = calories;
    if (description != null && description.isNotEmpty) body['description'] = description;
    if (servingSize != null && servingSize.isNotEmpty) body['servingSize'] = servingSize;
    if (servingPerContainer != null && servingPerContainer.isNotEmpty) body['servingPerContainer'] = servingPerContainer;
    if (protein != null) body['protein'] = protein;
    if (carbohydrates != null) body['carbohydrates'] = carbohydrates;
    if (totalFat != null) body['totalFat'] = totalFat;
    if (saturatedFat != null) body['saturatedFat'] = saturatedFat;
    if (polyunsaturatedFat != null) body['polyunsaturatedFat'] = polyunsaturatedFat;
    if (monounsaturatedFat != null) body['monounsaturatedFat'] = monounsaturatedFat;
    if (transFat != null) body['transFat'] = transFat;
    if (cholesterol != null) body['cholesterol'] = cholesterol;
    if (sodium != null) body['sodium'] = sodium;
    if (potassium != null) body['potassium'] = potassium;
    if (sugar != null) body['sugar'] = sugar;
    if (fiber != null) body['fiber'] = fiber;
    if (vitaminA != null) body['vitaminA'] = vitaminA;
    if (vitaminC != null) body['vitaminC'] = vitaminC;
    if (calcium != null) body['calcium'] = calcium;
    if (iron != null) body['iron'] = iron;
    if (category != null && category.isNotEmpty) body['category'] = category;

    await putAPI(
      methodName: 'api/foods/$foodId',
      param: body,
      callback: (resp) async {
        try {
          // Try to parse the response regardless of isError flag
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
          
          // Check if response has food data or success message
          if (parsed != null && parsed!['food'] == null && parsed!['message'] == null) {
            debugPrint('FoodService update error: ${resp.response}');
            parsed = null;
          }
        } catch (e) {
          debugPrint('FoodService update parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> searchFoods({
    required String searchTerm,
    int page = 1,
    int limit = 20,
  }) async {
    Map<String, dynamic>? parsed;
    await multiGetAPINew(
      methodName: 'api/foods/all',
      query: {
        'search': searchTerm,
        'page': page.toString(),
        'limit': limit.toString(),
      },
      callback: (resp) async {
        try {
          if (resp.isError == true) {
            debugPrint('FoodService searchFoods error: ${resp.response}');
            parsed = null;
            return;
          }
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('FoodService searchFoods parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }
}


import 'dart:convert';
import 'package:calorie_ai_app/utils/network.dart';
import 'package:flutter/foundation.dart';
import '../network/http_helper.dart' hide multiPostAPINew;

class FoodService {
  const FoodService();

  // Helper function to parse measurement string into object
  // Examples: "3 pcs" -> {value: 3, unit: "pcs"}, "1tbsp" -> {value: 1, unit: "tbsp"}, "100" -> {value: 100, unit: ""}
  Map<String, dynamic>? _parseMeasurement(String? measurement) {
    if (measurement == null || measurement.isEmpty) {
      debugPrint('🔍 _parseMeasurement: measurement is null or empty');
      return null;
    }
    
    final trimmed = measurement.trim();
    if (trimmed.isEmpty) {
      debugPrint('🔍 _parseMeasurement: trimmed is empty');
      return null;
    }
    
    debugPrint('🔍 _parseMeasurement: Input: "$trimmed"');
    
    // Try to match: number (with optional decimal) followed by optional whitespace and unit
    // Examples: "3 pcs", "1tbsp", "100.5 g", "2.5 cups"
    final match = RegExp(r'^(\d+(?:\.\d+)?)\s*(.*)$').firstMatch(trimmed);
    
    if (match != null) {
      final numberStr = match.group(1);
      final unitStr = match.group(2)?.trim() ?? '';
      
      debugPrint('🔍 _parseMeasurement: Matched - numberStr: "$numberStr", unitStr: "$unitStr"');
      
      final value = double.tryParse(numberStr ?? '');
      if (value != null) {
        // Preserve decimal if present, otherwise use int
        final numValue = value == value.toInt() ? value.toInt() : value;
        final result = {
          'value': numValue,
          'unit': unitStr,
        };
        debugPrint('🔍 _parseMeasurement: Result: $result');
        return result;
      }
    }
    
    // If regex didn't match, try parsing the whole string as a number
    final value = double.tryParse(trimmed);
    if (value != null) {
      final numValue = value == value.toInt() ? value.toInt() : value;
      final result = {
        'value': numValue,
        'unit': '',
      };
      debugPrint('🔍 _parseMeasurement: Parsed as number only: $result');
      return result;
    }
    
    // If we can't parse anything, return null (don't send invalid measurement)
    debugPrint('🔍 _parseMeasurement: Could not parse, returning null');
    return null;
  }

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
    String? measurement,
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
    String? loggedAt,
  }) async {
    debugPrint('🌐 FoodService.saveFood: Method called');
    debugPrint('🌐 FoodService.saveFood: Parameters - name: $name, calories: $calories, protein: $protein, carbs: $carbohydrates, fat: $totalFat, servingSize: $servingSize, isCustom: $isCustom, createdBy: $createdBy');
    
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
    // Parse measurement string into object with value and unit
    final parsedMeasurement = _parseMeasurement(measurement);
    debugPrint('🌐 FoodService.saveFood: Original measurement: $measurement');
    debugPrint('🌐 FoodService.saveFood: Parsed measurement: $parsedMeasurement');
    if (parsedMeasurement != null) {
      body['measurement'] = parsedMeasurement;
      debugPrint('🌐 FoodService.saveFood: Added measurement to body: ${body['measurement']}');
    } else {
      debugPrint('🌐 FoodService.saveFood: Parsed measurement is null, not adding to body');
    }
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
    // Add loggedAt date-time in ISO 8601 format (use current date-time if not provided)
    if (loggedAt != null && loggedAt.isNotEmpty) {
      body['loggedAt'] = loggedAt;
    } else {
      // Default to current local date-time in ISO 8601 format (YYYY-MM-DDTHH:mm:ss)
      final now = DateTime.now().toLocal();
      body['loggedAt'] = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    }

    debugPrint('🌐 FoodService.saveFood: Request body: $body');
    debugPrint('🌐 FoodService.saveFood: Making POST request to api/foods...');

    await multiPostAPINew(
      methodName: 'api/foods',
      param: body,
      callback: (resp) async {
        debugPrint('📥 FoodService.saveFood: API callback received');
        debugPrint('📥 FoodService.saveFood: Response code: ${resp.code}');
        debugPrint('📥 FoodService.saveFood: Response isError: ${resp.isError}');
        debugPrint('📥 FoodService.saveFood: Response: ${resp.response}');
        debugPrint('📥 FoodService.saveFood: Response type: ${resp.response.runtimeType}');
        
        try {
          // Try to parse the response regardless of isError flag
          // since 201 Created is a success status for POST requests
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
          debugPrint('✅ FoodService.saveFood: Response parsed successfully');
          debugPrint('✅ FoodService.saveFood: Parsed response: $parsed');
          debugPrint('✅ FoodService.saveFood: Parsed keys: ${parsed?.keys}');
          
          // Check if response has food data (indicates success)
          if (parsed != null && parsed!['food'] == null && parsed!['message'] == null) {
            debugPrint('❌ FoodService.saveFood: Response missing food/message: ${resp.response}');
            parsed = null;
          } else {
            debugPrint('✅ FoodService.saveFood: Response contains food or message');
          }
        } catch (e, stackTrace) {
          debugPrint('❌ FoodService.saveFood: Parse error: $e');
          debugPrint('❌ FoodService.saveFood: Stack trace: $stackTrace');
          debugPrint('❌ FoodService.saveFood: Raw response: ${resp.response}');
          parsed = null;
        }
      },
    );
    
    debugPrint('🏁 FoodService.saveFood: Method completed, returning: $parsed');
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
    String? measurement,
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
    // Parse measurement string into object with value and unit
    final parsedMeasurement = _parseMeasurement(measurement);
    debugPrint('🌐 FoodService.updateFood: Original measurement: $measurement');
    debugPrint('🌐 FoodService.updateFood: Parsed measurement: $parsedMeasurement');
    if (parsedMeasurement != null) {
      body['measurement'] = parsedMeasurement;
      debugPrint('🌐 FoodService.updateFood: Added measurement to body: ${body['measurement']}');
    } else {
      debugPrint('🌐 FoodService.updateFood: Parsed measurement is null, not adding to body');
    }
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

  Future<Map<String, dynamic>?> deleteFood({
    required String foodId,
  }) async {
    Map<String, dynamic>? parsed;

    await deleteAPI(
      methodName: 'api/foods/$foodId',
      param: {},
      callback: (resp) async {
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
          
          // If parsing succeeded but response indicates failure, set to null
          if (parsed != null && parsed!['message'] == null) {
            debugPrint('FoodService delete error: ${resp.response}');
            parsed = null;
          }
        } catch (e) {
          debugPrint('FoodService delete parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }
}


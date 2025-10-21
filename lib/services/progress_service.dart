import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../network/http_helper.dart' show multiGetAPINew;
import '../utils/network.dart' show multiPostAPINew;

class ProgressService extends GetxController {
  // Store daily progress data as reactive
  final Rx<Map<String, dynamic>?> _dailyProgressData = Rx<Map<String, dynamic>?>(null);
  
  // Getter to access stored daily progress data
  Map<String, dynamic>? get dailyProgressData => _dailyProgressData.value;
  
  // Method to update data and trigger UI refresh
  void updateProgressData(Map<String, dynamic>? data) {
    _dailyProgressData.value = data;
    update();
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
  }) async {
    Map<String, dynamic>? parsed;
    await multiGetAPINew(
      methodName: 'api/progress/daily',
      query: {
        'date': dateYYYYMMDD,
      },
      callback: (resp) async {
        print('date: $dateYYYYMMDD');
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
          
          // Store the data in the reactive variable
          _dailyProgressData.value = parsed;
          // Trigger UI update
          update();

          print('dailyProgressData: ${_dailyProgressData.value}');
        } catch (e) {
          debugPrint('ProgressService parse error: $e');
          parsed = null;
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
}





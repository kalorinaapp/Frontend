import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../network/http_helper.dart';
import '../utils/network.dart' show putAPI;

class ExerciseService {
  const ExerciseService();

  Future<Map<String, dynamic>?> estimateFromDescription({
    required String description,
    String intensity = 'medium',
    int durationMinutes = 30,
    bool autolog = true,
  }) async {
    Map<String, dynamic>? parsed;
    await multiPostAPINew(
      methodName: 'api/exercise/ai/estimate',
      param: {
        'description': description,
        'intensity': intensity,
        'durationMinutes': durationMinutes,
        'autolog': autolog,
      },
      callback: (resp) async {
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('ExerciseService parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> logExercise({
    required String type,
    required int durationMinutes,
    required String intensity,
    required String startedAtIso,
    int? caloriesBurned,
  }) async {
    Map<String, dynamic>? parsed;
    await multiPostAPINew(
      methodName: 'api/exercise',
      param: {
        'type': type,
        'durationMinutes': durationMinutes,
        'intensity': intensity,
        'loggedAt': startedAtIso,
        if (caloriesBurned != null) 'caloriesBurned': caloriesBurned,
      },
      callback: (resp) async {
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('ExerciseService logExercise parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> logDirectCalories({
    required int caloriesBurned,
    required String startedAtIso,
  }) async {
    Map<String, dynamic>? parsed;
    await multiPostAPINew(
      methodName: 'api/exercise',
      param: {
        'caloriesBurned': caloriesBurned,
        'loggedAt': startedAtIso,
      },
      callback: (resp) async {
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('ExerciseService logDirectCalories parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }

  Future<Map<String, dynamic>?> updateExercise({
    required String exerciseId,
    required Map<String, dynamic> payload,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{};

    void addField(String key) {
      if (payload.containsKey(key) && payload[key] != null) {
        body[key] = payload[key];
      }
    }

    addField('type');
    addField('durationMinutes');
    addField('intensity');
    addField('notes');
    addField('caloriesBurned');
    addField('loggedAt');

    if (body.isEmpty) {
      return null;
    }

    Map<String, dynamic>? parsed;
    await putAPI(
      methodName: 'api/exercise/$exerciseId',
      param: body,
      callback: (resp) async {
        debugPrint('ExerciseService updateExercise response: ${resp.response}');
        try {
          if (resp.response.isEmpty) {
            parsed = const {};
            return;
          }
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('ExerciseService updateExercise parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }
}



import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../network/http_helper.dart';

class ProgressService {
  const ProgressService();

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
        try {
          parsed = jsonDecode(resp.response) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('ProgressService parse error: $e');
          parsed = null;
        }
      },
    );
    return parsed;
  }
}



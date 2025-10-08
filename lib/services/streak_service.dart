import 'dart:convert';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../network/http_helper.dart';
import '../utils/network.dart' show getAPI, deleteAPI;

class StreakService extends GetxController {

  // Observable streak data - map of date strings to streak data
  final RxMap<String, Map<String, dynamic>> streaksMap = <String, Map<String, dynamic>>{}.obs;
  final RxMap<String, dynamic> streakData = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> streakHistory = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Helper to format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Create a streak for a specific day
  Future<Map<String, dynamic>?> createStreak({
    required String streakType,
    required DateTime date,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final Map<String, dynamic> params = {
        'streakType': streakType,
        'date': _formatDate(date),
      };

      Map<String, dynamic>? result;
      
      await multiPostAPINew(
        methodName: 'api/streaks/',
        param: params,
        callback: (ResponseAPI response) {
          if (response.isError == true) {
            errorMessage.value = response.response;
            return;
          }
          
          try {
            final data = jsonDecode(response.response);
            if (data['success'] == true && data['streak'] != null) {
              result = data['streak'];
              streakData.value = data['streak'];
              // Update local map
              final dateKey = _formatDate(date);
              streaksMap[dateKey] = data['streak'];
            } else {
              errorMessage.value = data['message'] ?? 'Failed to create streak';
            }
          } catch (e) {
            errorMessage.value = 'Failed to parse response: $e';
          }
        },
      );

      isLoading.value = false;
      return result;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to create streak: $e';
      return null;
    }
  }

  // Get streak data for a specific month
  Future<Map<String, dynamic>?> getStreaksForMonth({
    required int year,
    required int month,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final Map<String, dynamic> params = {
        'year': year,
        'month': month,
      };

      Map<String, dynamic>? result;
      
      await multiPostAPINew(
        methodName: 'streaks/month',
        param: params,
        callback: (ResponseAPI response) {
          if (response.isError == true) {
            errorMessage.value = response.response;
            return;
          }
          
          try {
            final data = jsonDecode(response.response);
            result = data;
            streakData.value = data;
          } catch (e) {
            errorMessage.value = 'Failed to parse response: $e';
          }
        },
      );

      isLoading.value = false;
      return result;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to get streaks: $e';
      return null;
    }
  }

  // Update streak status for a specific day
  Future<Map<String, dynamic>?> updateStreak({
    required String streakId,
    required String streakType,
    required DateTime date,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final Map<String, dynamic> params = {
        'streakId': streakId,
        'streakType': streakType,
        'date': _formatDate(date),
      };

      Map<String, dynamic>? result;
      
      await multiPostAPINew(
        methodName: 'streaks/update',
        param: params,
        callback: (ResponseAPI response) {
          if (response.isError == true) {
            errorMessage.value = response.response;
            return;
          }
          
          try {
            final data = jsonDecode(response.response);
            if (data['success'] == true && data['streak'] != null) {
              result = data['streak'];
              streakData.value = data['streak'];
            } else {
              errorMessage.value = data['message'] ?? 'Failed to update streak';
            }
          } catch (e) {
            errorMessage.value = 'Failed to parse response: $e';
          }
        },
      );

      isLoading.value = false;
      return result;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to update streak: $e';
      return null;
    }
  }

  // Delete/undo streak for a specific day
  Future<bool> deleteStreakDate({
    required String streakDateId,
    required DateTime date,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      bool success = false;
      
      await deleteAPI(
        methodName: 'api/streaks/dates/$streakDateId',
        param: {},
        callback: (response) {
          if (response.isError == true) {
            errorMessage.value = response.response;
            return null;
          }
          
          try {
            final data = jsonDecode(response.response);
            success = data['success'] == true;
            if (success) {
              // Remove from local map
              final dateKey = _formatDate(date);
              streaksMap.remove(dateKey);
            } else {
              errorMessage.value = data['message'] ?? 'Failed to delete streak';
            }
          } catch (e) {
            errorMessage.value = 'Failed to parse response: $e';
          }
          return null;
        },
      );

      isLoading.value = false;
      return success;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to delete streak: $e';
      return false;
    }
  }

  // Get streaks for a date range (month view)
  Future<List<Map<String, dynamic>>?> getStreaksForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final String startDateStr = _formatDate(startDate);
      final String endDateStr = _formatDate(endDate);

      List<Map<String, dynamic>>? result;
      
      await getAPI(
        methodName: 'api/streaks/date-range?startDate=$startDateStr&endDate=$endDateStr',
        callback: (response) {
          if (response.isError == true) {
            errorMessage.value = response.response;
            return null;
          }
          
          try {
            final data = jsonDecode(response.response);
            if (data['success'] == true && data['streaks'] != null) {
              result = List<Map<String, dynamic>>.from(data['streaks']);
              
              // Update local map with all streaks
              streaksMap.clear();
              for (var streak in result!) {
                if (streak['date'] != null) {
                  final dateKey = streak['date'] as String;
                  streaksMap[dateKey] = streak;
                }
              }
            } else {
              errorMessage.value = data['message'] ?? 'Failed to get streaks';
            }
          } catch (e) {
            errorMessage.value = 'Failed to parse response: $e';
          }
          return null;
        },
      );

      isLoading.value = false;
      return result;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to get streaks for date range: $e';
      return null;
    }
  }

  // Get streak type for a specific date from local map
  String? getStreakType(DateTime date) {
    final dateKey = _formatDate(date);
    return streaksMap[dateKey]?['streakType'];
  }

  // Get streak ID for a specific date from local map
  String? getStreakId(DateTime date) {
    final dateKey = _formatDate(date);
    return streaksMap[dateKey]?['id'];
  }

  // Check if a date has a streak entry
  bool hasStreakEntry(DateTime date) {
    final dateKey = _formatDate(date);
    return streaksMap.containsKey(dateKey);
  }

  // Get streak history (current streak, highest streak, etc.)
  Future<Map<String, dynamic>?> getStreakHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      Map<String, dynamic>? result;
      
      await getAPI(
        methodName: 'api/streaks/history/${AppConstants.userId}',
        callback: (response) {
          if (response.isError == true) {
            errorMessage.value = response.response;
            return null;
          }
          
          try {
            final data = jsonDecode(response.response);
            if (data['success'] == true && data['history'] != null) {
              result = data['history'];
              streakHistory.value = data['history'];
            } else {
              errorMessage.value = data['message'] ?? 'Failed to get streak history';
            }
          } catch (e) {
            errorMessage.value = 'Failed to parse response: $e';
          }
          return null;
        },
      );

      isLoading.value = false;
      return result;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to get streak history: $e';
      return null;
    }
  }

  // Get current streak count
  int getCurrentStreak() {
    return streakHistory['streak']?['currentStreak'] ?? 0;
  }

  // Get highest streak count
  int getHighestStreak() {
    return streakHistory['streak']?['highestStreak'] ?? 0;
  }
}

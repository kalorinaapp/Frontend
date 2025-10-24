import 'dart:convert';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../network/http_helper.dart';
import '../utils/network.dart' show deleteAPI, getAPI, putAPI;

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
      
      await putAPI(
        methodName: 'api/streaks/$streakId',
        param: params,
        callback: (response) {
          if (response.isError == true) {
            errorMessage.value = response.response;
            return;
          }
          
          try {
            final data = jsonDecode(response.response);
            if (data['success'] == true && data['streak'] != null) {
              result = data['streak'];
              streakData.value = data['streak'];
              // Update local map for this date
              final dateKey = _formatDate(date);
              streaksMap[dateKey] = data['streak'];
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

  // Create or update streak for a specific day depending on existing entry
  Future<Map<String, dynamic>?> upsertStreak({
    required String streakType,
    required DateTime date,
  }) async {
    final existingStreakId = getStreakId(date);
    print("Existing Streak Id $existingStreakId");
    if (existingStreakId != null && existingStreakId.isNotEmpty) {
      return await updateStreak(
        streakId: existingStreakId,
        streakType: streakType,
        date: date,
      );
    }
    
    // Create new streak if no existing one
    final created = await createStreak(
      streakType: streakType,
      date: date,
    );

    // If backend indicates it already exists, try update as a fallback
    if (created == null && errorMessage.value.toLowerCase().contains('already')) {
      final fallbackId = getStreakId(date);
      if (fallbackId != null && fallbackId.isNotEmpty) {
        return await updateStreak(
          streakId: fallbackId,
          streakType: streakType,
          date: date,
        );
      }
    }

    return created;
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
        methodName: 'api/streaks/date-range?startDate=$startDateStr&endDate=$endDateStr&currentDate=${DateTime.now().toLocal().toIso8601String()}',
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
        methodName: 'api/streaks/history/${AppConstants.userId}?currentDate=${DateTime.now().toLocal().toIso8601String()}',
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
              // Merge any available logged dates from history into streaksMap
              try {
                final raw = data['history'];
                // Primary shape: { history: [ { _id, date, streakType, ... }, ... ] }
                if (raw is Map<String, dynamic> && raw['history'] is List) {
                  _mergeHistoryListIntoMap(List<dynamic>.from(raw['history'] as List));
                } else if (raw is List) {
                  _mergeHistoryListIntoMap(raw);
                } else if (raw is Map<String, dynamic>) {
                  _mergeHistoryDatesIntoMap(raw);
                }
              } catch (_) {}
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

  // Merge dates from streak history payload into local streaksMap
  // Supports multiple shapes:
  // 1) { dates: ["YYYY-MM-DD", ...] }  -> defaults to Successful
  // 2) { successfulDates: [...], failedDates: [...] }
  // 3) { dates: [{ date: "YYYY-MM-DD", streakType: "Successful"|"Failed" }, ...] }
  void _mergeHistoryDatesIntoMap(Map<String, dynamic> history) {
    void upsertEntry(String dateKey, String? streakType, {String? id}) {
      final existing = streaksMap[dateKey] ?? <String, dynamic>{};
      streaksMap[dateKey] = {
        ...existing,
        'date': dateKey,
        if (streakType != null) 'streakType': streakType,
        if (id != null && id.isNotEmpty) 'id': id,
      };
    }

    String? normalizeType(dynamic raw) {
      if (raw is! String) return null;
      final s = raw.toLowerCase().trim();
      if (s.startsWith('succ')) return 'Successful';
      if (s.startsWith('pass')) return 'Successful';
      if (s.startsWith('win')) return 'Successful';
      if (s.startsWith('fail')) return 'Failed';
      if (s.startsWith('miss')) return 'Failed';
      if (s.startsWith('lose')) return 'Failed';
      return null;
    }

    // Case 2: explicit successful/failed arrays
    final successList = history['successfulDates'] ?? history['successDates'];
    final failedList = history['failedDates'] ?? history['failDates'];
    if (successList is List) {
      for (final d in successList) {
        if (d is String && d.isNotEmpty) {
          upsertEntry(d, 'Successful');
        }
        if (d is Map && d['date'] is String) {
          final t = normalizeType(d['streakType']) ?? 'Successful';
          final id = (d['_id'] ?? d['id'] ?? d['streakId'] ?? d['streakDateId']) as String?;
          upsertEntry(d['date'] as String, t, id: id);
        }
      }
    }
    if (failedList is List) {
      for (final d in failedList) {
        if (d is String && d.isNotEmpty) {
          upsertEntry(d, 'Failed');
        }
        if (d is Map && d['date'] is String) {
          final t = normalizeType(d['streakType']) ?? 'Failed';
          final id = (d['_id'] ?? d['id'] ?? d['streakId'] ?? d['streakDateId']) as String?;
          upsertEntry(d['date'] as String, t, id: id);
        }
      }
    }

    // Case 1/3: generic dates array
    final dates = history['dates'];
    if (dates is List) {
      for (final item in dates) {
        if (item is String && item.isNotEmpty) {
          // Do not assume type when only a date string is provided
          // Leave as-is; date-range API or per-day fetch will enrich later
          continue;
        } else if (item is Map) {
          final dateKey = item['date'];
          if (dateKey is String && dateKey.isNotEmpty) {
            final explicitType = normalizeType(item['streakType']) ?? normalizeType(item['status']) ?? normalizeType(item['type']);
            final id = (item['_id'] ?? item['id'] ?? item['streakId'] ?? item['streakDateId']) as String?;
            upsertEntry(dateKey, explicitType, id: id);
          }
        }
      }
    }

    // Generic catch-all: scan any list fields for objects with a date
    for (final entry in history.entries) {
      final value = entry.value;
      if (value is List) {
        for (final v in value) {
          if (v is Map) {
            final dateKey = v['date'];
            if (dateKey is String && dateKey.isNotEmpty) {
              final t = normalizeType(v['streakType']) ?? normalizeType(v['status']) ?? normalizeType(v['type']);
              final id = (v['_id'] ?? v['id'] ?? v['streakId'] ?? v['streakDateId']) as String?;
              upsertEntry(dateKey, t, id: id);
            }
          }
        }
      }
    }
  }

  // Merge when history is a List of objects with { _id|id, date, streakType|status|type }
  void _mergeHistoryListIntoMap(List<dynamic> historyList) {
    String? normalizeType(dynamic raw) {
      if (raw is! String) return null;
      final s = raw.toLowerCase().trim();
      if (s.startsWith('succ')) return 'Successful';
      if (s.startsWith('pass')) return 'Successful';
      if (s.startsWith('win')) return 'Successful';
      if (s.startsWith('fail')) return 'Failed';
      if (s.startsWith('miss')) return 'Failed';
      if (s.startsWith('lose')) return 'Failed';
      return null;
    }

    for (final item in historyList) {
      if (item is Map) {
        final dateKey = item['date'];
        if (dateKey is String && dateKey.isNotEmpty) {
          final streakType = normalizeType(item['streakType']) ?? normalizeType(item['status']) ?? normalizeType(item['type']);
          final id = (item['_id'] ?? item['id'] ?? item['streakId'] ?? item['streakDateId']) as String?;
          final existing = streaksMap[dateKey] ?? <String, dynamic>{};
          streaksMap[dateKey] = {
            ...existing,
            'date': dateKey,
            if (streakType != null) 'streakType': streakType,
            if (id != null && id.isNotEmpty) 'id': id,
          };
          
        }
      }
    }

    print("Streaks Map ${streaksMap}");
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

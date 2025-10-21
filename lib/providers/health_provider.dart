import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/user.prefs.dart' show UserPrefs;
import '../services/progress_service.dart' show ProgressService;

class HealthProvider extends ChangeNotifier {
  final Health _health = Health();
  
  int _stepsToday = 0;
  int _stepsGoal = 10000;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasPermissions = false;
  Timer? _autoTimer;
  final ProgressService _progress =  ProgressService();

  int get stepsToday => _stepsToday;
  int get stepsGoal => _stepsGoal;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasPermissions => _hasPermissions;

  // Platform-specific health data types
  final List<HealthDataType> _dataTypes = Platform.isAndroid
      ? <HealthDataType>[HealthDataType.STEPS]
      : <HealthDataType>[HealthDataType.STEPS];

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Optimistic: respect cached grant to avoid flashing CTA
      final bool cachedGranted = await UserPrefs.getHealthPermissionsGranted();
      if (cachedGranted) {
        _hasPermissions = true;
        notifyListeners();
      }

      // Configure health
      _health.configure();
      
      // Check permissions
      await _checkPermissions();
      // Persist the real state from OS
      await UserPrefs.setHealthPermissionsGranted(_hasPermissions);
      
      // Fetch today's steps if we have permissions
      if (_hasPermissions) {
        await _fetchTodaysSteps();
        _startAutoRefresh();
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize health: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      // Request runtime permissions for Android
      if (Platform.isAndroid) {
        await Permission.activityRecognition.request();
      }

      // Check health permissions
      final hasPermissions = await _health.hasPermissions(_dataTypes);
      _hasPermissions = hasPermissions ?? false;
    } catch (e) {
      _errorMessage = 'Failed to check permissions: $e';
      _hasPermissions = false;
    }
  }

  Future<void> requestPermissions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Request runtime permissions for Android
      if (Platform.isAndroid) {
        await Permission.activityRecognition.request();
      }

      // Request health permissions
      final authorized = await _health.requestAuthorization(_dataTypes);
      _hasPermissions = authorized;
      await UserPrefs.setHealthPermissionsGranted(_hasPermissions);

      if (_hasPermissions) {
        await _fetchTodaysSteps();
      }
    } catch (e) {
      _errorMessage = 'Failed to request permissions: $e';
      _hasPermissions = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchTodaysSteps() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final steps = await _health.getHealthDataFromTypes(
        types: _dataTypes,
        startTime: startOfDay,
        endTime: now,
      );

      // Sum up all steps from today
      int totalSteps = 0;
      for (final dataPoint in steps) {
        if (dataPoint.type == HealthDataType.STEPS) {
          totalSteps += (dataPoint.value as NumericHealthValue).numericValue.toInt();
        }
      }

      _stepsToday = totalSteps;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch steps: $e';
      _stepsToday = 0;
    }
  }

  Future<void> refreshSteps() async {
    if (_hasPermissions) {
      await _fetchTodaysSteps();
      notifyListeners();
    }
  }

  void _startAutoRefresh({Duration interval = const Duration(minutes: 30)}) {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(interval, (_) async {
      await refreshSteps();
      await _maybeSyncSteps();
    });
  }

  int estimateCaloriesFromSteps({
    required int steps,
    required double heightCm,
    required double weightKg,
    String gender = 'male',
  }) {
    if (steps <= 0 || heightCm <= 0 || weightKg <= 0) return 0;
    final double heightM = heightCm / 100.0;
    final double strideMeters = heightM * ((gender.toLowerCase() == 'female') ? 0.413 : 0.415);
    final double distanceKm = (steps * strideMeters) / 1000.0;
    // Approx kcal per km walking ≈ 0.53 * body weight (kg)
    final double kcal = weightKg * distanceKm * 0.53;
    if (kcal.isNaN || !kcal.isFinite || kcal < 0) return 0;
    return kcal.round();
  }

  Future<void> _maybeSyncSteps() async {
    try {
      final now = DateTime.now();
      final String dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final (String?, int?) cached = await UserPrefs.getLastSyncedSteps();
      final String? lastDate = cached.$1;
      final int? lastSteps = cached.$2;

      // Calculate steps difference
      int stepsToSend = 0;
      
      if (lastDate != dateStr) {
        // New day - send all current steps
        stepsToSend = _stepsToday;
      } else if (lastSteps != null && _stepsToday > lastSteps) {
        // Same day - send only the difference
        stepsToSend = _stepsToday - lastSteps;
      } else {
        // No new steps to sync
        return;
      }

      // Only send if there are steps to sync
      if (stepsToSend <= 0) {
        return;
      }

      final res = await _progress.logDailySteps(steps: stepsToSend, dateYYYYMMDD: dateStr);
      if (res != null && res['success'] == true) {
        await UserPrefs.setLastSyncedSteps(dateYYYYMMDD: dateStr, steps: _stepsToday);
        debugPrint('Steps synced: $stepsToSend (total: $_stepsToday)');
      }
    } catch (_) {}
  }

  void setStepsGoal(int goal) {
    _stepsGoal = goal;
    notifyListeners();
  }
}

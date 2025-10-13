import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthProvider extends ChangeNotifier {
  final Health _health = Health();
  
  int _stepsToday = 0;
  int _stepsGoal = 10000;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasPermissions = false;

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
    super.dispose();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Configure health
      _health.configure();
      
      // Check permissions
      await _checkPermissions();
      
      // Fetch today's steps if we have permissions
      if (_hasPermissions) {
        await _fetchTodaysSteps();
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

  void setStepsGoal(int goal) {
    _stepsGoal = goal;
    notifyListeners();
  }
}

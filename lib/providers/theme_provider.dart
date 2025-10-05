import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme_helper.dart';

enum ThemeMode { light, dark, automatic }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLightMode = true;

  ThemeMode get themeMode => _themeMode;
  bool get isLightMode => _isLightMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      _themeMode = ThemeMode.values[themeIndex];
      _updateTheme();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  void _updateTheme() {
    switch (_themeMode) {
      case ThemeMode.light:
        _isLightMode = true;
        break;
      case ThemeMode.dark:
        _isLightMode = false;
        break;
      case ThemeMode.automatic:
        // Get system brightness
        final brightness = PlatformDispatcher.instance.platformBrightness;
        _isLightMode = brightness == Brightness.light;
        break;
    }
    ThemeHelper.setLightMode(_isLightMode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
      _themeMode = mode;
      _updateTheme();
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  // Legacy methods for backward compatibility
  void setLightTheme() => setThemeMode(ThemeMode.light);
  void setDarkTheme() => setThemeMode(ThemeMode.dark);
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}

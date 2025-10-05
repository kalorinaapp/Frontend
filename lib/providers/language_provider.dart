import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('hr'); // Default to Croatian
  
  Locale get currentLocale => _currentLocale;
  
  // Available languages with their display names
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hr': 'Hrvatski',
    'es': 'Español',
    'de': 'Deutsch',
    'fr': 'Français',
    'it': 'Italiano',
  };
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  // Public method for awaitable initialization
  Future<void> initialize() async {
    await _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'hr';
      
      debugPrint('🌍 Loading saved language: $languageCode');
      
      // Map unsupported language codes to supported ones
      String mappedCode = languageCode;
      switch (languageCode) {
        case 'cg': // Montenegrin -> Serbian
          mappedCode = 'sr';
          break;
        case 'mk': // Macedonian -> Bulgarian  
          mappedCode = 'bg';
          break;
        default:
          mappedCode = languageCode;
      }
      
      debugPrint('🌍 Mapped language code: $mappedCode');
      
      _currentLocale = Locale(mappedCode);
      
      // Update GetX locale as well
      Get.updateLocale(_currentLocale);
      
      notifyListeners();
      debugPrint('🌍 Language loaded successfully: ${_currentLocale.languageCode}');
    } catch (e) {
      debugPrint('❌ Error loading language preference: $e');
    }
  }
  
  Future<void> changeLanguage(String languageCode) async {
    try {
      debugPrint('🌍 Changing language to: $languageCode');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      debugPrint('🌍 Saved language to SharedPreferences: $languageCode');
      
      // Map unsupported language codes to supported ones
      String mappedCode = languageCode;
      switch (languageCode) {
        case 'cg': // Montenegrin -> Serbian
          mappedCode = 'sr';
          break;
        case 'mk': // Macedonian -> Bulgarian  
          mappedCode = 'bg';
          break;
        default:
          mappedCode = languageCode;
      }
      
      debugPrint('🌍 Mapped to locale: $mappedCode');
      
      _currentLocale = Locale(mappedCode);
      
      // Update GetX locale as well to ensure immediate UI updates
      Get.updateLocale(_currentLocale);
      
      notifyListeners();
      
      debugPrint('🌍 Language change complete: ${_currentLocale.languageCode}');
    } catch (e) {
      debugPrint('❌ Error saving language preference: $e');
    }
  }
  
  String getCurrentLanguageName() {
    return supportedLanguages[_currentLocale.languageCode] ?? 'Hrvatski';
  }
}

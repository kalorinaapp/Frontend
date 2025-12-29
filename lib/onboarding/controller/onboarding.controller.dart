import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../utils/user.prefs.dart' show UserPrefs;

enum ValidationType {
  multipleChoice,
  singleChoice,
  textInput,
  dateInput,
  numberInput,
}

class PageValidationConfig {
  final String dataKey;
  final ValidationType validationType;
  final int? minSelections;
  final int? maxSelections;
  final bool? requiresInput;

  PageValidationConfig({
    required this.dataKey,
    required this.validationType,
    this.minSelections,
    this.maxSelections,
    this.requiresInput,
  });
}

class OnboardingController extends GetxController {
  // Current page tracking
  final RxInt currentPage = 0.obs;
  final RxBool isNextButtonEnabled = true.obs;
  final RxBool showNavigation = true.obs;
  final RxInt totalPages = 1.obs;
  
  // Dual button mode for Yes/No pages
  final RxBool isDualButtonMode = false.obs;
  final RxString dualButtonChoice = ''.obs;
  
  // Track if user has completed registration
  final RxBool isRegistrationComplete = false.obs;

  // Data storage for different page types
  final RxMap<String, dynamic> _pageData = <String, dynamic>{}.obs;
  final RxMap<String, bool> _pageValidation = <String, bool>{}.obs;

  // Page validation configuration
  final Map<int, PageValidationConfig> _pageValidationConfigs = {};

  // Define page colors using design gradients
  final List<Color> pageColors = [
    const Color(0xFF74A9DA), // Blue
    const Color(0xFF8C4CA2), // Purple
    const Color(0xFFFF6A00), // Orange
    const Color(0xFFEE0979), // Pink
  ];

  @override
  void onInit() {
    super.onInit();
    developer.log('OnboardingController initialized', name: 'OnboardingController');
    _initializePageValidation();
    
    // Load saved onboarding data
    _loadOnboardingData();

    // Listen to current page changes to update next button state
    currentPage.listen((page) {
      developer.log('Page changed to: $page', name: 'OnboardingController');
      _updateNextButtonState();
    });
    
    // Listen to page data changes to save progress
    _pageData.listen((_) {
      _saveOnboardingData();
    });
  }
  
  Future<void> _loadOnboardingData() async {
    try {
      final savedData = await UserPrefs.getOnboardingData();
      if (savedData.isNotEmpty) {
        developer.log('Loading saved onboarding data: ${savedData.keys.length} entries', name: 'OnboardingController');
        _pageData.addAll(savedData);
        // Re-validate all pages after loading data (only if configs are registered)
        _pageValidationConfigs.keys.forEach((pageIndex) {
          final config = _pageValidationConfigs[pageIndex];
          if (config != null) {
            final isValid = _validatePageData(config);
            _pageValidation[pageIndex.toString()] = isValid;
          }
        });
        _updateNextButtonState();
        developer.log('✅ Onboarding data loaded successfully', name: 'OnboardingController');
      }
    } catch (e) {
      developer.log('⚠️ Error loading onboarding data: $e', name: 'OnboardingController');
    }
  }
  
  Future<void> _saveOnboardingData() async {
    try {
      final dataToSave = Map<String, dynamic>.from(_pageData);
      // Convert DateTime objects to ISO strings for JSON serialization
      final Map<String, dynamic> serializableData = {};
      for (final entry in dataToSave.entries) {
        if (entry.value is DateTime) {
          serializableData[entry.key] = (entry.value as DateTime).toIso8601String();
        } else {
          serializableData[entry.key] = entry.value;
        }
      }
      await UserPrefs.setOnboardingData(serializableData);
      developer.log('💾 Saved onboarding data: ${serializableData.keys.length} entries', name: 'OnboardingController');
    } catch (e) {
      developer.log('⚠️ Error saving onboarding data: $e', name: 'OnboardingController');
    }
  }

  // Initialize validation state for all pages
  void _initializePageValidation() {
    developer.log('Initializing page validation for ${_pageValidationConfigs.keys.length} pages', name: 'OnboardingController');
    for (int pageIndex in _pageValidationConfigs.keys) {
      _pageValidation[pageIndex.toString()] = false;
      developer.log('Page $pageIndex validation initialized to false', name: 'OnboardingController');
    }
  }

  // Register a page for validation
  Future<void> registerPageValidation(
    int pageIndex,
    PageValidationConfig config,
  ) async {
    developer.log('Registering page validation for page $pageIndex with type: ${config.validationType}', name: 'OnboardingController');
    _pageValidationConfigs[pageIndex] = config;
    // If data already exists (from saved progress), validate it now
    final isValid = _validatePageData(config);
    _pageValidation[pageIndex.toString()] = isValid;
    _updateNextButtonState();
  }

  // Update next button state based on current page validation
  void _updateNextButtonState() {
    if (isDualButtonMode.value) {
      // For dual button mode, we don't need the next button enabled state
      // as we'll show Yes/No buttons instead
      developer.log('Skipping next button state update - dual button mode active', name: 'OnboardingController');
      return;
    }
    
    final currentPageKey = currentPage.value.toString();

    if (_pageValidationConfigs.containsKey(currentPage.value)) {
      final isValid = _pageValidation[currentPageKey] ?? false;
      isNextButtonEnabled.value = isValid;
      developer.log('Next button enabled: $isValid for page ${currentPage.value}', name: 'OnboardingController');
    } else {
      isNextButtonEnabled.value = true;
      developer.log('Next button enabled: true (no validation required) for page ${currentPage.value}', name: 'OnboardingController');
    }
  }

  // Generic method to set data for any page
  void setPageData<T>(String key, T value, {bool validateOnSet = true}) {
    developer.log('Setting page data: $key = $value', name: 'OnboardingController');
    _pageData[key] = value;

    if (validateOnSet) {
      _validateCurrentPage();
    }
  }

  // Generic method to get data for any page
  T? getPageData<T>(String key) {
    return _pageData[key] as T?;
  }

  // Specific setters for different data types

  // For string inputs (destinations, names, etc.)
  void setStringData(String key, String value) {
    setPageData(key, value);
  }

  String? getStringData(String key) {
    return getPageData<String>(key);
  }

  // For integer inputs (duration, budget, etc.)
  void setIntData(String key, int value) {
    setPageData(key, value);
  }

  int? getIntData(String key) {
    return getPageData<int>(key);
  }

  // For boolean inputs (preferences, toggles, etc.)
  void setBoolData(String key, bool value) {
    setPageData(key, value);
  }

  bool? getBoolData(String key) {
    return getPageData<bool>(key);
  }

  // For list of integers (multiple selections)
  void setListIntData(String key, List<int> value) {
    setPageData(key, value);
  }

  List<int>? getListIntData(String key) {
    return getPageData<List<int>>(key);
  }

  // For DateTime inputs (birthday, travel dates, etc.)
  void setDateTimeData(String key, DateTime value) {
    setPageData(key, value);
  }

  DateTime? getDateTimeData(String key) {
    return getPageData<DateTime>(key);
  }

  // For double inputs (precise budget, ratings, etc.)
  void setDoubleData(String key, double value) {
    setPageData(key, value);
  }

  double? getDoubleData(String key) {
    return getPageData<double>(key);
  }

  // For list of strings (multiple text selections)
  void setListStringData(String key, List<String> value) {
    setPageData(key, value);
  }

  List<String>? getListStringData(String key) {
    return getPageData<List<String>>(key);
  }

  // Toggle methods for list selections
  void toggleIntInList(String key, int value) {
    List<int> currentList = getListIntData(key) ?? <int>[];

    if (currentList.contains(value)) {
      currentList.remove(value);
    } else {
      currentList.add(value);
    }

    setListIntData(key, currentList);
  }

  void toggleStringInList(String key, String value) {
    List<String> currentList = getListStringData(key) ?? <String>[];

    if (currentList.contains(value)) {
      currentList.remove(value);
    } else {
      currentList.add(value);
    }

    setListStringData(key, currentList);
  }

  // Page-specific validation methods
  void _validateCurrentPage() {
    final pageKey = currentPage.value.toString();
    bool isValid = false;

    final config = _pageValidationConfigs[currentPage.value];
    if (config != null) {
      isValid = _validatePageData(config);
      developer.log('Validating page ${currentPage.value}: $isValid (type: ${config.validationType})', name: 'OnboardingController');
    } else {
      isValid = true;
      developer.log('Page ${currentPage.value} has no validation requirements - marking as valid', name: 'OnboardingController');
    }

    _pageValidation[pageKey] = isValid;
    _updateNextButtonState();
  }

  // Generic validation method based on configuration
  bool _validatePageData(PageValidationConfig config) {
    switch (config.validationType) {
      case ValidationType.multipleChoice:
        final data = getPageData(config.dataKey);
        final minSelections = config.minSelections ?? 1;
        if (data is List && data.length >= minSelections) {
          developer.log('Multiple choice validation passed: ${data.length} selections (min: $minSelections)', name: 'OnboardingController');
          return true;
        }
        developer.log('Multiple choice validation failed: ${data is List ? data.length : 0} selections (min: $minSelections)', name: 'OnboardingController');
        return false;
      case ValidationType.singleChoice:
        final selection = getStringData(config.dataKey);
        final isValid = selection != null && selection.isNotEmpty;
        developer.log('Single choice validation: $isValid (value: $selection)', name: 'OnboardingController');
        return isValid;

      case ValidationType.textInput:
        final text = getStringData(config.dataKey);
        final isValid = text != null && text.trim().isNotEmpty;
        developer.log('Text input validation: $isValid (length: ${text?.length ?? 0})', name: 'OnboardingController');
        return isValid;

      case ValidationType.dateInput:
        final date = getDateTimeData(config.dataKey);
        final isValid = date != null;
        developer.log('Date input validation: $isValid (date: $date)', name: 'OnboardingController');
        return isValid;

      case ValidationType.numberInput:
        final number = getIntData(config.dataKey);
        final isValid = number != null && number > 0;
        developer.log('Number input validation: $isValid (value: $number)', name: 'OnboardingController');
        return isValid;
    }
  }

  // Navigation methods
  void goToNextPage() {
    if (isNextButtonEnabled.value) {
      developer.log('Navigating to next page: ${currentPage.value} -> ${currentPage.value + 1}', name: 'OnboardingController');
      currentPage.value++;
    } else {
      developer.log('Cannot navigate to next page - validation failed for page ${currentPage.value}', name: 'OnboardingController');
    }
  }

  void goToPreviousPage() {
    if (currentPage.value > 0) {
      developer.log('Navigating to previous page: ${currentPage.value} -> ${currentPage.value - 1}', name: 'OnboardingController');
      currentPage.value--;
    } else {
      developer.log('Cannot navigate to previous page - already at first page', name: 'OnboardingController');
    }
  }

  void goToPage(int pageIndex) {
    developer.log('Navigating directly to page: ${currentPage.value} -> $pageIndex', name: 'OnboardingController');
    currentPage.value = pageIndex;
  }

  void setTotalPages(int total) {
    developer.log('Setting total pages to: $total', name: 'OnboardingController');
    totalPages.value = total;
  }

  // Utility methods
  bool isPageValid(int pageIndex) {
    return _pageValidation[pageIndex.toString()] ?? true;
  }

  void setPageRequiresInput(int pageIndex, bool requiresInput) {
    if (requiresInput) {
      // Note: This method is now deprecated. Use registerPageValidation instead.
    } else {
      _pageValidationConfigs.remove(pageIndex);
    }
    _initializePageValidation();
  }

  // Get all collected data
  Map<String, dynamic> getAllData() {
    developer.log('Retrieving all onboarding data: ${_pageData.keys.length} entries', name: 'OnboardingController');
    return Map<String, dynamic>.from(_pageData);
  }

  // Clear all data
  void clearAllData() async {
    developer.log('Clearing all onboarding data', name: 'OnboardingController');
    _pageData.clear();
    _pageValidation.clear();
    _initializePageValidation();
    // Also clear from persistent storage
    await UserPrefs.clearOnboardingProgress();
  }

  // Reset to specific page
  void resetToPage(int pageIndex) {
    developer.log('Resetting to page: $pageIndex', name: 'OnboardingController');
    currentPage.value = pageIndex;
    _updateNextButtonState();
  }

  // Check if onboarding is complete
  bool get isOnboardingComplete {
    final isComplete = _pageValidationConfigs.keys.every(
      (pageIndex) => _pageValidation[pageIndex.toString()] ?? false,
    );
    developer.log('Onboarding completion check: $isComplete', name: 'OnboardingController');
    return isComplete;
  }

  // Force validation of current page (useful for manual validation triggers)
  void validateCurrentPage() {
    developer.log('Manually triggering validation for current page: ${currentPage.value}', name: 'OnboardingController');
    _validateCurrentPage();
  }

  // Force validation of specific page
  void validatePage(int pageIndex) {
    developer.log('Manually triggering validation for page: $pageIndex', name: 'OnboardingController');
    final currentPageTemp = currentPage.value;
    currentPage.value = pageIndex;
    _validateCurrentPage();
    currentPage.value = currentPageTemp;
  }

  // Progress and UI methods
  double get progressPercentage {
    return (currentPage.value + 1) / totalPages.value;
  }

  bool get isLastPage {
    return currentPage.value == totalPages.value - 1;
  }

  Color get currentPageColor {
    if (currentPage.value < pageColors.length) {
      return pageColors[currentPage.value];
    }
    return const Color(0xFF74A9DA); // Default blue color
  }

  void setNavigationVisibility(bool show) {
    developer.log('Setting navigation visibility: $show', name: 'OnboardingController');
    showNavigation.value = show;
  }

  // Dual button mode methods
  void setDualButtonMode(bool enabled) {
    developer.log('Setting dual button mode: $enabled', name: 'OnboardingController');
    isDualButtonMode.value = enabled;
    if (!enabled) {
      dualButtonChoice.value = '';
    }
  }

  void setDualButtonChoice(String choice) {
    developer.log('Setting dual button choice: $choice', name: 'OnboardingController');
    dualButtonChoice.value = choice;
    // Auto-validate when a choice is made
    _validateCurrentPage();
  }

  bool get hasDualButtonChoice {
    return dualButtonChoice.value.isNotEmpty;
  }

}

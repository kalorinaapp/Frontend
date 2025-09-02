import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

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
    _initializePageValidation();

    // Listen to current page changes to update next button state
    currentPage.listen((page) {
      _updateNextButtonState();
    });
  }

  // Initialize validation state for all pages
  void _initializePageValidation() {
    for (int pageIndex in _pageValidationConfigs.keys) {
      _pageValidation[pageIndex.toString()] = false;
    }
  }

  // Register a page for validation
  Future<void> registerPageValidation(
    int pageIndex,
    PageValidationConfig config,
  ) async {
    _pageValidationConfigs[pageIndex] = config;
    _pageValidation[pageIndex.toString()] = false;
    _updateNextButtonState();
  }

  // Update next button state based on current page validation
  void _updateNextButtonState() {
    final currentPageKey = currentPage.value.toString();

    if (_pageValidationConfigs.containsKey(currentPage.value)) {
      isNextButtonEnabled.value = _pageValidation[currentPageKey] ?? false;
    } else {
      isNextButtonEnabled.value = true;
    }
  }

  // Generic method to set data for any page
  void setPageData<T>(String key, T value, {bool validateOnSet = true}) {
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
    } else {
      isValid = true;
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
          return true;
        }
        return false;
      case ValidationType.singleChoice:
        final selection = getStringData(config.dataKey);
        return selection != null && selection.isNotEmpty;

      case ValidationType.textInput:
        final text = getStringData(config.dataKey);
        return text != null && text.trim().isNotEmpty;

      case ValidationType.dateInput:
        final date = getDateTimeData(config.dataKey);
        return date != null;

      case ValidationType.numberInput:
        final number = getIntData(config.dataKey);
        return number != null && number > 0;
    }
  }

  // Navigation methods
  void goToNextPage() {
    if (isNextButtonEnabled.value) {
      currentPage.value++;
    }
  }

  void goToPreviousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  void goToPage(int pageIndex) {
    currentPage.value = pageIndex;
  }

  void setTotalPages(int total) {
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
    return Map<String, dynamic>.from(_pageData);
  }

  // Clear all data
  void clearAllData() {
    _pageData.clear();
    _pageValidation.clear();
    _initializePageValidation();
  }

  // Reset to specific page
  void resetToPage(int pageIndex) {
    currentPage.value = pageIndex;
    _updateNextButtonState();
  }

  // Check if onboarding is complete
  bool get isOnboardingComplete {
    return _pageValidationConfigs.keys.every(
      (pageIndex) => _pageValidation[pageIndex.toString()] ?? false,
    );
  }

  // Force validation of current page (useful for manual validation triggers)
  void validateCurrentPage() {
    _validateCurrentPage();
  }

  // Force validation of specific page
  void validatePage(int pageIndex) {
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
    showNavigation.value = show;
  }
}

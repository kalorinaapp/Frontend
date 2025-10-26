import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class HeightWeightPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const HeightWeightPage({super.key, required this.themeProvider});

  @override
  State<HeightWeightPage> createState() => _HeightWeightPageState();
}

class _HeightWeightPageState extends State<HeightWeightPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late OnboardingController _controller;

  // Toggle: true = Metric, false = Imperial.
  bool _isMetric = true;

  // Default Metric values.
  int _selectedMetricHeight = 170; // in cm (valid range: 10-500)
  int _selectedMetricWeight = 70; // in kg (valid range: 10-250)

  // Default Imperial values.
  int _selectedImperialHeight = 67; // in inches (derived from metric range)
  int _selectedImperialWeight = 154; // in lbs (derived from metric range)

  // Scroll controllers for pickers
  FixedExtentScrollController? _heightScrollController;
  FixedExtentScrollController? _weightScrollController;

  // Conversion methods
  int _cmToInches(int cm) => (cm / 2.54).round();
  int _kgToLbs(int kg) => (kg * 2.20462).round();
  int _inchesToCm(int inches) => (inches * 2.54).round();
  int _lbsToKg(int lbs) => (lbs / 2.20462).round();

  // Helper method to format height for display
  String _formatHeightForDisplay(int value, bool isMetric) {
    if (isMetric) {
      return "$value cm";
    } else {
      final feet = value ~/ 12;
      final inches = value % 12;
      return "$feet ft $inches in";
    }
  }

  // Helper method to format weight for display
  String _formatWeightForDisplay(int value, bool isMetric) {
    return isMetric ? "$value kg" : "$value lbs";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _controller = Get.find<OnboardingController>();
    
    // Initialize scroll controllers
    _initializeScrollControllers();
    
    // Initialize with default values
    _controller.setIntData('height', _selectedMetricHeight);
    _controller.setIntData('weight', _selectedMetricWeight);
    _controller.setBoolData('is_metric', _isMetric);
    });
  }

  void _initializeScrollControllers() {
    // Define metric boundaries
    const int minMetricHeight = 10;
    const int minMetricWeight = 10;

    // Calculate imperial boundaries
    final int minImperialHeight = (_cmToInches(minMetricHeight)).ceil();
    final int minImperialWeight = _kgToLbs(minMetricWeight);

    // Calculate initial indices
    final int heightInitialIndex = _isMetric
        ? _selectedMetricHeight - minMetricHeight
        : _selectedImperialHeight - minImperialHeight;

    final int weightInitialIndex = _isMetric
        ? _selectedMetricWeight - minMetricWeight
        : _selectedImperialWeight - minImperialWeight;

    // Initialize scroll controllers
    _heightScrollController = FixedExtentScrollController(initialItem: heightInitialIndex);
    _weightScrollController = FixedExtentScrollController(initialItem: weightInitialIndex);
  }

  @override
  void dispose() {
    _heightScrollController?.dispose();
    _weightScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Define metric boundaries.
    const int minMetricHeight = 10;
    const int maxMetricHeight = 500;
    const int minMetricWeight = 10;
    const int maxMetricWeight = 250;

    // Calculate imperial boundaries
    final int minImperialHeight = (_cmToInches(minMetricHeight)).ceil(); // ≈4 inches
    final int maxImperialHeight = (_cmToInches(maxMetricHeight)).floor(); // ≈196 inches
    final int minImperialWeight = _kgToLbs(minMetricWeight); // ≈22 lbs
    final int maxImperialWeight = _kgToLbs(maxMetricWeight); // ≈551 lbs

    // Create lists based on the selected unit.
    final List<int> heightItems = _isMetric
        ? List.generate(
            maxMetricHeight - minMetricHeight + 1,
            (index) => index + minMetricHeight,
          ) // 10 to 500 cm
        : List.generate(
            maxImperialHeight - minImperialHeight + 1,
            (index) => index + minImperialHeight,
          ); // e.g., 4 to 196 inches

    final List<int> weightItems = _isMetric
        ? List.generate(
            maxMetricWeight - minMetricWeight + 1,
            (index) => index + minMetricWeight,
          ) // 10 to 250 kg
        : List.generate(
            maxImperialWeight - minImperialWeight + 1,
            (index) => index + minImperialWeight,
          ); // e.g., 22 to 551 lbs


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Title
          Center(
            child: Text(
              'Visina i težina',
              style: ThemeHelper.title1.copyWith(
                color: ThemeHelper.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeHelper.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Ova informacija nam pomaže da personaliziramo vaše dnevne kalorijske i nutritivne ciljeve.',
                style: ThemeHelper.caption1.copyWith(
                  fontSize: 13,
                  color: ThemeHelper.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Toggle Switch for Metric vs Imperial.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Imperial",
                  style: ThemeHelper.headline.copyWith(
                    color: _isMetric ? ThemeHelper.textSecondary : ThemeHelper.textPrimary,
                  ),
                ),
                const SizedBox(width: 32),
                CupertinoSwitch(
                  value: _isMetric,
                  onChanged: (bool value) {
                    setState(() {
                      // Convert current selections to the other unit system
                      if (_isMetric) {
                        // Switching from Metric to Imperial
                        _selectedImperialHeight = _cmToInches(_selectedMetricHeight);
                        _selectedImperialWeight = _kgToLbs(_selectedMetricWeight);
                        _controller.setIntData('height', _selectedImperialHeight);
                        _controller.setIntData('weight', _selectedImperialWeight);
                      } else {
                        // Switching from Imperial to Metric
                        _selectedMetricHeight = _inchesToCm(_selectedImperialHeight);
                        _selectedMetricWeight = _lbsToKg(_selectedImperialWeight);
                        _controller.setIntData('height', _selectedMetricHeight);
                        _controller.setIntData('weight', _selectedMetricWeight);
                      }

                      _isMetric = value;
                      _controller.setBoolData('is_metric', _isMetric);
                      
                      // Reinitialize scroll controllers with new values
                      _heightScrollController?.dispose();
                      _weightScrollController?.dispose();
                      _initializeScrollControllers();
                    });
                  },
                  activeColor: ThemeHelper.textPrimary,
                ),
                const SizedBox(width: 32),
                Text(
                  "Metrički",
                  style: ThemeHelper.headline.copyWith(
                    color: _isMetric ? ThemeHelper.textPrimary : ThemeHelper.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Height & Weight selectors.
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Height Selector.
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Visina",
                        style: ThemeHelper.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 250,
                        child: CupertinoPicker(
                          scrollController: _heightScrollController,
                          itemExtent: 40,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              final int newValue = heightItems[index];
                              if (_isMetric) {
                                _selectedMetricHeight = newValue;
                                _controller.setIntData('height', _selectedMetricHeight);
                              } else {
                                _selectedImperialHeight = newValue;
                                _controller.setIntData('height', _selectedImperialHeight);
                              }
                            });
                          },
                          children: heightItems.map((int value) {
                            return Center(
                              child: Text(
                                _formatHeightForDisplay(value, _isMetric),
                                style: ThemeHelper.body1.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: ThemeHelper.textPrimary,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                // Weight Selector.
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Težina",
                        style: ThemeHelper.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 250,
                        child: CupertinoPicker(
                          scrollController: _weightScrollController,
                          itemExtent: 40,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              final int newValue = weightItems[index];
                              if (_isMetric) {
                                _selectedMetricWeight = newValue;
                                _controller.setIntData('weight', _selectedMetricWeight);
                              } else {
                                _selectedImperialWeight = newValue;
                                _controller.setIntData('weight', _selectedImperialWeight);
                              }
                            });
                          },
                          children: weightItems.map((int value) {
                            return Center(
                              child: Text(
                                _formatWeightForDisplay(value, _isMetric),
                                style: ThemeHelper.body1.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: ThemeHelper.textPrimary,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

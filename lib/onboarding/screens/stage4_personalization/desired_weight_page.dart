import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class DesiredWeightPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const DesiredWeightPage({super.key, required this.themeProvider});

  @override
  State<DesiredWeightPage> createState() => _DesiredWeightPageState();
}

class _DesiredWeightPageState extends State<DesiredWeightPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late OnboardingController _controller;
  
  // Weight unit: true = lbs, false = kg
  bool _isLbs = true;
  
  // Current weight value
  double _currentWeight = 130.0;
  
  // Weight ranges
  static const double _minWeightLbs = 50.0;
  static const double _maxWeightLbs = 500.0;
  static const double _minWeightKg = 22.7;
  static const double _maxWeightKg = 227.0;
  
  // Conversion factor
  static const double _lbsToKg = 0.453592;
  static const double _kgToLbs = 2.20462;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      
      
      // Initialize with default values
      _controller.setDoubleData('desired_weight', _currentWeight);
      _controller.setBoolData('weight_unit_lbs', _isLbs);
    });
  }

  void _updateWeight(double newWeight) {
    setState(() {
      _currentWeight = newWeight;
      _controller.setDoubleData('desired_weight', _currentWeight);
    });
  }

  void _toggleUnit() {
    setState(() {
      if (_isLbs) {
        // Convert from lbs to kg
        _currentWeight = _currentWeight * _lbsToKg;
        _isLbs = false;
      } else {
        // Convert from kg to lbs
        _currentWeight = _currentWeight * _kgToLbs;
        _isLbs = true;
      }
      _controller.setDoubleData('desired_weight', _currentWeight);
      _controller.setBoolData('weight_unit_lbs', _isLbs);
    });
  }

  String _formatWeight(double weight) {
    return _isLbs ? '${weight.toStringAsFixed(1)} lbs' : '${weight.toStringAsFixed(1)} kg';
  }

  double _getMinWeight() {
    return _isLbs ? _minWeightLbs : _minWeightKg;
  }

  double _getMaxWeight() {
    return _isLbs ? _maxWeightLbs : _maxWeightKg;
  }

  double _getSliderWidth() {
    final double minWeight = _getMinWeight();
    final double maxWeight = _getMaxWeight();
    final double percentage = (_currentWeight - minWeight) / (maxWeight - minWeight);
    final double clampedPercentage = percentage.clamp(0.0, 1.0);
    return (MediaQuery.of(context).size.width - 40) * clampedPercentage;
  }

  double _getPointerPosition() {
    final double minWeight = _getMinWeight();
    final double maxWeight = _getMaxWeight();
    final double percentage = (_currentWeight - minWeight) / (maxWeight - minWeight);
    final double clampedPercentage = percentage.clamp(0.0, 1.0);
    return 20 + ((MediaQuery.of(context).size.width - 40) * clampedPercentage) - 1;
  }

  void _updateWeightFromPosition(double localPosition) {
    final double containerWidth = MediaQuery.of(context).size.width - 40; // Account for margins
    final double percentage = (localPosition - 20) / containerWidth;
    final double clampedPercentage = percentage.clamp(0.0, 1.0);
    
    final double minWeight = _getMinWeight();
    final double maxWeight = _getMaxWeight();
    final double newWeight = minWeight + (clampedPercentage * (maxWeight - minWeight));
    
    _updateWeight(newWeight);
  }

  String _getGoalText() {
    final String? goal = _controller.getStringData('goal');
    switch (goal) {
      case 'lose_weight':
        return 'Smršati';
      case 'maintain_weight':
        return 'Održavati Težinu';
      case 'gain_weight':
        return 'Dobiti na Težini';
      default:
        return 'Dobiti na Težini';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        
        // Title
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            'What is your desired weight?',
            style: ThemeHelper.title3.copyWith(
              color: CupertinoColors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Weight unit selection
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (!_isLbs) _toggleUnit();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isLbs ? CupertinoColors.white : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'lbs',
                      style: ThemeHelper.headline.copyWith(
                        color: _isLbs ? CupertinoColors.black : CupertinoColors.systemGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (_isLbs) _toggleUnit();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: !_isLbs ? CupertinoColors.white : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Kg',
                      style: ThemeHelper.headline.copyWith(
                        color: !_isLbs ? CupertinoColors.black : CupertinoColors.systemGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Goal text
        Center(
          child: Text(
            _getGoalText(),
            style: ThemeHelper.body1.copyWith(
              color: CupertinoColors.systemGrey,
              fontSize: 16,
            ),
          ),
        ),
        
        const SizedBox(height: 10),
        
        // Current weight display
        Center(
          child: Text(
            _formatWeight(_currentWeight),
            style: ThemeHelper.title1.copyWith(
              color: CupertinoColors.black,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Weight slider
        Expanded(
          child: Center(
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: GestureDetector(
                onPanStart: (details) {
                  _updateWeightFromPosition(details.localPosition.dx);
                },
                onPanUpdate: (details) {
                  _updateWeightFromPosition(details.localPosition.dx);
                },
                onTapDown: (details) {
                  _updateWeightFromPosition(details.localPosition.dx);
                },
                child: Stack(
                  children: [
         
                    // Filled portion (darker gray)
                   
                    // Tick marks with varying heights
                    ...List.generate(41, (index) {
                      final double position = (index / 40) * (MediaQuery.of(context).size.width - 40);
                      final bool isMajorTick = index % 10 == 0;
                      final bool isMediumTick = index % 5 == 0 && !isMajorTick;
                      final bool isMinorTick = !isMajorTick && !isMediumTick;
                      
                      double tickHeight = 0;
                      if (isMajorTick) {
                        tickHeight = 35;
                      } else if (isMediumTick) {
                        tickHeight = 25;
                      } else if (isMinorTick) {
                        tickHeight = 15;
                      }
                      
                      return Positioned(
                        left: position + 20,
                        top: 50 - tickHeight,
                        child: Container(
                          width: 1,
                          height: tickHeight,
                          color: CupertinoColors.black,
                        ),
                      );
                    }),
                    // Grayish gradient shade overlay covering full ruler height
                    Positioned(
                      left: 20,
                      top: 15, // Start from major tick head
                      child: Container(
                        width: _getSliderWidth(),
                        height: 35, // From major tick head to feet
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              CupertinoColors.systemGrey.withOpacity(0.8), // Darker at top
                              CupertinoColors.systemGrey.withOpacity(0.5), // Lighter at bottom
                            ],
                          ),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                    // Pointer (tall black line positioned higher)
                    Positioned(
                      left: _getPointerPosition(),
                      top: -25, // Moved higher
                      child: Container(
                        width: 2,
                        height: 75, // Extended height
                        decoration: BoxDecoration(
                          color: CupertinoColors.black,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
    
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class WeightLossSpeedPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const WeightLossSpeedPage({super.key, required this.themeProvider});

  @override
  State<WeightLossSpeedPage> createState() => _WeightLossSpeedPageState();
}

class _WeightLossSpeedPageState extends State<WeightLossSpeedPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late OnboardingController _controller;
  
  // Weight loss speed values (kg/week)
  static const double _minSpeed = 0.2;
  static const double _maxSpeed = 1.4;
  static const double _defaultSpeed = 0.7;
  
  double _currentSpeed = _defaultSpeed;
  
  // Speed levels
  static const double _slowSpeed = 0.2;
  static const double _mediumSpeed = 0.7;
  static const double _fastSpeed = 1.4;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.setDoubleData('weight_loss_speed', _currentSpeed);
      debugPrint('========== Weight Loss Speed Page Initialized ==========');
      debugPrint('Default Speed: $_currentSpeed kg/week');
      debugPrint('Speed Level: ${_getSpeedLevel()}');
      debugPrint('==========================================');
    });
   
  }

  void _updateSpeed(double newSpeed) {
    setState(() {
      _currentSpeed = newSpeed;
      _controller.setDoubleData('weight_loss_speed', _currentSpeed);
      debugPrint('========== Weight Loss Speed Updated ==========');
      debugPrint('New Speed: $_currentSpeed kg/week (${_formatSpeed(_currentSpeed)})');
      debugPrint('Speed Level: ${_getSpeedLevel()}');
      debugPrint('==========================================');
    });
  }


  String _formatSpeed(double speed) {
    return '${speed.toStringAsFixed(1)} kg/week';
  }

  String _getSpeedLevel() {
    if (_currentSpeed <= _slowSpeed + 0.1) {
      return 'The Safest Option';
    } else if (_currentSpeed <= _mediumSpeed + 0.1) {
      return 'Balanced Approach';
    } else {
      return 'Aggressive Plan';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          const SizedBox(height: 40),
          
          // Title
          Text(
            'Pick your weight loss speed',
            style: ThemeHelper.title1.copyWith(
              color: CupertinoColors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Current speed display
          Text(
            _formatSpeed(_currentSpeed),
            style: ThemeHelper.title2.copyWith(
              color: CupertinoColors.black,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 60),
          
          // Vertical slider
          SizedBox(
            height: 350,
            child: Center(
              child: SizedBox(
                height: 350,
                width: 200,
                child: Stack(
                  children: [
                    // Speed indicators and icons
                    // Slow speed (top)
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Column(
                        children: [
                          // Slow icon placeholder
                          Image.asset('assets/icons/slow.png', width: 36, height: 36),
                        ],
                      ),
                    ),
                    
                    // Medium speed (middle)
                    Positioned(
                      left: 0,
                      top: 130,
                      child: Column(
                        children: [
                          // Medium icon placeholder
                          Image.asset('assets/icons/fast.png', width: 36, height: 36),
                        ],
                      ),
                    ),
                    
                    // Fast speed (bottom)
                    Positioned(
                      left: 0,
                      top: 280,
                      child: Column(
                        children: [
                          // Fast icon placeholder
                          Image.asset('assets/icons/swift.png', width: 36, height: 36),
                        ],
                      ),
                    ),
                    
                    // Weight values on the right
                    // Slow speed value (top)
                    Positioned(
                      left: 120,
                      top: 0,
                      child: Column(
                        children: [
                          const SizedBox(height: 18), // Center with icon
                          Text(
                            '${_slowSpeed.toStringAsFixed(1)} kg',
                            style: ThemeHelper.body1.copyWith(
                              color: CupertinoColors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Medium speed value (middle)
                    Positioned(
                      left: 120,
                      top: 130,
                      child: Column(
                        children: [
                          const SizedBox(height: 18), // Center with icon
                          Text(
                            '${_mediumSpeed.toStringAsFixed(1)} kg',
                            style: ThemeHelper.body1.copyWith(
                              color: CupertinoColors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Fast speed value (bottom)
                    Positioned(
                      left: 120,
                      top: 280,
                      child: Column(
                        children: [
                          const SizedBox(height: 18), // Center with icon
                          Text(
                            '${_fastSpeed.toStringAsFixed(1)} kg',
                            style: ThemeHelper.body1.copyWith(
                              color: CupertinoColors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Material Slider
                    Positioned(
                      left: 60,
                      top: 0,
                      child: SizedBox(
                        height: 350,
                        width: 40,
                        child: Material(
                          color: Colors.transparent,
                          child: RotatedBox(
                            quarterTurns: 1, // Rotate 90 degrees to make it vertical
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                sliderTheme: SliderTheme.of(context).copyWith(
                                  trackHeight: 8.0, // Make track thicker
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 12, // Make thumb larger
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 20,
                                  ),
                                ),
                              ),
                            child: Slider(
                              value: _maxSpeed - _currentSpeed + _minSpeed, // Invert the value
                              min: _minSpeed,
                              max: _maxSpeed,
                              activeColor: CupertinoColors.black, // Black slider
                              inactiveColor: CupertinoColors.systemGrey4, // Grey track
                              onChanged: (double value) {
                                _updateSpeed(_maxSpeed - value + _minSpeed); // Invert the value back
                              },
                            ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Speed level button
          SizedBox(
            width: double.infinity,
            height: 75,
            child: CupertinoButton(
              onPressed: () {
                debugPrint('========== Weight Loss Speed Page - Moving to Next ==========');
                debugPrint('Final Speed Selected: $_currentSpeed kg/week');
                debugPrint('Speed Level: ${_getSpeedLevel()}');
                debugPrint('All Data: ${_controller.getAllData()}');
                debugPrint('==========================================');
                _controller.goToNextPage();
              },
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.systemGrey4,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    _getSpeedLevel(),
                    style: ThemeHelper.headline.copyWith(
                      color: CupertinoColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

}

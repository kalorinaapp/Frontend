import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../../utils/page_animations.dart';
import '../../controller/onboarding.controller.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;

class WeightLossSpeedPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const WeightLossSpeedPage({super.key, required this.themeProvider});

  @override
  State<WeightLossSpeedPage> createState() => _WeightLossSpeedPageState();
}

class _WeightLossSpeedPageState extends State<WeightLossSpeedPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late OnboardingController _controller;
  late AnimationController _animationController;
  late Animation<double> _titleAnimation;
  late Animation<double> _speedDisplayAnimation;
  late Animation<double> _sliderAnimation;
  late Animation<double> _buttonAnimation;
  
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
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    
    _titleAnimation = PageAnimations.createTitleAnimation(_animationController);
    
    _speedDisplayAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _sliderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.setDoubleData('weight_loss_speed', _currentSpeed);
      debugPrint('========== Weight Loss Speed Page Initialized ==========');
      debugPrint('Default Speed: $_currentSpeed kg/week');
      debugPrint('==========================================');
    });
   
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateSpeed(double newSpeed) {
    setState(() {
      _currentSpeed = newSpeed;
      _controller.setDoubleData('weight_loss_speed', _currentSpeed);
      debugPrint('========== Weight Loss Speed Updated ==========');
      debugPrint('New Speed: $_currentSpeed kg/week (${_formatSpeed(_currentSpeed)})');
      debugPrint('==========================================');
    });
  }


  String _formatSpeed(double speed) {
    return '${speed.toStringAsFixed(1)} kg/week';
  }

  String _getSpeedLevel(AppLocalizations localizations) {
    if (_currentSpeed <= _slowSpeed + 0.1) {
      return localizations.theSafestOption;
    } else if (_currentSpeed <= _mediumSpeed + 0.1) {
      return localizations.balancedApproach;
    } else {
      return localizations.aggressivePlan;
    }
  }
  
  String _getTitleText(AppLocalizations localizations) {
    final String? goal = _controller.getStringData('goal');
    if (goal == 'gain_weight') {
      return localizations.pickWeightGainSpeed;
    } else {
      return localizations.pickWeightLossSpeed;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final localizations = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          const SizedBox(height: 40),
          
          // Title
          PageAnimations.animatedTitle(
            animation: _titleAnimation,
            child: Text(
              _getTitleText(localizations),
              style: ThemeHelper.title1.copyWith(
                color: ThemeHelper.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Current speed display
          PageAnimations.animatedContent(
            animation: _speedDisplayAnimation,
            child: Text(
              _formatSpeed(_currentSpeed),
              style: ThemeHelper.title2.copyWith(
                color: ThemeHelper.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Vertical slider
          PageAnimations.animatedContent(
            animation: _sliderAnimation,
            child: SizedBox(
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
                          Image.asset(
                            'assets/icons/slow.png',
                            width: 36,
                            height: 36,
                            color: ThemeHelper.textPrimary,
                          ),
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
                          Image.asset(
                            'assets/icons/fast.png',
                            width: 36,
                            height: 36,
                            color: ThemeHelper.textPrimary,
                          ),
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
                          Image.asset(
                            'assets/icons/swift.png',
                            width: 36,
                            height: 36,
                            color: ThemeHelper.textPrimary,
                          ),
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
                              color: ThemeHelper.textPrimary,
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
                              color: ThemeHelper.textPrimary,
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
                              color: ThemeHelper.textPrimary,
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
                              value: _currentSpeed,
                              min: _minSpeed,
                              max: _maxSpeed,
                              activeColor: ThemeHelper.textPrimary,
                              inactiveColor: ThemeHelper.divider,
                              onChanged: (double value) {
                                _updateSpeed(value);
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
          ),
          
          const SizedBox(height: 40),
          
          // Speed level button
          PageAnimations.animatedContent(
            animation: _buttonAnimation,
            child: SizedBox(
              width: double.infinity,
              height: 75,
              child: CupertinoButton(
              onPressed: () {
                debugPrint('========== Weight Loss Speed Page - Moving to Next ==========');
                debugPrint('Final Speed Selected: $_currentSpeed kg/week');
                debugPrint('Speed Level: ${_getSpeedLevel(localizations)}');
                debugPrint('All Data: ${_controller.getAllData()}');
                debugPrint('==========================================');
                _controller.goToNextPage();
              },
              color: ThemeHelper.cardBackground,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ThemeHelper.divider,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    _getSpeedLevel(localizations),
                    style: ThemeHelper.headline.copyWith(
                      color: ThemeHelper.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
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

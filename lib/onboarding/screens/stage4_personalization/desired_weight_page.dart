import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../../utils/page_animations.dart';
import '../../controller/onboarding.controller.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;

class DesiredWeightPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const DesiredWeightPage({super.key, required this.themeProvider});

  @override
  State<DesiredWeightPage> createState() => _DesiredWeightPageState();
}

class _DesiredWeightPageState extends State<DesiredWeightPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late OnboardingController _controller;
  late AnimationController _animationController;
  late Animation<double> _titleAnimation;
  late Animation<double> _toggleAnimation;
  late Animation<double> _goalTextAnimation;
  late Animation<double> _weightDisplayAnimation;
  late Animation<double> _sliderAnimation;
  
  // Scroll controller for the ruler
  late ScrollController _scrollController;
  
  // Weight unit: true = lbs, false = kg
  bool _isLbs = true;
  
  // Current weight value
  double _currentWeight = 130.0;
  
  // Track last haptic feedback position to avoid too frequent feedback
  int _lastHapticTickIndex = -1;
  
  // Tick spacing in pixels
  static const double _tickSpacing = 8.0; // pixels between ticks
  static const double _tickIncrementLbs = 1.0; // 1 lb per tick
  static const double _tickIncrementKg = 0.5; // 0.5 kg per tick
  
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
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _titleAnimation = PageAnimations.createTitleAnimation(_animationController);
    
    _toggleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _goalTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _weightDisplayAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );
    
    _sliderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
    
    // Initialize scroll controller
    _scrollController = ScrollController();
    
    // Load saved values AFTER build phase to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadSavedValues();
        _syncScrollToWeight();
      }
    });
    
    // Listen to scroll changes
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (!_scrollController.hasClients || !mounted) return;
    
    final double scrollOffset = _scrollController.offset;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double centerOffset = screenWidth / 2;
    final double totalOffset = scrollOffset + centerOffset;
    
    // Calculate weight from scroll position
    final double increment = _isLbs ? _tickIncrementLbs : _tickIncrementKg;
    final double minWeight = _isLbs ? _minWeightLbs : _minWeightKg;
    final double tickIndex = totalOffset / _tickSpacing;
    final double newWeight = minWeight + (tickIndex * increment);
    
    // Clamp to valid range
    final double maxWeight = _isLbs ? _maxWeightLbs : _maxWeightKg;
    final double clampedWeight = newWeight.clamp(minWeight, maxWeight);
    
    // Provide haptic feedback when crossing tick marks (every 5 ticks for medium feedback)
    final int currentTickIndex = tickIndex.round();
    if (currentTickIndex != _lastHapticTickIndex && currentTickIndex % 5 == 0) {
      HapticFeedback.selectionClick();
      _lastHapticTickIndex = currentTickIndex;
    }
    
    if ((_currentWeight - clampedWeight).abs() > 0.01) {
      setState(() {
        _currentWeight = clampedWeight;
        _controller.setDoubleData('desired_weight', _currentWeight);
      });
    }
  }
  
  void _syncScrollToWeight() {
    if (!_scrollController.hasClients || !mounted) return;
    
    final double increment = _isLbs ? _tickIncrementLbs : _tickIncrementKg;
    final double minWeight = _isLbs ? _minWeightLbs : _minWeightKg;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double centerOffset = screenWidth / 2;
    
    // Calculate scroll position from weight
    final double tickIndex = (_currentWeight - minWeight) / increment;
    final double totalOffset = tickIndex * _tickSpacing;
    final double scrollOffset = totalOffset - centerOffset;
    
    final double maxScroll = _scrollController.position.maxScrollExtent;
    _scrollController.jumpTo(scrollOffset.clamp(0.0, maxScroll));
  }
  
  // Calculate number of ticks needed for full range
  int _getTotalTicks() {
    final double minWeight = _isLbs ? _minWeightLbs : _minWeightKg;
    final double maxWeight = _isLbs ? _maxWeightLbs : _maxWeightKg;
    final double increment = _isLbs ? _tickIncrementLbs : _tickIncrementKg;
    return ((maxWeight - minWeight) / increment).ceil() + 1;
  }
  
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload values when navigating back to this page - use microtask to avoid build issues
    Future.microtask(() {
      if (mounted) {
        _loadSavedValues();
      }
    });
  }
  
  void _loadSavedValues() {
    if (!mounted) return;
    
    // Get the main unit system (from height/weight page)
    final bool isMetric = _controller.getBoolData('is_metric') ?? true;
    
    // Load saved desired weight if it exists
    final double? savedDesiredWeight = _controller.getDoubleData('desired_weight');
    final bool? savedUnitLbs = _controller.getBoolData('weight_unit_lbs');
    
    // Get current weight to set a sensible default
    final int? currentWeightInt = _controller.getIntData('weight');
    
    bool needsUpdate = false;
    
    if (savedDesiredWeight != null && savedUnitLbs != null) {
      // Load saved values
      if (_currentWeight != savedDesiredWeight || _isLbs != savedUnitLbs) {
        _currentWeight = savedDesiredWeight;
        _isLbs = savedUnitLbs;
        needsUpdate = true;
      }
    } else if (currentWeightInt != null) {
      // No saved desired weight, set default based on current weight and unit system
      _isLbs = !isMetric; // If metric, use kg; if imperial, use lbs
      if (isMetric) {
        // Current weight is in kg, set desired weight slightly less (for weight loss) or more (for gain)
        _currentWeight = (currentWeightInt * 0.95).toDouble(); // 5% less as default
      } else {
        // Current weight is in lbs, convert to lbs for desired
        _currentWeight = (currentWeightInt * 0.95).toDouble(); // 5% less as default
      }
      // Save the initialized values (defer to avoid build issues)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.setDoubleData('desired_weight', _currentWeight);
          _controller.setBoolData('weight_unit_lbs', _isLbs);
        }
      });
      needsUpdate = true;
    } else {
      // No current weight either, use defaults
      _isLbs = !isMetric;
      _currentWeight = _isLbs ? 130.0 : 59.0;
      // Save the defaults (defer to avoid build issues)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.setDoubleData('desired_weight', _currentWeight);
          _controller.setBoolData('weight_unit_lbs', _isLbs);
        }
      });
      needsUpdate = true;
    }
    
    // Sync unit with main unit system if different
    if (_isLbs == isMetric) {
      // Unit mismatch - convert desired weight to match main unit system
      if (isMetric && _isLbs) {
        // Main is metric (kg), but desired is in lbs - convert to kg
        _currentWeight = _currentWeight * _lbsToKg;
        _isLbs = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _controller.setDoubleData('desired_weight', _currentWeight);
            _controller.setBoolData('weight_unit_lbs', false);
          }
        });
        needsUpdate = true;
      } else if (!isMetric && !_isLbs) {
        // Main is imperial (lbs), but desired is in kg - convert to lbs
        _currentWeight = _currentWeight * _kgToLbs;
        _isLbs = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _controller.setDoubleData('desired_weight', _currentWeight);
            _controller.setBoolData('weight_unit_lbs', true);
          }
        });
        needsUpdate = true;
      }
    }
    
    if (needsUpdate && mounted) {
      setState(() {});
      // Sync scroll position after loading values
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncScrollToWeight();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateWeight(double newWeight) {
    setState(() {
      _currentWeight = newWeight;
      _controller.setDoubleData('desired_weight', _currentWeight);
    });
    // Sync scroll position after weight update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncScrollToWeight();
      }
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
    
    // Sync scroll position after unit change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncScrollToWeight();
      }
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


  String _getGoalText(AppLocalizations localizations) {
    final String? goal = _controller.getStringData('goal');
    switch (goal) {
      case 'lose_weight':
        return localizations.loseWeight;
      case 'maintain_weight':
        return localizations.maintainWeight;
      case 'gain_weight':
        return localizations.gainWeight;
      default:
        return localizations.gainWeight;
    }
  }
  
  String _getTitleText(AppLocalizations localizations) {
    final String? goal = _controller.getStringData('goal');
    switch (goal) {
      case 'lose_weight':
        return localizations.howMuchWeightToLose;
      case 'maintain_weight':
        return localizations.whatIsDesiredWeight;
      case 'gain_weight':
        return localizations.howMuchWeightToGain;
      default:
        return localizations.whatIsDesiredWeight;
    }
  }

  void _showWeightInputBottomSheet(BuildContext context, AppLocalizations localizations) {
    final TextEditingController textController = TextEditingController(
      text: _currentWeight.toStringAsFixed(1),
    );
    final FocusNode focusNode = FocusNode();

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            bool isValid = true;
            String errorMessage = '';

            void _validateInput(String value) {
              if (value.isEmpty) {
                setModalState(() {
                  isValid = false;
                  errorMessage = 'Please enter a weight';
                });
                return;
              }

              final double? parsed = double.tryParse(value);
              final double minWeight = _getMinWeight();
              final double maxWeight = _getMaxWeight();
              
              if (parsed != null && parsed >= minWeight && parsed <= maxWeight) {
                setModalState(() {
                  isValid = true;
                  errorMessage = '';
                });
                // Don't update parent state while typing - only validate
                // This prevents the text field from being reset
              } else {
                setModalState(() {
                  isValid = false;
                  errorMessage = 'Please enter a value between ${minWeight.toStringAsFixed(1)} and ${maxWeight.toStringAsFixed(1)} ${_isLbs ? 'lbs' : 'kg'}';
                });
              }
            }
            
            void _confirmWeight(double weight) {
              _updateWeight(weight);
              Navigator.of(context).pop();
            }

            // Focus the text field when bottom sheet appears (only once)
            // Don't auto-select text to allow user to type freely
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (focusNode.canRequestFocus) {
                focusNode.requestFocus();
              }
            });

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ThemeHelper.cardBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: ThemeHelper.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    
                    // Title
                    Text(
                      localizations.whatIsDesiredWeight,
                      style: TextStyle(
                        color: ThemeHelper.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      _isLbs ? 'Enter weight in lbs' : 'Enter weight in kg',
                      style: TextStyle(
                        color: ThemeHelper.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Text Field
                    CupertinoTextField(
                      controller: textController,
                      focusNode: focusNode,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        color: ThemeHelper.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: ThemeHelper.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isValid ? ThemeHelper.divider : CupertinoColors.systemRed,
                          width: 2,
                        ),
                      ),
                      suffix: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 16),
                        child: Text(
                          _isLbs ? 'lbs' : 'kg',
                          style: TextStyle(
                            color: ThemeHelper.textSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        _validateInput(value);
                      },
                      onSubmitted: (value) {
                        final double? parsed = double.tryParse(value);
                        final double minWeight = _getMinWeight();
                        final double maxWeight = _getMaxWeight();
                        
                        if (parsed != null && parsed >= minWeight && parsed <= maxWeight) {
                          _confirmWeight(parsed);
                        }
                      },
                    ),
                    
                    // Error message
                    if (!isValid && errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            color: ThemeHelper.background,
                            borderRadius: BorderRadius.circular(12),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              localizations.cancel,
                              style: TextStyle(
                                color: ThemeHelper.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            color: isValid ? ThemeHelper.textPrimary : CupertinoColors.systemGrey,
                            borderRadius: BorderRadius.circular(12),
                            onPressed: isValid
                                ? () {
                                    final double? parsed = double.tryParse(textController.text);
                                    final double minWeight = _getMinWeight();
                                    final double maxWeight = _getMaxWeight();
                                    
                                    if (parsed != null && parsed >= minWeight && parsed <= maxWeight) {
                                      _confirmWeight(parsed);
                                    }
                                  }
                                : null,
                            child: Text(
                              localizations.ok,
                              style: TextStyle(
                                color: isValid ? ThemeHelper.background : CupertinoColors.systemGrey2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        
        // Title
        PageAnimations.animatedTitle(
          animation: _titleAnimation,
          child: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              _getTitleText(localizations),
              style: ThemeHelper.title3.copyWith(
                color: ThemeHelper.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Weight unit selection
        PageAnimations.animatedContent(
          animation: _toggleAnimation,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ThemeHelper.cardBackground,
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
                        color: _isLbs ? ThemeHelper.background : ThemeHelper.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'lbs',
                        style: ThemeHelper.headline.copyWith(
                          color: _isLbs ? ThemeHelper.textPrimary : ThemeHelper.textSecondary,
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
                        color: !_isLbs ? ThemeHelper.background : ThemeHelper.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Kg',
                        style: ThemeHelper.headline.copyWith(
                          color: !_isLbs ? ThemeHelper.textPrimary : ThemeHelper.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Goal text
        PageAnimations.animatedContent(
          animation: _goalTextAnimation,
          child: Center(
            child: Text(
              _getGoalText(localizations),
              style: ThemeHelper.body1.copyWith(
                color: ThemeHelper.textSecondary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        // Current weight display (tappable to open bottom sheet)
        PageAnimations.animatedContent(
          animation: _weightDisplayAnimation,
          child: GestureDetector(
            onTap: () => _showWeightInputBottomSheet(context, localizations),
            child: Center(
              child: Text(
                _formatWeight(_currentWeight),
                style: ThemeHelper.title1.copyWith(
                  color: ThemeHelper.textPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Scrollable weight ruler
        Expanded(
          child: PageAnimations.animatedContent(
            animation: _sliderAnimation,
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                children: [
                  // Left gradient fade from center pointer
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Builder(
                      builder: (context) {
                        final double centerX = MediaQuery.of(context).size.width / 2;
                        final double gradientWidth = centerX;
                        return Container(
                          width: gradientWidth,
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                ThemeHelper.background,
                                ThemeHelper.background.withOpacity(0.0),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Right gradient fade from center pointer
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Builder(
                      builder: (context) {
                        final double centerX = MediaQuery.of(context).size.width / 2;
                        final double screenWidth = MediaQuery.of(context).size.width;
                        final double gradientWidth = screenWidth - centerX;
                        return Container(
                          width: gradientWidth,
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                ThemeHelper.cardBackground,
                                ThemeHelper.cardBackground.withOpacity(0.0),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Dark grey gradient overlay from start to center pointer
                  Positioned(
                    left: 0,
                    top: 25,
                    child: Builder(
                      builder: (context) {
                        final double centerX = MediaQuery.of(context).size.width / 2;
                        final double gradientWidth = centerX;
                        return Container(
                          width: gradientWidth,
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF6B6B6B).withOpacity(0.75), // Dark grey at top with transparency
                                const Color(0xFFD3D3D3).withOpacity(0.3), // Light grey at bottom with transparency
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),
                  ),
                  // Fixed center pointer (longest tick)
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 - 1.5,
                    top: 0,
                    child: Container(
                      width: 3,
                      height: 75,
                      decoration: BoxDecoration(
                        color: ThemeHelper.textPrimary,
                        borderRadius: BorderRadius.circular(1.5),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeHelper.textPrimary.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Scrollable ruler
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      height: 150,
                      width: _getTotalTicks() * _tickSpacing,
                      child: Stack(
                        children: [
                          // Generate all tick marks with original size variations
                          ...List.generate(_getTotalTicks(), (index) {
                            final double position = index * _tickSpacing;
                            
                            // Determine tick type based on index (more reliable than weight calculation)
                            // For lbs: 1 lb per tick, so index 0, 10, 20 = major (every 10 lbs)
                            //         index 5, 15, 25 = medium (every 5 lbs but not major)
                            // For kg: 0.5 kg per tick, so index 0, 10, 20 = major (every 5 kg)
                            //         index 5, 15, 25 = medium (every 2.5 kg but not major)
                            final bool isMajorTick = index % 10 == 0;
                            final bool isMediumTick = index % 5 == 0 && !isMajorTick;
                            final bool isMinorTick = !isMajorTick && !isMediumTick;
                            
                            double tickHeight = 0;
                            if (isMajorTick) {
                              tickHeight = 55; // Tallest for major ticks
                            } else if (isMediumTick) {
                              tickHeight = 40; // Medium height
                            } else {
                              tickHeight = 25; // Shortest for minor ticks
                            }
                            
                            return Positioned(
                              left: position,
                              top: 75 - tickHeight, // Center ticks at 75px (middle of 150px container)
                              child: Container(
                                width: isMajorTick ? 2.0 : 1.5,
                                height: tickHeight,
                                color: ThemeHelper.textPrimary.withOpacity(isMinorTick ? 0.6 : 1.0),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
    
      ],
    );
  }
}

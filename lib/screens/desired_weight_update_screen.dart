import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../authentication/user.controller.dart' show UserController;
import '../constants/app_constants.dart' show AppConstants;

class DesiredWeightUpdateScreen extends StatefulWidget {
  final bool isUpdatingTarget; // true => targetWeight, false => weight

  const DesiredWeightUpdateScreen({super.key, required this.isUpdatingTarget});

  @override
  State<DesiredWeightUpdateScreen> createState() => _DesiredWeightUpdateScreenState();
}

class _DesiredWeightUpdateScreenState extends State<DesiredWeightUpdateScreen> {
  late final UserController _userController;

  // Unit: true = lbs, false = kg
  bool _isLbs = false;

  // Current weight value (in current unit)
  double _currentWeight = 70.0;

  // Saving state for API call
  bool _isSaving = false;

  // Ranges
  static const double _minWeightLbs = 50.0;
  static const double _maxWeightLbs = 500.0;
  static const double _minWeightKg = 22.7;
  static const double _maxWeightKg = 227.0;

  // Conversions
  static const double _lbsToKg = 0.453592;
  static const double _kgToLbs = 2.20462;

  @override
  void initState() {
    super.initState();
    _userController = Get.find<UserController>();

    // Determine initial unit from user profile if available
    final String units = (_userController.userData['units'] ?? '').toString();
    _isLbs = units.toLowerCase() == 'imperial';

    // Load initial value from user data
    final dynamic raw = widget.isUpdatingTarget
        ? _userController.userData['targetWeight']
        : _userController.userData['weight'];
    double initialKg;
    if (raw is num) {
      initialKg = raw.toDouble();
    } else {
      initialKg = double.tryParse('${raw ?? ''}') ?? 70.0;
    }
    _currentWeight = _isLbs ? (initialKg * _kgToLbs) : initialKg;
  }

  void _toggleUnit() {
    setState(() {
      if (_isLbs) {
        // Switch to kg
        _currentWeight = _currentWeight * _lbsToKg;
        _isLbs = false;
      } else {
        // Switch to lbs
        _currentWeight = _currentWeight * _kgToLbs;
        _isLbs = true;
      }
    });
  }

  void _updateWeight(double newWeight) {
    setState(() {
      _currentWeight = newWeight;
    });
  }

  double _getMinWeight() => _isLbs ? _minWeightLbs : _minWeightKg;
  double _getMaxWeight() => _isLbs ? _maxWeightLbs : _maxWeightKg;

  double _getSliderWidth(BuildContext context) {
    final double minWeight = _getMinWeight();
    final double maxWeight = _getMaxWeight();
    final double percentage = (_currentWeight - minWeight) / (maxWeight - minWeight);
    final double clamped = percentage.clamp(0.0, 1.0);
    return (MediaQuery.of(context).size.width - 40) * clamped;
  }

  double _getPointerPosition(BuildContext context) {
    final double minWeight = _getMinWeight();
    final double maxWeight = _getMaxWeight();
    final double percentage = (_currentWeight - minWeight) / (maxWeight - minWeight);
    final double clamped = percentage.clamp(0.0, 1.0);
    return 20 + ((MediaQuery.of(context).size.width - 40) * clamped) - 1;
  }

  void _updateWeightFromPosition(BuildContext context, double localDx) {
    final double containerWidth = MediaQuery.of(context).size.width - 40;
    final double percentage = (localDx - 20) / containerWidth;
    final double clamped = percentage.clamp(0.0, 1.0);
    final double minWeight = _getMinWeight();
    final double maxWeight = _getMaxWeight();
    final double newWeight = minWeight + (clamped * (maxWeight - minWeight));
    _updateWeight(newWeight);
  }

  String _formatWeight(double w) => _isLbs ? '${w.toStringAsFixed(1)} lbs' : '${w.toStringAsFixed(1)} kg';

  Future<void> _save() async {
    if (_isSaving) return;
    // Always save as kg to backend
    final double valueKg = _isLbs ? (_currentWeight * _lbsToKg) : _currentWeight;
    final String key = widget.isUpdatingTarget ? 'targetWeight' : 'weight';
    final Map<String, dynamic> data = {key: num.parse(valueKg.toStringAsFixed(1))};
    final String userId = AppConstants.userId;
    if (userId.isEmpty) return;

    setState(() {
      _isSaving = true;
    });
    try {
      final bool ok = await _userController.updateUser(userId, data, context, Get.find(), Get.find());
      if (ok) {
        await _userController.getUserData(userId);
        if (mounted) Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.isUpdatingTarget ? 'Update Target Weight' : 'Log Weight';
    final String subtitle = widget.isUpdatingTarget ? 'Set your goal weight' : 'Enter your current weight';
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        middle: Text(title, style: const TextStyle(color: CupertinoColors.black)),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.black),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: 40),
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
                          style: TextStyle(
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
                          style: TextStyle(
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
            Center(
              child: Text(
                _formatWeight(_currentWeight),
                style: const TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: GestureDetector(
                    onPanStart: (d) => _updateWeightFromPosition(context, d.localPosition.dx),
                    onPanUpdate: (d) => _updateWeightFromPosition(context, d.localPosition.dx),
                    onTapDown: (d) => _updateWeightFromPosition(context, d.localPosition.dx),
                    child: Stack(
                      children: [
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
                        Positioned(
                          left: 20,
                          top: 15,
                          child: Container(
                            width: _getSliderWidth(context),
                            height: 35,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  CupertinoColors.systemGrey.withOpacity(0.8),
                                  CupertinoColors.systemGrey.withOpacity(0.5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                        Positioned(
                          left: _getPointerPosition(context),
                          top: -25,
                          child: Container(
                            width: 2,
                            height: 75,
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: _isSaving ? null : _save,
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: _isSaving ? CupertinoColors.black.withOpacity(0.6) : CupertinoColors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CupertinoActivityIndicator(color: CupertinoColors.white),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



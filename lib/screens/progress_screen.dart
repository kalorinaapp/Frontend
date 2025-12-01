// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'confirm_weight_screen.dart' show ConfirmWeightScreen;
import 'progress_photos_screen.dart' show ProgressPhotosScreen, ProgressPhotoItem;
import 'progress_photo_detail_screen.dart' show ProgressPhotoDetailScreen;
import '../controllers/progress_photos_card_controller.dart';
import '../providers/theme_provider.dart';
import '../providers/health_provider.dart';
import '../providers/language_provider.dart';
import '../utils/theme_helper.dart';
import 'package:get/get.dart';
import '../authentication/user.controller.dart' show UserController;
import '../constants/app_constants.dart' show AppConstants;
import 'desired_weight_update_screen.dart' show DesiredWeightUpdateScreen;
import '../services/progress_service.dart';
import '../services/streak_service.dart';
import '../utils/user.prefs.dart' show UserPrefs;
import '../l10n/app_localizations.dart';
import 'log_streak_screen.dart';

class ProgressScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  final HealthProvider healthProvider;
  final VoidCallback? onWeightLogged;

  const ProgressScreen({
    super.key, 
    required this.themeProvider, 
    required this.healthProvider,
    this.onWeightLogged,
  });

  // Format a weight value to at most 2 decimal places (trim trailing zeros)
  static String _formatWeight2dp(num? value) {
    if (value == null) return '-';
    String s = value.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '');
      s = s.replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Helper method to check if weigh-in is due today
  Future<bool> _isWeighInDueToday() async {
    final DateTime? lastWeighIn = await UserPrefs.getLastWeighInDate();
    if (lastWeighIn == null) return true; // If no previous weigh-in, suggest weighing in
    
    final DateTime now = DateTime.now();
    final int daysSince = now.difference(lastWeighIn).inDays;
    
    // Dynamic cadence based on user's weigh-in pattern
    int suggestedCadence;
    if (daysSince <= 3) {
      suggestedCadence = 3; // Frequent weighers
    } else if (daysSince <= 7) {
      suggestedCadence = 7; // Regular weighers
    } else {
      suggestedCadence = 14; // Less frequent weighers
    }
    
    final int remaining = suggestedCadence - daysSince;
    return remaining <= 0; // Due today or overdue
    }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Ensure UserController is available (will throw if not previously put)
    final UserController userController = Get.find<UserController>();
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: Listenable.merge([widget.themeProvider, widget.healthProvider]),
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: ThemeHelper.background,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
              l10n.progress,
              style: ThemeHelper.textStyleWithColor(
                ThemeHelper.title1,
                ThemeHelper.textPrimary,
              ),
            ),
                    _HeaderBadge(),
                  ],
                ),
                const SizedBox(height: 30),
                _FadeSlideIn(child: _WeightOverviewCard()),
                const SizedBox(height: 12),
                 Transform.scale(scaleX: 1.5, child: Divider(color: ThemeHelper.divider)),
                 const SizedBox(height: 12),
                _FadeSlideIn(
                  duration: const Duration(milliseconds: 500),
                  child: FutureBuilder<bool>(
                    future: _isWeighInDueToday(),
                    builder: (context, snapshot) {
                      return Obx(() {
                        dynamic w = userController.userData['weight'];
                        // Fallbacks if API nests data differently
                        w ??= (userController.userData['data'] is Map) ? userController.userData['data']['weight'] : null;
                        w ??= (userController.userData['user'] is Map) ? userController.userData['user']['weight'] : null;
                        // Last resort fallback if stored in constants
                        w ??= AppConstants.userId.isNotEmpty ? null : null;
                        final num? weightNum = w is num ? w : num.tryParse('${w ?? ''}');
                        final String weightStr = ProgressScreen._formatWeight2dp(weightNum);
                        return _WeightTile(
                          title: l10n.myWeight,
                          value: '$weightStr kg',
                          trailingLabel: l10n.logWeight,
                          leadingIcon: 'assets/icons/export.png',
                          isUpdateTarget: false,
                          isWeighInDueToday: snapshot.data ?? false,
                          onWeightLogged: widget.onWeightLogged,
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                _FadeSlideIn(
                  duration: const Duration(milliseconds: 550),
                  child: FutureBuilder<bool>(
                    future: _isWeighInDueToday(),
                    builder: (context, snapshot) {
                      return Obx(() {
                        dynamic tw = userController.userData['targetWeight'];
                        // Fallbacks if API nests data differently
                        tw ??= (userController.userData['data'] is Map) ? userController.userData['data']['targetWeight'] : null;
                        tw ??= (userController.userData['user'] is Map) ? userController.userData['user']['targetWeight'] : null;
                        final num? targetNum = tw is num ? tw : num.tryParse('${tw ?? ''}');
                        final String targetStr = ProgressScreen._formatWeight2dp(targetNum);
                        return _WeightTile(
                          title: l10n.targetWeight,
                          value: '$targetStr kg',
                          trailingLabel: l10n.update,
                          leadingIcon: 'assets/icons/trophy.png',
                          isUpdateTarget: true,
                          isWeighInDueToday: snapshot.data ?? false,
                          onWeightLogged: widget.onWeightLogged,
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),
               
                _FadeSlideIn(child: _GoalProgressCard()),
                const SizedBox(height: 12),
                _FadeSlideIn(child: _WeeklySummaryStrip()),
                const SizedBox(height: 12),
                _FadeSlideIn(
                  duration: const Duration(milliseconds: 550),
                  child: FutureBuilder<bool>(
                    future: _isWeighInDueToday(),
                    builder: (context, snapshot) {
                      return _ProgressPhotosCard(
                        isWeighInDueToday: snapshot.data ?? false,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _FadeSlideIn(child: _StreakCard()),
                const SizedBox(height: 12),
                _FadeSlideIn(
                  duration: const Duration(milliseconds: 500),
                  child: _StepsCard(healthProvider: widget.healthProvider),
                ),
                const SizedBox(height: 12),
                _FadeSlideIn(
                  duration: const Duration(milliseconds: 550),
                  child: _AddBurnedToGoalCard(healthProvider: widget.healthProvider),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderBadge extends StatefulWidget {
  @override
  State<_HeaderBadge> createState() => _HeaderBadgeState();
}

class _HeaderBadgeState extends State<_HeaderBadge> {
  int _daysRemaining = 7;
  bool _isDueToday = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Method to refresh the badge (can be called when user logs new weight)
  void refreshBadge() {
    _isDueToday = false; // Reset flag before reloading
    _load();
  }

  Future<void> _load() async {
    // Get the last weigh-in date
    final DateTime? lastWeighIn = await UserPrefs.getLastWeighInDate();
    if (lastWeighIn == null) {
      // If no previous weigh-in, show 7 days as default
      if (!mounted) return;
      setState(() {
        _daysRemaining = 7;
      });
      return;
    }
    
    // Calculate days since last weigh-in
    final DateTime now = DateTime.now();
    final int daysSince = now.difference(lastWeighIn).inDays;
    
    // Dynamic cadence based on user's weigh-in pattern
    // If user weighs in frequently (every 1-3 days), suggest 3 days
    // If user weighs in moderately (every 4-7 days), suggest 7 days  
    // If user weighs in less frequently (8+ days), suggest 14 days
    int suggestedCadence;
    if (daysSince <= 3) {
      suggestedCadence = 3; // Frequent weighers
    } else if (daysSince <= 7) {
      suggestedCadence = 7; // Regular weighers
    } else {
      suggestedCadence = 14; // Less frequent weighers
    }
    
    // Calculate remaining days based on the dynamic cadence
    final int remaining = suggestedCadence - daysSince;
    if (!mounted) return;
    setState(() {
      if (remaining <= 0) {
        _daysRemaining = 0; // Due today or overdue
        _isDueToday = (remaining == 0); // Exactly due today
      } else {
        _daysRemaining = remaining;
        _isDueToday = false;
      }
    });
  }

  String _label() {
    final l10n = AppLocalizations.of(context)!;
    if (_daysRemaining <= 0) {
      if (_isDueToday) {
        return "Next Weigh-In: Today";
      } else {
        return l10n.weighInDue;
      }
    }
    return l10n.nextWeighIn(_daysRemaining);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFE9D15),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 3),
          ],
        ),
        child: Text(
          _label(),
          style: ThemeHelper.textStyleWithColor(ThemeHelper.footnote, Colors.white),
        ),
      ),
    );
  }
}

/// Simple reusable fade + slide-in animation for cards/rows.
class _FadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const _FadeSlideIn({
    required this.child,
    this.duration = const Duration(milliseconds: 450),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _WeightOverviewCard extends StatefulWidget {
  @override
  State<_WeightOverviewCard> createState() => _WeightOverviewCardState();
}

class _WeightOverviewCardState extends State<_WeightOverviewCard> {
  final ProgressService _service = ProgressService();
  double? _lastWeight;
  double? _prevWeight;
  bool _loading = false;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!_hasLoaded) {
      _load();
    }
  }

  Future<void> _load() async {
    if (_hasLoaded || _loading) return;
    setState(() { _loading = true; });
    final res = await _service.fetchWeightHistory(page: 1, limit: 30);
    if (!mounted) return;
    try {
      if (res != null && res['success'] == true) {
        final List<dynamic> logs = (res['logs'] as List<dynamic>? ?? <dynamic>[]);
        if (logs.isNotEmpty) {
          // Parse and sort logs by date (newest first)
          final List<Map<String, dynamic>> parsedLogs = logs.map((e) {
            final loggedAt = DateTime.tryParse((e['loggedAt'] ?? '') as String);
            final weight = (e['weight'] as num?)?.toDouble();
            return {
              'loggedAt': loggedAt,
              'weight': weight,
              'dateOnly': loggedAt != null ? DateTime(loggedAt.year, loggedAt.month, loggedAt.day) : null,
            };
          }).where((m) => m['loggedAt'] != null && m['weight'] != null).toList();

          parsedLogs.sort((a, b) {
            final da = (a['loggedAt'] as DateTime?)?.millisecondsSinceEpoch ?? 0;
            final db = (b['loggedAt'] as DateTime?)?.millisecondsSinceEpoch ?? 0;
            return db.compareTo(da); // newest first
          });

          if (parsedLogs.isNotEmpty) {
            _lastWeight = parsedLogs.first['weight'] as double?;
            
            // Use the immediately previous entry (second most recent) for "since last weigh-in"
            if (parsedLogs.length > 1) {
              _prevWeight = parsedLogs[1]['weight'] as double?;
            }
          }
        }
      }
      _hasLoaded = true;
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.9,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
        decoration: BoxDecoration(
          color: ThemeHelper.cardBackground,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(color: ThemeHelper.textPrimary.withOpacity(0.1), blurRadius: 1, spreadRadius: 1),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final UserController uc = Get.find<UserController>();
              dynamic w = uc.userData['weight'];
              dynamic tw = uc.userData['targetWeight'];
              // Fallbacks for nested shapes
              w ??= (uc.userData['data'] is Map) ? uc.userData['data']['weight'] : null;
              w ??= (uc.userData['user'] is Map) ? uc.userData['user']['weight'] : null;
              tw ??= (uc.userData['data'] is Map) ? uc.userData['data']['targetWeight'] : null;
              tw ??= (uc.userData['user'] is Map) ? uc.userData['user']['targetWeight'] : null;
              final num? weightNum = w is num ? w : num.tryParse('${w ?? ''}');
              final num? targetNum = tw is num ? tw : num.tryParse('${tw ?? ''}');
              final String weightStr = ProgressScreen._formatWeight2dp(weightNum);
              final String targetStr = ProgressScreen._formatWeight2dp(targetNum);
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _KgValue(big: weightStr, small: 'kg'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(CupertinoIcons.arrow_right, size: 28, color: ThemeHelper.textPrimary),
                  ),
                  _KgValue(big: targetStr, small: 'kg'),
                ],
              );
            }),
            const SizedBox(height: 12),
            Divider(color: ThemeHelper.divider, height: 1),
            const SizedBox(height: 12),
            Obx(() {
              final UserController uc = Get.find<UserController>();
              dynamic rw = uc.userData['weight'];
              dynamic rtw = uc.userData['targetWeight'];
              // Fallbacks for nested shapes
              rw ??= (uc.userData['data'] is Map) ? uc.userData['data']['weight'] : null;
              rw ??= (uc.userData['user'] is Map) ? uc.userData['user']['weight'] : null;
              rtw ??= (uc.userData['data'] is Map) ? uc.userData['data']['targetWeight'] : null;
              rtw ??= (uc.userData['user'] is Map) ? uc.userData['user']['targetWeight'] : null;
              final num? w = rw is num ? rw : num.tryParse('${rw ?? ''}');
              final num? tw = rtw is num ? rtw : num.tryParse('${rtw ?? ''}');
              final l10n = AppLocalizations.of(context)!;
              String progressText = l10n.toTargetWeight;
              if (w != null && tw != null && w > 0) {
                final diff = (w - tw).abs();
                // Simple progress estimate: show remaining kg to target
                progressText = '${diff.toStringAsFixed(1)} kg ${l10n.toTargetWeight.toLowerCase()}';
              }
              return Text(
                progressText,
                style: ThemeHelper.textStyleWithColor(ThemeHelper.body1, ThemeHelper.textPrimary),
              );
            }),
            const SizedBox(height: 4),
            if (_loading)
              Shimmer.fromColors(
                baseColor: ThemeHelper.divider,
                highlightColor: ThemeHelper.cardBackground,
                child: Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: ThemeHelper.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )
            else
              Text(
                _deltaText(),
                style: ThemeHelper.textStyleWithColor(ThemeHelper.footnote, ThemeHelper.textSecondary),
              ),
            
          ],
        ),
      ),
    );
  }
  String _deltaText() {
    if (_lastWeight != null && _prevWeight != null) {
      final d = _lastWeight! - _prevWeight!;
      if (d.abs() < 0.01) {
        // If difference is essentially zero, show 0.0
        return '0.0 ${AppLocalizations.of(context)!.kg} ${AppLocalizations.of(context)!.sinceLastWeighIn}';
      }
      final sign = d > 0 ? '+' : '';
      return '$sign${d.toStringAsFixed(1)} ${AppLocalizations.of(context)!.kg} ${AppLocalizations.of(context)!.sinceLastWeighIn}';
    }
    // If only one weight entry or no previous weight, show the current weight if available
    if (_lastWeight != null) {
      return '${_lastWeight!.toStringAsFixed(1)} ${AppLocalizations.of(context)!.kg} (first weigh-in)';
    }
    // If no weight data at all
    return '- ${AppLocalizations.of(context)!.kg} ${AppLocalizations.of(context)!.sinceLastWeighIn}';
  }
}

class _KgValue extends StatelessWidget {
  final String big;
  final String small;
  const _KgValue({required this.big, required this.small});
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: big,
            style: ThemeHelper.textStyleWithColor(ThemeHelper.title1, ThemeHelper.textPrimary),
          ),
          TextSpan(
            text: small,
            style: ThemeHelper.textStyleWithColor(ThemeHelper.title3, ThemeHelper.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _WeightTile extends StatefulWidget {
  final String title;
  final String value;
  final String trailingLabel;
  final String leadingIcon;
  final bool isUpdateTarget;
  final bool isWeighInDueToday;
  final VoidCallback? onWeightLogged;
  const _WeightTile({
    required this.title,
    required this.value,
    required this.trailingLabel,
    required this.leadingIcon,
    this.isUpdateTarget = false,
    this.isWeighInDueToday = false,
    this.onWeightLogged,
  });

  @override
  State<_WeightTile> createState() => _WeightTileState();
}

class _WeightTileState extends State<_WeightTile> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -2.0), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: -2.0, end: 2.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 2.0, end: -1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: -1.0, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOut,
    ));
    
    // Start the periodic shake animation if weigh-in is due today
    if (!widget.isUpdateTarget && widget.isWeighInDueToday) {
      _startPeriodicShake();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _startPeriodicShake() {
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && !widget.isUpdateTarget && widget.isWeighInDueToday) {
        _shakeController.forward().then((_) {
          _shakeController.reverse().then((_) {
            // Schedule next shake with random interval between 8-10 seconds
            final randomDelay = 8 + (DateTime.now().millisecondsSinceEpoch % 3);
            Future.delayed(Duration(seconds: randomDelay), () {
              _startPeriodicShake();
            });
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(color: ThemeHelper.textPrimary.withOpacity(0.1), blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Row(
        children: [
          Image.asset(widget.leadingIcon, width: 44, height: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: ThemeHelper.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ThemeHelper.textPrimary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (ctx) => DesiredWeightUpdateScreen(isUpdatingTarget: widget.isUpdateTarget),
                ),
              );
              // Call the callback to refresh weigh-in status after returning
              if (widget.onWeightLogged != null) {
                widget.onWeightLogged!();
              }
            },
            child: _buildUpdateButton(context, widget.isUpdateTarget),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context, bool isUpdateTarget) {
    // Check if this is the weight row (not target weight) and if weigh-in is due today
    if (!isUpdateTarget && widget.isWeighInDueToday) {
      // Show custom orange button with shake animation when weigh-in is due today
      return AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: Container(
              width: 60,
              height: 30,
              decoration: ShapeDecoration(
                color: const Color(0xFFFE9D15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 3,
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Center(
                child: Text(
                  'UPDATE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      // For target weight, show the original button
      return Row(
        children: [
          Text(
            AppLocalizations.of(context)!.update,
            style: TextStyle(color: ThemeHelper.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 6),
          Icon(CupertinoIcons.pencil, size: 14, color: ThemeHelper.textSecondary),
        ],
      );
    }
  }
}

class _GoalProgressCard extends StatefulWidget {
  @override
  State<_GoalProgressCard> createState() => _GoalProgressCardState();
}

class _ChartSample {
  final DateTime date;
  final double weight;
  const _ChartSample({required this.date, required this.weight});
}

class _GoalProgressCardState extends State<_GoalProgressCard> {
  List<String> _getRanges(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [l10n.thirtyDays, l10n.ninetyDays, l10n.sixMonths, l10n.oneYear, l10n.allTime];
  }
  int _selectedIndex = 0;
  final ProgressService _service =  ProgressService();
  double? _lastWeight;
  double? _prevWeight;
  bool _loadingHistory = false;
  List<_ChartSample> _series = const [];
  Map<String, dynamic>? _summary;
  bool _hasLoadedHistory = false;
  bool _hasLoadedSummary = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoadedHistory) _loadHistory();
      if (!_hasLoadedSummary) _loadSummary();
    });
  }

  Future<void> _loadHistory() async {
    if (_hasLoadedHistory || _loadingHistory) return;
    setState(() { _loadingHistory = true; });
    final res = await _service.fetchWeightHistory(page: 1, limit: 30);
    if (!mounted) return;
    try {
      if (res != null && res['success'] == true) {
        final List<dynamic> logs = (res['logs'] as List<dynamic>? ?? <dynamic>[]);
        if (logs.isNotEmpty) {
          // Parse and sort logs by date (newest first)
          final List<Map<String, dynamic>> parsedLogs = logs.map((e) {
            final loggedAt = DateTime.tryParse((e['loggedAt'] ?? '') as String);
            final weight = (e['weight'] as num?)?.toDouble();
            return {
              'loggedAt': loggedAt,
              'weight': weight,
              'dateOnly': loggedAt != null ? DateTime(loggedAt.year, loggedAt.month, loggedAt.day) : null,
            };
          }).where((m) => m['loggedAt'] != null && m['weight'] != null).toList();

          parsedLogs.sort((a, b) {
            final da = (a['loggedAt'] as DateTime?)?.millisecondsSinceEpoch ?? 0;
            final db = (b['loggedAt'] as DateTime?)?.millisecondsSinceEpoch ?? 0;
            return db.compareTo(da); // newest first
          });

          if (parsedLogs.isNotEmpty) {
            _lastWeight = parsedLogs.first['weight'] as double?;
            
            // Use the immediately previous entry (second most recent) for "since last weigh-in"
            if (parsedLogs.length > 1) {
              _prevWeight = parsedLogs[1]['weight'] as double?;
            }
          
            final samples = parsedLogs.reversed
                .map((e) {
                  final d = e['loggedAt'] as DateTime?;
                  final w = e['weight'] as double?;
                  if (d == null || w == null) return null;
                  return _ChartSample(date: d, weight: w);
                })
                .whereType<_ChartSample>()
                .toList();
            _series = samples;
          }
        }
      }
      _hasLoadedHistory = true;
    } finally {
      if (mounted) setState(() { _loadingHistory = false; });
    }
  }

  Future<void> _loadSummary() async {
    if (_hasLoadedSummary) return;
    final res = await _service.fetchWeightSummary();
    if (!mounted) return;
    if (res != null && res['success'] == true) {
      setState(() {
        _summary = Map<String, dynamic>.from(res['summary'] as Map);
        _series = _seriesForIndex(_selectedIndex);
      });
      _hasLoadedSummary = true;
    }
  }

  List<_ChartSample> _seriesForIndex(int idx) {
    if (_summary == null) return _series;
    String key;
    switch (idx) {
      case 0: key = 'last30d'; break;
      case 1: key = 'last90d'; break;
      case 2: key = 'last6m'; break;
      case 3: key = 'last1y'; break;
      default: key = 'allTime';
    }
    final Map<String, dynamic>? bucket = (_summary![key] as Map<String, dynamic>?);
    final List<dynamic> points = (bucket?['points'] as List<dynamic>? ?? <dynamic>[]);
    // Sort by loggedAt ascending (oldest -> newest)
    points.sort((a, b) {
      final da = DateTime.tryParse((a['loggedAt'] ?? '') as String)?.millisecondsSinceEpoch ?? 0;
      final db = DateTime.tryParse((b['loggedAt'] ?? '') as String)?.millisecondsSinceEpoch ?? 0;
      return da.compareTo(db);
    });

    final List<_ChartSample> samples = [];
    for (final e in points) {
      final loggedAtStr = (e['loggedAt'] ?? '') as String;
      final d = DateTime.tryParse(loggedAtStr);
      final w = (e['weight'] as num?)?.toDouble();
      if (d != null && w != null) {
        samples.add(_ChartSample(date: d, weight: w));
      }
    }
    if (samples.isEmpty) return const [];

    return samples;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.weightGoalProgress, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ThemeHelper.textPrimary)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_getRanges(context).length, (i) {
                final bool selected = i == _selectedIndex;
                return Padding(
                  padding: EdgeInsets.only(right: i == _getRanges(context).length - 1 ? 0 : 8),
                  child: _chip(
                    _getRanges(context)[i],
                    selected: selected,
                    onTap: () => setState(() {
                      _selectedIndex = i;
                      _series = _seriesForIndex(i);
                    }),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          Builder(
            builder: (context) {
              final now = DateTime.now();
              late DateTime rangeStart;
              final DateTime rangeEnd = now;
              switch (_selectedIndex) {
                case 0:
                  rangeStart = now.subtract(const Duration(days: 30));
                  break;
                case 1:
                  rangeStart = now.subtract(const Duration(days: 90));
                  break;
                case 2:
                  rangeStart = DateTime(now.year, now.month - 6, now.day);
                  break;
                case 3:
                  rangeStart = DateTime(now.year - 1, now.month, now.day);
                  break;
                case 4:
                  if (_series.isNotEmpty) {
                    // All time: start from first sample date
                    rangeStart = _series.first.date;
                  } else {
                    rangeStart = now.subtract(const Duration(days: 30));
                  }
                  break;
                default:
                  rangeStart = now.subtract(const Duration(days: 30));
              }

              return _ChartPlaceholder(
                leftLabel: _startLabelForRange(_selectedIndex, context),
                rightLabel: _endLabelForRange(_selectedIndex, context),
                samples: List<_ChartSample>.from(_series),
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
              );
            },
          ),
          const SizedBox(height: 8),
          Builder(builder: (context) {
            if (_loadingHistory) {
              return Shimmer.fromColors(
                baseColor: ThemeHelper.divider,
                highlightColor: ThemeHelper.cardBackground,
                child: Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: ThemeHelper.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }
            double? delta;
            if (_lastWeight != null && _prevWeight != null) {
              delta = _lastWeight! - _prevWeight!;
            }
            final String subtitle;
            if (delta != null) {
              if (delta.abs() < 0.01) {
                subtitle = '0.0 ${AppLocalizations.of(context)!.kg} ${AppLocalizations.of(context)!.sinceLastWeighIn}';
              } else {
                subtitle = '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} ${AppLocalizations.of(context)!.kg} ${AppLocalizations.of(context)!.sinceLastWeighIn}';
              }
            } else if (_lastWeight != null) {
              subtitle = '${_lastWeight!.toStringAsFixed(1)} ${AppLocalizations.of(context)!.kg} (first weigh-in)';
            } else {
              subtitle = '- ${AppLocalizations.of(context)!.kg} ${AppLocalizations.of(context)!.sinceLastWeighIn}';
            }
            return Text(
              subtitle,
              style: ThemeHelper.textStyleWithColor(ThemeHelper.footnote, ThemeHelper.textSecondary),
            );
          }),
        ],
      ),
    );
  }

  Widget _chip(String label, {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? ThemeHelper.textPrimary : ThemeHelper.cardBackground,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: ThemeHelper.textPrimary.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? ThemeHelper.background : ThemeHelper.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final m = months[d.month - 1];
    return '$m ${d.day}';
  }

  String _startLabelForRange(int index, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    switch (index) {
      case 0: // 30 Days
        return _formatDate(now.subtract(const Duration(days: 30)));
      case 1: // 90 Days
        return _formatDate(now.subtract(const Duration(days: 90)));
      case 2: // 6 Months
        final d = DateTime(now.year, now.month - 6, now.day);
        return _formatDate(d);
      case 3: // 1 Year
        final d = DateTime(now.year - 1, now.month, now.day);
        return _formatDate(d);
      case 4: // All Time
        return l10n.start;
      default:
        return _formatDate(now);
    }
  }

  String _endLabelForRange(int index, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    if (index == 4) return l10n.now;
    return _formatDate(now);
  }
}

class _ChartPlaceholder extends StatefulWidget {
  final String leftLabel;
  final String rightLabel;
  final List<_ChartSample> samples; // date + weight
  final DateTime rangeStart;
  final DateTime rangeEnd;

  const _ChartPlaceholder({
    required this.leftLabel,
    required this.rightLabel,
    this.samples = const [],
    required this.rangeStart,
    required this.rangeEnd,
  });
  
  @override
  State<_ChartPlaceholder> createState() => _ChartPlaceholderState();
}

class _ChartPlaceholderState extends State<_ChartPlaceholder> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(color: ThemeHelper.textPrimary.withOpacity(0.1), blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 48,
          height: 232,
          child: Stack(
            children: [
              // Fixed Y-axis labels
              LayoutBuilder(
                builder: (context, constraints) {
                  final double totalHeight = constraints.maxHeight;
                  const double xAxisReserved = 28;
                  final double chartHeight = totalHeight - xAxisReserved;

                  double yForFraction(double f) => f * chartHeight;

                  Widget lineRow(String label, double fraction) {
                    return Positioned(
                      left: 0,
                      top: yForFraction(fraction),
                      child: SizedBox(
                        width: 24,
                        child: Text(label,
                            style: TextStyle(fontSize: 12, color: ThemeHelper.textPrimary)),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      lineRow('65', 0.10),
                      lineRow('70', 0.40),
                      lineRow('75', 0.70),
                      lineRow('80', 0.90),
                    ],
                  );
                },
              ),
              // Fixed X-axis labels - show date range
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.leftLabel, style: TextStyle(fontSize: 11, color: ThemeHelper.textPrimary)),
                      Text(widget.rightLabel, style: TextStyle(fontSize: 11, color: ThemeHelper.textPrimary)),
                    ],
                  ),
                ),
              ),
              // Simple chart area without gesture detection
              Positioned(
                left: 24, // Start after Y-axis labels (reduced from 34)
                right: 0,
                top: 0,
                bottom: 28, // Leave space for X-axis
                child: Stack(
                  children: [
                    // Chart line
                    CustomPaint(
                      size: Size.infinite,
                      painter: _SimpleChartPainter(
                        samples: widget.samples,
                        rangeStart: widget.rangeStart,
                        rangeEnd: widget.rangeEnd,
                      ),
                    ),
                    // Weight bubble image at the last point
                    if (widget.samples.isNotEmpty)
                      _buildWeightBubble(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildWeightBubble() {
    if (widget.samples.isEmpty) return const SizedBox.shrink();
    
    // Simple positioning - just place at the end of the chart area
    return Positioned(
      right: 20, // Position from the right edge
      top: 20,   // Position from the top
      child: Stack(
        children: [
          // Weight bubble image
          Image.asset(
            'assets/icons/weight_label.png',
            width: 50,
            height: 24,
            fit: BoxFit.contain,
            color: ThemeHelper.isLightMode ? Colors.black : Colors.white,
          ),
          // Weight text overlay
          Positioned(
            left: 15,
            top: 4,
            child: Text(
              '${ProgressScreen._formatWeight2dp(widget.samples.last.weight)} kg',
              style: TextStyle(
                color: ThemeHelper.isLightMode ? Colors.white : Colors.black,
                fontSize: 8,
                fontFamily: 'Instrument Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Removed _DashedLinePainter class since we now draw dotted lines directly in _LineAreaPainter

class _SimpleChartPainter extends CustomPainter {
  final List<_ChartSample> samples;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  
  _SimpleChartPainter({
    required this.samples,
    required this.rangeStart,
    required this.rangeEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;
    final double chartHeight = size.height;
    final double width = size.width;
    final int n = samples.length;
    if (n < 1) return;

    // Normalize raw weights
    double minW = samples.first.weight;
    double maxW = samples.first.weight;
    for (final s in samples) {
      if (s.weight < minW) minW = s.weight;
      if (s.weight > maxW) maxW = s.weight;
    }
    if ((maxW - minW).abs() < 0.001) {
      maxW = minW + 1.0;
    }
    
    final List<double> norm = samples
        .map((s) => ((s.weight - minW) / (maxW - minW)).clamp(0.0, 1.0))
        .map((v) => 1.0 - v)
        .toList();

    final double rangeMs = (rangeEnd.millisecondsSinceEpoch - rangeStart.millisecondsSinceEpoch).toDouble();
    if (rangeMs <= 0) return;

    // Build points
    final List<Offset> pts = List.generate(n, (i) {
      final sample = samples[i];
      final double t = ((sample.date.millisecondsSinceEpoch - rangeStart.millisecondsSinceEpoch) / rangeMs)
          .clamp(0.0, 1.0);
      final double x = t * width;
      final double y = (1.0 - norm[i]) * chartHeight;
      return Offset(x, y);
    });

    // Draw dotted curved line
    if (n > 1) {
      final Paint dottedLinePaint = Paint()
        ..color = ThemeHelper.textPrimary.withOpacity(0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      
      const double dashWidth = 4;
      const double dashGap = 3;
      
      // Draw dotted line manually
      for (int i = 0; i < pts.length - 1; i++) {
        final Offset start = pts[i];
        final Offset end = pts[i + 1];
        final double distance = (end - start).distance;
        final int segments = (distance / (dashWidth + dashGap)).ceil();
        
        for (int j = 0; j < segments; j++) {
          final double t1 = j * (dashWidth + dashGap) / distance;
          final double t2 = (j * (dashWidth + dashGap) + dashWidth) / distance;
          if (t1 < 1.0) {
            final Offset p1 = Offset.lerp(start, end, t1.clamp(0.0, 1.0))!;
            final Offset p2 = Offset.lerp(start, end, t2.clamp(0.0, 1.0))!;
            canvas.drawLine(p1, p2, dottedLinePaint);
          }
        }
      }
    }

    // Note: Bubble will be drawn using Image widget in the Stack, not in CustomPaint
  }

  @override
  bool shouldRepaint(covariant _SimpleChartPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.rangeStart != rangeStart ||
        oldDelegate.rangeEnd != rangeEnd;
  }
}

// Removed _LineAreaPainter class since we now use _InteractiveChartPainter

class _WeeklySummaryStrip extends StatefulWidget {
  @override
  State<_WeeklySummaryStrip> createState() => _WeeklySummaryStripState();
}

class _WeeklySummaryStripState extends State<_WeeklySummaryStrip> {
  final ProgressService _service =  ProgressService();
  String _headline = 'Great job!';
  String _headlineDeltaText = '';
  String _avgLabel = '';
  String _avgText = '- kg/day';
  String _toGoText = '- kg to go';
  bool _loading = false;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) _load();
    });
  }

  Future<void> _load() async {
    if (_hasLoaded || _loading) return;
    setState(() { _loading = true; });
    final res = await _service.fetchWeightHistory(page: 1, limit: 60);
    if (!mounted) return;
    try {
      if (res != null && res['success'] == true) {
        final List<dynamic> logs = (res['logs'] as List<dynamic>? ?? <dynamic>[]);
        if (logs.isNotEmpty) {
          // Get user controller and target weight
          final UserController uc = Get.find<UserController>();
          final double? target = (uc.userData['targetWeight'] as num?)?.toDouble() ??
              (uc.userData['data'] is Map ? (uc.userData['data']['targetWeight'] as num?)?.toDouble() : null) ??
              (uc.userData['user'] is Map ? (uc.userData['user']['targetWeight'] as num?)?.toDouble() : null);

          // Parse all logs with their dates and weights
          final List<Map<String, dynamic>> parsedLogs = logs.map((e) {
            final loggedAt = DateTime.tryParse((e['loggedAt'] ?? '') as String);
            final weight = (e['weight'] as num?)?.toDouble();
            return {
              'loggedAt': loggedAt,
              'weight': weight,
              'timestamp': loggedAt?.millisecondsSinceEpoch ?? 0,
            };
          }).where((m) => m['loggedAt'] != null && m['weight'] != null).toList();

          if (parsedLogs.isEmpty) {
            if (mounted) setState(() { _loading = false; });
            return;
          }

          // Sort by date (ascending - oldest first)
          parsedLogs.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));

          // Get the most recent weight (last entry)
          final Map<String, dynamic> latestEntry = parsedLogs.last;
          final double? latestWeight = latestEntry['weight'] as double?;
          final DateTime? latestDate = latestEntry['loggedAt'] as DateTime?;

          if (latestWeight == null || latestDate == null) {
            if (mounted) setState(() { _loading = false; });
            return;
          }

          // Find weight entry closest to exactly 7 days ago
          final DateTime now = DateTime.now();
          final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
          
          Map<String, dynamic>? weekAgoEntry;
          double minDaysDiff = double.infinity;

          for (final entry in parsedLogs) {
            final DateTime? entryDate = entry['loggedAt'] as DateTime?;
            if (entryDate == null) continue;
            
            // Find entry closest to 7 days ago (can be before or after)
            final double daysDiff = (entryDate.difference(sevenDaysAgo).inHours / 24.0).abs();
            if (daysDiff < minDaysDiff && entryDate.isBefore(now)) {
              minDaysDiff = daysDiff;
              weekAgoEntry = entry;
            }
          }

          // If no entry found close to 7 days ago, use the oldest entry
          if (weekAgoEntry == null && parsedLogs.isNotEmpty) {
            weekAgoEntry = parsedLogs.first;
          }

          final double? weekAgoWeight = weekAgoEntry?['weight'] as double?;
          final DateTime? weekAgoDate = weekAgoEntry?['loggedAt'] as DateTime?;

          if (weekAgoWeight == null || weekAgoDate == null) {
            if (mounted) setState(() { _loading = false; });
            return;
          }

          // Calculate delta and days spanned
          final double delta = latestWeight - weekAgoWeight;
          final double spannedDays = (latestDate.difference(weekAgoDate).inHours / 24.0).abs().clamp(1.0, 7.0);

          // Determine status: lost, gained, or maintained
          const double maintainThreshold = 0.2; // Consider changes < 0.2kg as maintained
          final bool isMaintained = delta.abs() < maintainThreshold;
          final bool lost = delta < -maintainThreshold;

          // Calculate average daily progress toward goal
          double avgProgress = 0.0;
          if (target != null && target > 0) {
            final double weekAgoDistToGoal = (weekAgoWeight - target).abs();
            final double latestDistToGoal = (latestWeight - target).abs();
            final double progressTowardGoal = weekAgoDistToGoal - latestDistToGoal; // positive = closer
            avgProgress = progressTowardGoal / spannedDays;
          }

          final String deltaText = delta.abs() < maintainThreshold 
              ? '0.0 ${AppLocalizations.of(context)!.kg}'
              : '${delta.abs().toStringAsFixed(1)} ${AppLocalizations.of(context)!.kg}';
          final String avgText = '${avgProgress >= 0 ? '+' : ''}${avgProgress.toStringAsFixed(2)} ${AppLocalizations.of(context)!.kgPerDay}';

          // Calculate "to go" - use current weight from userData for consistency with other UI elements
          final double? currentWeight = (uc.userData['weight'] as num?)?.toDouble() ??
              (uc.userData['data'] is Map ? (uc.userData['data']['weight'] as num?)?.toDouble() : null) ??
              (uc.userData['user'] is Map ? (uc.userData['user']['weight'] as num?)?.toDouble() : null);
          final double weightForToGo = currentWeight ?? latestWeight;
          final double toGo = (target != null && target > 0) ? (weightForToGo - target) : 0;

          final l10n = AppLocalizations.of(context)!;
          setState(() {
            if (isMaintained) {
              _headline = '${l10n.greatJob} You maintained your weight';
              _headlineDeltaText = '';
            } else if (lost) {
              _headline = '${l10n.greatJob} You lost ';
              _headlineDeltaText = '$deltaText this week';
            } else {
              _headline = '${l10n.greatJob} ${l10n.youGained} ';
              _headlineDeltaText = '$deltaText this week';
            }
            
            if (isMaintained) {
              _avgLabel = 'Avg daily maintained';
              _avgText = '0.00 ${l10n.kgPerDay}';
            } else {
              _avgLabel = lost ? l10n.avgDailyLost : l10n.avgDailyGained;
              _avgText = avgText;
            }
            
            _toGoText = '${toGo.abs().toStringAsFixed(1)} ${l10n.kgToGo}';
          });
          _hasLoaded = true;
        }
      }
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(color: ThemeHelper.textPrimary.withOpacity(0.1), blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: _loading
                ? Shimmer.fromColors(
                    baseColor: ThemeHelper.divider,
                    highlightColor: ThemeHelper.cardBackground,
                    child: Container(
                      height: 20,
                      width: 200,
                      decoration: BoxDecoration(
                        color: ThemeHelper.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                : Text.rich(
                    TextSpan(children: [
                      TextSpan(text: '$_headline ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ThemeHelper.textPrimary)),
                      TextSpan(text: _headlineDeltaText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ThemeHelper.textPrimary)),
                    ]),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(height: 8),
          Divider(color: ThemeHelper.divider, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_avgLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ThemeHelper.textPrimary)),
                  const SizedBox(height: 2),
                  Text(_avgText, style: TextStyle(fontSize: 12, color: ThemeHelper.textPrimary)),
                ],
              ),
              Container(width: 1, height: 28, color: ThemeHelper.divider),
              Text(_toGoText, style: const TextStyle(color: Color(0xFFFE9D15), fontWeight: FontWeight.w600, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressPhotosCard extends StatefulWidget {
  final bool isWeighInDueToday;
  
  const _ProgressPhotosCard({
    this.isWeighInDueToday = false,
  });
  
  @override
  State<_ProgressPhotosCard> createState() => _ProgressPhotosCardState();
}

class _ProgressPhotosCardState extends State<_ProgressPhotosCard> with TickerProviderStateMixin {
  late final ProgressPhotosCardController _controller;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ProgressPhotosCardController());
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -2.0), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: -2.0, end: 2.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 2.0, end: -1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: -1.0, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOut,
    ));
    
    // Start the periodic shake animation if weigh-in is due today
    if (widget.isWeighInDueToday) {
      _startPeriodicShake();
    }
  }

  @override
  void dispose() {
    Get.delete<ProgressPhotosCardController>();
    _shakeController.dispose();
    super.dispose();
  }

  void _startPeriodicShake() {
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && widget.isWeighInDueToday) {
        _shakeController.forward().then((_) {
          _shakeController.reverse().then((_) {
            // Schedule next shake with random interval between 8-10 seconds
            final randomDelay = 8 + (DateTime.now().millisecondsSinceEpoch % 3);
            Future.delayed(Duration(seconds: randomDelay), () {
              _startPeriodicShake();
            });
          });
        });
      }
    });
  }

  String _currentWeightLabel(BuildContext context) {
    try {
      final UserController uc = Get.find<UserController>();
      dynamic w = uc.userData['weight'];
      // Fallbacks for nested shapes
      w ??= (uc.userData['data'] is Map) ? uc.userData['data']['weight'] : null;
      w ??= (uc.userData['user'] is Map) ? uc.userData['user']['weight'] : null;
      if (w is num) return w.toString();
      final parsed = num.tryParse('${w ?? ''}');
      return parsed?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Widget _buildAnimatedUploadButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      height: 99,
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: ThemeHelper.textPrimary.withOpacity(0.1), blurRadius: 3)],
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: Container(
                width: 107,
                height: 30,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFE9D15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 3,
                      offset: Offset(0, 0),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 8,
                      top: 2,
                      child: Text(
                        '+',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          AppLocalizations.of(context)!.uploadPhoto,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Instrument Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSmallAnimatedUploadButton(BuildContext context) {
    return Container(
      width: 88,
      height: 120,
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ThemeHelper.divider),
        boxShadow: [BoxShadow(color: ThemeHelper.textPrimary.withOpacity(0.1), blurRadius: 3)],
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: SizedBox(
                width: 56,
                height: 55,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 56,
                        height: 50,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFE9D15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          shadows: [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 3,
                              offset: Offset(0, 0),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 12,
                      child: SizedBox(
                        width: 56,
                        child: Text(
                          'Upload\nPhoto',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontFamily: 'Instrument Sans',
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 24,
                      child: SizedBox(
                        width: 56,
                        child: Text(
                          '+',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Instrument Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showPickerSheet(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(AppLocalizations.of(context)!.addProgressPhoto),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final XFile? photo = await _controller.picker.pickImage(source: ImageSource.camera, imageQuality: 85);
              if (photo != null) {
                _controller.addLocalImage(photo);
                // Navigate to confirm screen
                await Navigator.of(context).push(CupertinoPageRoute(
                  builder: (_) => ConfirmWeightScreen(
                    weightLabel: _currentWeightLabel(context),
                    imagePaths: [photo.path],
                  ),
                ));
              }
            },
            child: Text(AppLocalizations.of(context)!.camera, style: TextStyle(color: ThemeHelper.textPrimary, fontWeight: FontWeight.w400)),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final List<XFile> files = await _controller.picker.pickMultiImage(imageQuality: 85);
              if (files.isNotEmpty) {
                _controller.addLocalImages(files);
                await Navigator.of(context).push(CupertinoPageRoute(
                  builder: (_) => ConfirmWeightScreen(
                    weightLabel: _currentWeightLabel(context),
                    imagePaths: files.map((f) => f.path).toList(),
                  ),
                ));
              }
            },
            child: Text(AppLocalizations.of(context)!.gallery, style: TextStyle(color: ThemeHelper.textPrimary, fontWeight: FontWeight.w400)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: ThemeHelper.textPrimary, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(color: ThemeHelper.textPrimary.withOpacity(0.1), blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.progressPhotos, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: ThemeHelper.textPrimary)),
                Obx(() {
                  if (_controller.serverPhotos.isNotEmpty || _controller.localImages.isNotEmpty) {
                    return GestureDetector(
                      onTap: () async {
                        // Navigate to progress photos screen with current server photos
                        await Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => ProgressPhotosScreen(
                              photos: _controller.serverPhotos.toList(),
                              shouldFetchFromServer: true,
                            ),
                          ),
                        );
                        // Refresh server photos when returning (in case a photo was deleted)
                        _controller.loadServerPhotos();
                      },
                      child: Container(
                        width: 102,
                        height: 28,
                        decoration: BoxDecoration(
                          color: ThemeHelper.cardBackground,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeHelper.textPrimary.withOpacity(0.1),
                              blurRadius: 5,
                              offset: Offset(0, 0),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 77,
                            height: 15,
                            child: Text(
                              AppLocalizations.of(context)!.seeProgress,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ThemeHelper.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (_controller.serverPhotos.isEmpty && _controller.localImages.isEmpty) {
              return Center(
                child: GestureDetector(
                  onTap: () => _showPickerSheet(context),
                  child:widget.isWeighInDueToday
                      ? _buildAnimatedUploadButton(context)
                      : Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          height: 99,
                          decoration: BoxDecoration(
                            color: ThemeHelper.cardBackground,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [BoxShadow(color: ThemeHelper.textPrimary.withOpacity(0.1), blurRadius: 3)],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppLocalizations.of(context)!.uploadPhoto, style: TextStyle(fontSize: 12, color: ThemeHelper.textSecondary)),
                                SizedBox(height: 4),
                                Text('+', style: TextStyle(fontSize: 22, color: ThemeHelper.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                   GestureDetector(
                    onTap: () => _showPickerSheet(context),
                    child: widget.isWeighInDueToday
                        ? _buildSmallAnimatedUploadButton(context)
                        : Container(
                            width: 88,
                            height: 120,
                            decoration: BoxDecoration(
                              color: ThemeHelper.cardBackground,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: ThemeHelper.divider),
                              boxShadow: [BoxShadow(color: ThemeHelper.textPrimary.withOpacity(0.1), blurRadius: 3)],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppLocalizations.of(context)!.upload, style: TextStyle(fontSize: 12, color: ThemeHelper.textSecondary)),
                                SizedBox(height: 4),
                                Icon(CupertinoIcons.add, size: 18, color: ThemeHelper.textSecondary),
                              ],
                            ),
                          ),
                  ),
                  // Server photos
                  ..._controller.serverPhotos.take(6).map((photo) {
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => ProgressPhotoDetailScreen(
                              photos: _controller.serverPhotos.toList(),
                              initialIndex: _controller.serverPhotos.indexOf(photo),
                              onLoadMore: (page) async {
                                final res = await _controller.service.fetchProgressPhotos(page: page, limit: 60);
                                if (res != null && res['success'] == true) {
                                  final List<dynamic> photosData = (res['photos'] as List<dynamic>? ?? <dynamic>[]);
                                  return photosData.map((p) {
                                    final Map<String, dynamic> m = Map<String, dynamic>.from(p as Map);
                                    final double? w = (m['weight'] as num?)?.toDouble();
                                    final String takenAt = (m['takenAt'] ?? '') as String;
                                    final String photoId = (m['id'] ?? m['_id'] ?? '') as String;
                                    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                                    String dateLabel = '';
                                    try {
                                      final d = DateTime.tryParse(takenAt)?.toLocal();
                                      if (d != null) {
                                        dateLabel = '${months[d.month-1]} ${d.day}, ${d.year}';
                                      }
                                    } catch (_) {}
                                    final String label = w != null ? '${w.toStringAsFixed(1)} kg - $dateLabel' : dateLabel;
                                    return ProgressPhotoItem(
                                      imagePath: (m['imageUrl'] ?? '') as String,
                                      label: label,
                                      isNetwork: true,
                                      weight: w,
                                      takenAt: takenAt,
                                      photoId: photoId,
                                    );
                                  }).toList();
                                }
                                return <ProgressPhotoItem>[];
                              },
                              onPhotoDeleted: (deletedPhotoId) {
                                // Optimistically remove the photo from the card
                                _controller.optimisticallyRemovePhoto(deletedPhotoId);
                              },
                            ),
                          ),
                        );
                        // Refresh after returning
                        _controller.loadServerPhotos();
                      },
                      child: Container(
                        width: 88,
                        height: 120,
                        decoration: ShapeDecoration(
                          image: DecorationImage(
                            image: NetworkImage(photo.imagePath) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  // Local images (not yet uploaded)
                  ..._controller.localImages.map((x) {
                    return Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 120,
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: FileImage(File(x.path)),
                              fit: BoxFit.cover,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StepsCard extends StatefulWidget {
  final HealthProvider healthProvider;
  
  const _StepsCard({required this.healthProvider});

  @override
  State<_StepsCard> createState() => _StepsCardState();
}

class _StepsCardState extends State<_StepsCard> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = widget.healthProvider;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(color: ThemeHelper.textPrimary.withOpacity(0.1), blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Row(
        children: [
          Image.asset('assets/icons/steps.png', width: 30, height: 30, color: ThemeHelper.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.stepsToday, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: ThemeHelper.textPrimary)),
                const SizedBox(height: 4),
                if (healthProvider.isLoading)
                  const Text('Loading...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
                else if (!healthProvider.hasPermissions)
                  GestureDetector(
                    onTap: () => healthProvider.requestPermissions(),
                    child: Text(
                      AppLocalizations.of(context)!.tapToEnableHealthPermissions,
                      style: TextStyle(
                        color: const Color(0xFFFE9D15),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else if (healthProvider.errorMessage.isNotEmpty)
                  Text(
                    'Error: ${healthProvider.errorMessage}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: '${healthProvider.stepsToday}',
                        style: TextStyle(
                          color: ThemeHelper.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '/${healthProvider.stepsGoal}',
                        style: TextStyle(
                          color: ThemeHelper.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ]),
                  ),
                const SizedBox(height: 2),
                // if (heightCm != null && weightKg != null)
                //   Text(
                //     '≈ ${estKcal} kcal',
                //     style: const TextStyle(fontSize: 12, color: Color(0x7F1E1822), fontWeight: FontWeight.w600),
                //   ),
              ],
            ),
          ),
          if (healthProvider.hasPermissions)
            GestureDetector(
              onTap: () async {
                // Trigger a single rotation animation regardless of how fast the refresh completes
                _rotationController.forward(from: 0);
                await healthProvider.refreshSteps();
              },
              child: RotationTransition(
                turns: _rotationController.drive(Tween<double>(begin: 0, end: 1)),
                child: Icon(
                  CupertinoIcons.refresh,
                  color: ThemeHelper.textSecondary,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddBurnedToGoalCard extends StatefulWidget {
  final HealthProvider healthProvider;
  
  const _AddBurnedToGoalCard({
    required this.healthProvider,
  });
  
  @override
  State<_AddBurnedToGoalCard> createState() => _AddBurnedToGoalCardState();
}

class _AddBurnedToGoalCardState extends State<_AddBurnedToGoalCard> {
  final UserController _userController = Get.find<UserController>();
  final ProgressService _progressService =  ProgressService();
  
  Map<String, dynamic>? _progressData;
  bool _isLoadingProgress = false;
  bool _hasLoaded = false;
  String? _lastLoadedDate;
  int? _lastStepsFromHealth;

  bool get _includeStepCaloriesInGoal {
    return _userController.userData['includeStepCaloriesInGoal'] ?? false;
  }

  @override
  void initState() {
    super.initState();
    // Listen for step changes so we can refresh calories/steps in this card
    widget.healthProvider.addListener(_onHealthChanged);
    if (!_hasLoaded) {
      _loadProgressData();
    }
  }

  @override
  void dispose() {
    widget.healthProvider.removeListener(_onHealthChanged);
    super.dispose();
  }

  void _onHealthChanged() {
    if (!_includeStepCaloriesInGoal) return;
    if (!widget.healthProvider.hasPermissions) return;
    if (widget.healthProvider.isLoading) return;

    final int currentSteps = widget.healthProvider.stepsToday;
    if (_lastStepsFromHealth != null && _lastStepsFromHealth == currentSteps) {
      return; // No step change
    }
    _lastStepsFromHealth = currentSteps;

    // Force a reload so burned calories and steps reflect latest health data
    _hasLoaded = false;
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    // Only reload if date changed or hasn't loaded yet
    if (_hasLoaded && _lastLoadedDate == today && !_isLoadingProgress) return;
    if (_isLoadingProgress) return;
    
    setState(() { _isLoadingProgress = true; });
    
    try {
      
      // Get steps from Apple Health if includeStepCaloriesInGoal is true
      int? steps;
      if (_includeStepCaloriesInGoal && widget.healthProvider.hasPermissions) {
        steps = widget.healthProvider.stepsToday;
      }
      
      final progress = await _progressService.fetchDailyProgress(
        dateYYYYMMDD: today,
        steps: steps,
      );
      
      if (mounted && progress != null && progress['success'] == true) {
        setState(() {
          _progressData = progress['progress'];
          _hasLoaded = true;
          _lastLoadedDate = today;
        });
      }
    } catch (e) {
      // Silently handle errors
    } finally {
      if (mounted) setState(() { _isLoadingProgress = false; });
    }
  }

  Future<void> _toggleIncludeStepCalories() async {
    final bool newValue = !_includeStepCaloriesInGoal;
    
    // Update user data optimistically for immediate UI feedback
    _userController.userData['includeStepCaloriesInGoal'] = newValue;
    setState(() {});
    
    // Make API call in background
    try {
       _userController.updateUser(
        _userController.userData['id'] ?? _userController.userData['_id'] ?? '',
        {'includeStepCaloriesInGoal': newValue},
        context,
        Get.find<ThemeProvider>(),
        Get.find<LanguageProvider>(),
      );
      
      // Reload progress data with steps if toggled on (force reload by resetting flag)
      if (newValue) {
        _hasLoaded = false; // Reset flag to allow reload
        _loadProgressData();
      }
    } catch (e) {
      // Silently handle errors - user can try again
    }
  }

  String _getCaloriesBurnedText() {
    if (_isLoadingProgress) return '...';
    if (_progressData == null) return '0';
    
    // Get calories burned from steps only
    final steps = _progressData!['steps'] as Map<String, dynamic>?;
    final caloriesBurned = (steps?['caloriesBurned'] as int?) ?? 0;
    
    return caloriesBurned.toString();
  }

  String _getStepsText() {
    if (_isLoadingProgress) return '...';
    if (_progressData == null) return '0';
    
    final steps = _progressData!['steps'] as Map<String, dynamic>?;
    final count = (steps?['count'] as int?) ?? 0;
    
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(color: ThemeHelper.textPrimary.withOpacity(0.1), blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.addBurnedCaloriesToDailyGoal, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ThemeHelper.textPrimary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Badge(
                      icon: "assets/icons/apple.png", 
                      title: _getCaloriesBurnedText(),
                      subtitle: AppLocalizations.of(context)!.caloriesBurned
                    ),
                    const SizedBox(width: 8),
                    _Badge(
                      icon: "assets/icons/shoe.png", 
                      title: _getStepsText(),
                      subtitle: AppLocalizations.of(context)!.steps
                    ),
                  ],
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            activeColor: ThemeHelper.textPrimary,
            value: _includeStepCaloriesInGoal,
            onChanged: (_) => _toggleIncludeStepCalories(),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  const _Badge({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: ThemeHelper.textPrimary.withOpacity(0.1), blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(icon, width: 14, height: 14, color: ThemeHelper.textPrimary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: ThemeHelper.textPrimary)),
              Text(subtitle, style: TextStyle(fontSize: 7, color: ThemeHelper.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatefulWidget {
  @override
  State<_StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<_StreakCard> {
  final StreakService _streakService = Get.put(StreakService());
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    await _streakService.getStreakHistory();
    if (mounted) {
      setState(() {
        _currentStreak = _streakService.getCurrentStreak();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: 335,
      height: 195,
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.textPrimary.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 0),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with flame icon and streak text
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/icons/flame.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        l10n.dayStreak(_currentStreak),
                        style: TextStyle(
                          color: ThemeHelper.textPrimary,
                          fontSize: 20,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      child: Text(
                        l10n.keepGoing,
                        style: TextStyle(
                          color: ThemeHelper.textPrimary,
                          fontSize: 12,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Inner gray container with navigation
            Center(
              child: GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const LogStreakScreen(),
                    ),
                  );
                  // Refresh streak data when returning from log streak screen
                  _loadStreakData();
                },
                child: Container(
                  width: 272,
                  height: 99,
                  decoration: BoxDecoration(
                    color: ThemeHelper.cardBackground,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeHelper.textPrimary.withOpacity(0.1),
                        blurRadius: 3,
                        offset: Offset(0, 0),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 86,
                      height: 26,
                      decoration: BoxDecoration(
                        color: ThemeHelper.cardBackground,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeHelper.textPrimary.withOpacity(0.1),
                            blurRadius: 3,
                            offset: Offset(0, 0),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/icons/flame.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 41,
                            child: Text(
                              l10n.logStreak,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ThemeHelper.textSecondary,
                                fontSize: 8,
                                fontFamily: 'Instrument Sans',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          SizedBox(
                            width: 6,
                            height: 16,
                            child: Text(
                              '+',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ThemeHelper.textSecondary,
                                fontSize: 14,
                                fontFamily: 'Instrument Sans',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'confirm_weight_screen.dart' show ConfirmWeightScreen;
import '../providers/theme_provider.dart';
import '../providers/health_provider.dart';
import '../providers/language_provider.dart';
import '../utils/theme_helper.dart';
import 'package:get/get.dart';
import '../authentication/user.controller.dart' show UserController;
import '../constants/app_constants.dart' show AppConstants;
import 'desired_weight_update_screen.dart' show DesiredWeightUpdateScreen;
import '../services/progress_service.dart';
import '../utils/user.prefs.dart' show UserPrefs;
import '../l10n/app_localizations.dart';

class ProgressScreen extends StatelessWidget {
  final ThemeProvider themeProvider;
  final HealthProvider healthProvider;

  const ProgressScreen({super.key, required this.themeProvider, required this.healthProvider});

  @override
  Widget build(BuildContext context) {
    // Ensure UserController is available (will throw if not previously put)
    final UserController userController = Get.find<UserController>();
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: Listenable.merge([themeProvider, healthProvider]),
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
                _WeightOverviewCard(),
                const SizedBox(height: 12),
                 Transform.scale(scaleX: 1.5, child: Divider(color: Colors.black.withOpacity(0.3))),
                 const SizedBox(height: 12),
                Obx(() {
                  dynamic w = userController.userData['weight'];
                  // Fallbacks if API nests data differently
                  w ??= (userController.userData['data'] is Map) ? userController.userData['data']['weight'] : null;
                  w ??= (userController.userData['user'] is Map) ? userController.userData['user']['weight'] : null;
                  // Last resort fallback if stored in constants
                  w ??= AppConstants.userId.isNotEmpty ? null : null;
                  final String weightStr = (w == null || (w is String && w.isEmpty)) ? '-' : w.toString();
                  return _WeightTile(
                    title: l10n.myWeight,
                    value: '$weightStr kg',
                    trailingLabel: l10n.logWeight,
                    leadingIcon: 'assets/icons/export.png',
                    isUpdateTarget: false,
                  );
                }),
                const SizedBox(height: 10),
                Obx(() {
                  dynamic tw = userController.userData['targetWeight'];
                  // Fallbacks if API nests data differently
                  tw ??= (userController.userData['data'] is Map) ? userController.userData['data']['targetWeight'] : null;
                  tw ??= (userController.userData['user'] is Map) ? userController.userData['user']['targetWeight'] : null;
                  final String targetStr = (tw == null || (tw is String && tw.isEmpty)) ? '-' : tw.toString();
                  return _WeightTile(
                    title: l10n.targetWeight,
                    value: '$targetStr kg',
                    trailingLabel: l10n.update,
                    leadingIcon: 'assets/icons/trophy.png',
                    isUpdateTarget: true,
                  );
                }),
                const SizedBox(height: 30),
               
                _GoalProgressCard(),
                const SizedBox(height: 12),
                _WeeklySummaryStrip(),
                const SizedBox(height: 12),
                _ProgressPhotosCard(),
                const SizedBox(height: 12),
                _StepsCard(healthProvider: healthProvider),
                const SizedBox(height: 12),
                _AddBurnedToGoalCard(),
                const SizedBox(height: 24),
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Method to refresh the badge (can be called when user logs new weight)
  void refreshBadge() {
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
      _daysRemaining = remaining <= 0 ? 0 : remaining;
    });
  }

  String _label() {
    final l10n = AppLocalizations.of(context)!;
    if (_daysRemaining <= 0) return l10n.weighInDue;
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

class _WeightOverviewCard extends StatefulWidget {
  @override
  State<_WeightOverviewCard> createState() => _WeightOverviewCardState();
}

class _WeightOverviewCardState extends State<_WeightOverviewCard> {
  final ProgressService _service = const ProgressService();
  double? _lastWeight;
  double? _prevWeight;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; });
    final res = await _service.fetchWeightHistory(page: 1, limit: 30);
    if (!mounted) return;
    try {
      if (res != null && res['success'] == true) {
        final List<dynamic> logs = (res['logs'] as List<dynamic>? ?? <dynamic>[]);
        if (logs.isNotEmpty) {
          logs.sort((a, b) {
            final da = DateTime.tryParse((a['loggedAt'] ?? '') as String)?.millisecondsSinceEpoch ?? 0;
            final db = DateTime.tryParse((b['loggedAt'] ?? '') as String)?.millisecondsSinceEpoch ?? 0;
            return db.compareTo(da);
          });
          _lastWeight = (logs.first['weight'] as num?)?.toDouble();
          if (logs.length > 1) {
            _prevWeight = (logs[1]['weight'] as num?)?.toDouble();
          }
        }
      }
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
          color: Color(0xFFFBFAFB),
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [
            BoxShadow(color: Color(0x3F000000), blurRadius: 1, spreadRadius: 1),
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
              final String weightStr = (w == null || (w is String && w.isEmpty)) ? '-' : w.toString();
              final String targetStr = (tw == null || (tw is String && tw.isEmpty)) ? '-' : tw.toString();
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _KgValue(big: weightStr, small: 'kg'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Icon(CupertinoIcons.arrow_right, size: 28, color: Colors.black),
                  ),
                  _KgValue(big: targetStr, small: 'kg'),
                ],
              );
            }),
            const SizedBox(height: 12),
            Divider(color: Colors.black.withOpacity(0.1), height: 1),
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
                style: ThemeHelper.textStyleWithColor(ThemeHelper.body1, Colors.black),
              );
            }),
            const SizedBox(height: 4),
            if (_loading)
              const SizedBox(height: 16, child: Center(child: CupertinoActivityIndicator()))
            else
              Text(
                _deltaText(),
                style: ThemeHelper.textStyleWithColor(ThemeHelper.footnote, Colors.black.withOpacity(0.5)),
              ),
            
          ],
        ),
      ),
    );
  }
  String _deltaText() {
    if (_lastWeight != null && _prevWeight != null) {
      final d = _lastWeight! - _prevWeight!;
      if (d != 0) {
        final sign = d > 0 ? '+' : '';
        return '$sign${d.toStringAsFixed(1)} ${AppLocalizations.of(context)!.kg} ${AppLocalizations.of(context)!.sinceLastWeighIn}';
      }
    }
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
            style: ThemeHelper.textStyleWithColor(ThemeHelper.title1, Colors.black),
          ),
          TextSpan(
            text: small,
            style: ThemeHelper.textStyleWithColor(ThemeHelper.title3, Colors.black,),
          ),
        ],
      ),
    );
  }
}

class _WeightTile extends StatelessWidget {
  final String title;
  final String value;
  final String trailingLabel;
  final String leadingIcon;
  final bool isUpdateTarget;
  const _WeightTile({
    required this.title,
    required this.value,
    required this.trailingLabel,
    required this.leadingIcon,
    this.isUpdateTarget = false,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(color: Color(0x3F000000), blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Row(
        children: [
          Image.asset(leadingIcon, width: 44, height: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (ctx) => DesiredWeightUpdateScreen(isUpdatingTarget: isUpdateTarget),
                ),
              );
            },
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.update,
                  style: TextStyle(color: Color(0x7F1E1822), fontSize: 10, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 6),
                Icon(CupertinoIcons.pencil, size: 14, color: Color(0x7F1E1822)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalProgressCard extends StatefulWidget {
  @override
  State<_GoalProgressCard> createState() => _GoalProgressCardState();
}

class _GoalProgressCardState extends State<_GoalProgressCard> {
  List<String> _getRanges(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [l10n.thirtyDays, l10n.ninetyDays, l10n.sixMonths, l10n.oneYear, l10n.allTime];
  }
  int _selectedIndex = 0;
  final ProgressService _service = const ProgressService();
  double? _lastWeight;
  double? _prevWeight;
  bool _loadingHistory = false;
  List<double> _series = const [];
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
      _loadSummary();
    });
  }

  Future<void> _loadHistory() async {
    setState(() { _loadingHistory = true; });
    final res = await _service.fetchWeightHistory(page: 1, limit: 30);
    if (!mounted) return;
    try {
      if (res != null && res['success'] == true) {
        final List<dynamic> logs = (res['logs'] as List<dynamic>? ?? <dynamic>[]);
        if (logs.isNotEmpty) {
          // assume logs are sorted desc by createdAt; if not, sort by loggedAt desc
          logs.sort((a, b) {
            final da = DateTime.tryParse((a['loggedAt'] ?? '') as String)?.millisecondsSinceEpoch ?? 0;
            final db = DateTime.tryParse((b['loggedAt'] ?? '') as String)?.millisecondsSinceEpoch ?? 0;
            return db.compareTo(da);
          });
          _lastWeight = (logs.first['weight'] as num?)?.toDouble();
          print('lastWeight: $_lastWeight');
          if (logs.length > 1) {
            _prevWeight = (logs[1]['weight'] as num?)?.toDouble();
            print('prevWeight: $_prevWeight');
          }

          // Build chart series (oldest -> newest)
          final weights = logs.reversed
              .map((e) => (e['weight'] as num?)?.toDouble())
              .whereType<double>()
              .toList();
          print('weights: $weights');
          _series = weights;
          print('series: $_series');
        }
      }
    } finally {
      if (mounted) setState(() { _loadingHistory = false; });
    }
  }

  Future<void> _loadSummary() async {
    final res = await _service.fetchWeightSummary();
    if (!mounted) return;
    if (res != null && res['success'] == true) {
      setState(() {
        _summary = Map<String, dynamic>.from(res['summary'] as Map);
        _series = _seriesForIndex(_selectedIndex);
      });
    }
  }

  List<double> _seriesForIndex(int idx) {
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
    final List<double> weights = points
        .map((e) => (e['weight'] as num?)?.toDouble())
        .whereType<double>()
        .toList();
    if (weights.isEmpty) return const [];
    final double minW = weights.reduce((a, b) => a < b ? a : b);
    final double maxW = weights.reduce((a, b) => a > b ? a : b);
    final double span = (maxW - minW).abs() < 0.001 ? 1.0 : (maxW - minW);
    return weights.map((w) => (w - minW) / span).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.weightGoalProgress, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
          _ChartPlaceholder(
            leftLabel: _startLabelForRange(_selectedIndex, context),
            rightLabel: _endLabelForRange(_selectedIndex, context),
            dataPoints: List<double>.from(_series),
          ),
          const SizedBox(height: 8),
          Builder(builder: (context) {
            if (_loadingHistory) {
              return const SizedBox(height: 16, child: Center(child: CupertinoActivityIndicator()));
            }
            double? delta;
            if (_lastWeight != null && _prevWeight != null) {
              delta = _lastWeight! - _prevWeight!;
              print('delta: $delta');
            }
            final String subtitle = (delta != null && delta != 0)
                ? '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} ${AppLocalizations.of(context)!.kg} ${AppLocalizations.of(context)!.sinceLastWeighIn}'
                : '- ${AppLocalizations.of(context)!.kg} ${AppLocalizations.of(context)!.sinceLastWeighIn}';
            return Text(
              subtitle,
              style: ThemeHelper.textStyleWithColor(ThemeHelper.footnote, Colors.black.withOpacity(0.5)),
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
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(color: Color(0x3F000000), blurRadius: 5, spreadRadius: 1)],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
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

class _ChartPlaceholder extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final List<double> dataPoints; // weights raw
  const _ChartPlaceholder({required this.leftLabel, required this.rightLabel, this.dataPoints = const []});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(color: Color(0x3F000000), blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double totalHeight = constraints.maxHeight;
            const double xAxisReserved = 28; // bottom area for dates
            final double chartHeight = totalHeight - xAxisReserved;

            double yForFraction(double f) => f * chartHeight; // 0..1 -> y within chart

            Widget lineRow(String label, double fraction) {
              return Positioned(
                left: 0,
                right: 0,
                top: yForFraction(fraction),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(label,
                          style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.8))),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SizedBox(
                        height: 1,
                        child: CustomPaint(
                          painter: _DashedLinePainter(color: Colors.black.withOpacity(0.2), dashWidth: 4, dashGap: 3),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _LineAreaPainter(
                data: dataPoints,
                bottomReserved: xAxisReserved,
                leftReserved: 34, // 28 for label + 6 spacing
              ),
              child: Stack(
                children: [
                  // dashed lines with labels (low at top, high at bottom)
                  lineRow('65', 0.10),
                  lineRow('70', 0.40),
                  lineRow('75', 0.70),
                  lineRow('80', 0.90),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(leftLabel, style: const TextStyle(fontSize: 11)),
                          Text(rightLabel, style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashGap;
  const _DashedLinePainter({required this.color, this.dashWidth = 4, this.dashGap = 3});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    double x = 0;
    final double y = size.height / 2;
    while (x < size.width) {
      final double x2 = (x + dashWidth).clamp(0, size.width);
      canvas.drawLine(Offset(x, y), Offset(x2, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.dashWidth != dashWidth || oldDelegate.dashGap != dashGap;
  }
}

class _LineAreaPainter extends CustomPainter {
  final List<double> data; // 0..1
  final double bottomReserved;
  final double leftReserved;
  _LineAreaPainter({required this.data, required this.bottomReserved, this.leftReserved = 0});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final double chartHeight = size.height - bottomReserved;
    final double width = size.width;
    final int n = data.length;
    if (n < 2) return;

    // Normalize raw weights using provided yMin/yMax, else auto-fit to data range
    double minW = data.reduce((a, b) => a < b ? a : b);
    double maxW = data.reduce((a, b) => a > b ? a : b);
    if ((maxW - minW).abs() < 0.001) {
      maxW = minW + 1.0;
    }
    // Reverse y-axis: higher weights closer to bottom (value 1.0), lower to top (0.0)
    List<double> norm = data
        .map((w) => ((w - minW) / (maxW - minW)).clamp(0.0, 1.0))
        .map((v) => 1.0 - v)
        .toList();

    // Build points
    final double dx = (width - leftReserved) / (n - 1);
    final List<Offset> pts = List.generate(n, (i) {
      final double x = leftReserved + i * dx;
      final double y = (1.0 - norm[i]) * chartHeight; // norm==1 => top, but we reversed above
      return Offset(x, y);
    });

    // Area path (under line)
    final Path area = Path()
      ..moveTo(pts.first.dx, chartHeight)
      ..lineTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      area.lineTo(pts[i].dx, pts[i].dy);
    }
    area.lineTo(pts.last.dx, chartHeight);
    area.close();

    final Rect shaderRect = Rect.fromLTWH(leftReserved, 0, width - leftReserved, chartHeight);
    final Paint areaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black,
          Color(0xFF777777),
          Colors.white,
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(shaderRect)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..colorFilter = const ColorFilter.mode(Colors.black12, BlendMode.srcATop);
    canvas.drawPath(area, areaPaint);

    // Line path
    final Path line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      line.lineTo(pts[i].dx, pts[i].dy);
    }
    final Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    canvas.drawPath(line, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineAreaPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.bottomReserved != bottomReserved;
  }
}

class _WeeklySummaryStrip extends StatefulWidget {
  @override
  State<_WeeklySummaryStrip> createState() => _WeeklySummaryStripState();
}

class _WeeklySummaryStripState extends State<_WeeklySummaryStrip> {
  final ProgressService _service = const ProgressService();
  String _headline = 'Great job!';
  String _headlineDeltaText = '';
  String _avgLabel = '';
  String _avgText = '- kg/day';
  String _toGoText = '- kg to go';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; });
    final res = await _service.fetchWeightHistory(page: 1, limit: 60);
    if (!mounted) return;
    try {
      if (res != null && res['success'] == true) {
        final List<dynamic> logs = (res['logs'] as List<dynamic>? ?? <dynamic>[]);
        if (logs.isNotEmpty) {
          // sort asc by loggedAt
          logs.sort((a, b) {
            final da = DateTime.tryParse((a['loggedAt'] ?? '') as String)?.millisecondsSinceEpoch ?? 0;
            final db = DateTime.tryParse((b['loggedAt'] ?? '') as String)?.millisecondsSinceEpoch ?? 0;
            return da.compareTo(db);
          });
          final DateTime now = DateTime.now();
          final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
          final List<Map<String, dynamic>> recent = logs
              .map((e) => Map<String, dynamic>.from(e as Map))
              .where((m) => DateTime.tryParse((m['loggedAt'] ?? '') as String)?.isAfter(sevenDaysAgo) == true)
              .toList();

          double? earliest;
          double? latest;
          if (recent.isNotEmpty) {
            earliest = (recent.first['weight'] as num?)?.toDouble();
            latest = (recent.last['weight'] as num?)?.toDouble();
          } else {
            earliest = (logs.first['weight'] as num?)?.toDouble();
            latest = (logs.last['weight'] as num?)?.toDouble();
          }

          final double delta = ((latest ?? 0) - (earliest ?? 0));
          // Use a stable denominator: days spanned, clamped to at least 1 day and at most 7 days
          double spannedDays;
          if ((recent.isNotEmpty ? recent.last : logs.last)['loggedAt'] != null && (recent.isNotEmpty ? recent.first : logs.first)['loggedAt'] != null) {
            final DateTime end = DateTime.tryParse(((recent.isNotEmpty ? recent.last : logs.last)['loggedAt']) as String) ?? now;
            final DateTime start = DateTime.tryParse(((recent.isNotEmpty ? recent.first : logs.first)['loggedAt']) as String) ?? sevenDaysAgo;
            spannedDays = (end.difference(start).inHours / 24.0).abs();
          } else {
            spannedDays = 7.0;
          }
          spannedDays = spannedDays.clamp(1.0, 7.0);

          // Compute progress TOWARD target per day
          final UserController uc = Get.find<UserController>();
          final double? target = (uc.userData['targetWeight'] as num?)?.toDouble() ??
              (uc.userData['data'] is Map ? (uc.userData['data']['targetWeight'] as num?)?.toDouble() : null) ??
              (uc.userData['user'] is Map ? (uc.userData['user']['targetWeight'] as num?)?.toDouble() : null);
          final double t = target ?? (latest ?? earliest ?? 0);
          final double startDist = (earliest ?? t) - t;
          final double endDist = (latest ?? t) - t;
          final double progressTowardGoal = startDist.abs() - endDist.abs(); // positive means moved closer
          final double avgProgress = progressTowardGoal / spannedDays;

          final bool lost = delta < 0;
          final String deltaText = '${lost ? (-delta).toStringAsFixed(1) : delta.toStringAsFixed(1)} ${AppLocalizations.of(context)!.kg}';
          final String avgText = '${avgProgress >= 0 ? '+' : ''}${avgProgress.toStringAsFixed(2)} ${AppLocalizations.of(context)!.kgPerDay}';

          // target vs latest for "to go"
          final double latestWeight = (latest ?? (uc.userData['weight'] as num?)?.toDouble() ?? 0);
          final double toGo = (target != null && target > 0) ? (latestWeight - target) : 0;

          final l10n = AppLocalizations.of(context)!;
          setState(() {
            _headline = lost ? '${l10n.greatJob} You lost ' : '${l10n.greatJob} ${l10n.youGained} ';
            _headlineDeltaText = deltaText + ' this week';
            _avgLabel = lost ? l10n.avgDailyLost : l10n.avgDailyGained;
            _avgText = avgText;
            _toGoText = '${toGo.abs().toStringAsFixed(1)} ${l10n.kgToGo}';
          });
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(color: Color(0x3F000000), blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: _loading
                ? const CupertinoActivityIndicator()
                : Text.rich(
                    TextSpan(children: [
                      TextSpan(text: _headline + ' ', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      TextSpan(text: _headlineDeltaText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ]),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.black.withOpacity(0.1), height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_avgLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(_avgText, style: const TextStyle(fontSize: 12)),
                ],
              ),
              Container(width: 1, height: 28, color: Colors.black.withOpacity(0.1)),
              Text(_toGoText, style: const TextStyle(color: Color(0xFFFE9D15), fontWeight: FontWeight.w600, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressPhotosCard extends StatefulWidget {
  @override
  State<_ProgressPhotosCard> createState() => _ProgressPhotosCardState();
}

class _ProgressPhotosCardState extends State<_ProgressPhotosCard> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

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

  Future<void> _showPickerSheet(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(AppLocalizations.of(context)!.addProgressPhoto),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
              if (photo != null) {
                setState(() => _images.add(photo));
                // Navigate to confirm screen
                await Navigator.of(context).push(CupertinoPageRoute(
                  builder: (_) => ConfirmWeightScreen(
                    weightLabel: _currentWeightLabel(context),
                    imagePaths: [photo.path],
                  ),
                ));
              }
            },
            child: Text(AppLocalizations.of(context)!.camera, style: TextStyle(color: CupertinoColors.black, fontWeight: FontWeight.w400)),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final List<XFile> files = await _picker.pickMultiImage(imageQuality: 85);
              if (files.isNotEmpty) {
                setState(() => _images.addAll(files));
                await Navigator.of(context).push(CupertinoPageRoute(
                  builder: (_) => ConfirmWeightScreen(
                    weightLabel: _currentWeightLabel(context),
                    imagePaths: files.map((f) => f.path).toList(),
                  ),
                ));
              }
            },
            child: Text(AppLocalizations.of(context)!.gallery, style: TextStyle(color: CupertinoColors.black, fontWeight: FontWeight.w400)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: CupertinoColors.black, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(color: Color(0x3F000000), blurRadius: 5, spreadRadius: 1),
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
                Text(AppLocalizations.of(context)!.progressPhotos, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                if (_images.isNotEmpty)
                Container(
                  width: 102,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3F000000),
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
                          color: Colors.black.withOpacity(0.60),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_images.isEmpty)
            Center(
              child: GestureDetector(
                onTap: () => _showPickerSheet(context),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: 99,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FC),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 3)],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.uploadPhoto, style: TextStyle(fontSize: 12, color: Color(0xB21E1822))),
                        SizedBox(height: 4),
                        Text('+', style: TextStyle(fontSize: 22, color: Color(0xB21E1822))),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                   GestureDetector(
                    onTap: () => _showPickerSheet(context),
                    child: Container(
                      width: 88,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F7FC),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 3)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.upload, style: TextStyle(fontSize: 12, color: Color(0xB21E1822))),
                          SizedBox(height: 4),
                          Icon(CupertinoIcons.add, size: 18, color: Color(0xB21E1822)),
                        ],
                      ),
                    ),
                  ),
                  // Existing images with delete button
                  ..._images.asMap().entries.map((entry) {
                    final XFile x = entry.value;
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
                  // Upload tile (same ratio) to add more
                 
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StepsCard extends StatelessWidget {
  final HealthProvider healthProvider;
  
  const _StepsCard({required this.healthProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(color: Color(0x3F000000), blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Row(
        children: [
          Image.asset('assets/icons/steps.png', width: 30, height: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.stepsToday, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                if (healthProvider.isLoading)
                  const Text('Loading...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
                else if (!healthProvider.hasPermissions)
                  GestureDetector(
                    onTap: () => healthProvider.requestPermissions(),
                    child: Text(
                      AppLocalizations.of(context)!.tapToEnableHealthPermissions,
                      style: TextStyle(
                        color: Color(0xFFFE9D15),
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
                        style: const TextStyle(
                          color: Color(0xFF1E1822),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '/${healthProvider.stepsGoal}',
                        style: const TextStyle(
                          color: Color(0x7F1E1822),
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
          if (healthProvider.hasPermissions && !healthProvider.isLoading)
            GestureDetector(
              onTap: () => healthProvider.refreshSteps(),
              child: const Icon(
                CupertinoIcons.refresh,
                color: Color(0x7F1E1822),
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}

class _AddBurnedToGoalCard extends StatefulWidget {
  @override
  State<_AddBurnedToGoalCard> createState() => _AddBurnedToGoalCardState();
}

class _AddBurnedToGoalCardState extends State<_AddBurnedToGoalCard> {
  final UserController _userController = Get.find<UserController>();
  final ProgressService _progressService = const ProgressService();
  
  Map<String, dynamic>? _progressData;
  bool _isLoadingProgress = false;

  bool get _includeStepCaloriesInGoal {
    return _userController.userData['includeStepCaloriesInGoal'] ?? false;
  }

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() { _isLoadingProgress = true; });
    
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final progress = await _progressService.fetchDailyProgress(dateYYYYMMDD: today);
      
      if (mounted && progress != null && progress['success'] == true) {
        setState(() {
          _progressData = progress['progress'];
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(color: Color(0x3F000000), blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.addBurnedCaloriesToDailyGoal, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
            activeColor: CupertinoColors.black,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Color(0x3F000000), blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(icon, width: 14, height: 14),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.9))),
              Text(subtitle, style: TextStyle(fontSize: 7, color: Colors.black.withOpacity(0.7))),
            ],
          ),
        ],
      ),
    );
  }
}

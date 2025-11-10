import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../l10n/app_localizations.dart' show AppLocalizations;
import '../providers/theme_provider.dart';
import '../services/streak_service.dart';
import '../services/progress_service.dart';
import '../utils/theme_helper.dart' show ThemeHelper;
import 'log_streak_screen.dart' show LogStreakScreen;
import 'set_goals_screen.dart' show SetGoalsScreen;
import 'exercise_detail_screen.dart' show ExerciseDetailScreen;
import 'meal_details_screen.dart' show MealDetailsScreen;
import '../controllers/home_screen_controller.dart';

enum StreakStatus {
  completed,
  missed,
  neutral,
}

class DashboardScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  final File? selectedImage;
  final bool isAnalyzing;
  final Map<String, dynamic>? scanResult;
  final Map<String, int>? todayTotals;
  final String? todayCreatedAt;
  final List<Map<String, dynamic>>? todayEntries;
  final List<Map<String, dynamic>>? todayMeals;
  final List<Map<String, dynamic>>? todayExercises;
  final Map<String, dynamic>? dailyProgress;
  final Map<String, dynamic>? dailySummary;
  final bool hasScanError;
  final bool isLoadingInitialData;
  final VoidCallback? onRetryScan;
  final VoidCallback? onCloseError;

  const DashboardScreen({
    super.key, 
    required this.themeProvider,
    this.selectedImage,
    this.isAnalyzing = false,
    this.scanResult,
    this.todayTotals,
    this.todayCreatedAt,
    this.todayEntries,
    this.todayMeals,
    this.todayExercises,
    this.dailyProgress,
    this.dailySummary,
    this.hasScanError = false,
    this.isLoadingInitialData = false,
    this.onRetryScan,
    this.onCloseError,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  int selectedDay = 6; // Thursday (6th)
  bool _showStreakCard = false; // State for showing streak card
  late final StreakService streakService;
  List<DateTime> weekDates = [];

  List<Map<String, dynamic>> _localTodayMeals = [];
  Map<String, int>? _localTodayTotals;
  List<Map<String, dynamic>> _localTodayExercises = [];
  bool _cardAnimationsActivated = false;
  final Set<String> _scheduledCardAnimations = <String>{};
  final Set<String> _visibleAnimatedCards = <String>{};
  
  // Mock data - replace with real data from your backend
  final int dailyCalorieGoal = 2000;
  final int consumedCalories = 1000;
  final int remainingCalories = 1000;
  final int proteinLeft = 100;
  final int carbsLeft = 99;
  final int fatLeft = 25;

  @override
  void initState() {
    super.initState();
    streakService = Get.put(StreakService());
    _initializeWeek();
    _syncFromWidget();
    _loadStreaksForWeek();
    // Ensure progress data loads independently of meals fetch timing
    try {
      final now = DateTime.now();
      final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final progressService = Get.find<ProgressService>();
      // Fire and forget; GetBuilder will rebuild on update
      // ignore: discarded_futures
      progressService.fetchDailyProgress(dateYYYYMMDD: dateStr);
    } catch (_) {}
    
    
    // Animation setup removed as it's no longer needed

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _cardAnimationsActivated = true;
      });
    });
  }

  void _initializeWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Get Monday of current week (weekday 1)
    final monday = today.subtract(Duration(days: today.weekday - 1));
    
    weekDates = List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  void _syncFromWidget() {
    _localTodayMeals = (widget.todayMeals ?? const [])
        .map((meal) => Map<String, dynamic>.from(meal))
        .toList();
    _localTodayTotals = widget.todayTotals != null
        ? Map<String, int>.from(widget.todayTotals!)
        : null;
    _localTodayExercises = (widget.todayExercises ?? const [])
        .map((exercise) => Map<String, dynamic>.from(exercise))
        .toList();
    _recalculateLocalTotals(preferWidgetTotals: true);
  }

  void _applyLocalMealUpdate(Map<String, dynamic> updatedMeal) {
    final Map<String, dynamic> copy = Map<String, dynamic>.from(updatedMeal);
    final String? targetId = _extractMealId(copy);
    if (targetId == null) {
      _localTodayMeals.insert(0, copy);
      widget.todayMeals?.insert(0, copy);
      return;
    }

    final int existingIndex = _localTodayMeals.indexWhere((meal) {
      final id = _extractMealId(meal);
      return id != null && id == targetId;
    });

    if (existingIndex >= 0) {
      _localTodayMeals[existingIndex] = copy;
      if (widget.todayMeals != null && existingIndex < widget.todayMeals!.length) {
        widget.todayMeals![existingIndex] = copy;
      }
    } else {
      _localTodayMeals.insert(0, copy);
      widget.todayMeals?.insert(0, copy);
    }
  }

  void _applyLocalExerciseUpdate(Map<String, dynamic> updatedExercise) {
    final Map<String, dynamic> copy = Map<String, dynamic>.from(updatedExercise);
    final String? targetId = _extractExerciseId(copy);

    if (targetId == null) {
      _localTodayExercises.insert(0, copy);
    } else {
      final int existingIndex = _localTodayExercises.indexWhere((exercise) {
        final id = _extractExerciseId(exercise);
        return id != null && id == targetId;
      });

      if (existingIndex >= 0) {
        _localTodayExercises[existingIndex] = copy;
      } else {
        _localTodayExercises.insert(0, copy);
      }
    }

    if (widget.todayExercises != null) {
      widget.todayExercises!
        ..clear()
        ..addAll(_localTodayExercises.map((exercise) => Map<String, dynamic>.from(exercise)));
    }

    if (Get.isRegistered<HomeScreenController>()) {
      final controller = Get.find<HomeScreenController>();
      controller.todayExercises.assignAll(
        _localTodayExercises.map((exercise) => Map<String, dynamic>.from(exercise)).toList(),
      );
    }
  }

  void _recalculateLocalTotals({bool preferWidgetTotals = false}) {
    if (preferWidgetTotals && widget.todayTotals != null) {
      _localTodayTotals = Map<String, int>.from(widget.todayTotals!);
      return;
    }

    int calories = 0;
    int protein = 0;
    int carbs = 0;
    int fat = 0;

    if (_localTodayMeals.isEmpty) {
      _localTodayTotals = null;
      return;
    }

    for (final meal in _localTodayMeals) {
      calories += _intFrom(meal['totalCalories']);
      protein += _intFrom(meal['totalProtein']);
      carbs += _intFrom(meal['totalCarbs']);
      fat += _intFrom(meal['totalFat']);
    }

    _localTodayTotals = {
      'totalCalories': calories,
      'totalProtein': protein,
      'totalCarbs': carbs,
      'totalFat': fat,
    };

    if (widget.todayTotals != null) {
      widget.todayTotals!
        ..update('totalCalories', (_) => calories, ifAbsent: () => calories)
        ..update('totalProtein', (_) => protein, ifAbsent: () => protein)
        ..update('totalCarbs', (_) => carbs, ifAbsent: () => carbs)
        ..update('totalFat', (_) => fat, ifAbsent: () => fat);
    }
  }

  int _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    return 0;
  }

  String? _extractMealId(Map<String, dynamic> meal) {
    final dynamic id = meal['id'] ?? meal['_id'] ?? meal['mealId'];
    if (id == null) return null;
    return id.toString();
  }

  String? _extractExerciseId(Map<String, dynamic> exercise) {
    final dynamic id = exercise['id'] ?? exercise['_id'] ?? exercise['exerciseId'];
    if (id == null) return null;
    return id.toString();
  }

  int? _getLocalTotal(String key) => _localTodayTotals?[key];

  int? _getLocalMacro(String dataKey) {
    switch (dataKey.toLowerCase()) {
      case 'carbs':
        return _localTodayTotals?['totalCarbs'];
      case 'protein':
        return _localTodayTotals?['totalProtein'];
      case 'fat':
        return _localTodayTotals?['totalFat'];
      default:
        return null;
    }
  }

  Widget _animateCard({
    required String id,
    required Widget child,
    int order = 0,
    Duration duration = const Duration(milliseconds: 320),
  }) {
    final bool isVisible = _visibleAnimatedCards.contains(id);

    if (_cardAnimationsActivated && !isVisible && !_scheduledCardAnimations.contains(id)) {
      _scheduledCardAnimations.add(id);
      Future<void>.delayed(Duration(milliseconds: 70 * order), () {
        if (!mounted) return;
        if (_visibleAnimatedCards.contains(id)) return;
        setState(() {
          _visibleAnimatedCards.add(id);
        });
      });
    }

    final bool targetVisible = _visibleAnimatedCards.contains(id);

    return AnimatedOpacity(
      key: ValueKey<String>('card_anim_$id'),
      opacity: targetVisible ? 1.0 : 0.0,
      duration: duration,
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: targetVisible ? Offset.zero : const Offset(0, 0.06),
        duration: duration,
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }

  Future<void> _loadStreaksForWeek() async {
    if (weekDates.isEmpty) return;
    
    final startDate = weekDates.first;
    final endDate = weekDates.last;
    
    // Only load streaks for the current week since full history is already loaded in home screen
    await streakService.getStreaksForDateRange(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnalyzing && !oldWidget.isAnalyzing) {
      // Start animation when analyzing begins
    } else if (!widget.isAnalyzing && oldWidget.isAnalyzing) {
      // Reset animation when analyzing stops
    }
    if (widget.todayMeals != oldWidget.todayMeals ||
        widget.todayTotals != oldWidget.todayTotals ||
        widget.todayExercises != oldWidget.todayExercises) {
      _syncFromWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: widget.themeProvider.isLightMode ? [
                  Color(0xFFD1D9E6), // More visible bluish slate at top
                  Color(0xFFE2E8F0), // Light slate blue-gray
                  Color(0xFFF1F5F9), // Very light bluish gray
                  Color(0xFFFFFFFF), // Pure white at bottom
                ] : [
                  Color(0xFF1A202C), // Dark bluish slate at top
                  Color(0xFF171923), // Darker slate blue-gray
                  Color(0xFF0F1419), // Very dark bluish gray
                  Color(0xFF0A0A0A), // Almost black at bottom
                ],
                stops: [0.0, 0.3, 0.6, 1.0],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Main content
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
              // Top Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // App Title
                    Image.asset('assets/icons/app_logo.png', width: 48, height: 48, color: ThemeHelper.textPrimary),
                    Text(
                      l10n.appTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelper.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    // Log Streak button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const LogStreakScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: ThemeHelper.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeHelper.textPrimary.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/icons/flame.png', width: 16, height: 16),
                            const SizedBox(width: 6),
                            Text(
                              l10n.logStreak,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ThemeHelper.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              CupertinoIcons.add,
                              size: 16,
                              color: ThemeHelper.textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Day Selector
              _animateCard(
                id: 'day_selector',
                order: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeHelper.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeHelper.textPrimary.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: weekDates.asMap().entries.map((entry) {
                          final index = entry.key;
                          final date = entry.value;
                          return _buildDaySelector(date, index, l10n);
                        }).toList(),
                      )),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Main Content Row - Calories on left, Macros on right
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side - Calories Card
                    Expanded(
                      flex: 2,
                      child: _animateCard(
                        id: 'calorie_card',
                        order: 1,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SetGoalsScreen(dailyProgress: _localTodayTotals),
                              ),
                            );
                          },
                          child: Container(
                            height: 264, // Match macro stack height (3×80 + 2×12)
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ThemeHelper.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeHelper.textPrimary.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  l10n.calories,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeHelper.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Progress ring with apple icon
                                Center(
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Progress circle
                                        GetBuilder<ProgressService>(
                                          builder: (progressService) {
                                            final progressData = progressService.dailyProgressData;
                                            
                                            int consumed = _getLocalTotal('totalCalories') ?? 0;
                                            int goal = 0;
                                            
                                            if (progressData != null && progressData['progress'] != null) {
                                              final progress = progressData['progress'] as Map<String, dynamic>;
                                              goal = ((progress['calories']?['goal'] ?? 0) as num).toInt();
                                              if (consumed == 0) {
                                                consumed = ((progress['calories']?['consumed'] ?? 0) as num).toInt();
                                              }
                                            }
                                            
                                            final double progressValue = goal > 0 ? consumed / goal : 0.0;
                                            
                                            return TweenAnimationBuilder<double>(
                                              key: ValueKey<double>(consumed.toDouble()),
                                              tween: Tween(
                                                begin: 0,
                                                end: progressValue.clamp(0.0, 1.0),
                                              ),
                                              duration: const Duration(milliseconds: 450),
                                              curve: Curves.easeOut,
                                              builder: (context, animatedValue, child) {
                                                return SizedBox(
                                                  width: 80,
                                                  height: 80,
                                                  child: CircularProgressIndicator(
                                                    value: animatedValue,
                                                    strokeWidth: 6,
                                                    backgroundColor: ThemeHelper.divider,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      ThemeHelper.textPrimary,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        // Center apple icon
                                        Image.asset('assets/icons/apple.png', width: 24, height: 24, color: ThemeHelper.textPrimary),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Calories numbers
                                Center(
                                  child: GetBuilder<ProgressService>(
                                    builder: (progressService) {
                                      final progressData = progressService.dailyProgressData;
                                      
                                      final localConsumed = _getLocalTotal('totalCalories');
                                      int consumed = localConsumed ?? 0;
                                      int goal = 0;
                                      
                                      if (progressData != null && progressData['progress'] != null) {
                                        final progress = progressData['progress'] as Map<String, dynamic>;
                                        if (consumed == 0) {
                                          consumed = ((progress['calories']?['consumed'] ?? 0) as num).toInt();
                                        }
                                        goal = ((progress['calories']?['goal'] ?? 0) as num).toInt();
                                      }
                                      
                                      return RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '$consumed',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: ThemeHelper.textPrimary,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '/$goal',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: ThemeHelper.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Info message
                                Center(
                                  child: GetBuilder<ProgressService>(
                                    builder: (progressService) {
                                      final progressData = progressService.dailyProgressData;
                                      
                                      final localConsumed = _getLocalTotal('totalCalories');
                                      int consumed = localConsumed ?? 0;
                                      int goal = 0;
                                      int remaining;
                                      
                                      if (progressData != null && progressData['progress'] != null) {
                                        final progress = progressData['progress'] as Map<String, dynamic>;
                                        if (consumed == 0) {
                                          consumed = ((progress['calories']?['consumed'] ?? 0) as num).toInt();
                                        }
                                        goal = ((progress['calories']?['goal'] ?? 0) as num).toInt();
                                      }

                                      remaining = goal > 0 ? (goal - consumed).clamp(0, goal) : 0;
                                      
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            CupertinoIcons.info_circle,
                                            size: 12,
                                            color: ThemeHelper.textSecondary,
                                          ),
                                          const SizedBox(width: 3),
                                          Flexible(
                                            child: Text(
                                              '$remaining ${l10n.caloriesMoreToGo}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: ThemeHelper.textSecondary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right side - Macro Cards (stacked vertically)
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _animateCard(
                            id: 'macro_fat',
                            order: 2,
                            child: _buildCompactMacroCard(
                              l10n.fats,
                              'fat',
                              CupertinoColors.systemRed,
                              l10n,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _animateCard(
                            id: 'macro_protein',
                            order: 3,
                            child: _buildCompactMacroCard(
                              l10n.protein,
                              'protein',
                              CupertinoColors.systemBlue,
                              l10n,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _animateCard(
                            id: 'macro_carbs',
                            order: 4,
                            child: _buildCompactMacroCard(
                              l10n.carbs,
                              'carbs',
                              CupertinoColors.systemOrange,
                              l10n,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              
              const SizedBox(height: 32),

               // Show exercise cards if available
                      if (_localTodayExercises.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              // Section title
                              _animateCard(
                                id: 'recent_exercises_title',
                                order: 5,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    l10n.recentlyUploaded,
                                    style: TextStyle(
                                      color: ThemeHelper.textPrimary,
                                      fontSize: 20,
                                      fontFamily: 'Instrument Sans',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              // Exercise cards
                              ..._localTodayExercises.asMap().entries.map((entry) {
                                final index = entry.key;
                                final exercise = entry.value;
                                return _animateCard(
                                  id: 'exercise_$index',
                                  order: 6 + index,
                                  child: _buildExerciseCard(exercise, l10n),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
              
              // Recently Logged Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.isLoadingInitialData) ...[
                      // Show shimmer loading effect while fetching initial data
                      Shimmer.fromColors(
                        baseColor: ThemeHelper.divider,
                        highlightColor: ThemeHelper.cardBackground,
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: ThemeHelper.cardBackground,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeHelper.textPrimary.withOpacity(0.1),
                                blurRadius: 3,
                                offset: Offset(0, 0),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Shimmer image placeholder
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: ThemeHelper.background,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Shimmer content placeholder
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Title placeholder
                                      Container(
                                        width: double.infinity,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: ThemeHelper.background,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Nutrition cards placeholders
                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                width: 70,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: widget.themeProvider.isLightMode 
                                                      ? Colors.white 
                                                      : const Color(0xFF1A1A1A),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                width: 70,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: widget.themeProvider.isLightMode 
                                                      ? Colors.white 
                                                      : const Color(0xFF1A1A1A),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            children: [
                                              Container(
                                                width: 70,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: widget.themeProvider.isLightMode 
                                                      ? Colors.white 
                                                      : const Color(0xFF1A1A1A),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                width: 70,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: widget.themeProvider.isLightMode 
                                                      ? Colors.white 
                                                      : const Color(0xFF1A1A1A),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ] else if ((widget.selectedImage == null || widget.isAnalyzing) &&
                        (_localTodayTotals == null) &&
                        ((widget.todayEntries == null) || widget.todayEntries!.isEmpty) &&
                        _localTodayExercises.isEmpty) ...[
                      Text(
                        l10n.noFoodLogged,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _animateCard(
                        id: 'recently_logged',
                        order: 3,
                        child: _buildRecentlyLoggedCard(),
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      if (widget.isAnalyzing)
                        _animateCard(
                          id: 'analyzing_card',
                          order: 2,
                          child: _buildRecentlyLoggedCard(),
                        ),
                      if (widget.hasScanError)
                        _animateCard(
                          id: 'scan_error_card',
                          order: 2,
                          child: _buildScanErrorCard(),
                        ),
                      // Removed optimistic scanned food card - only show after meal is saved
                      if (_localTodayMeals.isNotEmpty) ...[
                        Column(
                          children: _localTodayMeals.asMap().entries
                              .map((entry) {
                                final index = entry.key;
                                final meal = entry.value;
                                final mealId = _extractMealId(meal) ?? 'idx_$index';
                                return _animateCard(
                                  id: 'meal_$mealId',
                                  order: 4 + index,
                                  child: GestureDetector(
                                    onTap: () => _openMealDetails(meal),
                                    child: _buildMealTotalsCard(meal, l10n),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                      ] else if (_localTodayTotals != null) ...[
                        _animateCard(
                          id: 'today_totals_card',
                          order: 4,
                          child: _buildTodayTotalsCard(l10n, _localTodayTotals!),
                        ),
                        const SizedBox(height: 12),
                      ],
                     
                      // Only show overall meal, not separate entries
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: 40 + MediaQuery.of(context).padding.bottom + 20),
                      ],
                    ),
                  ),
                  
                  // Overlay and streak card
                  if (_showStreakCard) ...[
                    // Darkened background overlay
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showStreakCard = false;
                          });
                        },
                        child: Container(
                          color: ThemeHelper.textPrimary.withOpacity(0.5),
                        ),
                      ),
                    ),
                    
                    // Streak information card
                    Positioned(
                      top: 180, // Higher position, around where calorie tracker is
                      left: 30,
                      right: 30,
                      child: _buildStreakCard(l10n),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openMealDetails(Map<String, dynamic> meal) async {
    final updatedMeal = await Navigator.of(context).push<Map<String, dynamic>>(
      CupertinoPageRoute(
        builder: (context) => MealDetailsScreen(
          mealData: meal,
        ),
      ),
    );

    if (updatedMeal != null) {
      setState(() {
        _applyLocalMealUpdate(updatedMeal);
        _recalculateLocalTotals();
      });
      if (Get.isRegistered<HomeScreenController>()) {
        final controller = Get.find<HomeScreenController>();
        // Refresh backend data to keep other observers in sync.
        controller.fetchTodayTotals();
      }
    }
  }

  Future<void> _openExerciseDetails(Map<String, dynamic> exercise) async {
    final updatedExercise = await Navigator.of(context).push<Map<String, dynamic>>(
      CupertinoPageRoute(
        builder: (context) => ExerciseDetailScreen(
          exerciseData: Map<String, dynamic>.from(exercise),
        ),
      ),
    );

    if (updatedExercise != null) {
      setState(() {
        _applyLocalExerciseUpdate(updatedExercise);
      });
      if (Get.isRegistered<HomeScreenController>()) {
        final controller = Get.find<HomeScreenController>();
        controller.fetchTodayTotals();
      }
    }
  }

  Widget _buildDaySelector(DateTime date, int dayIndex, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isSelected = date.isAtSameMomentAs(today);
    
    // Get localized day abbreviation
    String dayAbbr;
    switch (date.weekday) {
      case 1: dayAbbr = l10n.monday; break;
      case 2: dayAbbr = l10n.tuesday; break;
      case 3: dayAbbr = l10n.wednesday; break;
      case 4: dayAbbr = l10n.thursday; break;
      case 5: dayAbbr = l10n.friday; break;
      case 6: dayAbbr = l10n.saturday; break;
      case 7: dayAbbr = l10n.sunday; break;
      default: dayAbbr = DateFormat('E').format(date).substring(0, 3);
    }
    
    // Get streak status from service
    final streakStatus = _getStreakStatusForDate(date, today);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDay = dayIndex;
        });
      },
      child: Column(
        children: [
          // Day label
          Text(
            dayAbbr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ThemeHelper.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Status icon
          SizedBox(
            width: 32,
            height: 32,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
                return FadeTransition(
                  opacity: curved,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
                    child: child,
                  ),
                );
              },
              child: _buildDayIcon(streakStatus, isSelected),
            ),
          ),
        ],
      ),
    );
  }

  StreakStatus _getStreakStatusForDate(DateTime date, DateTime today) {
    // Future dates are neutral
    if (date.isAfter(today)) {
      return StreakStatus.neutral;
    }
    
    // Check if there's a streak entry for this date
    final streakType = streakService.getStreakType(date);
    
    if (streakType == null) {
      // No entry - neutral/not logged
      return StreakStatus.neutral;
    } else if (streakType == 'Successful') {
      return StreakStatus.completed;
    } else {
      // Failed
      return StreakStatus.missed;
    }
  }

  Widget _buildDayIcon(StreakStatus status, bool isSelected) {
    final key = ValueKey<String>('streak_${status.name}_${isSelected ? 'selected' : 'normal'}');
    switch (status) {
      case StreakStatus.completed:
        return Image.asset(
          'assets/icons/flame.png',
          key: key,
          width: 32,
          height: 32,
        );
      case StreakStatus.missed:
        return Opacity(
          key: key,
          opacity: 0.6,
          child: Image.asset('assets/icons/flame_missed.png', width: 32, height: 32),
        );
      case StreakStatus.neutral:
        return Opacity(
          key: key,
          opacity: 0.3,
          child: Image.asset('assets/icons/flame.png', width: 32, height: 32),
        );
    }
  }

  // Helper method to get icon for macro based on dataKey
  Widget _getIconForMacro(String dataKey) {
    // Check against data key directly to avoid localization issues
    switch (dataKey.toLowerCase()) {
      case 'carbs':
        return Image.asset('assets/icons/carbs.png', width: 16, height: 16);
      case 'protein':
        return Image.asset('assets/icons/drumstick.png', width: 16, height: 16);
      case 'fat':
        return Image.asset('assets/icons/fat.png', width: 16, height: 16);
      default:
        return Icon(CupertinoIcons.circle_fill, size: 16, color: CupertinoColors.systemGrey);
    }
  }

  Widget _buildCompactMacroCard(String label, String dataKey, Color color, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetGoalsScreen(dailyProgress: _localTodayTotals),
          ),
        );
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: ThemeHelper.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.textPrimary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Progress circle
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress circle
                    GetBuilder<ProgressService>(
                      builder: (progressService) {
                        final progressData = progressService.dailyProgressData;
                        
                        final localConsumed = _getLocalMacro(dataKey);
                        int consumed = localConsumed ?? 0;
                        int goal = 0;
                        
                        if (progressData != null && progressData['progress'] != null) {
                          final progress = progressData['progress'] as Map<String, dynamic>;
                          if (progress['macros'] != null) {
                            final macros = progress['macros'] as Map<String, dynamic>;
                            if (consumed == 0) {
                              consumed = ((macros[dataKey]?['consumed'] ?? 0) as num).toInt();
                            }
                            goal = ((macros[dataKey]?['goal'] ?? 0) as num).toInt();
                          }
                        }
                        
                        double progressValue = goal > 0 ? consumed / goal : 0.0;
                        
                                        return TweenAnimationBuilder<double>(
                                          key: ValueKey<String>('${dataKey}_$consumed'),
                                          tween: Tween(
                                            begin: 0,
                                            end: progressValue.clamp(0.0, 1.0),
                                          ),
                                          duration: const Duration(milliseconds: 450),
                                          curve: Curves.easeOut,
                                          builder: (context, animatedValue, child) {
                                            return CustomPaint(
                                              size: Size(48, 48),
                                              painter: CircleProgressPainter(
                                                progress: animatedValue,
                                                color: color,
                                                strokeWidth: 4,
                                              ),
                                            );
                                          },
                                        );
                      },
                    ),
                    // Center icon based on dataKey
                    _getIconForMacro(dataKey),
                  ],
                ),
              ),
            ),
            // Table-like container with label and amount
            Expanded(
              child: Container(
                height: 80,
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ThemeHelper.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeHelper.textPrimary.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Label as table header with gray background
                    Container(
                      width: double.infinity,
                      height: 28,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: ThemeHelper.divider.withOpacity(0.5),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: widget.themeProvider.isLightMode ? Colors.black : Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                    // Values as table content with white background
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ThemeHelper.cardBackground,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: GetBuilder<ProgressService>(
                            builder: (progressService) {
                              final progressData = progressService.dailyProgressData;
                              
                              final localConsumed = _getLocalMacro(dataKey);
                              int consumed = localConsumed ?? 0;
                              int goal = 0;
                              
                              if (progressData != null && progressData['progress'] != null) {
                                final progress = progressData['progress'] as Map<String, dynamic>;
                                if (progress['macros'] != null) {
                                  final macros = progress['macros'] as Map<String, dynamic>;
                                  if (consumed == 0) {
                                    consumed = ((macros[dataKey]?['consumed'] ?? 0) as num).toInt();
                                  }
                                  goal = ((macros[dataKey]?['goal'] ?? 0) as num).toInt();
                                }
                              }
                              
                              return RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$consumed',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeHelper.textPrimary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '/$goal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: ThemeHelper.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRecentlyLoggedCard() {
    // If there's an image and not analyzing, show only the image
    if (widget.selectedImage != null && !widget.isAnalyzing) {
      return SizedBox.shrink(); // Hide this when showing scanned food card
    }

    // Show analyzing card when analyzing
    if (widget.isAnalyzing) {
      return _buildAnalyzingCard();
    }

    // Otherwise, show the full layout with text
    return Column(
      children: [
        // Food image with rounded border
        Container(
          width: widget.selectedImage != null ? 80 : double.infinity,
          height: widget.selectedImage != null ? 80 : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: CupertinoColors.systemGrey4,
              width: widget.selectedImage != null ? 1 : 0,
            ),
          ),
          child: Stack(
            children: [
              // Show selected image if available, otherwise placeholder
              if (widget.selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    widget.selectedImage!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Image.asset(ThemeHelper.isLightMode ? 'assets/images/AI_Slides_Image.png' : 'assets/images/AI_Slides_Image_Dark.png'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Message text
        Text(
          AppLocalizations.of(context)!.tapPlusToTrack,
          style: TextStyle(
            fontSize: 16,
            color: ThemeHelper.textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScanErrorCard() {
    return Container(
      width: 345,
      height: 106,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: ShapeDecoration(
        color: ThemeHelper.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadows: [
          BoxShadow(
            color: ThemeHelper.textPrimary.withOpacity(0.2),
            blurRadius: 3,
            offset: Offset(0, 0),
            spreadRadius: 0,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Food image with opacity overlay
            Opacity(
              opacity: 0.80,
              child: Container(
                width: 91,
                height: 91,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: widget.selectedImage != null
                      ? DecorationImage(
                          image: FileImage(widget.selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage('assets/images/AI_Slides_Image.png'),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Error content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Error text
                  Text(
                    'No food detected',
                    style: const TextStyle(
                      color: Color(0xFFDE2222),
                      fontSize: 12,
                      fontFamily: 'Instrument Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Retry button
                  GestureDetector(
                    onTap: widget.onRetryScan,
                    child: Text(
                      'Retry',
                      style: TextStyle(
                        color: ThemeHelper.textPrimary,
                        fontSize: 12,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Close button
            GestureDetector(
              onTap: widget.onCloseError,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ThemeHelper.textPrimary,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.xmark,
                    size: 12,
                    color: ThemeHelper.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzingCard() {
    return Container(
      width: double.infinity,
      height: 106,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: ShapeDecoration(
        color: ThemeHelper.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        shadows: [
          BoxShadow(
            color: ThemeHelper.textPrimary.withOpacity(0.1),
            blurRadius: 3,
            offset: Offset(0, 0),
            spreadRadius: 0,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Food image with opacity overlay
            Opacity(
              opacity: 0.6,
              child: Container(
                width: 90,
                height: 93,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: widget.selectedImage != null
                      ? DecorationImage(
                          image: FileImage(widget.selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage('assets/images/AI_Slides_Image.png'),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Analyzing content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Analyzing text
                  Text(
                    AppLocalizations.of(context)!.analyzing,
                    style: TextStyle(
                      color: ThemeHelper.textPrimary,
                      fontSize: 12,
                      fontFamily: 'Instrument Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Placeholder nutrition cards in 2x2 grid
                  Row(
                    children: [
                      // Left column
                      Column(
                        children: [
                          _buildPlaceholderNutritionCard(),
                          const SizedBox(height: 4),
                          _buildPlaceholderNutritionCard(),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Right column
                      Column(
                        children: [
                          _buildPlaceholderNutritionCard(),
                          const SizedBox(height: 4),
                          _buildPlaceholderNutritionCard(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Chevron icon
            Container(
              width: 24,
              height: 24,
              child: Icon(
                CupertinoIcons.chevron_right,
                size: 24,
                color: ThemeHelper.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderNutritionCard() {
    return Container(
      width: 70,
      height: 24,
      decoration: ShapeDecoration(
        color: ThemeHelper.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        shadows: [
          BoxShadow(
            color: ThemeHelper.textPrimary.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 0),
            spreadRadius: 1,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Placeholder icon
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: ThemeHelper.textPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Placeholder text lines
                Opacity(
                  opacity: 0.1,
                  child: Container(
                    width: 35,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ThemeHelper.textPrimary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Opacity(
                  opacity: 0.1,
                  child: Container(
                    width: 20,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ThemeHelper.textPrimary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Removed _buildScannedFoodCard method - no longer needed since we don't show optimistic meal cards

  Widget _buildNutritionCard(String value, String label, String iconPath) {
    return Container(
      width: 70,
      height: 30,
      decoration: ShapeDecoration(
        color: ThemeHelper.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        shadows: [
          BoxShadow(
            color: ThemeHelper.textPrimary.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 0),
            spreadRadius: 1,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              iconPath,
              width: 12,
              height: 12,
            ),
            const SizedBox(width: 4),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value g',
                  style: TextStyle(
                    color: ThemeHelper.textPrimary,
                    fontSize: 9,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: ThemeHelper.textSecondary,
                    fontSize: 7,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Removed banner; using original analyzing card with image and overlay

  // Removed per-entry card rendering per requirement (overall meal only)

  Widget _buildTodayTotalsCard(AppLocalizations l10n, Map<String, int> totals) {
    final calories = totals['totalCalories'] ?? 0;
    final protein = totals['totalProtein'] ?? 0;
    final fat = totals['totalFat'] ?? 0;
    final carbs = totals['totalCarbs'] ?? 0;
    // Build time from todayCreatedAt using app's locale
    String timeString = '';
    if (widget.todayCreatedAt != null) {
      try {
        final createdAt = DateTime.parse(widget.todayCreatedAt!);
        timeString = DateFormat('HH:mm', Localizations.localeOf(context).toString()).format(createdAt);
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 12),
      decoration: ShapeDecoration(
        color: ThemeHelper.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadows: [
          BoxShadow(
            color: ThemeHelper.textPrimary.withOpacity(0.2),
            blurRadius: 3,
            offset: Offset(0, 0),
            spreadRadius: 0,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Placeholder image area for consistency in layout
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: widget.themeProvider.isLightMode 
                    ? Colors.white 
                    : const Color(0xFF1A1A1A),
              ),
              child: Center(
                child: Image.asset('assets/icons/apple.png', width: 24, height: 24, color: ThemeHelper.textPrimary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.todaysLunchTotals,
                          style: TextStyle(
                            color: ThemeHelper.textPrimary,
                            fontSize: 14,
                            fontFamily: 'Instrument Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  if (timeString.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: ShapeDecoration(
                        color: ThemeHelper.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadows: [
                          BoxShadow(
                            color: ThemeHelper.textPrimary.withOpacity(0.2),
                            blurRadius: 3,
                            offset: Offset(0, 0),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Text(
                        timeString,
                        style: TextStyle(
                          color: ThemeHelper.textPrimary,
                          fontSize: 9,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        children: [
                          _buildNutritionCard(calories.toString(), l10n.calories, 'assets/icons/carbs.png'),
                          const SizedBox(height: 4),
                          _buildNutritionCard(protein.toString(), l10n.protein, 'assets/icons/drumstick.png'),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          _buildNutritionCard(fat.toString(), l10n.fats, 'assets/icons/fat.png'),
                          const SizedBox(height: 4),
                          _buildNutritionCard(carbs.toString(), l10n.carbs, 'assets/icons/carbs.png'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              child: Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: ThemeHelper.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTotalsCard(Map<String, dynamic> meal, AppLocalizations l10n) {
    final calories = ((meal['totalCalories'] ?? 0) as num).toInt();
    final protein = ((meal['totalProtein'] ?? 0) as num).toInt();
    final fat = ((meal['totalFat'] ?? 0) as num).toInt();
    final carbs = ((meal['totalCarbs'] ?? 0) as num).toInt();
    final mealName = (meal['mealName'] as String?)?.trim();
    // Prefer mealImage; fallback to first entry.imageUrl if available
    String? imageUrl = (meal['mealImage'] as String?)?.trim();
    if ((imageUrl == null || imageUrl.isEmpty) && meal['entries'] is List) {
      final entries = meal['entries'] as List;
      if (entries.isNotEmpty && entries.first is Map) {
        final first = entries.first as Map;
        final url = first['imageUrl'];
        if (url is String && url.isNotEmpty) {
          imageUrl = url;
        }
      }
    }
    String timeString = '';
    final createdAtStr = meal['createdAt'] as String?;
    if (createdAtStr != null) {
      try {
        final createdAt = DateTime.parse(createdAtStr).toLocal();
        timeString = DateFormat('HH:mm', Localizations.localeOf(context).toString()).format(createdAt);
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 12),
      decoration: ShapeDecoration(
        color: ThemeHelper.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadows: [
          BoxShadow(
            color: ThemeHelper.textPrimary.withOpacity(0.2),
            blurRadius: 3,
            offset: Offset(0, 0),
            spreadRadius: 0,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 96,
                height: 96,
                color: widget.themeProvider.isLightMode 
                    ? Colors.white 
                    : const Color(0xFF1A1A1A),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Image.asset('assets/icons/apple.png', width: 24, height: 24, color: ThemeHelper.textPrimary),
                        ),
                      )
                    : Center(
                        child: Image.asset('assets/icons/apple.png', width: 24, height: 24, color: ThemeHelper.textPrimary),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mealName != null && mealName.isNotEmpty ? mealName : l10n.mealTotals,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ThemeHelper.textPrimary,
                            fontSize: 14,
                            fontFamily: 'Instrument Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (timeString.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadows: [
                              BoxShadow(
                                color: ThemeHelper.textPrimary.withOpacity(0.2),
                                blurRadius: 3,
                                offset: Offset(0, 0),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Text(
                            timeString,
                            style: const TextStyle(
                              color: Color(0xFF1E1822),
                              fontSize: 9,
                              fontFamily: 'Instrument Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        children: [
                          _buildNutritionCard(calories.toString(), l10n.calories, 'assets/icons/carbs.png'),
                          const SizedBox(height: 4),
                          _buildNutritionCard(protein.toString(), l10n.protein, 'assets/icons/drumstick.png'),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          _buildNutritionCard(fat.toString(), l10n.fats, 'assets/icons/fat.png'),
                          const SizedBox(height: 4),
                          _buildNutritionCard(carbs.toString(), l10n.carbs, 'assets/icons/carbs.png'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                CupertinoIcons.chevron_right,
                size: 24,
                color: ThemeHelper.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, AppLocalizations l10n) {
    final caloriesBurned = ((exercise['caloriesBurned'] ?? 0) as num).toInt();
    final exerciseType = exercise['type'] as String? ?? 'Exercise';
    final loggedAt = exercise['loggedAt'] as String?;
    final notes = exercise['notes'] as String?;

    String timeString = '';
    if (loggedAt != null) {
      try {
        final loggedDateTime = DateTime.parse(loggedAt);
        timeString = DateFormat('HH:mm', Localizations.localeOf(context).toString()).format(loggedDateTime);
      } catch (_) {}
    }

    String exerciseName = exerciseType;
    if (notes != null && notes.isNotEmpty) {
      exerciseName = notes;
    }

    final String iconPath = _getExerciseIcon(exerciseType);

    return GestureDetector(
      onTap: () => _openExerciseDetails(exercise),
      child: Container(
        width: double.infinity,
        height: 106,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: ShapeDecoration(
          color: ThemeHelper.cardBackground,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          shadows: [
            BoxShadow(
              color: ThemeHelper.textPrimary.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 0),
              spreadRadius: 0,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: ShapeDecoration(
                  color: widget.themeProvider.isLightMode ? Colors.white : const Color(0xFF1A1A1A),
                  shape: const OvalBorder(),
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exerciseName,
                            style: TextStyle(
                              color: ThemeHelper.textPrimary,
                              fontSize: 12,
                              fontFamily: 'Instrument Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        if (timeString.isNotEmpty)
                          Container(
                            width: 24,
                            height: 12,
                            decoration: ShapeDecoration(
                              color: widget.themeProvider.isLightMode ? Colors.white : const Color(0xFF1A1A1A),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: ThemeHelper.textPrimary.withOpacity(0.2),
                                  blurRadius: 3,
                                  offset: const Offset(0, 0),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                timeString,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ThemeHelper.textPrimary,
                                  fontSize: 6,
                                  fontFamily: 'Instrument Sans',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 70,
                      height: 24,
                      decoration: ShapeDecoration(
                        color: widget.themeProvider.isLightMode ? Colors.white : const Color(0xFF1A1A1A),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 5,
                            offset: Offset(0, 0),
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/icons/apple.png',
                              color: ThemeHelper.textPrimary,
                              width: 12,
                              height: 12,
                            ),
                            const SizedBox(width: 4),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  caloriesBurned.toString(),
                                  style: TextStyle(
                                    color: ThemeHelper.textPrimary,
                                    fontSize: 7,
                                    fontFamily: 'Instrument Sans',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  l10n.calories,
                                  style: TextStyle(
                                    color: ThemeHelper.textSecondary,
                                    fontSize: 6,
                                    fontFamily: 'Instrument Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    CupertinoIcons.chevron_right,
                    size: 24,
                    color: ThemeHelper.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getExerciseIcon(String exerciseType) {
    // Map exercise types to appropriate icons (using same icons as log screen)
    switch (exerciseType.toLowerCase()) {
      case 'steps':
        return 'assets/icons/steps.png';
      case 'running':
      case 'cardio':
        return 'assets/icons/heartbeat.png'; // Same as cardio in log screen
      case 'weight_lifting':
      case 'strength':
        return 'assets/icons/weights.png'; // Same as weight training in log screen
      case 'cycling':
      case 'bike':
        return 'assets/icons/bike.png';
      case 'swimming':
        return 'assets/icons/swimming.png';
      case 'yoga':
        return 'assets/icons/yoga.png';
      case 'describe':
      case 'custom':
        return 'assets/icons/stats.png'; // Same as describe exercise in log screen
      case 'direct_input':
        return 'assets/icons/input.png'; // Same as direct input in log screen
      default:
        return 'assets/icons/heartbeat.png'; // Default to cardio icon
    }
  }

  Widget _buildStreakCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.textPrimary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top section with app name and streak counter
          Row(
            children: [
              // App icon and name
              Row(
                children: [
                  Image.asset('assets/icons/app_logo.png', width: 24, height: 24, color: ThemeHelper.textPrimary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.kalorina,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ThemeHelper.textPrimary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Streak counter in top right
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ThemeHelper.divider,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icons/flame.png', width: 16, height: 16),
                    const SizedBox(width: 4),
                    Text(
                      '0',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Compact flame icons row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Active flames (first 4)
              Image.asset('assets/icons/flame.png', width: 28, height: 28),
              const SizedBox(width: 6),
              Image.asset('assets/icons/flame.png', width: 28, height: 28),
              const SizedBox(width: 6),
              Image.asset('assets/icons/flame.png', width: 28, height: 28),
              const SizedBox(width: 6),
              Image.asset('assets/icons/flame.png', width: 28, height: 28),
              const SizedBox(width: 6),
              // Inactive flames (last 3)
              Opacity(
                opacity: 0.3,
                child: Image.asset('assets/icons/flame.png', width: 28, height: 28),
              ),
              const SizedBox(width: 6),
              Opacity(
                opacity: 0.2,
                child: Image.asset('assets/icons/flame.png', width: 28, height: 28),
              ),
              const SizedBox(width: 6),
              Opacity(
                opacity: 0.1,
                child: Image.asset('assets/icons/flame.png', width: 28, height: 28),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Message text
          Text(
            l10n.consistencyMatters,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ThemeHelper.textSecondary,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // Continue button
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: ThemeHelper.textPrimary,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: () {
                setState(() {
                  _showStreakCard = false;
                });
              },
              child: Text(
                l10n.continueButton,
                style: TextStyle(
                  color: ThemeHelper.background,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle (light grey outline)
    final backgroundPaint = Paint()
      ..color = ThemeHelper.divider
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc (colored outline only)
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * 3.14159 * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is CircleProgressPainter &&
        (oldDelegate.progress != progress ||
            oldDelegate.color != color ||
            oldDelegate.strokeWidth != strokeWidth);
  }
}

class DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ThemeHelper.divider
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 2) / 2;

    // Create dashed circle
    const dashWidth = 3.0;
    const dashSpace = 2.0;
    const totalDashLength = dashWidth + dashSpace;
    final circumference = 2 * 3.14159 * radius;
    final dashCount = (circumference / totalDashLength).floor();

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * totalDashLength / radius) - (3.14159 / 2);
      final endAngle = ((i * totalDashLength + dashWidth) / radius) - (3.14159 / 2);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart' show AppLocalizations;
import '../providers/theme_provider.dart';
import '../services/streak_service.dart';
import 'log_streak_screen.dart' show LogStreakScreen;

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
  final Map<String, dynamic>? dailyProgress;

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
    this.dailyProgress,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  int selectedDay = 6; // Thursday (6th)
  bool _showStreakCard = false; // State for showing streak card
  late final StreakService streakService;
  List<DateTime> weekDates = [];
  
  // Mock data - replace with real data from your backend
  final int dailyCalorieGoal = 2000;
  final int consumedCalories = 1000;
  final int remainingCalories = 1000;
  final int proteinLeft = 100;
  final int carbsLeft = 99;
  final int fatLeft = 25;

  late AnimationController _percentageController;
  late Animation<int> _percentageAnimation;

  @override
  void initState() {
    super.initState();
    streakService = Get.put(StreakService());
    _initializeWeek();
    _loadStreaksForWeek();
    
    _percentageController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _percentageAnimation = IntTween(
      begin: 0,
      end: 100,
    ).animate(CurvedAnimation(
      parent: _percentageController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Get Monday of current week (weekday 1)
    final monday = today.subtract(Duration(days: today.weekday - 1));
    
    weekDates = List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  Future<void> _loadStreaksForWeek() async {
    if (weekDates.isEmpty) return;
    
    final startDate = weekDates.first;
    final endDate = weekDates.last;
    
    await Future.wait([
      streakService.getStreaksForDateRange(
        startDate: startDate,
        endDate: endDate,
      ),
      streakService.getStreakHistory(),
    ]);
  }

  @override
  void dispose() {
    _percentageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnalyzing && !oldWidget.isAnalyzing) {
      // Start animation when analyzing begins
      _percentageController.forward();
    } else if (!widget.isAnalyzing && oldWidget.isAnalyzing) {
      // Reset animation when analyzing stops
      _percentageController.reset();
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
                colors: [
                  Color(0xFFD1D9E6), // More visible bluish slate at top
                  Color(0xFFE2E8F0), // Light slate blue-gray
                  Color(0xFFF1F5F9), // Very light bluish gray
                  Color(0xFFFFFFFF), // Pure white at bottom
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
                    Image.asset('assets/icons/apple.png', width: 48, height: 48),
                    Text(
                      l10n.appTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
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
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(0.1),
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
                            const Text(
                              'Log Streak',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.black,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              CupertinoIcons.add,
                              size: 16,
                              color: CupertinoColors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Day Selector
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.05),
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
                    return _buildDaySelector(date, index);
                  }).toList(),
                )),
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
                        child: Container(
                        height: 264, // Match macro stack height (3×80 + 2×12)
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(0.05),
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
                                color: CupertinoColors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Progress ring with apple icon
                            Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Progress circle
                                    SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: CircularProgressIndicator(
                                        value: 0.83, // 1875/2250
                                        strokeWidth: 6,
                                        backgroundColor: CupertinoColors.systemGrey5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          CupertinoColors.black,
                                        ),
                                      ),
                                    ),
                                    // Center apple icon
                                    Image.asset('assets/icons/apple.png', width: 24, height: 24),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Calories numbers
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                      TextSpan(
                                      text: '${widget.dailyProgress?['calories']?['consumed'] ?? 0}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                      TextSpan(
                                      text: '/${widget.dailyProgress?['calories']?['goal'] ?? 0}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Info message
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.info_circle,
                                    size: 12,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      '${(widget.dailyProgress?['calories']?['remaining'] ?? 0)} Calories more to go!',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Right side - Macro Cards (stacked vertically)
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildCompactMacroCard(
                            'Fats',
                            ((widget.dailyProgress?['macros']?['fat']?['consumed'] ?? 0) as num).toInt(),
                            ((widget.dailyProgress?['macros']?['fat']?['goal'] ?? 0) as num).toInt(),
                            CupertinoColors.systemRed,
                          ),
                          const SizedBox(height: 12),
                          _buildCompactMacroCard(
                            'Protein',
                            ((widget.dailyProgress?['macros']?['protein']?['consumed'] ?? 0) as num).toInt(),
                            ((widget.dailyProgress?['macros']?['protein']?['goal'] ?? 0) as num).toInt(),
                            CupertinoColors.systemBlue,
                          ),
                          const SizedBox(height: 12),
                          _buildCompactMacroCard(
                            'Carbohydrates',
                            ((widget.dailyProgress?['macros']?['carbs']?['consumed'] ?? 0) as num).toInt(),
                            ((widget.dailyProgress?['macros']?['carbs']?['goal'] ?? 0) as num).toInt(),
                            CupertinoColors.systemOrange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              
              const SizedBox(height: 32),
              
              // Recently Logged Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if ((widget.selectedImage == null || widget.isAnalyzing) && (widget.todayTotals == null) && ((widget.todayEntries == null) || widget.todayEntries!.isEmpty)) ...[
                      Text(
                        l10n.noFoodLogged,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRecentlyLoggedCard(),
                      const SizedBox(height: 20),
                    ] else ...[
                      if (widget.isAnalyzing) _buildRecentlyLoggedCard(),
                      if (widget.selectedImage != null && !widget.isAnalyzing)
                        _buildScannedFoodCard(),
                      if ((widget.todayMeals ?? []).isNotEmpty) ...[
                        Column(
                          children: widget.todayMeals!.map((meal) => _buildMealTotalsCard(meal)).toList(),
                        ),
                        const SizedBox(height: 12),
                      ] else if (widget.todayTotals != null) ...[
                        _buildTodayTotalsCard(),
                        const SizedBox(height: 12),
                      ],
                      // Only show overall meal, not separate entries
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 40), // Replace Spacer with fixed height
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
                          color: CupertinoColors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                    
                    // Streak information card
                    Positioned(
                      top: 180, // Higher position, around where calorie tracker is
                      left: 30,
                      right: 30,
                      child: _buildStreakCard(),
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

  Widget _buildDaySelector(DateTime date, int dayIndex) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isSelected = date.isAtSameMomentAs(today);
    
    // Get day abbreviation (Mon, Tue, etc.)
    final dayAbbr = DateFormat('E').format(date).substring(0, 3);
    
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
              color: CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 8),
          // Status icon
          Container(
            width: 32,
            height: 32,
            child: _buildDayIcon(streakStatus, isSelected),
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
    switch (status) {
      case StreakStatus.completed:
        return Image.asset('assets/icons/flame.png', width: 32, height: 32);
      case StreakStatus.missed:
        return Opacity(
          opacity: 0.6,
          child: Image.asset('assets/icons/flame_missed.png', width: 32, height: 32),
        );
      case StreakStatus.neutral:
        return Opacity(
          opacity: 0.3,
          child: Image.asset('assets/icons/flame.png', width: 32, height: 32),
        );
    }
  }

  // Helper method to get icon for macro based on label
  Widget _getIconForMacro(String label) {
    if (label.toLowerCase().contains('carb')) {
      return Image.asset('assets/icons/carbs.png', width: 16, height: 16);
    } else if (label.toLowerCase().contains('protein')) {
      return Image.asset('assets/icons/drumstick.png', width: 16, height: 16);
    } else if (label.toLowerCase().contains('fat')) {
      return Image.asset('assets/icons/fat.png', width: 16, height: 16);
    } else {
      return Icon(CupertinoIcons.circle_fill, size: 16, color: CupertinoColors.systemGrey);
    }
  }

  Widget _buildCompactMacroCard(String label, int current, int total, Color color) {
    double progress = current / total;
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.05),
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
            child: Container(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress circle
                  CustomPaint(
                    size: Size(48, 48),
                    painter: CircleProgressPainter(
                      progress: progress,
                      color: color,
                      strokeWidth: 4,
                    ),
                  ),
                  // Center icon based on label
                  _getIconForMacro(label),
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
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.03),
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
                      color: CupertinoColors.systemGrey6,
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
                          color: CupertinoColors.systemGrey,
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
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$current',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.black,
                                ),
                              ),
                              TextSpan(
                                text: '/$total',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
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
    );
  }


  Widget _buildRecentlyLoggedCard() {
    // If there's an image and not analyzing, show only the image
    if (widget.selectedImage != null && !widget.isAnalyzing) {
      return SizedBox.shrink(); // Hide this when showing scanned food card
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
                Image.asset('assets/images/AI_Slides_Image.png'),
              // Progress overlay (only show when analyzing)
              if (widget.isAnalyzing)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: CupertinoColors.black.withOpacity(0.3),
                    ),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _percentageAnimation,
                        builder: (context, child) {
                          return Text(
                            '${_percentageAnimation.value}%',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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
        const SizedBox(height: 16),
        // Message text
        Text(
          widget.isAnalyzing 
            ? AppLocalizations.of(context)!.analyzing
            : AppLocalizations.of(context)!.tapPlusToTrack,
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScannedFoodCard() {
    // Extract data from nested scan result structure
    final scanData = widget.scanResult?['scanResult'];
    final items = scanData?['items'] as List? ?? [];
    final foodName = items.isNotEmpty ? items.first['name'] ?? 'Scanned Food' : 'Scanned Food';
    final calories = scanData?['totalCalories'] ?? 0;
    
    // Calculate totals from individual items since totalProtein, totalFat, totalCarbs are not in the response
    int totalProtein = 0;
    int totalFat = 0;
    int totalCarbs = 0;
    
    for (var item in items) {
      final macros = item['macros'] as Map<String, dynamic>? ?? {};
      totalProtein += ((macros['protein'] ?? 0) as num).toInt();
      totalFat += ((macros['fat'] ?? 0) as num).toInt();
      totalCarbs += ((macros['carbs'] ?? 0) as num).toInt();
    }
    
    // Debug logging removed per project rules
    
    // Use createdAt for timestamp, fallback to current time
    String timeString;
    if (widget.scanResult?['createdAt'] != null) {
      try {
        final createdAt = DateTime.parse(widget.scanResult!['createdAt']);
        timeString = '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        final now = DateTime.now();
        timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      }
    } else {
      final now = DateTime.now();
      timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    }
    
    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 12),
      decoration: ShapeDecoration(
        color: const Color(0xFFF8F7FC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Food image
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: FileImage(widget.selectedImage!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Food details and nutrition
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food name and time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          foodName,
                          style: TextStyle(
                            color: const Color(0xFF1E1822),
                            fontSize: 14,
                            fontFamily: 'Instrument Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Time badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                        child: Text(
                          timeString,
                          style: TextStyle(
                            color: const Color(0xFF1E1822),
                            fontSize: 9,
                            fontFamily: 'Instrument Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Nutrition cards in 2x2 grid
                   Row(
                     children: [
                       // Left column
                       Column(
                         children: [
                          _buildNutritionCard(
                            (widget.todayTotals?['totalCalories'] ?? calories).toString(),
                            'Calories',
                            'assets/icons/carbs.png',
                          ),
                           const SizedBox(height: 4),
                          _buildNutritionCard(
                            (widget.todayTotals?['totalProtein'] ?? totalProtein).toString(),
                            'Protein',
                            'assets/icons/drumstick.png',
                          ),
                         ],
                       ),
                       const SizedBox(width: 12),
                       // Right column
                       Column(
                         children: [
                          _buildNutritionCard(
                            (widget.todayTotals?['totalFat'] ?? totalFat).toString(),
                            'Fat',
                            'assets/icons/fat.png',
                          ),
                           const SizedBox(height: 4),
                          _buildNutritionCard(
                            (widget.todayTotals?['totalCarbs'] ?? totalCarbs).toString(),
                            'Carbs',
                            'assets/icons/carbs.png',
                          ),
                         ],
                       ),
                     ],
                   ),
                ],
              ),
            ),
            
            // Arrow icon
            Container(
              width: 20,
              height: 20,
              child: Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(String value, String label, String iconPath) {
    return Container(
      width: 70,
      height: 30,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        shadows: [
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
                    color: Colors.black.withOpacity(0.90),
                    fontSize: 9,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.70),
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

  Widget _buildTodayTotalsCard() {
    final totals = widget.todayTotals!;
    final calories = totals['totalCalories'] ?? 0;
    final protein = totals['totalProtein'] ?? 0;
    final fat = totals['totalFat'] ?? 0;
    final carbs = totals['totalCarbs'] ?? 0;
    // Build time from todayCreatedAt
    String timeString = '';
    if (widget.todayCreatedAt != null) {
      try {
        final createdAt = DateTime.parse(widget.todayCreatedAt!);
        timeString = '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 12),
      decoration: ShapeDecoration(
        color: const Color(0xFFF8F7FC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
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
                color: Colors.white,
              ),
              child: Center(
                child: Image.asset('assets/icons/apple.png', width: 24, height: 24),
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
                          'Today\'s lunch totals',
                          style: TextStyle(
                            color: const Color(0xFF1E1822),
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
                            color: Color(0x33000000),
                            blurRadius: 3,
                            offset: Offset(0, 0),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Text(
                        timeString,
                        style: TextStyle(
                          color: const Color(0xFF1E1822),
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
                          _buildNutritionCard(calories.toString(), 'Calories', 'assets/icons/carbs.png'),
                          const SizedBox(height: 4),
                          _buildNutritionCard(protein.toString(), 'Protein', 'assets/icons/drumstick.png'),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          _buildNutritionCard(fat.toString(), 'Fat', 'assets/icons/fat.png'),
                          const SizedBox(height: 4),
                          _buildNutritionCard(carbs.toString(), 'Carbs', 'assets/icons/carbs.png'),
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
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTotalsCard(Map<String, dynamic> meal) {
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
        final createdAt = DateTime.parse(createdAtStr);
        timeString = '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 12),
      decoration: ShapeDecoration(
        color: const Color(0xFFF8F7FC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 96,
                height: 96,
                color: Colors.white,
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
                          child: Image.asset('assets/icons/apple.png', width: 24, height: 24),
                        ),
                      )
                    : Center(
                        child: Image.asset('assets/icons/apple.png', width: 24, height: 24),
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
                          mealName != null && mealName.isNotEmpty ? mealName : 'Meal totals',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1E1822),
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
                                color: Color(0x33000000),
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
                          _buildNutritionCard(calories.toString(), 'Calories', 'assets/icons/carbs.png'),
                          const SizedBox(height: 4),
                          _buildNutritionCard(protein.toString(), 'Protein', 'assets/icons/drumstick.png'),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          _buildNutritionCard(fat.toString(), 'Fat', 'assets/icons/fat.png'),
                          const SizedBox(height: 4),
                          _buildNutritionCard(carbs.toString(), 'Carbs', 'assets/icons/carbs.png'),
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
              child: const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.15),
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
                  Image.asset('assets/icons/apple.png', width: 24, height: 24),
                  const SizedBox(width: 6),
                  Text(
                    'Kalorina',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Streak counter in top right
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
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
                        color: CupertinoColors.black,
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
            'Consistency matters for achieving your goals!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.systemGrey,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // Continue button
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: CupertinoColors.black,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: () {
                setState(() {
                  _showStreakCard = false;
                });
              },
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: CupertinoColors.white,
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
      ..color = CupertinoColors.systemGrey5
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
      ..color = CupertinoColors.systemGrey4
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

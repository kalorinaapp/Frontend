// ignore_for_file: unused_element

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../services/streak_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme_helper.dart' show ThemeHelper;

class LogStreakScreen extends StatefulWidget {
  const LogStreakScreen({super.key});

  @override
  State<LogStreakScreen> createState() => _LogStreakScreenState();
}

class _LogStreakScreenState extends State<LogStreakScreen> {
  late final StreakService streakService;

  @override
  void initState() {
    super.initState();
    streakService = Get.put(StreakService());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }


  Map<String, int> _getStreaksFromBackend() {
    // Get streak data from backend API
    final currentStreak = streakService.getCurrentStreak();
    final highestStreak = streakService.getHighestStreak();

    return {'current': currentStreak, 'longest': highestStreak};
  }

  Future<void> _loadHistory() async {
    await streakService.getStreakHistory();
    if (mounted) setState(() {});
  }

  Future<void> _loadStreaksForMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    await Future.wait([
      streakService.getStreaksForDateRange(
        startDate: startOfMonth,
        endDate: endOfMonth,
      ),
      streakService.getStreakHistory(),
    ]);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final DateTime now = DateTime.now();
    final DateTime firstOfMonth = DateTime(now.year, now.month, 1);
    final DateTime firstOfNextMonth = DateTime(now.year, now.month + 1, 1);
    final int daysInMonth = firstOfNextMonth.difference(firstOfMonth).inDays;
    final String monthTitle = DateFormat('LLLL, y', Localizations.localeOf(context).toString()).format(now); // e.g., September, 2025
    final int today = now.day;

    return CupertinoPageScaffold(
      backgroundColor: ThemeHelper.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top app bar area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back chevron (text style per spec)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 24,
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Text(
                        '←',
                        style: TextStyle(
                          color: ThemeHelper.textPrimary,
                          fontSize: 28,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),
                    ),
                  ),


                 
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minSize: 24,
                    onPressed: () => _showHowItWorksDialog(context),
                    child: SizedBox(
                      width: 120,
                      child: Text(
                        l10n.howDoesItWork,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: ThemeHelper.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Divider line
            
            const SizedBox(height: 12),
             Center(
               child: Text(
                 l10n.logStreak,
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   color: ThemeHelper.textPrimary,
                   fontSize: 28,
                   fontFamily: 'Instrument Sans',
                   fontWeight: FontWeight.w700,
                 ),
               ),
             ),
             const SizedBox(height: 30),
            // Streak summary chips (smaller ~40% width)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                final streaks = _getStreaksFromBackend();
                final currentStreak = streaks['current'] ?? 0;
                final longestStreak = streaks['longest'] ?? 0;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.6,
                      child: _summaryPill('🔥', '${l10n.currentStreak}: $currentStreak ${currentStreak == 1 ? l10n.day : l10n.days}'),
                    ),
                    const SizedBox(height: 8),
                    FractionallySizedBox(
                      widthFactor: 0.6,
                      child: _summaryPill('🏆', '${l10n.longestStreak}: $longestStreak ${longestStreak == 1 ? l10n.day : l10n.days}'),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 12),
            // Divider after chips
            Container(
              width: double.infinity,
              height: 1,
              color: ThemeHelper.divider,
            ),

            const SizedBox(height: 12),
            // Month heading (left aligned)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  monthTitle,
                  style: TextStyle(
                    color: ThemeHelper.textPrimary,
                    fontSize: 22,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

           

            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _MonthGrid(
                  daysInMonth: daysInMonth,
                  monthStart: firstOfMonth,
                  today: today,
                  streakService: streakService,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _summaryPill(String emoji, String text) {
    return Container(
      height: 36,
      decoration: ShapeDecoration(
        color: ThemeHelper.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        shadows: [
          BoxShadow(
            color: ThemeHelper.textPrimary.withOpacity(0.1),
            blurRadius: 3,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: ThemeHelper.textPrimary,
                fontSize: 14,
                fontFamily: 'Instrument Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showHowItWorksDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: ThemeHelper.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: ThemeHelper.divider, width: 1),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title - centered
              Center(
                child: Text(
                  l10n.howDoesItWorkTitle,
                  style: TextStyle(
                    color: ThemeHelper.textPrimary,
                    fontSize: 24,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Content - left aligned
              Text(
                l10n.howDoesItWorkDescription,
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/icons/flame.png', width: 24, height: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.successfulDescription,
                      style: TextStyle(
                        color: ThemeHelper.textPrimary,
                        fontSize: 16,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/icons/flame_missed.png', width: 24, height: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.failedDescription,
                      style: TextStyle(
                        color: ThemeHelper.textPrimary,
                        fontSize: 16,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l10n.streakExplanation,
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final int daysInMonth;
  final DateTime monthStart;
  final int today;
  final StreakService streakService;
  const _MonthGrid({
    required this.daysInMonth,
    required this.monthStart,
    required this.today,
    required this.streakService,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 16;
        final double totalInterItemSpacing = spacing * 2; // between 3 items
        final double tileWidth = (constraints.maxWidth - totalInterItemSpacing) / 3;

        return Obx(() {
          final List<Widget> tiles = List.generate(daysInMonth, (i) {
            final int day = i + 1;
            final DateTime date = DateTime(monthStart.year, monthStart.month, day);
            final String label = DateFormat('MMM d, y', Localizations.localeOf(context).toString()).format(date);

            // Get status from streak service
            _DayStatus status;
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final currentDate = DateTime(date.year, date.month, date.day);
            
            if (currentDate.isAfter(today)) {
              // Future dates are neutral
              status = _DayStatus.neutral;
            } else {
              // Check if there's a streak entry for this date
              final streakType = streakService.getStreakType(date);
              if (streakType == null) {
                // No entry - neutral/not logged
                status = _DayStatus.neutral;
              } else if (streakType == 'Successful') {
                status = _DayStatus.completed;
              } else {
                // Failed
                status = _DayStatus.missed;
              }
            }

            return SizedBox(
              width: tileWidth,
              child: _DayTile(
                label: label,
                status: status,
                date: date,
                streakService: streakService,
              ),
            );
          });

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: tiles,
          );
        });
      },
    );
  }
}

enum _DayStatus { completed, missed, neutral }

class _DayTile extends StatelessWidget {
  final String label;
  final _DayStatus status;
  final DateTime date;
  final StreakService streakService;
  const _DayTile({
    required this.label, 
    required this.status,
    required this.date,
    required this.streakService,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTileTap(context),
      child: Container(
        height: 130,
        decoration: ShapeDecoration(
          color: ThemeHelper.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _flameForStatus(status),
                  
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: ThemeHelper.textSecondary,
                fontSize: 12,
                fontFamily: 'Instrument Sans',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleTileTap(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentDate = DateTime(date.year, date.month, date.day);
    
    // Check if date is in the future
    if (currentDate.isAfter(today)) {
      _showFutureDateDialog(context);
    } else {
      _showDayOptionsDialog(context);
    }
  }

  void _showFutureDateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: ThemeHelper.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: ThemeHelper.divider, width: 1),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: ThemeHelper.cardBackground,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.calendar_badge_minus,
                    size: 32,
                    color: ThemeHelper.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                l10n.cannotLogFutureStreak,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 20,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                l10n.cannotLogFutureStreakDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeHelper.textSecondary,
                  fontSize: 16,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // OK button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: ThemeHelper.textPrimary,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.ok,
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
        ),
      ),
    );
  }

  void _showDayOptionsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 60,
          decoration: ShapeDecoration(
            color: ThemeHelper.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            shadows: [
              BoxShadow(
                color: ThemeHelper.textPrimary.withOpacity(0.3),
                blurRadius: 3,
                offset: Offset(0, 0),
                spreadRadius: 0,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Successful day option
              GestureDetector(
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _handleStreakAction('Successful', context);
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Image.asset('assets/icons/flame.png', width: 24, height: 24),
                      const SizedBox(width: 8),
                      Text(
                        l10n.successfulDay,
                        style: TextStyle(
                          color: ThemeHelper.textPrimary,
                          fontSize: 13,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Divider
              Container(
                width: 300,
                height: 1,
                color: ThemeHelper.divider,
              ),
              // Failed day option
              GestureDetector(
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _handleStreakAction('Failed', context);
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Image.asset('assets/icons/flame_missed.png', width: 24, height: 24),
                      const SizedBox(width: 8),
                      Text(
                        l10n.failedDay,
                        style: TextStyle(
                          color: ThemeHelper.textPrimary,
                          fontSize: 13,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Divider
              Container(
                width: 300,
                height: 1,
                color: ThemeHelper.divider,
              ),
              // Undo option
              GestureDetector(
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _handleStreakAction('Undo', context);
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                       Image.asset('assets/icons/undo.png', width: 16, height: 16),
                      const SizedBox(width: 8),
                      Text(
                        l10n.undo,
                        style: TextStyle(
                          color: ThemeHelper.textPrimary,
                          fontSize: 13,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleStreakAction(String action, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final previousSummary = streakService.snapshotStreakSummary();
    
    switch (action) {
      case 'Successful':
        // Optimistically update UI
        Map<String, dynamic>? previousData;
        final currentEntry = streakService.streaksMap[dateKey];
        if (currentEntry != null) {
          previousData = Map<String, dynamic>.from(currentEntry);
        }
        final Map<String, dynamic> existing = currentEntry != null
            ? Map<String, dynamic>.from(currentEntry)
            : <String, dynamic>{};
        // Preserve existing id and other fields; only change type/date
        streakService.streaksMap[dateKey] = {
          ...existing,
          'streakType': 'Successful',
          'date': dateKey,
        };
        streakService.applyLocalStreakSummary();
        
        final result = await streakService.upsertStreak(
          streakType: 'Successful',
          date: date.toLocal(),
        );
        
        // Revert if failed
        if (result == null || streakService.errorMessage.value.isNotEmpty) {
          if (previousData != null) {
            streakService.streaksMap[dateKey] = previousData;
          } else {
            streakService.streaksMap.remove(dateKey);
          }
          streakService.restoreStreakSummary(previousSummary);
          Get.snackbar(
            l10n.error,
            streakService.errorMessage.value.isNotEmpty 
                ? streakService.errorMessage.value 
                : l10n.failedToCreateStreak,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
          );
        } else {
          // Refresh streak history after successful creation
          await streakService.getStreakHistory();
        }
        break;
        
      case 'Failed':
        // Optimistically update UI
        Map<String, dynamic>? previousData;
        final currentEntry = streakService.streaksMap[dateKey];
        if (currentEntry != null) {
          previousData = Map<String, dynamic>.from(currentEntry);
        }
        final Map<String, dynamic> existing = currentEntry != null
            ? Map<String, dynamic>.from(currentEntry)
            : <String, dynamic>{};
        // Preserve existing id and other fields; only change type/date
        streakService.streaksMap[dateKey] = {
          ...existing,
          'streakType': 'Failed',
          'date': dateKey,
        };
        streakService.applyLocalStreakSummary();
        
        final result = await streakService.upsertStreak(
          streakType: 'Failed',
          date: date.toLocal(),
        );
        
        // Revert if failed
        if (result == null || streakService.errorMessage.value.isNotEmpty) {
          if (previousData != null) {
            streakService.streaksMap[dateKey] = previousData;
          } else {
            streakService.streaksMap.remove(dateKey);
          }
          streakService.restoreStreakSummary(previousSummary);
          Get.snackbar(
            l10n.error,
            streakService.errorMessage.value.isNotEmpty 
                ? streakService.errorMessage.value 
                : l10n.failedToCreateStreak,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
          );
        } else {
          // Refresh streak history after successful creation
          await streakService.getStreakHistory();
        }
        break;
        
      case 'Undo':
        // Get the streak date ID for this date
        final streakDateId = streakService.getStreakId(date);
        if (streakDateId != null) {
          // Optimistically remove from UI
          Map<String, dynamic>? previousData;
          final currentEntry = streakService.streaksMap[dateKey];
          if (currentEntry != null) {
            previousData = Map<String, dynamic>.from(currentEntry);
          }
          streakService.streaksMap.remove(dateKey);
          streakService.applyLocalStreakSummary();
          
          final success = await streakService.deleteStreakDate(
            streakDateId: streakDateId,
            date: date,
          );
          
          if (success) {
            // Refresh streak history after successful deletion
            await streakService.getStreakHistory();
            Get.snackbar(
              l10n.success,
              '${l10n.streakUndoneFor} ${DateFormat('MMM d, y', Localizations.localeOf(context).toString()).format(date)}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withOpacity(0.8),
              colorText: Colors.white,
            );
          } else {
            // Revert if failed
            if (previousData != null) {
              streakService.streaksMap[dateKey] = previousData;
            } else {
              streakService.streaksMap.remove(dateKey);
            }
            streakService.restoreStreakSummary(previousSummary);
            Get.snackbar(
              l10n.error,
              streakService.errorMessage.value,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white,
            );
          }
        } else {
          Get.snackbar(
            l10n.info,
            '${l10n.noStreakToUndoFor} ${DateFormat('MMM d, y', Localizations.localeOf(context).toString()).format(date)}',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        break;
    }
  }

  Widget _flameForStatus(_DayStatus s) {
    final Widget img = Image.asset(_DayStatus.missed == s ? 'assets/icons/flame_missed.png' : 'assets/icons/flame.png', width: 40, height: 40, );
    switch (s) {
      case _DayStatus.completed:
        return img;
      case _DayStatus.missed:
        return Opacity(opacity: 0.6, child: img);
      case _DayStatus.neutral:
        return Opacity(opacity: 0.25, child: img);
    }
  }
}



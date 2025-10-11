import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../services/streak_service.dart';

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
    // _loadStreaksForMonth();
  }


  Map<String, int> _getStreaksFromBackend() {
    // Get streak data from backend API
    final currentStreak = streakService.getCurrentStreak();
    final highestStreak = streakService.getHighestStreak();

    return {'current': currentStreak, 'longest': highestStreak};
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime firstOfMonth = DateTime(now.year, now.month, 1);
    final DateTime firstOfNextMonth = DateTime(now.year, now.month + 1, 1);
    final int daysInMonth = firstOfNextMonth.difference(firstOfMonth).inDays;
    final String monthTitle = DateFormat('LLLL, y').format(now); // e.g., September, 2025
    final int today = now.day;

    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
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
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Text(
                        '←',
                        style: TextStyle(
                          color: Colors.black,
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
                    child: const SizedBox(
                      width: 120,
                      child: Text(
                        'How does it work?',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(0xB21E1822),
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
                 'Log Streak',
                 textAlign: TextAlign.center,
                 style: const TextStyle(
                   color: Colors.black,
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
                      child: _summaryPill('🔥', 'Current streak: $currentStreak ${currentStreak == 1 ? 'day' : 'days'}'),
                    ),
                    const SizedBox(height: 8),
                    FractionallySizedBox(
                      widthFactor: 0.6,
                      child: _summaryPill('🏆', 'Longest streak: $longestStreak ${longestStreak == 1 ? 'day' : 'days'}'),
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
              color: Colors.black.withOpacity(0.15),
            ),

            const SizedBox(height: 12),
            // Month heading (left aligned)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  monthTitle,
                  style: const TextStyle(
                    color: Colors.black,
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
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x33000000),
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
              style: const TextStyle(
                color: Colors.black,
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
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title - centered
              const Center(
                child: Text(
                  'How does it work?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Content - left aligned
              const Text(
                'Every day, you can log your fire to reflect on whether you felt like you truly achieved what you wanted.',
                style: TextStyle(
                  color: Colors.black,
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
                  const Expanded(
                    child: Text(
                      'Successful → You reached your daily goal or feel satisfied with your progress.',
                      style: TextStyle(
                        color: Colors.black,
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
                  const Expanded(
                    child: Text(
                      'Failed → You didn\'t meet your goal or the day didn\'t go as planned.',
                      style: TextStyle(
                        color: Colors.black,
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
              const Text(
                'Your fires build streaks that show your consistency. The longer you log honestly, the clearer you\'ll see your real progress.',
                style: TextStyle(
                  color: Colors.black,
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
            final String label = DateFormat('MMM d, y').format(date);

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
      onTap: () => _showDayOptionsDialog(context),
      child: Container(
        height: 130,
        decoration: ShapeDecoration(
          color: const Color(0xFFF8F7FC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3F000000),
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
                color: Colors.black.withOpacity(0.6),
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

  void _showDayOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 60,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x4C000000),
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
                  Navigator.of(context).pop();
                  _handleStreakAction('Successful');
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Image.asset('assets/icons/flame.png', width: 24, height: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Successful day',
                        style: TextStyle(
                          color: Colors.black,
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
                color: Colors.black.withOpacity(0.10),
              ),
              // Failed day option
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  _handleStreakAction('Failed');
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Image.asset('assets/icons/flame_missed.png', width: 24, height: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Failed day',
                        style: TextStyle(
                          color: Colors.black,
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
                color: Colors.black.withOpacity(0.10),
              ),
              // Undo option
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  _handleStreakAction('Undo');
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                       Image.asset('assets/icons/undo.png', width: 16, height: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Undo',
                        style: TextStyle(
                          color: Colors.black,
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

  void _handleStreakAction(String action) async {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    switch (action) {
      case 'Successful':
        // Optimistically update UI
        final previousData = streakService.streaksMap[dateKey];
        streakService.streaksMap[dateKey] = {
          'streakType': 'Successful',
          'date': dateKey,
        };
        
        final result = await streakService.createStreak(
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
          Get.snackbar(
            'Error',
            streakService.errorMessage.value.isNotEmpty 
                ? streakService.errorMessage.value 
                : 'Failed to create streak',
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
        final previousData = streakService.streaksMap[dateKey];
        streakService.streaksMap[dateKey] = {
          'streakType': 'Failed',
          'date': dateKey,
        };
        
        final result = await streakService.createStreak(
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
          Get.snackbar(
            'Error',
            streakService.errorMessage.value.isNotEmpty 
                ? streakService.errorMessage.value 
                : 'Failed to create streak',
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
          final previousData = streakService.streaksMap[dateKey];
          streakService.streaksMap.remove(dateKey);
          
          final success = await streakService.deleteStreakDate(
            streakDateId: streakDateId,
            date: date,
          );
          
          if (success) {
            // Refresh streak history after successful deletion
            await streakService.getStreakHistory();
            Get.snackbar(
              'Success',
              'Streak undone for ${DateFormat('MMM d, y').format(date)}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withOpacity(0.8),
              colorText: Colors.white,
            );
          } else {
            // Revert if failed
            if (previousData != null) {
              streakService.streaksMap[dateKey] = previousData;
            }
            Get.snackbar(
              'Error',
              streakService.errorMessage.value,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white,
            );
          }
        } else {
          Get.snackbar(
            'Info',
            'No streak to undo for ${DateFormat('MMM d, y').format(date)}',
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



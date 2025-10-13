import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../providers/health_provider.dart';
import '../utils/theme_helper.dart';

class ProgressScreen extends StatelessWidget {
  final ThemeProvider themeProvider;
  final HealthProvider healthProvider;

  const ProgressScreen({super.key, required this.themeProvider, required this.healthProvider});

  @override
  Widget build(BuildContext context) {
    final addBurnedToGoal = ValueNotifier<bool>(false);
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
              'Progress',
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
                _WeightTile(
                  title: 'My Weight',
                  value: '72 kg',
                  trailingLabel: 'Log Weight',
                  leadingIcon: 'assets/icons/export.png',
                ),
                const SizedBox(height: 10),
                _WeightTile(
                  title: 'Target Weight',
                  value: '65 kg',
                  trailingLabel: 'Update',
                  leadingIcon: 'assets/icons/trophy.png',
                ),
                const SizedBox(height: 30),
               
                _GoalProgressCard(),
                const SizedBox(height: 12),
                _WeeklySummaryStrip(),
                const SizedBox(height: 12),
                _ProgressPhotosCard(),
                const SizedBox(height: 12),
                _StepsCard(healthProvider: healthProvider),
                const SizedBox(height: 12),
                _AddBurnedToGoalCard(addBurnedToGoal: addBurnedToGoal),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderBadge extends StatelessWidget {
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
          'Next weigh-in: 7d',
          style: ThemeHelper.textStyleWithColor(ThemeHelper.footnote, Colors.white),
        ),
      ),
    );
  }
}

class _WeightOverviewCard extends StatelessWidget {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _KgValue(big: '79', small: 'kg'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(CupertinoIcons.arrow_right, size: 28, color: Colors.black),
                ),
                _KgValue(big: '65', small: 'kg'),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.black.withOpacity(0.1), height: 1),
            const SizedBox(height: 12),
            Text(
              '51% to target weight',
              style: ThemeHelper.textStyleWithColor(ThemeHelper.body1, Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              '-1.3 kg since last weigh in',
              style: ThemeHelper.textStyleWithColor(ThemeHelper.footnote, Colors.black.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
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
  const _WeightTile({
    required this.title,
    required this.value,
    required this.trailingLabel,
    required this.leadingIcon,
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
          Text(
            trailingLabel,
            style: TextStyle(color: const Color(0x7F1E1822), fontSize: 10, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          const Icon(CupertinoIcons.pencil, size: 14, color: Color(0x7F1E1822)),
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
  final List<String> _ranges = const ['30 Days', '90 Days', '6 Months', '1 Year', 'All Time'];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weight Goal Progress', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_ranges.length, (i) {
                final bool selected = i == _selectedIndex;
                return Padding(
                  padding: EdgeInsets.only(right: i == _ranges.length - 1 ? 0 : 8),
                  child: _chip(
                    _ranges[i],
                    selected: selected,
                    onTap: () => setState(() => _selectedIndex = i),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          _ChartPlaceholder(
            leftLabel: _startLabelForRange(_selectedIndex),
            rightLabel: _endLabelForRange(_selectedIndex),
          ),
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

  String _startLabelForRange(int index) {
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
        return 'Start';
      default:
        return _formatDate(now);
    }
  }

  String _endLabelForRange(int index) {
    final now = DateTime.now();
    if (index == 4) return 'Now';
    return _formatDate(now);
  }
}

class _ChartPlaceholder extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  const _ChartPlaceholder({required this.leftLabel, required this.rightLabel});
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

            return Stack(
              children: [
                // dashed lines with labels 80, 75, 70, 65 kg (top to bottom)
                lineRow('80', 0.10),
                lineRow('75', 0.40),
                lineRow('70', 0.70),
                lineRow('65', 0.90),
                // x-axis labels
                const SizedBox(height: 12),
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

class _WeeklySummaryStrip extends StatelessWidget {
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
          const Center(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: 'Great job! You lost ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                TextSpan(text: '1.3 kg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                TextSpan(text: ' this week', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
                children: const [
                  Text('Avg daily lost', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text('0.19 kg/day', style: TextStyle(fontSize: 12)),
                ],
              ),
              Container(width: 1, height: 28, color: Colors.black.withOpacity(0.1)),
              const Text('7 kg to go', style: TextStyle(color: Color(0xFFFE9D15), fontWeight: FontWeight.w600, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressPhotosCard extends StatelessWidget {
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
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 14),
            child: const Text('Progress Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Center(
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
                  children: const [
                    Text('Upload Photo', style: TextStyle(fontSize: 12, color: Color(0xB21E1822))),
                    SizedBox(height: 4),
                    Text('+', style: TextStyle(fontSize: 22, color: Color(0xB21E1822))),
                  ],
                ),
              ),
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
                const Text('Steps Today', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                if (healthProvider.isLoading)
                  const Text('Loading...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
                else if (!healthProvider.hasPermissions)
                  GestureDetector(
                    onTap: () => healthProvider.requestPermissions(),
                    child: const Text(
                      'Tap to enable health permissions',
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

class _AddBurnedToGoalCard extends StatelessWidget {
  final ValueNotifier<bool> addBurnedToGoal;
  const _AddBurnedToGoalCard({required this.addBurnedToGoal});
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
                const Text('Add burned calories to daily goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Badge(icon: "assets/icons/apple.png", title: '175', subtitle: 'Calories Burned'),
                    const SizedBox(width: 8),
                    _Badge(icon: "assets/icons/shoe.png", title: '+3565', subtitle: 'Steps'),
                  ],
                ),
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: addBurnedToGoal,
            builder: (context, value, _) {
              return CupertinoSwitch(
                activeColor: CupertinoColors.black,
                value: value,
                onChanged: (v) => addBurnedToGoal.value = v,
              );
            },
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

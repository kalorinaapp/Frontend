import 'package:flutter/cupertino.dart';
import '../l10n/app_localizations.dart' show AppLocalizations;
import '../providers/theme_provider.dart';

class HealthConsistencyScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const HealthConsistencyScreen({
    super.key,
    required this.themeProvider,
  });

  @override
  State<HealthConsistencyScreen> createState() => _HealthConsistencyScreenState();
}

class _HealthConsistencyScreenState extends State<HealthConsistencyScreen> {
  // Days of the week in Croatian
  final List<String> _weekDays = ['Z', 'D', 'R', 'A', 'V', 'LJ', 'E'];

  
  
  // Track which days are completed (first 4 are completed in the design)
  final List<bool> _completedDays = [true, true, true, true, false, false, false];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemBackground,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  // Main title
                  Text(
                    l10n.consistencyBuildsHealth,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.healthHabitsDescription,
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // Week days row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (index) {
                      return Column(
                        children: [
                          // Day letter
                          _completedDays[index]
                            ? Text(
                                _weekDays[index],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.black,
                                ),
                              )
                            : Stack(
                                children: [
                                  // Outline text
                                  Text(
                                    _weekDays[index],
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 1.5
                                        ..color = CupertinoColors.systemGrey3,
                                    ),
                                  ),
                                ],
                              ),
                          
                          const SizedBox(height: 16),
                          
                          // Checkmark circle
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _completedDays[index] 
                                ? CupertinoColors.systemGreen
                                : CupertinoColors.systemGreen.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.checkmark,
                              color: CupertinoColors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  
                  const Spacer(),
                  
                  // Bottom section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.positiveHealthEffects,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.black,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          l10n.healthBenefits,
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

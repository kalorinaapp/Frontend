import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;
import '../../../utils/page_animations.dart';

class BirthDatePage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const BirthDatePage({super.key, required this.themeProvider});

  @override
  State<BirthDatePage> createState() => _BirthDatePageState();
}

class _BirthDatePageState extends State<BirthDatePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late OnboardingController _controller;
  late AnimationController _animationController;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _pickersAnimation;

  // Default values
  int _selectedMonth = 9; // September (1-indexed)
  int _selectedDay = 7;
  int _selectedYear = 2004;

  // Scroll controllers for proper initialization
  FixedExtentScrollController? _monthScrollController;
  FixedExtentScrollController? _dayScrollController;
  FixedExtentScrollController? _yearScrollController;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _titleAnimation = PageAnimations.createTitleAnimation(_animationController);
    
    _subtitleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _pickersAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
    
    // Initialize scroll controllers with correct positions
    _initializeScrollControllers();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateBirthDate();
    });
  }

  void _initializeScrollControllers() {
    final yearsList = _getYearsList();
    
    // Initialize scroll controllers with correct initial positions
    _monthScrollController = FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _dayScrollController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _yearScrollController = FixedExtentScrollController(
      initialItem: yearsList.indexOf(_selectedYear)
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _monthScrollController?.dispose();
    _dayScrollController?.dispose();
    _yearScrollController?.dispose();
    super.dispose();
  }

  void _updateBirthDate() {
    final birthDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    _controller.setDateTimeData('birth_date', birthDate);
  }

  int _getDaysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  List<int> _getDaysList() {
    final daysInMonth = _getDaysInMonth(_selectedMonth, _selectedYear);
    return List.generate(daysInMonth, (index) => index + 1);
  }

  List<int> _getYearsList() {
    final currentYear = DateTime.now().year;
    final minYear = currentYear - 100; // Allow up to 100 years old
    final maxYear = currentYear - 13; // Minimum 13 years old
    
    return List.generate(maxYear - minYear + 1, (index) => maxYear - index);
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    final localizations = AppLocalizations.of(context)!;
    
    // Month names from localization
    final monthNames = [
      localizations.january,
      localizations.february,
      localizations.march,
      localizations.april,
      localizations.may,
      localizations.june,
      localizations.july,
      localizations.august,
      localizations.september,
      localizations.october,
      localizations.november,
      localizations.december,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Title with animation
          PageAnimations.animatedTitle(
            animation: _titleAnimation,
            child: Center(
              child: Text(
                localizations.whenWereYouBorn,
                style: ThemeHelper.title1.copyWith(
                  color: ThemeHelper.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle with animation
          PageAnimations.animatedContent(
            animation: _subtitleAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeHelper.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  localizations.birthDateSubtitle,
                  style: ThemeHelper.caption1.copyWith(
                    fontSize: 13,
                    color: ThemeHelper.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Date pickers with animation
          Expanded(
            child: PageAnimations.animatedContent(
              animation: _pickersAnimation,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Month Picker
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        localizations.monthLabel,
                        style: ThemeHelper.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: _monthScrollController,
                          itemExtent: 50,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              _selectedMonth = index + 1;
                              // Adjust day if it's invalid for the new month
                              final daysInNewMonth = _getDaysInMonth(_selectedMonth, _selectedYear);
                              if (_selectedDay > daysInNewMonth) {
                                _selectedDay = daysInNewMonth;
                                // Update day scroll controller
                                _dayScrollController?.dispose();
                                _dayScrollController = FixedExtentScrollController(
                                  initialItem: _selectedDay - 1
                                );
                              }
                              _updateBirthDate();
                            });
                          },
                          children: monthNames.map((String month) {
                            return Center(
                              child: Text(
                                month,
                                style: ThemeHelper.body1.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: ThemeHelper.textPrimary,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Day Picker
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        localizations.dayLabel,
                        style: ThemeHelper.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: _dayScrollController,
                          itemExtent: 50,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              _selectedDay = index + 1;
                              _updateBirthDate();
                            });
                          },
                          children: _getDaysList().map((int day) {
                            return Center(
                              child: Text(
                                day.toString().padLeft(2, '0'),
                                style: ThemeHelper.body1.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: ThemeHelper.textPrimary,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Year Picker
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        localizations.yearLabel,
                        style: ThemeHelper.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: _yearScrollController,
                          itemExtent: 50,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              _selectedYear = _getYearsList()[index];
                              // Adjust day if it's invalid for the new year (leap year handling)
                              final daysInNewMonth = _getDaysInMonth(_selectedMonth, _selectedYear);
                              if (_selectedDay > daysInNewMonth) {
                                _selectedDay = daysInNewMonth;
                                // Update day scroll controller
                                _dayScrollController?.dispose();
                                _dayScrollController = FixedExtentScrollController(
                                  initialItem: _selectedDay - 1
                                );
                              }
                              _updateBirthDate();
                            });
                          },
                          children: _getYearsList().map((int year) {
                            return Center(
                              child: Text(
                                year.toString(),
                                style: ThemeHelper.body1.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: ThemeHelper.textPrimary,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
          
          // const SizedBox(height: 20),
          
          // Age display
          // Center(
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //     decoration: BoxDecoration(
          //       color: CupertinoColors.systemGrey6,
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //     child: Text(
          //       'Dob: ${_calculateAge()} godina',
          //       style: ThemeHelper.subhead.copyWith(
          //         color: CupertinoColors.systemGrey,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ),
          // ),
          
          // const SizedBox(height: 20),
        ],
      ),
    );
  }
}

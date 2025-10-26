import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class BirthDatePage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const BirthDatePage({super.key, required this.themeProvider});

  @override
  State<BirthDatePage> createState() => _BirthDatePageState();
}

class _BirthDatePageState extends State<BirthDatePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late OnboardingController _controller;

  // Default values
  int _selectedMonth = 9; // September (1-indexed)
  int _selectedDay = 7;
  int _selectedYear = 2004;

  // Month names
  final List<String> _monthNames = [
    'Siječanj', 'Veljača', 'Ožujak', 'Travanj', 'Svibanj', 'Lipanj',
    'Srpanj', 'Kolovoz', 'Rujan', 'Listopad', 'Studeni', 'Prosinac'
  ];

  // Scroll controllers for proper initialization
  FixedExtentScrollController? _monthScrollController;
  FixedExtentScrollController? _dayScrollController;
  FixedExtentScrollController? _yearScrollController;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
    
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Title
          Center(
            child: Text(
              'Kada ste rođeni?',
              style: ThemeHelper.title1.copyWith(
                color: ThemeHelper.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeHelper.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Ovo će se uzeti u obzir pri izračunu vaših dnevnih nutritivnih ciljeva.',
                style: ThemeHelper.caption1.copyWith(
                  fontSize: 13,
                  color: ThemeHelper.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Date pickers
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Month Picker
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Mjesec",
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
                          children: _monthNames.map((String month) {
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
                        "Dan",
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
                        "Godina",
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

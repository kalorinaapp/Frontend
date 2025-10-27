import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;

class WorkoutFrequencyPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const WorkoutFrequencyPage({super.key, required this.themeProvider});

  @override
  State<WorkoutFrequencyPage> createState() => _WorkoutFrequencyPageState();
}

class _WorkoutFrequencyPageState extends State<WorkoutFrequencyPage> {
  late OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Title
          Center(
            child: Text(
              localizations.howManyWorkoutsPerWeek,
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
                localizations.selectBestOption,
                style: ThemeHelper.caption1.copyWith(
                  fontSize: 13,
                  color: ThemeHelper.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Workout frequency options
          Column(
            children: [
              // Option 1: 0 - Ne treniram
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('workout_frequency', '0');
                  _controller.validatePage(_controller.currentPage.value);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('workout_frequency') == '0' 
                        ? ThemeHelper.textPrimary
                        : ThemeHelper.cardBackground,
                    border: Border.all(
                      color: _controller.getStringData('workout_frequency') == '0'
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.divider,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Image.asset(
                          'assets/icons/warning.png',
                          width: 24,
                          height: 24,
                          color: _controller.getStringData('workout_frequency') == '0'
                              ? ThemeHelper.background
                              : ThemeHelper.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '0',
                            style: ThemeHelper.headline.copyWith(
                              color: _controller.getStringData('workout_frequency') == '0'
                                  ? ThemeHelper.background
                                  : ThemeHelper.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localizations.noWorkouts,
                            style: ThemeHelper.subhead.copyWith(
                              color: _controller.getStringData('workout_frequency') == '0'
                                  ? ThemeHelper.background
                                  : ThemeHelper.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
              
              // Option 2: 1-2 - Treninzi s vremena na vrijeme
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('workout_frequency', '1-2');
                  _controller.validatePage(_controller.currentPage.value);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('workout_frequency') == '1-2' 
                        ? ThemeHelper.textPrimary
                        : ThemeHelper.cardBackground,
                    border: Border.all(
                      color: _controller.getStringData('workout_frequency') == '1-2'
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.divider,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Image.asset(
                          'assets/icons/shoe.png',
                          width: 24,
                          height: 24,
                          color: _controller.getStringData('workout_frequency') == '1-2'
                              ? ThemeHelper.background
                              : ThemeHelper.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1-2',
                              style: ThemeHelper.headline.copyWith(
                                color: _controller.getStringData('workout_frequency') == '1-2'
                                    ? ThemeHelper.background
                                    : ThemeHelper.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              localizations.occasionalWorkouts,
                              style: ThemeHelper.subhead.copyWith(
                                color: _controller.getStringData('workout_frequency') == '1-2'
                                    ? ThemeHelper.background
                                    : ThemeHelper.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              
              // Option 3: 3-5 - Nekoliko treninga tjedno
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('workout_frequency', '3-5');
                  _controller.validatePage(_controller.currentPage.value);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('workout_frequency') == '3-5' 
                        ? ThemeHelper.textPrimary
                        : ThemeHelper.cardBackground,
                    border: Border.all(
                      color: _controller.getStringData('workout_frequency') == '3-5'
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.divider,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Image.asset(
                          'assets/icons/weights.png',
                          width: 24,
                          height: 24,
                          color: _controller.getStringData('workout_frequency') == '3-5'
                              ? ThemeHelper.background
                              : ThemeHelper.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '3-5',
                              style: ThemeHelper.headline.copyWith(
                                color: _controller.getStringData('workout_frequency') == '3-5'
                                    ? ThemeHelper.background
                                    : ThemeHelper.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              localizations.severalWorkoutsWeekly,
                              style: ThemeHelper.subhead.copyWith(
                                color: _controller.getStringData('workout_frequency') == '3-5'
                                    ? ThemeHelper.background
                                    : ThemeHelper.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              
              // Option 4: 6-7 - Predani sportaš
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('workout_frequency', '6-7');
                  _controller.validatePage(_controller.currentPage.value);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('workout_frequency') == '6-7' 
                        ? ThemeHelper.textPrimary
                        : ThemeHelper.cardBackground,
                    border: Border.all(
                      color: _controller.getStringData('workout_frequency') == '6-7'
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.divider,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Image.asset(
                          'assets/icons/flame_black.png',
                          width: 24,
                          height: 24,
                          color: _controller.getStringData('workout_frequency') == '6-7'
                              ? ThemeHelper.background
                              : ThemeHelper.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '6-7',
                            style: ThemeHelper.headline.copyWith(
                              color: _controller.getStringData('workout_frequency') == '6-7'
                                  ? ThemeHelper.background
                                  : ThemeHelper.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localizations.dedicatedAthlete,
                            style: ThemeHelper.subhead.copyWith(
                              color: _controller.getStringData('workout_frequency') == '6-7'
                                  ? ThemeHelper.background
                                  : ThemeHelper.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

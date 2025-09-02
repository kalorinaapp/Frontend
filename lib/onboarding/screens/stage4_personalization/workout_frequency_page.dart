import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Title
          Center(
            child: Text(
              'Koliko treninga radiš tjedno',
              style: ThemeHelper.title1.copyWith(
                color: CupertinoColors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Odaberite opciju koja vam najviše odgovara',
                style: ThemeHelper.caption1.copyWith(
                  fontSize: 13,
                  color: CupertinoColors.systemGrey,
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
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('workout_frequency') == '0' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('workout_frequency') == '0'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '0',
                        style: ThemeHelper.headline.copyWith(
                          color: _controller.getStringData('workout_frequency') == '0'
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ne treniram',
                        style: ThemeHelper.subhead.copyWith(
                          color: _controller.getStringData('workout_frequency') == '0'
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              
              // Option 2: 1-2 - Treninzi s vremena na vrijeme
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('workout_frequency', '1-2');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('workout_frequency') == '1-2' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('workout_frequency') == '1-2'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '1-2',
                        style: ThemeHelper.headline.copyWith(
                          color: _controller.getStringData('workout_frequency') == '1-2'
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Treninzi s vremena na vrijeme',
                        style: ThemeHelper.subhead.copyWith(
                          color: _controller.getStringData('workout_frequency') == '1-2'
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )),
              
              // Option 3: 3-5 - Nekoliko treninga tjedno
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('workout_frequency', '3-5');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('workout_frequency') == '3-5' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('workout_frequency') == '3-5'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '3-5',
                        style: ThemeHelper.headline.copyWith(
                          color: _controller.getStringData('workout_frequency') == '3-5'
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nekoliko treninga tjedno',
                        style: ThemeHelper.subhead.copyWith(
                          color: _controller.getStringData('workout_frequency') == '3-5'
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )),
              
              // Option 4: 6-7 - Predani sportaš
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('workout_frequency', '6-7');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('workout_frequency') == '6-7' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('workout_frequency') == '6-7'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '6-7',
                        style: ThemeHelper.headline.copyWith(
                          color: _controller.getStringData('workout_frequency') == '6-7'
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Predani sportaš',
                        style: ThemeHelper.subhead.copyWith(
                          color: _controller.getStringData('workout_frequency') == '6-7'
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
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

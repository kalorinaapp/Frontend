import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class PersonalGoalsPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const PersonalGoalsPage({super.key, required this.themeProvider});

  @override
  State<PersonalGoalsPage> createState() => _PersonalGoalsPageState();
}

class _PersonalGoalsPageState extends State<PersonalGoalsPage> {
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
          const SizedBox(height: 30),
          
          // Title
          Text(
            textAlign: TextAlign.center,
            'Što biste željeli postići?',
            style: ThemeHelper.title2.copyWith(
              color: CupertinoColors.black,
            ),
          ),
          
          const SizedBox(height: 80),
          
          // Personal goals selection options
          Column(
            children: [
              // Option 1: Stay motivated and disciplined
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('personal_goal', 'stay_motivated');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('personal_goal') == 'stay_motivated' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('personal_goal') == 'stay_motivated'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8.0),
                      Image.asset('assets/icons/broccoli.png', width: 48, height: 48),
                      const SizedBox(width: 4.0),
                      Text(
                        'ostati motiviran i discipliniran',
                        style: ThemeHelper.headline.copyWith(
                          color: _controller.getStringData('personal_goal') == 'stay_motivated'
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer()
                    ],
                  ),
                ),
              )),
              
              // Option 2: Feel better about your body
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('personal_goal', 'feel_better_body');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('personal_goal') == 'feel_better_body' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('personal_goal') == 'feel_better_body'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8.0),
                      Image.asset('assets/icons/lightning.png', width: 48, height: 48),
                      const SizedBox(width: 4.0),
                      Text(
                        'osjecati se bolje u vezi svog tijela',
                        style: ThemeHelper.headline.copyWith(
                          color: _controller.getStringData('personal_goal') == 'feel_better_body'
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer()
                    ],
                  ),
                ),
              )),
              
              // Option 3: Improve health long-term
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('personal_goal', 'improve_health');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('personal_goal') == 'improve_health' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('personal_goal') == 'improve_health'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8.0),
                      Image.asset('assets/icons/wrist.png', width: 48, height: 48),
                      const SizedBox(width: 4.0),
                      Text(
                        'dugoročno poboljšati zdravije',
                        style: ThemeHelper.headline.copyWith(
                          color: _controller.getStringData('personal_goal') == 'improve_health'
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer()
                    ],
                  ),
                ),
              )),
              
              // Option 4: Increase mood and energy
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('personal_goal', 'increase_mood_energy');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('personal_goal') == 'increase_mood_energy' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('personal_goal') == 'increase_mood_energy'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8.0),
                      Image.asset('assets/icons/flex.png', width: 48, height: 48),
                      const SizedBox(width: 4.0),
                      Text(
                        'povecati raspolozenje i energiju',
                        style: ThemeHelper.headline.copyWith(
                          color: _controller.getStringData('personal_goal') == 'increase_mood_energy'
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer()
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

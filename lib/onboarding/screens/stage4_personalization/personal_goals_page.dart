import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // Title
          Text(
            textAlign: TextAlign.center,
            l10n.whatWouldYouLikeToAchieve,
            style: ThemeHelper.title2.copyWith(
              color: ThemeHelper.textPrimary,
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
                        ? ThemeHelper.textPrimary
                        : ThemeHelper.cardBackground,
                    border: Border.all(
                      color: _controller.getStringData('personal_goal') == 'stay_motivated'
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.divider,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8.0),
                      Image.asset('assets/icons/broccoli.png', width: 48, height: 48),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          l10n.stayMotivatedAndDisciplined,
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('personal_goal') == 'stay_motivated'
                                ? ThemeHelper.background
                                : ThemeHelper.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
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
                        ? ThemeHelper.textPrimary
                        : ThemeHelper.cardBackground,
                    border: Border.all(
                      color: _controller.getStringData('personal_goal') == 'feel_better_body'
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.divider,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8.0),
                      Image.asset('assets/icons/lightning.png', width: 48, height: 48),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          l10n.feelBetterAboutYourBody,
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('personal_goal') == 'feel_better_body'
                                ? ThemeHelper.background
                                : ThemeHelper.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
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
                        ? ThemeHelper.textPrimary
                        : ThemeHelper.cardBackground,
                    border: Border.all(
                      color: _controller.getStringData('personal_goal') == 'improve_health'
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.divider,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8.0),
                      Image.asset('assets/icons/wrist.png', width: 48, height: 48),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          l10n.improveHealthLongTerm,
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('personal_goal') == 'improve_health'
                                ? ThemeHelper.background
                                : ThemeHelper.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
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
                        ? ThemeHelper.textPrimary
                        : ThemeHelper.cardBackground,
                    border: Border.all(
                      color: _controller.getStringData('personal_goal') == 'increase_mood_energy'
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.divider,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8.0),
                      Image.asset('assets/icons/flex.png', width: 48, height: 48),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          l10n.increaseMoodAndEnergy,
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('personal_goal') == 'increase_mood_energy'
                                ? ThemeHelper.background
                                : ThemeHelper.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
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

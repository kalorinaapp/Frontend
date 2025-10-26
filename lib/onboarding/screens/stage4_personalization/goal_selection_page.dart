import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class GoalSelectionPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const GoalSelectionPage({super.key, required this.themeProvider});

  @override
  State<GoalSelectionPage> createState() => _GoalSelectionPageState();
}

class _GoalSelectionPageState extends State<GoalSelectionPage> {
  late OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeHelper.background,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Title
          Center(
            child: Text(
              'Koji je tvoj cilj',
              style: ThemeHelper.title3.copyWith(
                color: ThemeHelper.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Target icon
              SizedBox(
                                 child: const Text('🎯', style: TextStyle(fontSize: 32),),

                
                 ),
              
              // const SizedBox(width: 8),
              // Subtitle text
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  
                  'Odaberite cilj koji vam najviše odgovara',
                  style: ThemeHelper.caption1.copyWith(
                    fontSize: 13,
                    color: ThemeHelper.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 80),
          
          // Goal selection options
          Column(
            children: [
              // Option 1: Lose Weight
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('goal', 'lose_weight');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('goal') == 'lose_weight' 
                        ? ThemeHelper.textPrimary
                        : ThemeHelper.cardBackground,
                    border: Border.all(
                      color: _controller.getStringData('goal') == 'lose_weight'
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.divider,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/lose.png',
                        width: 24,
                        height: 24,
                        color: _controller.getStringData('goal') == 'lose_weight'
                            ? ThemeHelper.background
                            : ThemeHelper.textPrimary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Smršati',
                        style: ThemeHelper.headline.copyWith(
                          color: _controller.getStringData('goal') == 'lose_weight'
                              ? ThemeHelper.background
                              : ThemeHelper.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              
              // Option 2: Maintain Weight
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('goal', 'maintain_weight');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('goal') == 'maintain_weight' 
                        ? ThemeHelper.textPrimary
                        : ThemeHelper.cardBackground,
                    border: Border.all(
                      color: _controller.getStringData('goal') == 'maintain_weight'
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.divider,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/maintain.png',
                        width: 24,
                        height: 24,
                        color: _controller.getStringData('goal') == 'maintain_weight'
                            ? ThemeHelper.background
                            : ThemeHelper.textPrimary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Održavati Težinu',
                        style: ThemeHelper.headline.copyWith(
                          color: _controller.getStringData('goal') == 'maintain_weight'
                              ? ThemeHelper.background
                              : ThemeHelper.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              
              // Option 3: Gain Weight
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('goal', 'gain_weight');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('goal') == 'gain_weight' 
                        ? ThemeHelper.textPrimary
                        : ThemeHelper.cardBackground,
                    border: Border.all(
                      color: _controller.getStringData('goal') == 'gain_weight'
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.divider,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/gain.png',
                        width: 24,
                        height: 24,
                        color: _controller.getStringData('goal') == 'gain_weight'
                            ? ThemeHelper.background
                            : ThemeHelper.textPrimary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Dobiti na Težini',
                        style: ThemeHelper.headline.copyWith(
                          color: _controller.getStringData('goal') == 'gain_weight'
                              ? ThemeHelper.background
                              : ThemeHelper.textPrimary,
                          fontWeight: FontWeight.bold,
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

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class DietaryPreferencePage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const DietaryPreferencePage({super.key, required this.themeProvider});

  @override
  State<DietaryPreferencePage> createState() => _DietaryPreferencePageState();
}

class _DietaryPreferencePageState extends State<DietaryPreferencePage> {
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
              'Pridržavate li se određene dijete?',
              style: ThemeHelper.title3.copyWith(
                color: CupertinoColors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Informational banner with carrot icon
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Carrot icon
                const Text('🥕', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                // Informational text
                Expanded(
                  child: Text(
                    'Pomoći ćemo vam pratiti kalorije prema vašem načinu prehrane',
                    style: ThemeHelper.caption1.copyWith(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Dietary preference selection options
          Column(
            children: [
              // Option 1: Classic
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('dietary_preference', 'classic');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('dietary_preference') == 'classic' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('dietary_preference') == 'classic'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'klasična',
                    style: ThemeHelper.headline.copyWith(
                      color: _controller.getStringData('dietary_preference') == 'classic'
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
              
              // Option 2: Carnivore
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('dietary_preference', 'carnivore');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('dietary_preference') == 'carnivore' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('dietary_preference') == 'carnivore'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'carnivore',
                    style: ThemeHelper.headline.copyWith(
                      color: _controller.getStringData('dietary_preference') == 'carnivore'
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
              
              // Option 3: Keto
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('dietary_preference', 'keto');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('dietary_preference') == 'keto' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('dietary_preference') == 'keto'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'keto',
                    style: ThemeHelper.headline.copyWith(
                      color: _controller.getStringData('dietary_preference') == 'keto'
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
              
              // Option 4: Vegan
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('dietary_preference', 'vegan');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('dietary_preference') == 'vegan' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('dietary_preference') == 'vegan'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'vegan',
                    style: ThemeHelper.headline.copyWith(
                      color: _controller.getStringData('dietary_preference') == 'vegan'
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
              
              // Option 5: Vegetarian
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('dietary_preference', 'vegetarian');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('dietary_preference') == 'vegetarian' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('dietary_preference') == 'vegetarian'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'vegetarian',
                    style: ThemeHelper.headline.copyWith(
                      color: _controller.getStringData('dietary_preference') == 'vegetarian'
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
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

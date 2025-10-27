import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;

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
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Title
            Center(
              child: Text(
                localizations.doYouFollowDiet,
                style: ThemeHelper.title3.copyWith(
                  color: ThemeHelper.textPrimary,
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
                color: ThemeHelper.cardBackground,
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
                      localizations.helpTrackCaloriesDiet,
                      style: ThemeHelper.caption1.copyWith(
                        fontSize: 13,
                        color: ThemeHelper.textSecondary,
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
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.cardBackground,
                      border: Border.all(
                        color: _controller.getStringData('dietary_preference') == 'classic'
                            ? ThemeHelper.textPrimary
                            : ThemeHelper.divider,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.,
                      children: [
                      const SizedBox(width: 16),
                       Image.asset(
                         'assets/icons/plates.png',
                         width: 48,
                         height: 48,
                       ),
                        const SizedBox(width: 12),
                        Text(
                          localizations.classic,
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('dietary_preference') == 'classic'
                                ? ThemeHelper.background
                                : ThemeHelper.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer()
                      ],
                      
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
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.cardBackground,
                      border: Border.all(
                        color: _controller.getStringData('dietary_preference') == 'carnivore'
                            ? ThemeHelper.textPrimary
                            : ThemeHelper.divider,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                       Image.asset(
                         'assets/icons/chicken.png',
                         width: 48,
                         height: 48,
                       ),
                        const SizedBox(width: 12),
                        Text(
                          localizations.carnivore,
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('dietary_preference') == 'carnivore'
                                ? ThemeHelper.background
                                : ThemeHelper.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer()
                      ],
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
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.cardBackground,
                      border: Border.all(
                        color: _controller.getStringData('dietary_preference') == 'keto'
                            ? ThemeHelper.textPrimary
                            : ThemeHelper.divider,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                     Image.asset(
                       'assets/icons/avacado.png',
                       width: 48,
                       height: 48,
                     ),
                      const SizedBox(width: 12),
                        Text(
                          localizations.keto,
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('dietary_preference') == 'keto'
                                ? ThemeHelper.background
                                : ThemeHelper.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer()
                      ],
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
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.cardBackground,
                      border: Border.all(
                        color: _controller.getStringData('dietary_preference') == 'vegan'
                            ? ThemeHelper.textPrimary
                            : ThemeHelper.divider,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
const SizedBox(width: 16),
                     Image.asset(
                       'assets/icons/vegan.png',
                       width: 48,
                       height: 48,
                     ),
                      const SizedBox(width: 12),
                        Text(
                          localizations.vegan,
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('dietary_preference') == 'vegan'
                                ? ThemeHelper.background
                                : ThemeHelper.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer()
                      ],
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
                          ? ThemeHelper.textPrimary
                          : ThemeHelper.cardBackground,
                      border: Border.all(
                        color: _controller.getStringData('dietary_preference') == 'vegetarian'
                            ? ThemeHelper.textPrimary
                            : ThemeHelper.divider,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                     Image.asset(
                       'assets/icons/vegetarian.png',
                       width: 48,
                       height: 48,
                     ),
                      const SizedBox(width: 12),
                        Text(
                          localizations.vegetarian,
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('dietary_preference') == 'vegetarian'
                                ? ThemeHelper.background
                                : ThemeHelper.textPrimary,
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
      ),
    );
  }
}

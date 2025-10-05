import 'package:get/get.dart';

import '../onboarding/controller/onboarding.controller.dart' show OnboardingController;

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Get.put(ThemeProvider());
    // Get.put(LanguageProvider());
    // Get.put(UserController());
    Get.put(OnboardingController());
    // LanguageProvider is now registered in main.dart to ensure same instance
    // This ensures both the main app and GetX use the same provider instance
  }
}



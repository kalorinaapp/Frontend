import 'package:get/get.dart';

import '../authentication/user.controller.dart' show UserController;
import '../onboarding/controller/onboarding.controller.dart' show OnboardingController;
import '../providers/language_provider.dart' show LanguageProvider;
import '../providers/theme_provider.dart' show ThemeProvider;

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeProvider());
    Get.put(LanguageProvider());
    Get.put(UserController());
    Get.put(OnboardingController());
    // LanguageProvider is now registered in main.dart to ensure same instance
    // This ensures both the main app and GetX use the same provider instance
  }
}



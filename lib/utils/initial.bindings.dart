import 'package:get/get.dart';

import '../authentication/user.controller.dart' show UserController;
import '../onboarding/controller/onboarding.controller.dart' show OnboardingController;
import '../providers/health_provider.dart' show HealthProvider;
import '../providers/language_provider.dart' show LanguageProvider;
import '../providers/theme_provider.dart' show ThemeProvider;

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Only register if not already registered (avoid duplicates)
    // ThemeProvider and LanguageProvider are already registered in main.dart
    if (!Get.isRegistered<ThemeProvider>()) {
      Get.put(ThemeProvider(), permanent: true);
    }
    if (!Get.isRegistered<LanguageProvider>()) {
      Get.put(LanguageProvider(), permanent: true);
    }
    if (!Get.isRegistered<UserController>()) {
      Get.put(UserController(), permanent: true);
    }
    if (!Get.isRegistered<OnboardingController>()) {
      Get.put(OnboardingController(), permanent: true);
    }
    if (!Get.isRegistered<HealthProvider>()) {
      Get.put(HealthProvider(), permanent: true);
    }
  }
}



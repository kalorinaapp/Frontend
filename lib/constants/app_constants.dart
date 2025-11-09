import 'dart:io';

class AppConstants {
  static String referralCode = '';
  static String influencerId = '';
  static bool updateInstallCount = false;
  static String authToken = '';
  static String userId = '';
  static String userEmail = '';
  static String userName = '';
  static String refreshToken = '';

  static String get baseUrl {
    if (Platform.isAndroid) return 'https://backend-production-72a2.up.railway.app/';
    return 'https://backend-production-72a2.up.railway.app/';
  }

  static String revenueCatId = '';
  static String currentSubscription = '';
  static bool isSubscriptionActive = false;
  static String showPaywallonhome = '';
  static String revenueCatApiKey = '';
}



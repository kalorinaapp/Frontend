import 'dart:io';

class AppConstants {
  static String authToken = '';
  static String userId = '';
  static String userEmail = '';
  static String userName = '';
  static String refreshToken = '';

  static String get baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/';
    return 'http://192.168.0.104:3000/';
  }

  static String revenueCatId = '';
  static String currentSubscription = '';
  static bool isSubscriptionActive = false;
  static String showPaywallonhome = '';
  static String revenueCatApiKey = '';
}



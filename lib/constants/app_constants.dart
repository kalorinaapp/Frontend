import 'dart:io';

class AppConstants {
  static String authToken = '';
  static String userId = '';
  static String userEmail = '';
  static String userName = '';
  static String refreshToken = '';

  static String get baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/';
    return 'http://172.20.10.13:3000/';
  }
}



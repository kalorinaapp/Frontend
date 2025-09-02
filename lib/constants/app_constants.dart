import 'dart:io';

class AppConstants {
  static String authToken = '';

  static String get baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://127.0.0.1:3000';
  }
}



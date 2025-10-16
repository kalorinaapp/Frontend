import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserPrefs {
  static const String keyName = 'user_name';
  static const String keyEmail = 'user_email';
  static const String keyToken = 'user_token';
  static const String keyRefreshToken = 'user_refresh_token';
  static const String keyId = 'user_id';
  static const String keyLastWeighInIso = 'last_weigh_in_iso';

  static Future<void> saveUserData({
    required String name,
    required String email,
    required String token,
    required String refreshToken,
    required String id,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyName, name);
    await prefs.setString(keyEmail, email);
    await prefs.setString(keyToken, token);
    await prefs.setString(keyRefreshToken, refreshToken);
    await prefs.setString(keyId, id);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyName);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyEmail);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyRefreshToken);
  }

  static Future<String?> getId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyId);
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyName);
    await prefs.remove(keyEmail);
    await prefs.remove(keyToken);
    await prefs.remove(keyRefreshToken);
    await prefs.remove(keyId);
    await prefs.remove(keyLastWeighInIso);
  }

  static bool isTokenInvalid(String? token) {
    if (token == null || token.isEmpty) return true;
    try {
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = parts[1];
      // Base64 decode, add padding if needed
      String normalized = base64Url.normalize(payload);
      final payloadMap = json.decode(utf8.decode(base64Url.decode(normalized)));
      if (payloadMap is! Map<String, dynamic>) return true;
      final exp = payloadMap['exp'];
      if (exp == null) return true;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  // Weigh-in helpers
  static Future<void> setLastWeighInNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastWeighInIso, DateTime.now().toIso8601String());
  }

  static Future<void> setLastWeighInDate(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastWeighInIso, dateTime.toIso8601String());
  }

  static Future<DateTime?> getLastWeighInDate() async {
    final prefs = await SharedPreferences.getInstance();
    final String? iso = prefs.getString(keyLastWeighInIso);
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso);
    } catch (_) {
      return null;
    }
  }

  static Future<int> daysUntilNextWeighIn({int cadenceDays = 7}) async {
    final DateTime? last = await getLastWeighInDate();
    if (last == null) return cadenceDays;
    final now = DateTime.now();
    final int daysSince = now.difference(last).inDays;
    final int remaining = cadenceDays - daysSince;
    return remaining <= 0 ? 0 : remaining;
  }
}

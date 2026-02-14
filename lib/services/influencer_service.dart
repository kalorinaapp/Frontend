import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../network/http_helper.dart' show multiPostAPINew;
import '../utils/user.prefs.dart' show UserPrefs;

class InfluencerService {
  static const String _deviceIdKey = 'device_id';
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get or create a unique device ID stored in SharedPreferences
  Future<String> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(_deviceIdKey);
      
      if (deviceId == null || deviceId.isEmpty) {
        // Generate a new UUID for this device
        deviceId = const Uuid().v4();
        await prefs.setString(_deviceIdKey, deviceId);
      }
      
      return deviceId;
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      // Fallback to a generated UUID if SharedPreferences fails
      return const Uuid().v4();
    }
  }

  /// Get device information
  Future<Map<String, String?>> getDeviceInfo() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'deviceModel': iosInfo.model,
          'osVersion': 'iOS ${iosInfo.systemVersion}',
          'platform': 'ios',
        };
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'deviceModel': androidInfo.model,
          'osVersion': 'Android ${androidInfo.version.release}',
          'platform': 'android',
        };
      } else {
        return {
          'deviceModel': 'Unknown',
          'osVersion': 'Unknown',
          'platform': 'web',
        };
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return {
        'deviceModel': null,
        'osVersion': null,
        'platform': Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'web'),
      };
    }
  }

  /// Get timezone
  Future<String> getTimezone() async {
    try {
      final tz = await FlutterTimezone.getLocalTimezone();
      return tz.identifier;
    } catch (e) {
      debugPrint('Error getting timezone: $e');
      return 'UTC';
    }
  }

  /// Get region from device locale
  String getRegion() {
    try {
      // Get the locale from the system
      final locale = Platform.localeName;
      // Extract country code (e.g., "en_US" -> "US")
      final parts = locale.split('_');
      if (parts.length >= 2) {
        return parts[1].toUpperCase();
      }
      // Fallback to first two characters if format is different
      if (locale.length >= 2) {
        return locale.substring(0, 2).toUpperCase();
      }
      return 'US'; // Default fallback
    } catch (e) {
      debugPrint('Error getting region: $e');
      return 'US';
    }
  }

  /// Track app installation from influencer referral
  Future<Map<String, dynamic>?> trackInstall({
    required String influencerCode,
  }) async {
    try {
      // Get required data
      final deviceId = await getDeviceId();
      final deviceInfo = await getDeviceInfo();
      final timezone = await getTimezone();
      final region = getRegion();
      final userId = await UserPrefs.getId();

      // Build request body
      final Map<String, dynamic> body = {
        'influencerCode': influencerCode,
        'deviceId': deviceId,
        'platform': deviceInfo['platform'] ?? (Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'web')),
        'region': region,
        'timezone': timezone,
      };

      // Add optional fields
      if (userId != null && userId.isNotEmpty) {
        body['userId'] = userId;
      }

      if (deviceInfo['deviceModel'] != null) {
        body['deviceModel'] = deviceInfo['deviceModel'];
      }

      if (deviceInfo['osVersion'] != null) {
        body['osVersion'] = deviceInfo['osVersion'];
      }

      // Get app version from package info (optional)
      try {
        // You can add package_info_plus if needed for app version
        // For now, we'll skip it
      } catch (_) {}

      // Add install date
      body['installDate'] = DateTime.now().toUtc().toIso8601String();

      Map<String, dynamic>? parsed;
      
      await multiPostAPINew(
        methodName: 'api/influencer/track-install',
        param: body,
        callback: (resp) async {
          try {
            parsed = jsonDecode(resp.response) as Map<String, dynamic>;
            debugPrint('Track install response: $parsed');
          } catch (e) {
            debugPrint('InfluencerService track install parse error: $e');
            parsed = null;
          }
        },
      );

      return parsed;
    } catch (e) {
      debugPrint('Error tracking install: $e');
      return null;
    }
  }
}


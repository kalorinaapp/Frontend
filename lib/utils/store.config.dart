import 'package:purchases_flutter/purchases_flutter.dart';

class StoreConfig {
  final Store store;
  final String apiKey;
  static StoreConfig? _instance;

  factory StoreConfig({required Store store, required String apiKey}) {
    _instance ??= StoreConfig._internal(store, apiKey);
    return _instance!;
  }

  StoreConfig._internal(this.store, this.apiKey);

  static StoreConfig get instance {
    return _instance!;
  }

  static bool isForAppleStore() => instance.store == Store.appStore;

  static bool isForGooglePlay() => instance.store == Store.playStore;

  static bool isForAmazonAppstore() => instance.store == Store.amazon;
}


abstract class EntitleMents {
  static const String entitlementId = "all.features.access.entitlement";

  static const String footerText = "Example Footer Text for Unfold Us";

  static const String appleApiKey = "appl_HjRMWdCkaoPXwPgAWKArUWglLkL";

  static const String googleApiKey = "goog_KdWSNfedjaPsuKqcUXEoxCJiqkH";
}

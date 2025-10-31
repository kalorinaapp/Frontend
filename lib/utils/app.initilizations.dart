import 'dart:convert' show json;
import 'dart:io' show Platform;
import 'package:calorie_ai_app/utils/network.dart' show multiPostAPINew;
import 'package:calorie_ai_app/utils/store.config.dart' show EntitleMents, StoreConfig;
import 'package:jwt_decoder/jwt_decoder.dart' show JwtDecoder;
import 'package:onesignal_flutter/onesignal_flutter.dart' show OneSignal, OSLogLevel;
import 'package:purchases_flutter/models/customer_info_wrapper.dart' show CustomerInfo;
import 'package:purchases_flutter/models/entitlement_info_wrapper.dart' show EntitlementInfo;
import 'package:purchases_flutter/models/store.dart' show Store;
import 'package:purchases_flutter/purchases_flutter.dart' show Purchases, LogLevel, PurchasesConfiguration, PurchasesAreCompletedByRevenueCat, AmazonConfiguration;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import '../constants/app_constants.dart' show AppConstants;


class AppInitializationMethods with RefreshToken {
  Future<void> initialize() async {
 
      if (Platform.isIOS || Platform.isMacOS) {
        StoreConfig(store: Store.appStore, apiKey: EntitleMents.appleApiKey);
      } else if (Platform.isAndroid) {
        // Run the app passing --dart-define=AMAZON=true
        const useAmazon = bool.fromEnvironment("amazon");
        StoreConfig(
          store: useAmazon ? Store.amazon : Store.playStore,
          apiKey: useAmazon ? '' : EntitleMents.appleApiKey,
        );
      }

      // await initPlatformState();

      //    await _configureSDK();

  
      // await fetchRevenueCatDetailsFn();


    
    } 



    // Platform messages are asynchronous, so we initialize in an async method.
  static Future<void> initPlatformState() async {
       OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.Debug.setAlertLevel(OSLogLevel.none);
     OneSignal.consentRequired(true);
    // OneSignal.consentRequired(_requireConsent);

    // NOTE: Replace with your own app ID from https://www.onesignal.com
    OneSignal.initialize("c5fb6b72-40ad-4062-82ec-c576bd7709c8");

      OneSignal.consentGiven(true);
  }


  static Future<void> _configureSDK() async {
    // Enable debug logs before calling `configure`.
    await Purchases.setLogLevel(LogLevel.debug);

    print('===== REVENUECAT API KEY =====');
    print('API Key: ${EntitleMents.appleApiKey}');
    print('================================');

    PurchasesConfiguration configuration;

    if (StoreConfig.isForAmazonAppstore()) {
      configuration =
          AmazonConfiguration(StoreConfig.instance.apiKey)
            ..appUserID = null
            ..purchasesAreCompletedBy =
                const PurchasesAreCompletedByRevenueCat();
    } else {
      configuration = PurchasesConfiguration(
        Platform.isAndroid
            ? EntitleMents.googleApiKey
            : EntitleMents.appleApiKey,
      );
      // ..appUserID = null
      // ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat();
    }

    await Purchases.configure(configuration);
  }

  static Future<void> fetchRevenueCatDetailsFn() async {
    // final signUpcontroller = Get.find<SignUpController>();

    CustomerInfo customerInfo = await Purchases.getCustomerInfo();

    // Fetch and log all available offerings/products
    final offerings = await Purchases.getOfferings();
    
    print('===== REVENUECAT OFFERINGS =====');
    print('Current offering: ${offerings.current?.identifier}');
    
    if (offerings.current != null) {
      print('Available packages: ${offerings.current!.availablePackages.length}');
      
      for (var package in offerings.current!.availablePackages) {
        print('--- Package: ${package.identifier} ---');
        print('Product ID: ${package.storeProduct.identifier}');
        print('Title: ${package.storeProduct.title}');
        print('Description: ${package.storeProduct.description}');
        print('Price: ${package.storeProduct.priceString}');
        print('Price (raw): ${package.storeProduct.price}');
        print('Currency: ${package.storeProduct.currencyCode}');
        print('Subscription period: ${package.storeProduct.subscriptionPeriod}');
        print('----');
      }
    }
    
    print('All offerings: ${offerings.all.keys.toList()}');
    print('================================');

    EntitlementInfo? entitlement =
        customerInfo.entitlements.all[EntitleMents.entitlementId];

          AppConstants.revenueCatId = customerInfo.originalAppUserId;


      print('Revenue Cat ID: ${AppConstants.revenueCatId}');

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {

      // Handle subscription status update
      bool isSubscribed =
          customerInfo.entitlements.all[EntitleMents.entitlementId]?.isActive ??
          false;

      if (isSubscribed) {
        AppConstants.isSubscriptionActive = isSubscribed;
      } else {
        AppConstants.isSubscriptionActive = isSubscribed;
      }

    


      final hasActiveEntitlementOrSubscription =
          customerInfo
              .hasActiveEntitlementOrSubscription(); // Why? -> https://www.revenuecat.com/docs/entitlements#entitlements

      if (hasActiveEntitlementOrSubscription) {
        // await Superwall.shared.setSubscriptionStatus(
        //   SubscriptionStatusActive(
        //     entitlements:
        //         customerInfo.entitlements.active.keys
        //             .map((id) => Entitlement(id: id))
        //             .toSet(),
        //   ),
        // );
      } else {
        // await Superwall.shared.setSubscriptionStatus(
        //   SubscriptionStatusInactive(),
        // );
      }
    });

    // Utils.logger.f('Revenue Cat ID: ${customerInfo.originalAppUserId}');

    AppConstants.currentSubscription = entitlement?.productIdentifier ?? '';
    AppConstants.revenueCatId = customerInfo.originalAppUserId;

    // final trialEligibility =
    //     await Purchases.checkTrialOrIntroductoryPriceEligibility([
    //       signUpcontroller
    //               .offerings
    //               ?.current
    //               ?.availablePackages[1]
    //               .storeProduct
    //               .identifier
    //               .toString() ??
    //           '',
    //     ]);

    // AppConstants.eligibleForTrial =
    //     trialEligibility.entries.first.value.status ==
    //             IntroEligibilityStatus.introEligibilityStatusIneligible
    //         ? false
    //         : true;
  }
  }

  mixin RefreshToken {
  tokenRefresh() async {
    bool isTokenExpired = JwtDecoder.isExpired(AppConstants.authToken);
    // Utils.logger.e('Is JWT expired $isTokenExpired');
    if (isTokenExpired) {
      String token = await refreshToken();
      AppConstants.authToken = token;
      //log("refresh token===${AppConstants.authToken}");
    }
  }
  

  String fetchToken = "api/auth/access-token";
  Future<String> refreshToken() async {
    String authToken = "";
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await multiPostAPINew(
        param: {"accessToken": AppConstants.authToken},
        methodName: fetchToken,
        callback: (value) async {
          Map<String, dynamic> valueMap = json.decode(value.response);
          // Utils.logger.e('ValueMap Type ---> ${valueMap.runtimeType}');
          if (valueMap.containsKey('data')) {
            prefs.setString('authToken', valueMap["data"]);
            // Utils.logger.e('Access token fetched ---> ${valueMap['data']}');
            AppConstants.authToken = valueMap["data"];
            authToken = valueMap["data"];
            
          } else {
            throw valueMap["message"];
          }
        },
      );
      return authToken;
    } catch (ex) {
      throw ex.toString();
    }
  }

  // destroyData(context) async {
  //   AppConstants.userId = "";
  //   AppConstants.name = "";
  //   AppConstants.authToken = "";
  //   AppConstants.email = "";
  //   AppConstants.username = "";

  //   SharedPreferences sp = await SharedPreferences.getInstance();
  //   sp.remove('userId');
  //   sp.remove('authToken');
  //   sp.remove('name');
  //   sp.remove('email');
  //   // CachedQuery.instance.invalidateCache();
  //   // Navigator.of(context, rootNavigator: false).push(
  //   //   CupertinoPageRoute(
  //   //     builder: (context) => WillPopScope(
  //   //       onWillPop: () async => false,
  //   //       child: const CupertinoScaffold(body: WelcomeScreen1()),
  //   //     ),
  //   //   ),
  //   // );
  // }
  
  /// Update iOS storage with new auth token

  }
extension CustomerInfoAdditions on CustomerInfo {
  bool hasActiveEntitlementOrSubscription() {
    return (activeSubscriptions.isNotEmpty || entitlements.active.isNotEmpty);
  }
}

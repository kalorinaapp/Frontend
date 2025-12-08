// ignore_for_file: unnecessary_type_check

import 'package:calorie_ai_app/screens/home_screen.dart';
import 'package:flutter/cupertino.dart'
    show
        Navigator,
        CupertinoPageRoute,
        BuildContext,
        showCupertinoDialog,
        CupertinoAlertDialog,
        CupertinoDialogAction,
        Text;
import 'package:get/get.dart';
import '../constants/app_constants.dart' show AppConstants;
import '../onboarding/controller/onboarding.controller.dart' show OnboardingController;
import '../providers/language_provider.dart' show LanguageProvider;
import '../providers/theme_provider.dart' show ThemeProvider;
import 'dart:convert' show jsonDecode, base64Url, utf8;
import '../utils/network.dart' show deleteAPI, getAPI, multiPostAPINew, putAPI;
import '../utils/user.prefs.dart' show UserPrefs;

class UserController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSuccess = false.obs;
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  Future<void> registerUser(
    Map<String, dynamic> data,
    BuildContext context,
    ThemeProvider themeProvider,
    LanguageProvider languageProvider,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isSuccess.value = false;
      userData.clear();

      await multiPostAPINew(
        methodName: 'api/auth/register',
        param: data,
        callback: (response) async {
          try {
            isLoading.value = false;
            final decoded = response.response;
           
            final json = decoded is String ? jsonDecode(decoded) : decoded;
            
            // Handle both response formats: with 'success' field or with 'user' and 'token' fields
            final bool hasSuccess = json['success'] == true;
            final bool hasUserAndToken = (json['user'] != null && json['token'] != null);
            final bool isSuccessResponse = hasSuccess || hasUserAndToken;
            
            if (isSuccessResponse) {
              // Extract user data
              final user = json['user'] ?? {};
              final token = json['token'] ?? '';
              
              // Only proceed if we have user data and token
              if (user.isNotEmpty && token.isNotEmpty) {
                isSuccess.value = true;
                userData.assignAll(user);

                print('✅ Registration/Login successful!');
                print('📦 Full response: $json');
                
                // Use same token as refresh token if not provided separately
                final refreshToken = json['refreshToken'] ?? token;
                
                print('🔑 Extracted token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
                
                // Try to extract user ID from multiple sources
                String userId = '';
                
                // First, try to get from user object
                final userObjectId = user['_id'] ?? user['id'];
                if (userObjectId != null) {
                  userId = userObjectId.toString();
                }
                
                // If not found in user object, try to extract from JWT token
                if (userId.isEmpty && token.isNotEmpty) {
                  try {
                    // JWT format: header.payload.signature
                    final parts = token.split('.');
                    if (parts.length == 3) {
                      // Decode the payload (second part)
                      String payload = parts[1];
                      // Normalize base64url (same approach as user.prefs.dart)
                      String normalized = base64Url.normalize(payload);
                      final decodedBytes = base64Url.decode(normalized);
                      final payloadJson = jsonDecode(utf8.decode(decodedBytes));
                      if (payloadJson is Map<String, dynamic>) {
                        final tokenId = payloadJson['id']?.toString();
                        if (tokenId != null && tokenId.isNotEmpty) {
                          userId = tokenId;
                          print('🔍 Extracted user ID from JWT token: $userId');
                        }
                      }
                    }
                  } catch (e) {
                    print('⚠️ Could not extract ID from token: $e');
                  }
                }
                
                print('👤 Extracted user ID: ${userId.isNotEmpty ? userId : 'NOT FOUND'}');
                
                // Create full name from firstName and lastName
                final firstName = user['firstName'] ?? '';
                final lastName = user['lastName'] ?? '';
                final fullName = '$firstName $lastName'.trim();
                
                print('💾 Saving to SharedPreferences - ID: $userId');
                
                // Save to shared prefs - AWAIT to ensure it completes
                await UserPrefs.saveUserData(
                  name: fullName.isNotEmpty ? fullName : (user['email'] ?? ''),
                  email: user['email'] ?? '',
                  token: token,
                  refreshToken: refreshToken,
                  id: userId,
                );
                
                print('✅ Successfully saved user data to SharedPreferences');

                // Set AppConstants
                AppConstants.userId = userId;
                AppConstants.authToken = token;
                
                print('✅ AppConstants.userId set to: ${AppConstants.userId}');
                print('✅ AppConstants.authToken set to: ${AppConstants.authToken.substring(0, AppConstants.authToken.length > 20 ? 20 : AppConstants.authToken.length)}...');

                // Check if this was a login or a new registration
                final bool isLogin = json['isLogin'] == true;
                print('🔐 isLogin flag: $isLogin');
                
                // If user is logging in, navigate directly to home screen (skip onboarding)
                // If user is signing up, let onboarding continue (don't navigate here)
                if (isLogin) {
                  print('🔄 Redirecting to HomeScreen (existing user login)');
                  Navigator.of(context).pushAndRemoveUntil(
                    CupertinoPageRoute(
                      builder: (context) => HomeScreen(
                        themeProvider: themeProvider, 
                        languageProvider: languageProvider,
                      ),
                    ),
                    (route) => false, // Remove all previous routes
                  );
                } else {
                  OnboardingController().goToNextPage();
                  print('📝 New registration - continuing with onboarding');
                }
                // If isLogin is false, it's a new registration - onboarding will continue
              } else {
                errorMessage.value = 'Invalid response: missing user data or token.';
                print('❌ Invalid response: user data or token is missing');
              }
            } else {
              errorMessage.value = json['message'] ?? 'Registration failed.';
              print('❌ Registration failed: ${errorMessage.value}');
            }
          } catch (e) {
            isLoading.value = false;
            errorMessage.value = 'Invalid server response.';
            print('❌ Error processing registration response: $e');
          }
        },
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Registration failed. Please check your connection and try again.';
      print('❌ Error during registration: $e');
    }
  }

  Future<void> registerGuestUser(
    Map<String, dynamic> data,
    BuildContext context,
    ThemeProvider themeProvider,
    LanguageProvider languageProvider,
  ) async {
    try {
      print('📞 registerGuestUser called with data: $data');
      isLoading.value = true;
      errorMessage.value = '';
      isSuccess.value = false;
      userData.clear();

      print('🌐 Making API call to: api/guest/register');
      await multiPostAPINew(
        methodName: 'api/auth/guest/register',
        param: data,
        callback: (response) {
          print('📥 API Response received - Status: ${response.code}, Response: ${response.response}');
          try {
            isLoading.value = false;
            final decoded = response.response;
           
            final json = decoded is String ? jsonDecode(decoded) : decoded;
            if (json['success'] == true) {
              isSuccess.value = true;
              userData.assignAll(json['user'] ?? {});

              print('✅ Guest registration successful!');
              print('📦 Full response: $json');
              
              // Save to shared prefs
              final user = json['user'] ?? {};
              final token = json['token'] ?? '';
              final refreshToken = token; // Use same token as refresh token if not provided separately
              
              print('🔑 Extracted token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
              print('👤 Extracted user ID: ${user['_id'] ?? user['id'] ?? 'NOT FOUND'}');
              
              // Create full name from firstName and lastName
              final firstName = user['firstName'] ?? '';
              final lastName = user['lastName'] ?? '';
              final fullName = '$firstName $lastName'.trim();
              
              final userId = user['_id'] ?? user['id'] ?? '';
              print('💾 Saving to SharedPreferences - ID: $userId');
              
              UserPrefs.saveUserData(
                name: fullName.isNotEmpty ? fullName : 'Guest User',
                email: '', // Guest users don't have email
                token: token,
                refreshToken: refreshToken,
                id: userId,
              );

              AppConstants.userId = userId;
              AppConstants.authToken = token;
              
              print('✅ AppConstants.userId set to: ${AppConstants.userId}');
              print('✅ AppConstants.authToken set to: ${AppConstants.authToken.substring(0, AppConstants.authToken.length > 20 ? 20 : AppConstants.authToken.length)}...');

              // Navigate to home screen
              Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(
                  builder: (context) => HomeScreen(
                    themeProvider: themeProvider, 
                    languageProvider: languageProvider,
                  ),
                ),
                (route) => false, // Remove all previous routes
              );
            } else {
              errorMessage.value = json['message'] ?? 'Guest registration failed.';
            }
          } catch (e) {
            isLoading.value = false;
            errorMessage.value = 'Invalid server response.';
            print('❌ Error processing guest registration response: $e');
          }
        },
      );
    } catch (e, stackTrace) {
      isLoading.value = false;
      errorMessage.value = 'Guest registration failed. Please check your connection and try again.';
      print('❌ Error during guest registration: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<bool> loginUser(
    Map<String, dynamic> data,
    BuildContext context,
    ThemeProvider themeProvider,
    LanguageProvider languageProvider,
  ) async {
    bool result = false;
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isSuccess.value = false;
      userData.clear();

      await multiPostAPINew(
        methodName: 'api/users/login',
        param: data,
        callback: (response) {
          try {
            isLoading.value = false;
            final decoded = response.response;
            final json = decoded is String ? jsonDecode(decoded) : decoded;
            if (json['success'] == true) {
              isSuccess.value = true;
              userData.assignAll(json['user'] ?? {});

              print('✅ Login successful!');
              print('📦 Full response: $json');
              
              // Save to shared prefs
              final user = json['user'] ?? {};
              final token = json['token'] ?? '';
              final refreshToken = token; // Use same token if no separate refresh token
              
              print('🔑 Extracted token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
              print('👤 Extracted user ID: ${user['_id'] ?? user['id'] ?? 'NOT FOUND'}');
              
              // Create full name from firstName and lastName
              final firstName = user['firstName'] ?? '';
              final lastName = user['lastName'] ?? '';
              final fullName = '$firstName $lastName'.trim();
              
              final userId = user['_id'] ?? user['id'] ?? '';
              print('💾 Saving to SharedPreferences - ID: $userId');
              
              AppConstants.authToken = token;
              AppConstants.userId = userId;
              
              print('✅ AppConstants.userId set to: ${AppConstants.userId}');
              print('✅ AppConstants.authToken set to: ${AppConstants.authToken.substring(0, AppConstants.authToken.length > 20 ? 20 : AppConstants.authToken.length)}...');
              
              UserPrefs.saveUserData(
                name: fullName.isNotEmpty ? fullName : user['email'] ?? '',
                email: user['email'] ?? '',
                token: token,
                refreshToken: refreshToken,
                id: userId,
              );
              result = true;
              
              // Navigate to home screen and remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(
                  builder: (context) => HomeScreen(
                    themeProvider: themeProvider, 
                    languageProvider: languageProvider,
                  ),
                ),
                (route) => false, // Remove all previous routes
              );
            } else {
              errorMessage.value = json['message'] ?? 'Login failed.';
              // If backend indicates user not found, show a Cupertino dialog (no Material)
              (json['message'] ?? '').toString().toLowerCase();
              // if (msg.contains('not found') || msg.contains('no user')) {
                showCupertinoDialog(
                  context: context,
                  builder: (ctx) => CupertinoAlertDialog(
                    title: const Text('Account Not Found'),
                    content: const Text('This account does not exist.'),
                    actions: [
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              // }
            }
          } catch (e) {
            isLoading.value = false;
            errorMessage.value = 'Invalid server response.';
            print('❌ Error processing login response: $e');
          }
        },
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Login failed. Please check your connection and try again.';
      print('❌ Error during login: $e');
    }
    return result;
  }

  // Future<void> updateInfluencerCommission(String influencerId) async {
  //   try {
  //     final Map<String, dynamic> body = {
  //       'influencerId': AppConstants.influencerId,
  //       'amount': AppConstants.subscriptionAmount,
  //       'purchaseType': AppConstants.currentSubscription,
  //       'userId': AppConstants.userId,
  //       'updateInstalCount': AppConstants.updateInstallCount,
  //     };

  //     print("Body of commission: $body");

  //     await multiPostAPINew(
  //       methodName: 'api/v1/influencers/process-commission',
  //       param: body,
  //       callback: (response) async {
  //         print("Response of commission: ${response.response}");
  //         try {
  //           final decoded = response.response;
  //           final json = decoded is String ? jsonDecode(decoded) : decoded;
  //           final bool ok = (json['success'] == true) ||
  //               (json['statusCode'] == 200) ||
  //               (json['status'] == 'ok');
  //           if (ok) {
  //             // Also update user's referredBy with influencer id
  //             print("Updating user referred by: ${AppConstants.userId} with influencer id: ${AppConstants.influencerId}");
  //             await _updateUserReferredBy(
  //               AppConstants.userId,
  //               AppConstants.influencerId,
  //             );
  //           }
  //         } catch (_) {}
  //       },
  //     );
  //   } catch (_) {}
  // }


  //   Future<void> influencerReferral(String influencerId) async {
  //   try {
  //     final Map<String, dynamic> body = {
  //       'referralCode': AppConstants.referralCode,
  //     };

  //     print("Body of commission: $body");

  //     await multiPostAPINew(
  //       methodName: 'api/v1/influencers/lookup-by-referral',
  //       param: body,
  //       callback: (response) async {
  //         print("Response of referral: ${response.response}");
  //         try {
  //           final decoded = response.response;
  //           final json = decoded is String ? jsonDecode(decoded) : decoded;
  //           final data = json['data'] as Map<String, dynamic>?;
  //           if (json['success'] == true && data != null) {
  //             final id = (data['influencerId'] ?? '').toString();
  //             if (id.isNotEmpty) {
  //               AppConstants.influencerId = id;
  //             }
  //             print("Influencer ID: $id");
  //           }
  //         } catch (_) {}
  //       },
  //     );
  //   } catch (_) {}
  // }

  // Future<void> _updateUserReferredBy(
  //   String userId,
  //   String influencerId,
  // ) async {
  //   print("Updating user referred by: $userId with influencer id: $influencerId");
  //   if (userId.isEmpty || influencerId.isEmpty) return;
  //   try {
  //     await putAPI(
  //       methodName: 'api/v1/users/users/$userId',
  //       param: {
  //         'referredBy': AppConstants.influencerId,
  //         'currentSubscription': AppConstants.currentSubscription,
  //         'referralDate': DateTime.now().toIso8601String(),
  //       },
  //       callback: (response) {
  //         print("Response of update user referred by: ${response.response}");
  //       },
  //     );
  //   } catch (_) {}
  // }

  Future<bool> updateUser(
    String userId,
    Map<String, dynamic> data,
    BuildContext context,
    ThemeProvider themeProvider,
    LanguageProvider languageProvider,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';
    isSuccess.value = false;
    // Do not clear userData here; keep current values to avoid UI flicker

    bool result = false;
    await putAPI(
      methodName: 'api/users/$userId',
      param: data,
      callback: (response) {
        print('data: ${data}');
        isLoading.value = false;
        final decoded = response.response;
        try {
          final json = decoded is String ? jsonDecode(decoded) : decoded;
          print('json: ${json}');
          if (json['success'] == true) {
            
            isSuccess.value = true;
            final dynamic payload = json['data'] ?? json['user'];
            if (payload is Map<String, dynamic>) {
              userData.assignAll(payload);
            }
            // Save to shared prefs
            try {
              final Map<String, dynamic> u = (payload is Map<String, dynamic>) ? payload : <String, dynamic>{};
              UserPrefs.saveUserData(
                name: u['name'] ?? (u['firstName'] != null || u['lastName'] != null ? '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim() : ''),
                email: u['email'] ?? '',
                token: AppConstants.authToken, // No token in update response
                refreshToken: AppConstants.authToken, // No refreshToken in update response
                id: u['_id'] ?? u['id'] ?? '',
              );
            } catch (_) {}
            result = true;
          } else {
            errorMessage.value = json['message'] ?? 'Update failed.';
          }
        } catch (e) {
          errorMessage.value = 'Invalid server response.';
        }
      },
    );
    return result;
  }

  Future<bool> refreshToken(String refreshToken) async {
    isLoading.value = true;
    errorMessage.value = '';
    isSuccess.value = false;

    bool result = false;
    await multiPostAPINew(
      methodName: 'api/users/refresh-token',
      param: {"refreshToken": refreshToken},
      callback: (response) {
        isLoading.value = false;
        final decoded = response.response;
        try {
          final json = decoded is String ? jsonDecode(decoded) : decoded;
          if (json['success'] == true) {
            isSuccess.value = true;
            final user = json['data']['user'] ?? {};
            final token = json['data']['token'] ?? '';
            final newRefreshToken = json['data']['refreshToken'] ?? '';

            AppConstants.authToken = token;
            userData.assignAll(user);
            UserPrefs.saveUserData(
              name: user['name'] ?? '',
              email: user['email'] ?? '',
              token: token,
              refreshToken: newRefreshToken,
              id: user['_id'] ?? '',
            );
            result = true;
          } else {
            errorMessage.value = json['message'] ?? 'Token refresh failed.';
          }
        } catch (e) {
          errorMessage.value = 'Invalid server response.';
        }
      },
    );
    return result;
  }

  Future<bool> getUserData(String userId) async {
    isLoading.value = true;
    errorMessage.value = '';
    isSuccess.value = false;
    userData.clear();

    bool result = false;
    await getAPI(
      methodName: 'api/users/$userId',
      callback: (response) {
        isLoading.value = false;
        final decoded = response.response;
        try {
          final json = decoded is String ? jsonDecode(decoded) : decoded;
          print('json: ${json}');
          if (json['success'] == true) {
            print('json: ${json}');
            isSuccess.value = true;
            final dynamic payload = json['data'] ?? json['user'];

            if (payload is List) {
              // Handle array payloads by selecting matching user or first
              Map<String, dynamic>? selected;
              for (final item in payload) {
                final Map<String, dynamic> u = Map<String, dynamic>.from(item);
                final id = (u['_id'] ?? u['id'] ?? '').toString();
                if (id == userId) {
                  selected = u;
                  break;
                }
              }
              selected ??= (payload.isNotEmpty
                  ? Map<String, dynamic>.from(payload.first)
                  : <String, dynamic>{});
              userData.assignAll(selected);
              result = true;
            } else if (payload is Map<String, dynamic>) {
              userData.assignAll(payload);
              result = true;
            } else {
              // No recognizable payload, keep previous state
              result = false;
            }

            print('userData: ${userData}');
          } else {
            errorMessage.value = json['message'] ?? 'Failed to fetch user data.';
          }
        } catch (e) {
          errorMessage.value = 'Invalid server response.';
        }
      },
    );
    return result;
  }

  /// Delete user account
  Future<bool> deleteUser(String userId) async {
    isLoading.value = true;
    errorMessage.value = '';
    isSuccess.value = false;

    bool result = false;
    await deleteAPI(
      methodName: 'api/users/$userId',
      param: {},
      callback: (response) {
        isLoading.value = false;
        final decoded = response.response;
        try {
          final json = decoded is String ? jsonDecode(decoded) : decoded;
          if (json['success'] == true) {
            isSuccess.value = true;
            userData.clear();
            result = true;
          } else {
            errorMessage.value = json['message'] ?? 'Failed to delete user.';
          }
        } catch (e) {
          errorMessage.value = 'Invalid server response.';
        }
      },
    );
    return result;
  }
}

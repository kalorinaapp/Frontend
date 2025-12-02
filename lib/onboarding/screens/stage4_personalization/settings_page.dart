// ignore_for_file: unused_local_variable

import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/health_provider.dart';
import '../../../screens/appearance_screen.dart' show AppearanceScreen;
import '../../../screens/language_selection_screen.dart' show LanguageSelectionScreen;
import '../../../screens/set_goals_screen.dart' show SetGoalsScreen;
import '../../../utils/theme_helper.dart';
import '../../../authentication/user.controller.dart';
import '../../../constants/app_constants.dart';
import '../../../utils/user.prefs.dart';
import '../../../onboarding_screen.dart';
import '../../../l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  final String avatarAsset;
  final String inviteAsset;

  const SettingsPage({
    super.key,
    required this.themeProvider,
    this.avatarAsset = 'assets/images/avatar_placeholder.png',
    this.inviteAsset = 'assets/images/invite_placeholder.png',
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ThemeProvider themeProvider;
  @override
  void initState() {
    super.initState();
    themeProvider = widget.themeProvider;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, _) {
        return CupertinoPageScaffold(
          backgroundColor: ThemeHelper.background,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                16 + MediaQuery.of(context).padding.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _UserCard(avatarAsset: 'assets/icons/profile.png'),
                  const SizedBox(height: 16),
                  _InviteCard(inviteAsset: 'assets/icons/friends.png'),
                  const SizedBox(height: 16),
                  _PersonalDetailsCard(),
                  const SizedBox(height: 16),
                  _SettingsListCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeHelper.divider, width: 1),
        boxShadow: ThemeHelper.isLightMode
            ? [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.2),
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: child,
    );
  }
}

class _UserCard extends StatelessWidget {
  final String avatarAsset;
  const _UserCard({required this.avatarAsset});

  void _showUsernameDialog(BuildContext context, UserController userController, String currentName) {
    final TextEditingController controller = TextEditingController(text: currentName);

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 220,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.separator,
                        width: 0.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Cancel', style: TextStyle(color: ThemeHelper.textPrimary)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        AppLocalizations.of(context)!.enterUsername,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Save', style: TextStyle(color: ThemeHelper.textPrimary, fontWeight: FontWeight.w600)),
                        onPressed: () {
                          final newName = controller.text.trim();
                          if (newName.isNotEmpty) {
                            final parts = newName.split(' ');
                            final firstName = parts.isNotEmpty ? parts[0] : '';
                            final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

                            final oldFirstName = userController.userData['firstName'];
                            final oldLastName = userController.userData['lastName'];

                            userController.userData['firstName'] = firstName;
                            userController.userData['lastName'] = lastName;

                            userController
                                .updateUser(
                                  AppConstants.userId,
                                  {
                                    'firstName': firstName,
                                    'lastName': lastName,
                                  },
                                  context,
                                  Get.find<ThemeProvider>(),
                                  Get.find<LanguageProvider>(),
                                )
                                .catchError((error) {
                              debugPrint('Error updating name: $error');
                              userController.userData['firstName'] = oldFirstName;
                              userController.userData['lastName'] = oldLastName;
                              return false;
                            });
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CupertinoTextField(
                      controller: controller,
                      placeholder: AppLocalizations.of(context)!.enterUsername,
                      style: const TextStyle(fontSize: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ThemeHelper.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      autofocus: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    
    return _CardShell(
      child: Obx(() {
        final firstName = userController.userData['firstName'] ?? '';
        final lastName = userController.userData['lastName'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        final displayName = fullName.isNotEmpty ? fullName : 'User Name';
        final isEmpty = fullName.isEmpty;
        // If name is empty, make font size 30% smaller (20 * 0.7 = 14)
        final fontSize = isEmpty ? 14.0 : 20.0;
        
        return GestureDetector(
          onTap: () => _showUsernameDialog(context, userController, displayName),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(avatarAsset, width: 35, height: 35),
              Row(
                children: [
                  Text(
                    displayName,
                    style: ThemeHelper.textStyleWithColorAndSize(
                      ThemeHelper.body1,
                      ThemeHelper.textSecondary,
                      fontSize,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Icon(CupertinoIcons.pencil, size: 18, color: ThemeHelper.textSecondary),
                ],
              ),
              const SizedBox(width: 8.0),
            ],
          ),
        );
      }),
    );
  }
}

class _InviteCard extends StatelessWidget {
  final String inviteAsset;
  const _InviteCard({required this.inviteAsset});

  Future<void> _shareApp(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    // App store links
    const String appStoreLink = 'https://apps.apple.com/app/kalorina/id123456789'; // TODO: Replace with actual App Store link
    const String playStoreLink = 'https://play.google.com/store/apps/details?id=com.kalorina.app'; // TODO: Replace with actual Play Store link
    
    // Share message with localization
    final String shareMessage = '${l10n.inviteFriends}!\n\n'
        'Download Kalorina - AI Calorie Tracker:\n'
        'iOS: $appStoreLink\n'
        'Android: $playStoreLink';
    
    try {
      await Share.share(
        shareMessage,
        subject: 'Join me on Kalorina!',
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _shareApp(context),
      child: _CardShell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(inviteAsset, width: 35, height: 35),
              
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.inviteFriends,
                  style: ThemeHelper.textStyleWithColorAndSize(
                    ThemeHelper.body1,
                    ThemeHelper.textSecondary,
                    16,
                  ),
                ),

            const SizedBox(width: 8.0),
            Icon(CupertinoIcons.share_up, size: 18, color: ThemeHelper.textSecondary),
              ],
            ),
            const SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }
}

class _PersonalDetailsCard extends StatelessWidget {
  const _PersonalDetailsCard();

  void _updateUserField(String field, dynamic value) {
    final userController = Get.find<UserController>();
    final oldValue = userController.userData[field];
    
    // Optimistically update the UI
    userController.userData[field] = value;
    
    // Make the API call in the background
    userController.updateUser(
      AppConstants.userId,
      {field: value},
      Get.context!,
      Get.find<ThemeProvider>(),
      Get.find<LanguageProvider>(),
    ).catchError((error) {
      // If the API call fails, revert the change
      debugPrint('Error updating $field: $error');
      userController.userData[field] = oldValue;
      return false;
    });
  }

  void _showWeightDialog(BuildContext context, double currentWeight) {
    double tempWeight = currentWeight;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.separator,
                        width: 0.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Cancel', style: TextStyle(color: ThemeHelper.textPrimary)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        AppLocalizations.of(context)!.weight,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Save', style: TextStyle(color: ThemeHelper.textPrimary, fontWeight: FontWeight.w600)),
                        onPressed: () {
                          _updateUserField('weight', tempWeight);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setSheetState) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${tempWeight.round()} kg',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: CupertinoSlider(
                              value: tempWeight,
                              min: 30.0,
                              max: 200.0,
                              divisions: 170,
                              activeColor: ThemeHelper.textPrimary,
                              onChanged: (value) {
                                setSheetState(() {
                                  tempWeight = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text('30 kg', style: TextStyle(color: ThemeHelper.textSecondary)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 30),
                                child: Text('200 kg', style: TextStyle(color: ThemeHelper.textSecondary)),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHeightDialog(BuildContext context, double currentHeight) {
    double tempHeight = currentHeight;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.separator,
                        width: 0.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Cancel', style: TextStyle(color: ThemeHelper.textPrimary)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        AppLocalizations.of(context)!.height,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Save', style: TextStyle(color: ThemeHelper.textPrimary, fontWeight: FontWeight.w600)),
                        onPressed: () {
                          _updateUserField('height', tempHeight);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setSheetState) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${tempHeight.round()} cm',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: CupertinoSlider(
                              value: tempHeight,
                              min: 120.0,
                              max: 220.0,
                              divisions: 100,
                              activeColor: ThemeHelper.textPrimary,
                              onChanged: (value) {
                                setSheetState(() {
                                  tempHeight = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text('120 cm', style: TextStyle(color: ThemeHelper.textSecondary)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 30),
                                child: Text('220 cm', style: TextStyle(color: ThemeHelper.textSecondary)),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStepsDialog(BuildContext context, int currentSteps) {
    int tempSteps = currentSteps;
    final healthProvider = Get.find<HealthProvider>();
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.separator,
                        width: 0.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Cancel', style: TextStyle(color: ThemeHelper.textPrimary)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        AppLocalizations.of(context)!.dailyStepsGoal,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Save', style: TextStyle(color: ThemeHelper.textPrimary, fontWeight: FontWeight.w600)),
                        onPressed: () {
                          // Optimistically update and close immediately
                          healthProvider.setStepsGoal(tempSteps);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setSheetState) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${tempSteps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} steps',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: CupertinoSlider(
                              value: tempSteps.toDouble(),
                              min: 1000.0,
                              max: 30000.0,
                              divisions: 29,
                              activeColor: ThemeHelper.textPrimary,
                              onChanged: (value) {
                                setSheetState(() {
                                  tempSteps = value.round();
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text('1,000', style: TextStyle(color: ThemeHelper.textSecondary)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 30),
                                child: Text('30,000', style: TextStyle(color: ThemeHelper.textSecondary)),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGenderDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(AppLocalizations.of(context)!.gender),
          content: const SizedBox(height: 20),
          actions: [
            CupertinoDialogAction(
              child: Text(AppLocalizations.of(context)!.male, style: TextStyle(color: ThemeHelper.textPrimary)),
              onPressed: () {
                _updateUserField('gender', 'male');
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(AppLocalizations.of(context)!.female, style: TextStyle(color: ThemeHelper.textPrimary)),
              onPressed: () {
                _updateUserField('gender', 'female');
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: ThemeHelper.textPrimary)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showBirthdayDialog(BuildContext context, DateTime currentBirthday) {
    DateTime tempBirthday = currentBirthday;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 350,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.separator,
                        width: 0.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Cancel', style: TextStyle(color: ThemeHelper.textPrimary)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        AppLocalizations.of(context)!.birthday,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Save', style: TextStyle(color: ThemeHelper.textPrimary, fontWeight: FontWeight.w600)),
                        onPressed: () {
                          // Calculate age from birthday
                          final now = DateTime.now();
                          final age = now.year - tempBirthday.year - 
                            ((now.month > tempBirthday.month || 
                              (now.month == tempBirthday.month && now.day >= tempBirthday.day)) ? 0 : 1);
                          
                          _updateUserField('age', age);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: currentBirthday,
                    maximumDate: DateTime.now(),
                    minimumDate: DateTime(1900),
                    onDateTimeChanged: (DateTime newDate) {
                      tempBirthday = newDate;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(String label, String value, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: ThemeHelper.textStyleWithColorAndSize(
                    ThemeHelper.title2,
                    ThemeHelper.textPrimary,
                    14,
                  ).copyWith(fontWeight: FontWeight.w400),
                ),
              ),
              Text(
                value,
                style: ThemeHelper.textStyleWithColorAndSize(
                  ThemeHelper.body1,
                  ThemeHelper.textPrimary,
                  14,
                ),
              ),
              const SizedBox(width: 8),
              Icon(CupertinoIcons.pencil, size: 16, color: ThemeHelper.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 1, 
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 0),
          color: ThemeHelper.divider,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final healthProvider = Get.find<HealthProvider>();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeHelper.divider, width: 1),
        boxShadow: ThemeHelper.isLightMode
            ? [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.2),
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Obx(() {
        final weight = (userController.userData['weight'] as num?)?.toDouble() ?? 70.0;
        final height = (userController.userData['height'] as num?)?.toDouble() ?? 170.0;
        final age = userController.userData['age'] as int? ?? 24;
        final gender = (userController.userData['gender'] as String? ?? 'male').capitalize ?? 'Male';
        final stepsGoal = healthProvider.stepsGoal;
        // Use the actual backend field names from the API response
        final rolloverCalories = userController.userData['rolloverCalories'] ?? false;
        final addBurnedCalories = userController.userData['includeStepCaloriesInGoal'] ?? false;
        
        // Calculate birthday from age (approximate)
        final now = DateTime.now();
        final birthday = DateTime(now.year - age, now.month, now.day);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/personal_details.png', width: 18, height: 18, color: ThemeHelper.textPrimary),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.personalDetails,
                  style: ThemeHelper.textStyleWithColorAndSize(
                    ThemeHelper.body1,
                    ThemeHelper.textPrimary,
                    16,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _row(AppLocalizations.of(context)!.weight, '${weight.round()} kg', () => _showWeightDialog(context, weight)),
            _row(AppLocalizations.of(context)!.height, '${height.round()} cm', () => _showHeightDialog(context, height)),
            _row(AppLocalizations.of(context)!.birthday, '${birthday.day.toString().padLeft(2, '0')}/${birthday.month.toString().padLeft(2, '0')}/${birthday.year}', () => _showBirthdayDialog(context, birthday)),
            _row(AppLocalizations.of(context)!.gender, gender, () => _showGenderDialog(context)),
            _row(AppLocalizations.of(context)!.steps, '$stepsGoal', () => _showStepsDialog(context, stepsGoal)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.rolloverLeftOverCalories,
                    style: ThemeHelper.textStyleWithColorAndSize(
                      ThemeHelper.body1,
                      ThemeHelper.textPrimary,
                      14,
                    ),
                  ),
                ),
                CupertinoSwitch(
                  value: rolloverCalories,
                  activeColor: ThemeHelper.textPrimary,
                  thumbColor: ThemeHelper.isLightMode ? null : CupertinoColors.black,
                  onChanged: (v) => _updateUserField('rolloverCalories', v),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.addBurnedCalories,
                    style: ThemeHelper.textStyleWithColorAndSize(
                      ThemeHelper.body1,
                      ThemeHelper.textPrimary,
                      14,
                    ),
                  ),
                ),
                CupertinoSwitch(
                  value: addBurnedCalories,
                  activeColor: ThemeHelper.textPrimary,
                  thumbColor: ThemeHelper.isLightMode ? null : CupertinoColors.black,
                  onChanged: (v) => _updateUserField('includeStepCaloriesInGoal', v),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _SettingsListCard extends StatelessWidget {
  const _SettingsListCard();

  // Helper to check if user is a guest
  // Only returns true if isGuest flag is explicitly set to true in userData
  bool _isGuestUser() {
    final userController = Get.find<UserController>();
    final isGuest = userController.userData['isGuest'] as bool?;
    // Only hide features if isGuest is explicitly true
    return isGuest == true;
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@kalorina.app',
      query: 'subject=Support Request&body=Hello Kalorina Support Team,\n\n',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Fallback: try to launch Gmail web with the email
        final Uri gmailUri = Uri.parse(
          'https://mail.google.com/mail/?view=cm&fs=1&to=support@kalorina.app&su=Support Request&body=Hello Kalorina Support Team,',
        );
        
        if (await canLaunchUrl(gmailUri)) {
          await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
        } else {
          // If both fail, we could show an error dialog or copy to clipboard
          throw 'Could not launch email client';
        }
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      // You could show a snackbar or dialog here to inform the user
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri privacyUri = Uri.parse('https://kalorina.app/privacy-policy/');
    
    try {
      if (await canLaunchUrl(privacyUri)) {
        await launchUrl(privacyUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch privacy policy URL';
      }
    } catch (e) {
      debugPrint('Error launching privacy policy: $e');
    }
  }

  Future<void> _launchTermsAndConditions() async {
    final Uri termsUri = Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
    
    try {
      if (await canLaunchUrl(termsUri)) {
        await launchUrl(termsUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch terms and conditions URL';
      }
    } catch (e) {
      debugPrint('Error launching terms and conditions: $e');
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    // Call the delete API
    final userController = Get.find<UserController>();
    
    final success = await userController.deleteUser(AppConstants.userId);
    
    if (success) {
      // Clear all user data
      userController.userData.clear();
      
      // Clear SharedPreferences
      await UserPrefs.clearUserData();
      
      // Clear AppConstants
      AppConstants.userId = '';
      AppConstants.authToken = '';
      AppConstants.userEmail = '';
      AppConstants.userName = '';
      AppConstants.refreshToken = '';
      
      // Navigate to onboarding screen and remove all previous routes
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(
            builder: (context) => OnboardingScreen(
              themeProvider: Get.find<ThemeProvider>(),
            ),
          ),
          (route) => false, // Remove all previous routes
        );
      }
    } else {
      // Show error dialog if deletion failed
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.error),
            content: Text(userController.errorMessage.value),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    // Show confirmation dialog
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 320,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: ThemeHelper.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Header with title and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.deleteAccountTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.textPrimary,
                        ),
                      ),
                      CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: ThemeHelper.background,
                          shape: BoxShape.circle,
                        ),
                        child:                           Icon(
                            weight: 30.0,
                            CupertinoIcons.xmark_circle,
                            color: ThemeHelper.textPrimary,
                            size: 24,
                          ),
                      ),
                    ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    AppLocalizations.of(context)!.accountWillBePermanentlyDeleted,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ThemeHelper.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Buttons
                  Row(
                    children: [
                      // No button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: ThemeHelper.cardBackground,
                              border: Border.all(
                                color: ThemeHelper.divider,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                'No',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeHelper.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Yes button
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.of(context).pop();
                            await _handleDeleteAccount(context);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCD5C5C), // Matching the red color from screenshot
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Center(
                              child: Text(
                                'Yes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
     
  });

// ... existing code ...
  }



  void _handleLogout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 320,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: ThemeHelper.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Header with title and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.logoutTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.textPrimary,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: ThemeHelper.cardBackground,
                            shape: BoxShape.circle,
                          ),
                          child:                           Icon(
                            weight: 30.0,
                            CupertinoIcons.xmark_circle,
                            color: ThemeHelper.textPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    AppLocalizations.of(context)!.areYouSureYouWantToLogOut,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ThemeHelper.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Buttons
                  Row(
                    children: [
                      // No button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: ThemeHelper.cardBackground,
                              border: Border.all(
                                color: ThemeHelper.divider,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                'No',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeHelper.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Yes button
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.of(context).pop();
                            
                            // Clear UserController data
                            final userController = Get.find<UserController>();
                            userController.userData.clear();
                            
                            // Clear SharedPreferences
                            await UserPrefs.clearUserData();
                            
                            // Clear AppConstants
                            AppConstants.userId = '';
                            AppConstants.authToken = '';
                            AppConstants.userEmail = '';
                            AppConstants.userName = '';
                            AppConstants.refreshToken = '';
                            
                            // Navigate to onboarding screen and remove all previous routes
                            Navigator.of(context).pushAndRemoveUntil(
                              CupertinoPageRoute(
                                builder: (context) => OnboardingScreen(
                                  themeProvider: Get.find<ThemeProvider>(),
                                ),
                              ),
                              (route) => false, // Remove all previous routes
                            );
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: ThemeHelper.textPrimary,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                'Yes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeHelper.background,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tile(String title, String icon, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          children: [
            Image.asset(icon, width: 16, height: 16, color: ThemeHelper.textPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: ThemeHelper.textStyleWithColorAndSize(
                  ThemeHelper.body1,
                  ThemeHelper.textPrimary,
                  15,
                ),
              ),
            ),
            Icon(CupertinoIcons.chevron_right, size: 16, color: ThemeHelper.textSecondary),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 14),
          Container(height: 1, color: ThemeHelper.divider),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = _isGuestUser();
    
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, CupertinoPageRoute(builder: (context) =>  SetGoalsScreen()));
            },
            child: _tile(AppLocalizations.of(context)!.adjustMacronutrients, 'assets/icons/adjust.png'),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, CupertinoPageRoute(builder: (context) =>  AppearanceScreen()));
            },
            child: _tile(AppLocalizations.of(context)!.appearance, 'assets/icons/appearance.png')),
          GestureDetector(
            onTap: () {
              Navigator.push(context, CupertinoPageRoute(builder: (context) =>  LanguageSelectionScreen()));
            },
            child: _tile(AppLocalizations.of(context)!.language, 'assets/icons/language.png')),
          GestureDetector(
            onTap: _launchEmail,
            child: _tile(AppLocalizations.of(context)!.support, 'assets/icons/support.png'),
          ),
          GestureDetector(
            onTap: _launchPrivacyPolicy,
            child: _tile(AppLocalizations.of(context)!.privacyPolicy, 'assets/icons/privacy.png'),
          ),
          GestureDetector(
            onTap: _launchTermsAndConditions,
            child: _tile(AppLocalizations.of(context)!.termsAndConditions, 'assets/icons/terms.png'),
          ),
          // Only show delete account and logout for non-guest users
          if (!isGuest) ...[
            GestureDetector(
              onTap: () => _showDeleteAccountConfirmation(context),
              child: _tile(AppLocalizations.of(context)!.deleteAccount, 'assets/icons/delete_account.png'),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _handleLogout(context);
              },
              child: _tile(AppLocalizations.of(context)!.logout, 'assets/icons/logout.png', isLast: true)),
          ],
        ],
      ),
    );
  }
}



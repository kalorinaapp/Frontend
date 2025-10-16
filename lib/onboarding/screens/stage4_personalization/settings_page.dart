import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
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
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, _) {
        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.white,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _UserCard(avatarAsset: 'assets/icons/profile.png'),
                  const SizedBox(height: 16),
                  _InviteCard(inviteAsset: 'assets/icons/friends.png'),
                  const SizedBox(height: 16),
                  const _PersonalDetailsCard(),
                  const SizedBox(height: 16),
                  const _SettingsListCard(),
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
        color: ThemeHelper.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeHelper.divider, width: 1),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: CupertinoColors.black.withOpacity(0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
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
    
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: CupertinoTextField(
              controller: controller,
              placeholder: 'Enter username',
              style: const TextStyle(fontSize: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              autofocus: true,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel', style: TextStyle(color: CupertinoColors.black)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              child: const Text('Save', style: TextStyle(color: CupertinoColors.black, fontWeight: FontWeight.w600)),
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  final parts = newName.split(' ');
                  final firstName = parts.isNotEmpty ? parts[0] : '';
                  final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
                  
                  await userController.updateUser(
                    AppConstants.userId,
                    {
                      'firstName': firstName,
                      'lastName': lastName,
                    },
                    context,
                    Get.find<ThemeProvider>(),
                    Get.find<LanguageProvider>(),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
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
                      16,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  const Icon(CupertinoIcons.pencil, size: 18, color: CupertinoColors.systemGrey),
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

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(inviteAsset, width: 35, height: 35),
            
          Row(
            children: [
              Text(
                'Invite Friends',
                style: ThemeHelper.textStyleWithColorAndSize(
                  ThemeHelper.body1,
                  ThemeHelper.textSecondary,
                  16,
                ),
              ),

          const SizedBox(width: 8.0),
          const Icon(CupertinoIcons.share_up, size: 18, color: CupertinoColors.systemGrey),
            ],
          ),
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }
}

class _PersonalDetailsCard extends StatelessWidget {
  const _PersonalDetailsCard();

  Future<void> _updateUserField(String field, dynamic value) async {
    final userController = Get.find<UserController>();
    await userController.updateUser(
      AppConstants.userId,
      {field: value},
      Get.context!,
      Get.find<ThemeProvider>(),
      Get.find<LanguageProvider>(),
    );
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
                        child: const Text('Cancel', style: TextStyle(color: CupertinoColors.black)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Weight',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text('Save', style: TextStyle(color: CupertinoColors.black, fontWeight: FontWeight.w600)),
                        onPressed: () async {
                          await _updateUserField('weight', tempWeight);
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
                              activeColor: CupertinoColors.black,
                              onChanged: (value) {
                                setSheetState(() {
                                  tempWeight = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text('30 kg', style: TextStyle(color: CupertinoColors.systemGrey)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 30),
                                child: Text('200 kg', style: TextStyle(color: CupertinoColors.systemGrey)),
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
                        child: const Text('Cancel', style: TextStyle(color: CupertinoColors.black)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Height',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text('Save', style: TextStyle(color: CupertinoColors.black, fontWeight: FontWeight.w600)),
                        onPressed: () async {
                          await _updateUserField('height', tempHeight);
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
                              activeColor: CupertinoColors.black,
                              onChanged: (value) {
                                setSheetState(() {
                                  tempHeight = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text('120 cm', style: TextStyle(color: CupertinoColors.systemGrey)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 30),
                                child: Text('220 cm', style: TextStyle(color: CupertinoColors.systemGrey)),
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
                        child: const Text('Cancel', style: TextStyle(color: CupertinoColors.black)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Daily Steps Goal',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text('Save', style: TextStyle(color: CupertinoColors.black, fontWeight: FontWeight.w600)),
                        onPressed: () {
                          final healthProvider = Get.find<HealthProvider>();
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
                              activeColor: CupertinoColors.black,
                              onChanged: (value) {
                                setSheetState(() {
                                  tempSteps = value.round();
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text('1,000', style: TextStyle(color: CupertinoColors.systemGrey)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 30),
                                child: Text('30,000', style: TextStyle(color: CupertinoColors.systemGrey)),
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
          title: const Text('Gender'),
          content: const SizedBox(height: 20),
          actions: [
            CupertinoDialogAction(
              child: const Text('Male', style: TextStyle(color: CupertinoColors.black)),
              onPressed: () async {
                await _updateUserField('gender', 'male');
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('Female', style: TextStyle(color: CupertinoColors.black)),
              onPressed: () async {
                await _updateUserField('gender', 'female');
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('Cancel', style: TextStyle(color: CupertinoColors.black)),
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
                        child: const Text('Cancel', style: TextStyle(color: CupertinoColors.black)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Birthday',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text('Save', style: TextStyle(color: CupertinoColors.black, fontWeight: FontWeight.w600)),
                        onPressed: () async {
                          // Calculate age from birthday
                          final now = DateTime.now();
                          final age = now.year - tempBirthday.year - 
                            ((now.month > tempBirthday.month || 
                              (now.month == tempBirthday.month && now.day >= tempBirthday.day)) ? 0 : 1);
                          
                          await _updateUserField('age', age);
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
              const Icon(CupertinoIcons.pencil, size: 16, color: CupertinoColors.systemGrey2),
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
        color: ThemeHelper.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeHelper.divider, width: 1),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: CupertinoColors.black.withOpacity(0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Obx(() {
        final weight = (userController.userData['weight'] as num?)?.toDouble() ?? 70.0;
        final height = (userController.userData['height'] as num?)?.toDouble() ?? 170.0;
        final age = userController.userData['age'] as int? ?? 24;
        final gender = (userController.userData['gender'] as String? ?? 'male').capitalize ?? 'Male';
        final stepsGoal = healthProvider.stepsGoal;
        final addBurnedCalories = userController.userData['addBurnedCaloriesToGoal'] ?? false;
        
        // Calculate birthday from age (approximate)
        final now = DateTime.now();
        final birthday = DateTime(now.year - age, now.month, now.day);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/personal_details.png', width: 18, height: 18),
                const SizedBox(width: 8),
                Text(
                  'Personal Details',
                  style: ThemeHelper.textStyleWithColorAndSize(
                    ThemeHelper.body1,
                    ThemeHelper.textPrimary,
                    16,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _row('Weight', '${weight.round()} kg', () => _showWeightDialog(context, weight)),
            _row('Height', '${height.round()} cm', () => _showHeightDialog(context, height)),
            _row('Birthday', '${birthday.day.toString().padLeft(2, '0')}/${birthday.month.toString().padLeft(2, '0')}/${birthday.year}', () => _showBirthdayDialog(context, birthday)),
            _row('Gender', gender, () => _showGenderDialog(context)),
            _row('Steps', '$stepsGoal', () => _showStepsDialog(context, stepsGoal)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Rollover up to 200 Left Over Calories From Yesterday',
                    style: ThemeHelper.textStyleWithColorAndSize(
                      ThemeHelper.body1,
                      ThemeHelper.textPrimary,
                      14,
                    ),
                  ),
                ),
                CupertinoSwitch(
                  value: addBurnedCalories,
                  activeColor: CupertinoColors.black,
                  onChanged: (v) => _updateUserField('rolloverLeftOverCalories', v),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Burned Calories',
                    style: ThemeHelper.textStyleWithColorAndSize(
                      ThemeHelper.body1,
                      ThemeHelper.textPrimary,
                      14,
                    ),
                  ),
                ),
                CupertinoSwitch(
                  value: addBurnedCalories,
                  activeColor: CupertinoColors.black,
                  onChanged: (v) => _updateUserField('addBurnedCaloriesToGoal', v),
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

  void _handleDeleteAccount(BuildContext context) {


    
    // TODO: Implement actual account deletion logic
    // This would typically involve:
    // 1. Calling an API to delete the account
    // 2. Clearing local storage/cache
    // 3. Navigating back to login/onboarding screen
    
    // For now, just show a confirmation
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 320,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
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
                        'Delete Account?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.black,
                        ),
                      ),
                      CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: CupertinoColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          weight: 30.0,
                          CupertinoIcons.xmark_circle,
                          color: CupertinoColors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Account will be permanently deleted',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: CupertinoColors.systemGrey,
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
                              color: CupertinoColors.white,
                              border: Border.all(
                                color: CupertinoColors.systemGrey3,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Center(
                              child: Text(
                                'No',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.black,
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
                          onTap: () {
                            Navigator.of(context).pop();
                            _handleDeleteAccount(context);
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
              color: CupertinoColors.white,
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
                        'Log out?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.black,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: CupertinoColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            weight: 30.0,
                            CupertinoIcons.xmark_circle,
                            color: CupertinoColors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Are you sure you want to log out?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: CupertinoColors.systemGrey,
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
                              color: CupertinoColors.white,
                              border: Border.all(
                                color: CupertinoColors.systemGrey3,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Center(
                              child: Text(
                                'No',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.black,
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
                              color: CupertinoColors.black,
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
      },
    );
  }

  Widget _tile(String title, String icon, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          children: [
            Image.asset(icon, width: 16, height: 16),
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
            const Icon(CupertinoIcons.chevron_right, size: 16, color: CupertinoColors.systemGrey2),
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
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {

              Navigator.push(context, CupertinoPageRoute(builder: (context) =>  SetGoalsScreen()));
            },
            child: _tile('Adjust Macronutrients', 'assets/icons/adjust.png'),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, CupertinoPageRoute(builder: (context) =>  AppearanceScreen()));
            },
            child: _tile('Appearance', 'assets/icons/appearance.png')),
          GestureDetector(
          onTap: () {
            Navigator.push(context, CupertinoPageRoute(builder: (context) =>  LanguageSelectionScreen()));
          },
          child: _tile('Language', 'assets/icons/language.png')),
          GestureDetector(
            onTap: _launchEmail,
            child: _tile('Support', 'assets/icons/support.png'),
          ),
          GestureDetector(
            onTap: _launchPrivacyPolicy,
            child: _tile('Privacy Policy', 'assets/icons/privacy.png'),
          ),
          GestureDetector(
            onTap: _launchTermsAndConditions,
            child: _tile('Terms and Conditions', 'assets/icons/terms.png'),
          ),
          GestureDetector(
            onTap: () => _handleDeleteAccount(context),
            child: _tile('Delete Account', 'assets/icons/delete_account.png'),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _handleLogout(context);
            },
            child: _tile('Logout', 'assets/icons/logout.png', isLast: true)),
        ],
      ),
    );
  }
}



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../l10n/app_localizations.dart' show AppLocalizations;
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/health_provider.dart';
import '../utils/theme_helper.dart';
import '../constants/app_constants.dart';
import '../authentication/user.controller.dart';
import 'health_consistency_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  final LanguageProvider languageProvider;

  const ProfileScreen({
    super.key, 
    required this.themeProvider,
    required this.languageProvider,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserController userController;
  late HealthProvider healthProvider;

  @override
  void initState() {
    super.initState();
    userController = Get.find<UserController>();
    healthProvider = Get.find<HealthProvider>();
  }

  Future<void> _updateUserField(String field, dynamic value) async {
    await userController.updateUser(
      AppConstants.userId,
      {field: value},
      context,
      widget.themeProvider,
      widget.languageProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: Listenable.merge([widget.themeProvider, widget.languageProvider]),
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: ThemeHelper.background,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: ThemeHelper.background,
            border: Border(
              bottom: BorderSide(
                color: ThemeHelper.divider,
                width: 0.5,
              ),
            ),
            middle: Text(
              l10n.settings,
              style: ThemeHelper.textStyleWithColor(
                ThemeHelper.headline,
                ThemeHelper.textPrimary,
              ),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // User Profile Section
                  Obx(() {
                    final firstName = userController.userData['firstName'] ?? '';
                    final lastName = userController.userData['lastName'] ?? '';
                    final fullName = '$firstName $lastName'.trim();
                    final email = userController.userData['email'] ?? '';
                    
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Profile Avatar
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey5,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Name
                          GestureDetector(
                            onTap: () => _showEditNameDialog(fullName),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  fullName.isNotEmpty ? fullName : l10n.setName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.black,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(CupertinoIcons.pencil, size: 16, color: CupertinoColors.systemGrey),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Email
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 24),
                  
                  // Personal Info Section
                  Text(
                    l10n.personalInformation,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Personal Info Cards
                  Obx(() => _buildInfoCard(
                    icon: 'assets/icons/weights.png',
                    title: l10n.weight,
                    value: '${userController.userData['weight'] ?? '-'} kg',
                    onTap: () => _showEditDialog(l10n.weight, 'weight', userController.userData['weight']),
                  )),
                  const SizedBox(height: 12),
                  
                  Obx(() => _buildInfoCard(
                    icon: 'assets/icons/up.png',
                    title: l10n.height,
                    value: '${userController.userData['height'] ?? '-'} cm',
                    onTap: () => _showEditDialog(l10n.height, 'height', userController.userData['height']),
                  )),
                  const SizedBox(height: 12),
                  
                  Obx(() {
                    final age = userController.userData['age'];
                    return _buildInfoCard(
                      icon: 'assets/icons/profile.png',
                      title: l10n.age,
                      value: age != null ? '$age ${l10n.years}' : '-',
                      onTap: () => _showEditDialog(l10n.age, 'age', age),
                    );
                  }),
                  const SizedBox(height: 12),
                  
                  Obx(() {
                    final gender = userController.userData['gender'] ?? '-';
                    return _buildInfoCard(
                      icon: gender == 'male' ? 'assets/icons/male.png' : 'assets/icons/female.png',
                      title: l10n.gender,
                      value: gender.toString().capitalize ?? '-',
                      onTap: () => _showGenderDialog(),
                    );
                  }),
                  const SizedBox(height: 12),
                  
                  Obx(() {
                    final stepsGoal = healthProvider.stepsGoal;
                    return _buildInfoCard(
                      icon: 'assets/icons/steps.png',
                      title: l10n.dailyStepsGoal,
                      value: '$stepsGoal ${l10n.steps}',
                      onTap: () => _showEditDialog(l10n.dailyStepsGoal, 'stepsGoal', stepsGoal),
                    );
                  }),
                  const SizedBox(height: 12),
                  
                  // Add Burned Calories Toggle
                  Obx(() {
                    final addBurnedCalories = userController.userData['addBurnedCaloriesToGoal'] ?? false;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/icons/apple.png', width: 24, height: 24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              l10n.addBurnedCaloriesToGoal,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.black,
                              ),
                            ),
                          ),
                          CupertinoSwitch(
                            activeColor: CupertinoColors.black,
                            value: addBurnedCalories,
                            onChanged: (value) {
                              _updateUserField('addBurnedCaloriesToGoal', value);
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 40),
                  
                  const SizedBox(height: 20),
                  
                  // Language Section
                  Text(
                    l10n.language,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Language Selection Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: LanguageProvider.supportedLanguages.entries
                          .map((entry) => _buildLanguageOption(
                                context,
                                entry.key,
                                entry.value,
                              ))
                          .toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Other Settings Section
                  Text(
                    l10n.settings,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Settings Cards
                  _buildSettingsCard(
                    icon: CupertinoIcons.person,
                    title: l10n.account,
                    subtitle: l10n.manageYourProfileAndAccountSettings,
                    onTap: () {
                      // TODO: Navigate to account settings
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSettingsCard(
                    icon: CupertinoIcons.heart,
                    title: l10n.healthTracking,
                    subtitle: l10n.viewYourHealthConsistencyAndProgress,
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => HealthConsistencyScreen(
                            themeProvider: widget.themeProvider,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSettingsCard(
                    icon: CupertinoIcons.bell,
                    title: l10n.notifications,
                    subtitle: l10n.configureYourNotificationPreferences,
                    onTap: () {
                      // TODO: Navigate to notification settings
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSettingsCard(
                    icon: CupertinoIcons.info,
                    title: l10n.about,
                    subtitle: l10n.appVersionAndInformation,
                    onTap: () {
                      // TODO: Navigate to about page
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 24, height: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.pencil,
              color: CupertinoColors.systemGrey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(String currentName) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController controller = TextEditingController(text: currentName);
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(l10n.editName),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CupertinoTextField(
            controller: controller,
            placeholder: l10n.enterYourName,
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
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
                  widget.themeProvider,
                  widget.languageProvider,
                );
              }
              Navigator.of(context).pop();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String fieldName, String fieldKey, dynamic currentValue) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController controller = TextEditingController(
      text: currentValue?.toString() ?? '',
    );
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('${l10n.editName} $fieldName'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Enter $fieldName',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              final valueText = controller.text.trim();
              if (valueText.isNotEmpty) {
                final numValue = num.tryParse(valueText);
                if (numValue != null) {
                  if (fieldKey == 'stepsGoal') {
                    healthProvider.setStepsGoal(numValue.toInt());
                  } else {
                    await _updateUserField(fieldKey, numValue);
                  }
                }
              }
              Navigator.of(context).pop();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showGenderDialog() {
    final l10n = AppLocalizations.of(context)!;
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(l10n.selectGender),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                await _updateUserField('gender', 'male');
                Navigator.of(context).pop();
              },
              child: Text(l10n.male),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                await _updateUserField('gender', 'female');
                Navigator.of(context).pop();
              },
              child: Text(l10n.female),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String languageCode, String languageName) {
    final isSelected = widget.languageProvider.currentLocale.languageCode == languageCode;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.languageProvider.changeLanguage(languageCode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
            ? CupertinoColors.systemBlue.withOpacity(0.1)
            : CupertinoColors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
            ? Border.all(color: CupertinoColors.systemBlue, width: 1)
            : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.black,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                CupertinoIcons.check_mark,
                color: CupertinoColors.systemBlue,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: CupertinoColors.systemGrey,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey3,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

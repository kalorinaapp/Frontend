import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;
import '../../controller/onboarding.controller.dart';

class ReferralPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  final String userName;
  
  const ReferralPage({
    super.key, 
    required this.themeProvider,
    required this.userName,
  });

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _referralController = TextEditingController();
  final FocusNode _referralFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation when page loads
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _referralController.dispose();
    _referralFocusNode.dispose();
    super.dispose();
  }

  void _continue() {
    // Process referral code if provided and continue to next onboarding page
    final controller = Get.find<OnboardingController>();
    final String referralCode = _referralController.text.trim();

    if (referralCode.isNotEmpty) {
      controller.setStringData('referral_code', referralCode);
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Advance onboarding just like the global "Continue" button
    controller.goToNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: ThemeHelper.background,
          child: GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside
              FocusScope.of(context).unfocus();
            },
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    
                    // Title
                    Text(
                      l10n.enterReferralCode,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelper.textPrimary,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      l10n.notRequired,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: ThemeHelper.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 120),
                    
                    // Referral code input container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: ThemeHelper.cardBackground,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoTextField(
                              controller: _referralController,
                              focusNode: _referralFocusNode,
                              placeholder: l10n.influencerCode,
                              style: TextStyle(
                                fontSize: 16,
                                color: ThemeHelper.textPrimary,
                                fontWeight: FontWeight.normal,
                              ),
                              placeholderStyle: TextStyle(
                                fontSize: 16,
                                color: ThemeHelper.textSecondary,
                                fontWeight: FontWeight.normal,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: null,
                              ),
                              textCapitalization: TextCapitalization.characters,
                              autocorrect: false,
                              onChanged: (value) {
                                setState(() {
                                  // Trigger rebuild to update button state
                                });
                              },
                            ),
                          ),
                          // Submit button
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: _referralController.text.trim().isNotEmpty 
                                ? CupertinoColors.black 
                                : CupertinoColors.systemGrey2,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              onPressed: _continue,
                              child: Text(
                                l10n.confirm,
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/icons/check.png', width: 16, height: 16),
                        const SizedBox(width: 12),
                        Text(
                          l10n.applied,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: ThemeHelper.textSecondary,
                          ),
                        ),
                      ],
                    )
                    
                   
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 
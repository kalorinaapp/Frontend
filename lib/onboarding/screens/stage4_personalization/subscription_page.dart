import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import '../../../providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;
import '../../../utils/theme_helper.dart' show ThemeHelper;

class SubscriptionPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  final String userName;

  const SubscriptionPage({
    super.key,
    required this.themeProvider,
    required this.userName,
  });

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  int _selectedPlan = 0; // 0 = Yearly, 1 = Monthly

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

    // Start animation
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _startTrial() {
    HapticFeedback.mediumImpact();
    // Handle subscription logic here
    Navigator.of(context).pushReplacementNamed('/main');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemBackground,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: CupertinoColors.systemBackground,
            border: null,
            leading: GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                // _previousPage();
                              },
                              child: SvgPicture.asset(
                                color: ThemeHelper.textPrimary,
                                'assets/icons/back.svg',
                                width: 20,
                                height: 20,
                              ),
                            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Show different content based on selected plan
                    if (_selectedPlan == 0) ...[
                      const SizedBox(height: 20),
                      
                      // Main title
                      Text(
                        l10n.pricingTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Day timeline cards
                      _buildDayCard(
                        day: l10n.day1,
                        title: l10n.day1Title,
                        description: l10n.day1Description,
                        icon: CupertinoIcons.shield,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildDayCard(
                        day: l10n.day2,
                        title: l10n.day2Title,
                        description: l10n.day2Description,
                        icon: CupertinoIcons.bell,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildDayCard(
                        day: l10n.day3,
                        title: l10n.day3Title,
                        description: l10n.day3Description,
                        icon: CupertinoIcons.sparkles,
                      ),
                      
                      const SizedBox(height: 30),
                    ] else ...[
                      const SizedBox(height: 20),
                      
                      // Benefits content for Monthly plan
                      _buildBenefitsContent(l10n),
                      
                      const SizedBox(height: 40),
                    ],
                    
                    // Subscription options
                    _buildSubscriptionOption(
                      title: l10n.yearlyPlan,
                      subtitle: l10n.yearlyPrice,
                      isSelected: _selectedPlan == 0,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedPlan = 0;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildSubscriptionOption(
                      title: l10n.monthlyPlan,
                      subtitle: '',
                      isSelected: _selectedPlan == 1,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedPlan = 1;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Start trial button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: CupertinoColors.black,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _startTrial,
                        child: Text(
                          l10n.startTrialButton,
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Cancel anytime text
                    Text(
                      l10n.cancelAnytime,
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayCard({
    required String day,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGrey4,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Icon placeholder for SVG
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: CupertinoColors.systemGrey4,
                width: 1,
              ),
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                // Placeholder for SVG - can be replaced with SvgPicture.asset later
                child: Icon(
                  icon,
                  color: CupertinoColors.systemGrey,
                  size: 14,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemGrey,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? CupertinoColors.black 
              : CupertinoColors.systemGrey5,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
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
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Selection indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected 
                  ? CupertinoColors.black 
                  : CupertinoColors.systemGrey4,
                shape: BoxShape.circle,
              ),
              child: isSelected
                ? const Icon(
                    CupertinoIcons.checkmark,
                    color: CupertinoColors.white,
                    size: 12,
                  )
                : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsContent(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 20),
        
        // Main title
        Text(
          l10n.smarterWayTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.black,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 40),
        
        // Benefits timeline
        _buildBenefitSection(
          title: l10n.noCalorieMath,
          description: l10n.noCalorieMathDesc,
          showLine: true,
        ),
        
        const SizedBox(height: 30),
        
        _buildBenefitSection(
          title: l10n.scanTrackDone,
          description: l10n.scanTrackDoneDesc,
          showLine: true,
        ),
        
        const SizedBox(height: 30),
        
        _buildBenefitSection(
          title: l10n.stayOnTopEffortlessly,
          description: l10n.stayOnTopEffortlesslyDesc,
          showLine: false,
        ),
      ],
    );
  }

  Widget _buildBenefitSection({
    required String title,
    required String description,
    required bool showLine,
  }) {
    return Column(
      children: [
        // Title
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.black,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 6),
        
        // Description
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        
        // Vertical line
        if (showLine) ...[
          const SizedBox(height: 20),
          Container(
            width: 2,
            height: 30,
            color: CupertinoColors.black,
          ),
        ],
      ],
    );
  }
}

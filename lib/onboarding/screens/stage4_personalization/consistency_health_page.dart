// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';

class ConsistencyHealthPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const ConsistencyHealthPage({super.key, required this.themeProvider});

  @override
  State<ConsistencyHealthPage> createState() => _ConsistencyHealthPageState();
}

class _ConsistencyHealthPageState extends State<ConsistencyHealthPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 393,
      height: 852,
      decoration: BoxDecoration(color: ThemeHelper.background),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            
            // Main Title
            SizedBox(
              width: 320,
              child: Text(
                l10n.consistencyBuildsHealth,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 30,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Descriptive Text
            SizedBox(
              width: 336,
              child: Text(
                l10n.everydayLogFireReflect,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeHelper.textSecondary,
                  fontSize: 16,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Fire streak visualization with flow of opacity
            Container(
              width: 300,
              height: 45,
              decoration: ShapeDecoration(
                color: ThemeHelper.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                shadows: [
                  BoxShadow(
                    color: ThemeHelper.isLightMode
                        ? const Color(0x33000000)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: 3,
                    offset: const Offset(0, 0),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // First 4 fires - full opacity (active streak)
                    _buildFireIcon(1.0), // Day 1 - full opacity
                    _buildFireIcon(1.0), // Day 2 - full opacity
                    _buildFireIcon(1.0), // Day 3 - full opacity
                    _buildFireIcon(1.0), // Day 4 - full opacity
                    
                    // Last 3 fires - decreasing opacity (inactive/future)
                    _buildFireIcon(0.3), // Day 5 - faded
                    _buildFireIcon(0.2), // Day 6 - more faded
                    _buildFireIcon(0.1), // Day 7 - most faded
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Statistics Card
            Container(
              width: 251,
              height: 160, // Increased height to prevent overflow
              decoration: ShapeDecoration(
                color: ThemeHelper.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                shadows: [
                  BoxShadow(
                    color: ThemeHelper.isLightMode
                        ? const Color(0x33000000)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: 3,
                    offset: const Offset(0, 0),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Card Title
                    SizedBox(
                      width: 234,
                      child: Text(
                        l10n.longLastingHealthEffects,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ThemeHelper.textPrimary,
                          fontSize: 18,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Statistics Text with Rich formatting
                    SizedBox(
                      width: 216,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: l10n.ninetyPercent,
                              style: TextStyle(
                                color: ThemeHelper.textPrimary,
                                fontSize: 11,
                                fontFamily: 'Instrument Sans',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: l10n.usersStayConsistentMaintainWeight,
                              style: TextStyle(
                                color: ThemeHelper.textPrimary,
                                fontSize: 11,
                                fontFamily: 'Instrument Sans',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: l10n.twelveMonthsLater,
                              style: TextStyle(
                                color: ThemeHelper.textPrimary,
                                fontSize: 11,
                                fontFamily: 'Instrument Sans',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: '.',
                              style: TextStyle(
                                color: ThemeHelper.textPrimary,
                                fontSize: 11,
                                fontFamily: 'Instrument Sans',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFireIcon(double opacity) {
    return Container(
      width: 40,
      height: 40,
      child: Opacity(
        opacity: opacity,
        child: Image.asset(
          'assets/icons/flame.png',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../providers/theme_provider.dart' show ThemeProvider;
import '../../screens/paywall_screen.dart' show PaywallScreen;
import '../../utils/theme_helper.dart';

class HowItWorksPage extends StatelessWidget {
  final bool? postSignUp;
  final ThemeProvider themeProvider;

  const HowItWorksPage({
    super.key,
    this.postSignUp,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ThemeHelper.background,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24, 
            vertical: postSignUp == true ? 60 : 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                'How Kalorina\'s unique\napproach works',
                style: ThemeHelper.textStyleWithColorAndSize(
                  ThemeHelper.headline,
                  ThemeHelper.textPrimary,
                  28,
                ).copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
      
              const SizedBox(height: 80),
      
              // Step 1: Scan
              _buildStep(
                index: 0,
                label: 'Scan',
                imagePath: 'assets/images/scan.png',
                arrowPath: null,
                rotation: -15, // Rotated counterclockwise
                labelAlignment: Alignment.topLeft,
                labelOffset: const Offset(40, -56),
              ),
      
              const SizedBox(height: 20),
      
              // Step 2: Analyze
              _buildStep(
                index: 1,
                label: 'Analyze',
                imagePath: 'assets/images/analyze.png',
                arrowPath: 'assets/icons/arrow_one.png',
                rotation: 8, // Slight rotation to the right
                labelAlignment: Alignment.topRight,
                labelOffset: const Offset(-40, -48),
              ),
      
              const SizedBox(height: 20),
      
              // Step 3: Track
              _buildStep(
                index: 2,
                label: 'Track',
                imagePath: 'assets/images/track.png',
                arrowPath: 'assets/icons/arrow_two.png',
                rotation: 0, // No rotation
                labelAlignment: Alignment.topLeft,
                labelOffset: const Offset(80, -40), // Positioned next to arrow
              ),
      
              const SizedBox(height: 40),
              
              // Post signup design
              if (postSignUp == true) ...[
                const SizedBox(height: 40),
                _buildPostSignUpDesign(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    int? index,
    required String label,
    required String? imagePath,
    required String? arrowPath,
    required double rotation,
    required Alignment labelAlignment,
    required Offset labelOffset,
  }) {
    return Column(
      children: [
        // Arrow (only show if arrowPath is provided)
        if (arrowPath != null) ...[
          SizedBox(
            width: double.infinity,
            height: 60,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Image.asset(
                  arrowPath,
                  width: 60,
                  height: 50,
                
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
        ],

        // Image and Label Stack
        SizedBox(
          height:  index == 0 ? 200 : 100, // Taller for scan image
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath ?? '',
                  // fit: index == 0 ? BoxFit.contain : BoxFit.cover,
                ),
              ),


              // Label positioned based on alignment
              Positioned.fill(
                child: Align(
                  alignment: labelAlignment,
                  child: Transform.translate(
                    offset: labelOffset,
                    child: Transform.rotate(
                      angle: rotation * 3.14159 / 180, // Convert degrees to radians
                      child: Text(
                        label,
                        style: ThemeHelper.textStyleWithColorAndSize(
                          ThemeHelper.headline,
                          ThemeHelper.textPrimary,
                          28, // Smaller font size
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostSignUpDesign(BuildContext context) {
    return Column(
      children: [
        // Notification reminder text with bell icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Image.asset('assets/images/notifications.png', width: 30, height: 30, color: ThemeHelper.textPrimary.withOpacity(0.3),),
            const SizedBox(width: 12),
            SizedBox(
              width: 157,
              child: Text(
                'We\'ll remind you before your free trial ends.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 12,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 30),
        
        // Main CTA Button
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => PaywallScreen(themeProvider: themeProvider),
              ),
            );
          },
          child: Container(
            width: 290,
            height: 50,
            decoration: ShapeDecoration(
              color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                'Probaj za BESPLATNO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Disclaimer text
        SizedBox(
          width: 293,
          child: Text(
            'Probaj za €0.00 - Nema naplate ako otkažeš na vrijeme. Otkaži u bilo kojem trenutku.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontSize: 12,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}


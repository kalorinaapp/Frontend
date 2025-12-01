import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../../utils/page_animations.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;

class SupportMotivationPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const SupportMotivationPage({super.key, required this.themeProvider});

  @override
  State<SupportMotivationPage> createState() => _SupportMotivationPageState();
}

class _SupportMotivationPageState extends State<SupportMotivationPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late AnimationController _animationController;
  late Animation<double> _titleAnimation;
  late Animation<double> _imageAnimation;
  late Animation<double> _messageAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _titleAnimation = PageAnimations.createTitleAnimation(_animationController);
    
    _imageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _messageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final localizations = AppLocalizations.of(context)!;

    return Container(
      width: 393,
      height: 852,
      decoration: BoxDecoration(color: ThemeHelper.background),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            
            // Title
            PageAnimations.animatedTitle(
              animation: _titleAnimation,
              child: SizedBox(
                width: 268,
                child: Text(
                  localizations.wereHereForYou,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemeHelper.textPrimary,
                    fontSize: 30,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Central illustration (finger heart gesture)
            PageAnimations.animatedContent(
              animation: _imageAnimation,
              child: Image.asset('assets/images/hands.png', width: 200, height: 200,),
            ),
            
            const SizedBox(height: 60),
            
            // Message container
            PageAnimations.animatedContent(
              animation: _messageAnimation,
              child: Container(
                width: 299,
                height: 112,
                decoration: ShapeDecoration(
                  color: ThemeHelper.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(13)),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 275,
                    child: Text(
                      localizations.journeySupportMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ThemeHelper.textSecondary,
                        fontSize: 16,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
           
          ],
        ),
      ),
    );
  }
}

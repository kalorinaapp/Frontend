import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;

class SupportMotivationPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const SupportMotivationPage({super.key, required this.themeProvider});

  @override
  State<SupportMotivationPage> createState() => _SupportMotivationPageState();
}

class _SupportMotivationPageState extends State<SupportMotivationPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
            SizedBox(
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
            
            const SizedBox(height: 60),
            
            // Central illustration (finger heart gesture)
            Image.asset('assets/images/hands.png', width: 200, height: 200, color: ThemeHelper.textPrimary,),
            
            const SizedBox(height: 60),
            
            // Message container
            Container(
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
            
           
          ],
        ),
      ),
    );
  }
}

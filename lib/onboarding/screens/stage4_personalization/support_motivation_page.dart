import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../providers/theme_provider.dart';

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

    return Container(
      width: 393,
      height: 852,
      decoration: const BoxDecoration(color: Colors.white),
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
                'We\'re here for you!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF1E1822),
                  fontSize: 30,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Central illustration (finger heart gesture)
            Image.asset('assets/images/hands.png', width: 200, height: 200),
            
            const SizedBox(height: 60),
            
            // Message container
            Container(
              width: 299,
              height: 112,
              decoration: const ShapeDecoration(
                color: Color(0xFFF8F7FC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(13)),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 275,
                  child: Text(
                    'The journey to your goal might be challenging at times, but we\'re here to support you every step of the way. You won\'t have to face it alone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xCC1E1822),
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

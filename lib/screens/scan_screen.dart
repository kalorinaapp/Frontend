import 'package:flutter/cupertino.dart';
import '../providers/theme_provider.dart';
import '../utils/theme_helper.dart';
import '../camera/scan_page.dart';

class ScanScreen extends StatelessWidget {
  final ThemeProvider themeProvider;

  const ScanScreen({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
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
              'Scan Food',
              style: ThemeHelper.textStyleWithColor(
                ThemeHelper.headline,
                ThemeHelper.textPrimary,
              ),
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.camera,
                    size: 80,
                    color: ThemeHelper.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scan Food',
                    style: ThemeHelper.textStyleWithColor(
                      ThemeHelper.title2,
                      ThemeHelper.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Point your camera at food to get\nnutritional information',
                    style: ThemeHelper.textStyleWithColor(
                      ThemeHelper.body1,
                      ThemeHelper.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CupertinoButton.filled(
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const ScanPage(),
                        ),
                      );
                    },
                    child: const Text('Start Scanning'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

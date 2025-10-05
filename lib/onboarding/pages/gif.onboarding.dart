import 'package:calorie_ai_app/providers/theme_provider.dart';
import 'package:flutter/cupertino.dart';

class GIFScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  const GIFScreen({super.key, required this.themeProvider});

  @override
  State<GIFScreen> createState() => _GIFScreenState();
}

class _GIFScreenState extends State<GIFScreen> {
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("I will be adding a tutorial gif showcasing how the app is used here once the app is finished. Implement this flow in the onboarding flow.")
      ],
    ),);
  }
}
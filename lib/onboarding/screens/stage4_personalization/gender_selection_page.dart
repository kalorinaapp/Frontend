import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class GenderSelectionPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const GenderSelectionPage({super.key, required this.themeProvider});

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {
  late OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Title
          Center(
            child: Text(
              'Odaberi svoj Spol',
              style: ThemeHelper.title1.copyWith(
                color: CupertinoColors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Informational message box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  '👉',
                  style: TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Odaberite spol kojem odgovara fiziologija vašeg tijela za precizno praćenje kalorija',
                    style: ThemeHelper.caption1.copyWith(
                      fontSize: 13,
                      color: CupertinoColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 120),
          
          // Gender selection buttons
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Male button
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('selected_gender', 'male');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('selected_gender') == 'male' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('selected_gender') == 'male'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Muškarac',
                    style: ThemeHelper.headline.copyWith(
                      color: _controller.getStringData('selected_gender') == 'male'
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
              
              const SizedBox(height: 16),
              
              // Female button
              Obx(() => GestureDetector(
                onTap: () {
                  _controller.setStringData('selected_gender', 'female');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: _controller.getStringData('selected_gender') == 'female' 
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    border: Border.all(
                      color: _controller.getStringData('selected_gender') == 'female'
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey4,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Žena',
                    style: ThemeHelper.headline.copyWith(
                      color: _controller.getStringData('selected_gender') == 'female'
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

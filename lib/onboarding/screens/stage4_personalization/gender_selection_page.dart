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
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
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
                  style: ThemeHelper.textStyleWithColor(
                    ThemeHelper.title1,
                    ThemeHelper.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Informational message box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeHelper.cardBackground,
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
                        style: ThemeHelper.textStyleWithColor(
                          ThemeHelper.caption1.copyWith(fontSize: 13),
                          ThemeHelper.textPrimary,
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
                            ? ThemeHelper.textPrimary
                            : ThemeHelper.background,
                        border: Border.all(
                          color: _controller.getStringData('selected_gender') == 'male'
                              ? ThemeHelper.textPrimary
                              : ThemeHelper.divider,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Leading icon
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Image.asset("assets/icons/male.png", height: 24, width: 24, color: _controller.getStringData('selected_gender') == 'male' ? ThemeHelper.background : ThemeHelper.textPrimary,),
                          ),
                          const SizedBox(width: 8.0,),

                          // Centered label
                          Expanded(
                            child: Center(
                              child: Text(
                                'Muškarac',
                                style: ThemeHelper.textStyleWithColor(
                                  ThemeHelper.headline,
                                  _controller.getStringData('selected_gender') == 'male'
                                      ? ThemeHelper.background
                                      : ThemeHelper.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          // Trailing spacer to balance the leading icon width
                          const SizedBox(width: 32),
                        ],
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
                            ? ThemeHelper.textPrimary
                            : ThemeHelper.background,
                        border: Border.all(
                          color: _controller.getStringData('selected_gender') == 'female'
                              ? ThemeHelper.textPrimary
                              : ThemeHelper.divider,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Leading icon
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Image.asset("assets/icons/female.png", height: 24, width: 24, color: _controller.getStringData('selected_gender') == 'female' ? ThemeHelper.background : ThemeHelper.textPrimary,),
                          ),
                          const SizedBox(width: 8.0,),

                          // Centered label
                          Expanded(
                            child: Center(
                              child: Text(
                                'Žena',
                                style: ThemeHelper.textStyleWithColor(
                                  ThemeHelper.headline,
                                  _controller.getStringData('selected_gender') == 'female'
                                      ? ThemeHelper.background
                                      : ThemeHelper.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          // Trailing spacer to balance the leading icon width
                          const SizedBox(width: 32),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

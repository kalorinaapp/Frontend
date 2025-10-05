import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class HearAboutUsPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const HearAboutUsPage({super.key, required this.themeProvider});

  @override
  State<HearAboutUsPage> createState() => _HearAboutUsPageState();
}

class _HearAboutUsPageState extends State<HearAboutUsPage> {
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Title
            Center(
              child: Text(
                'Gdje ste čuli za nas?',
                style: ThemeHelper.title3.copyWith(
                  color: CupertinoColors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Selection options
            Column(
              children: [
                // Option 1: Google Play
                Obx(() => GestureDetector(
                  onTap: () {
                    _controller.setStringData('hear_about_us', 'google_play');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _controller.getStringData('hear_about_us') == 'google_play' 
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                      border: Border.all(
                        color: _controller.getStringData('hear_about_us') == 'google_play'
                            ? CupertinoColors.black
                            : CupertinoColors.systemGrey4,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Image.asset('assets/images/PlayStore.png', width: 48, height: 48),
                        const SizedBox(width: 12),
                        Text(
                          'Google Play',
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('hear_about_us') == 'google_play'
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )),
                
                // Option 2: YouTube
                Obx(() => GestureDetector(
                  onTap: () {
                    _controller.setStringData('hear_about_us', 'youtube');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _controller.getStringData('hear_about_us') == 'youtube' 
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                      border: Border.all(
                        color: _controller.getStringData('hear_about_us') == 'youtube'
                            ? CupertinoColors.black
                            : CupertinoColors.systemGrey4,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Image.asset('assets/images/Youtube.png', width: 48, height: 48),
                        const SizedBox(width: 12),
                        Text(
                          'YouTube',
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('hear_about_us') == 'youtube'
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )),
                
                // Option 3: TikTok
                Obx(() => GestureDetector(
                  onTap: () {
                    _controller.setStringData('hear_about_us', 'tiktok');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _controller.getStringData('hear_about_us') == 'tiktok' 
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                      border: Border.all(
                        color: _controller.getStringData('hear_about_us') == 'tiktok'
                            ? CupertinoColors.black
                            : CupertinoColors.systemGrey4,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Image.asset('assets/images/Tiktok.png', width: 48, height: 48),
                        const SizedBox(width: 12),
                        Text(
                          'TikTok',
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('hear_about_us') == 'tiktok'
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )),
                

                
                // Option 5: Google
                Obx(() => GestureDetector(
                  onTap: () {
                    _controller.setStringData('hear_about_us', 'instagram');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _controller.getStringData('hear_about_us') == 'instagram' 
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                      border: Border.all(
                        color: _controller.getStringData('hear_about_us') == 'instagram'
                            ? CupertinoColors.black
                            : CupertinoColors.systemGrey4,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Image.asset('assets/images/Instagram.png', width: 48, height: 48),
                        const SizedBox(width: 12),
                        Text(
                          'Instagram',
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('hear_about_us') == 'instagram'
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )),
                
                // Option 6: Friends or Family
                Obx(() => GestureDetector(
                  onTap: () {
                    _controller.setStringData('hear_about_us', 'influencer');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _controller.getStringData('hear_about_us') == 'influencer' 
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                      border: Border.all(
                        color: _controller.getStringData('hear_about_us') == 'influencer'
                            ? CupertinoColors.black
                            : CupertinoColors.systemGrey4,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Image.asset('assets/images/Influencer.png', width: 48, height: 48),
                        const SizedBox(width: 12),
                        Text(
                            'Influencer',
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('hear_about_us') == 'influencer'
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )),
                
                // Option 7: Instagram
                Obx(() => GestureDetector(
                  onTap: () {
                    _controller.setStringData('hear_about_us', 'friends_family');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: _controller.getStringData('hear_about_us') == 'friends_family' 
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                      border: Border.all(
                        color: _controller.getStringData('hear_about_us') == 'friends_family'
                            ? CupertinoColors.black
                            : CupertinoColors.systemGrey4,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Image.asset('assets/images/Friends.png', width: 48, height: 48),
                        const SizedBox(width: 12),
                        Text(
                          'Friends or Family',
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('hear_about_us') == 'friends_family'
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )),

                const SizedBox(height: 16),

                                // Option 7: Instagram
                Obx(() => GestureDetector(
                  onTap: () {
                    _controller.setStringData('hear_about_us', 'other');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: _controller.getStringData('hear_about_us') == 'other' 
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                      border: Border.all(
                        color: _controller.getStringData('hear_about_us') == 'other'
                            ? CupertinoColors.black
                            : CupertinoColors.systemGrey4,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Image.asset('assets/images/Other.png', width: 48, height: 48),
                        const SizedBox(width: 12),
                        Text(
                          'Other',
                          style: ThemeHelper.headline.copyWith(
                            color: _controller.getStringData('hear_about_us') == 'other'
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )),

                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

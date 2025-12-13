
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart' show InAppReview;
import 'dart:async';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart' show OnboardingController;
import '../../../l10n/app_localizations.dart' show AppLocalizations;

class RatingPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  
  const RatingPage({Key? key, required this.themeProvider}) : super(key: key);

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage>
    with SingleTickerProviderStateMixin {

      late OnboardingController _controller;

      final InAppReview inAppReview = InAppReview.instance;
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  List<TestimonialCard> _getLocalizedReviews(AppLocalizations l10n) {
    return [
      TestimonialCard(
        name: l10n.testimonial1Name,
        review: l10n.testimonial1Review,
      ),
      TestimonialCard(
        name: l10n.testimonial2Name,
        review: l10n.testimonial2Review,
      ),
      TestimonialCard(
        name: l10n.testimonial3Name,
        review: l10n.testimonial3Review,
      ),
      TestimonialCard(
        name: l10n.testimonial4Name,
        review: l10n.testimonial4Review,
      ),
    ];
  }

  List<TestimonialCard> _duplicatedReviews(AppLocalizations l10n) {
    final reviews = _getLocalizedReviews(l10n);
    return [...reviews, ...reviews];
  }

  @override
  void initState() {
    _controller = Get.put(OnboardingController());

     WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controller.isDualButtonMode.value = false;
    });

    super.initState();
    

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      }
      _startAutoScroll();
    });

    Future.delayed(const Duration(seconds: 3), () {
      // Mark page as completed if you have similar functionality
      // controller.updatebuttonState();
    });
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients) {
        if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 100) {
          _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent / 2);
        } else {
          _scrollController.animateTo(
            _scrollController.offset + 1.0,
            duration: const Duration(milliseconds: 30),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: ThemeHelper.background,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    l10n.leaveUsReview,
                    textAlign: TextAlign.center,
                    style: ThemeHelper.textStyleWithColorAndSize(
                      ThemeHelper.title1,
                      ThemeHelper.textPrimary,
                      28,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                
                  // Centered image with rating design behind it
                  SizedBox(
                    height: 240,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        // Rating design background - positioned at top
                        Positioned(
                          top: 0,
                          child: Container(
                            width: 265,
                            height: 82,
                            decoration: ShapeDecoration(
                              color: !widget.themeProvider.isLightMode 
                                  ? const Color(0xFF2C2C2E)
                                  : const Color(0xFFF8F7FC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Rating number
                                Text(
                                  '4.8',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: ThemeHelper.textPrimary,
                                    fontSize: 22,
                                    fontFamily: 'Instrument Sans',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Stars
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    5,
                                    (index) => const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 2),
                                      child: Icon(
                                        CupertinoIcons.star_fill,
                                        color: Color(0xFFF4A261),
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Description text
                                SizedBox(
                                  width: 220,
                                  child: Text(
                                    '4.8 ${l10n.starsAcrossApps}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: ThemeHelper.textSecondary,
                                      fontSize: 13,
                                      fontFamily: 'Instrument Sans',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Reviewer image - positioned below, appears in front
                        Positioned(
                          top: 68,
                          child: SizedBox(
                            width: 210,
                            height: 300,
                            child: Image.asset(
                              "assets/images/reviewer_1.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 72),
                  // Headline under image
                  Text(
                    l10n.joinOver10000People,
                    textAlign: TextAlign.center,
                    style: ThemeHelper.textStyleWithColorAndSize(
                      ThemeHelper.title1,
                      ThemeHelper.textPrimary,
                      22,
                    ).copyWith(fontWeight: FontWeight.w700, height: 1.25),
                  ),
                  const SizedBox(height: 28),
                  // Auto-scrolling reviews list with fade masks
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 260,
                    child: Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _duplicatedReviews(l10n).length,
                          itemBuilder: (context, index) {
                            return _duplicatedReviews(l10n)[index];
                          },
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  ThemeHelper.background,
                                  ThemeHelper.background.withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  ThemeHelper.background,
                                  ThemeHelper.background.withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String imagePath;
  final double rating;
  final String name;
  final String review;

  const ReviewCard({
    Key? key,
    required this.imagePath,
    required this.rating,
    required this.name,
    required this.review,
  }) : super(key: key);

  Widget _buildStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(
        CupertinoIcons.star_fill,
        color: CupertinoColors.systemYellow,
        size: 16,
      ));
    }

    if (hasHalfStar) {
      stars.add(const Icon(
        CupertinoIcons.star_lefthalf_fill,
        color: CupertinoColors.systemYellow,
        size: 16,
      ));
    }

    while (stars.length < 5) {
      stars.add(Icon(
        CupertinoIcons.star,
        color: ThemeHelper.textSecondary.withOpacity(0.3),
        size: 16,
      ));
    }

    return Row(
      children: stars,
      mainAxisSize: MainAxisSize.min,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeHelper.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeHelper.divider,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer Image
          CircleAvatar(
            radius: 26,
            backgroundColor: ThemeHelper.background,
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(width: 24),
          // Reviewer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reviewer Name and Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: ThemeHelper.textStyleWithColorAndSize(
                          ThemeHelper.body1,
                          ThemeHelper.textPrimary,
                          16,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildStars(rating),
                  ],
                ),
                const SizedBox(height: 4),
                // Review Text
                Text(
                  review,
                  style: ThemeHelper.textStyleWithColorAndSize(
                    ThemeHelper.title2,
                    ThemeHelper.textSecondary,
                    14,
                  ).copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



 

class TestimonialCard extends StatelessWidget {
  final String name;
  final String review;

  const TestimonialCard({
    Key? key,
    required this.name,
    required this.review,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeHelper.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4A261),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.check_mark,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: ThemeHelper.textStyleWithColorAndSize(
                  ThemeHelper.body1,
                  ThemeHelper.textPrimary,
                  16,
                ).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review,
            style: ThemeHelper.textStyleWithColorAndSize(
              ThemeHelper.title2,
              ThemeHelper.textSecondary,
              14,
            ).copyWith(
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}


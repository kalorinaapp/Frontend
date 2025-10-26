
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart' show InAppReview;
import 'dart:async';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart' show OnboardingController;
import '../../../providers/language_provider.dart';
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
      late LanguageProvider _languageController;

      final InAppReview inAppReview = InAppReview.instance;
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  
  // Multi-language testimonials
  final Map<String, List<TestimonialCard>> _languageReviews = {
    'en': [
      const TestimonialCard(
        name: "James L.",
        review: "I never thought tracking calories could be this easy. I lost 15 pounds in less than 2 months.",
      ),
      const TestimonialCard(
        name: "Sarah M.",
        review: "The accuracy is incredible. Finally, I know exactly what I'm eating and feel so much better.",
      ),
      const TestimonialCard(
        name: "Michael R.",
        review: "Perfect for my daily routine. I scan my meals quickly and feel progress within a week.",
      ),
      const TestimonialCard(
        name: "Emma K.",
        review: "Simple, accurate, and useful. I track calories without hassle and feel lighter throughout the day.",
      ),
    ],
    'hr': [
      const TestimonialCard(
        name: "Ana M.",
        review: "Aplikacija je nevjerovatno precizna. Konačno znam koliko jedem i osjećam se puno bolje kroz dan.",
      ),
      const TestimonialCard(
        name: "Marko P.",
        review: "Od kad koristim aplikaciju, svjestan sam porcija. Jedem pametnije i imam više energije tokom dana.",
      ),
      const TestimonialCard(
        name: "Jelena K.",
        review: "Preciznost unosa me oduševila. Napokon imam kontrolu nad kalorijama bez stresa i brojanja.",
      ),
      const TestimonialCard(
        name: "Emir S.",
        review: "Savršeno za svakodnevnu rutinu. Brzo skeniram obroke i osjećam napredak već nakon sedmice.",
      ),
    ],
    'sr': [
      const TestimonialCard(
        name: "Лука Ј.",
        review: "Апликација је невероватно прецизна. Коначно знам колико једем и осећам се пуно боље кроз дан.",
      ),
      const TestimonialCard(
        name: "Марко П.",
        review: "Од кад користим апликацију, свестан сам порција. Једем паметније и имам више енергије током дана.",
      ),
      const TestimonialCard(
        name: "Јелена К.",
        review: "Прецизност уноса ме одушевила. Напокон имам контролу над калоријама без стреса и бројања.",
      ),
      const TestimonialCard(
        name: "Емир С.",
        review: "Савршено за свакодневну рутину. Брзо скенирам оброке и осећам напредак већ након седмице.",
      ),
    ],
    'mk': [
      const TestimonialCard(
        name: "Лука Ј.",
        review: "Апликацијата е неверојатно прецизна. Конечно знам колку јадам и се чувствувам многу подобро низ денот.",
      ),
      const TestimonialCard(
        name: "Марко П.",
        review: "Од кога ја користам апликацијата, свесен сум за порциите. Јадам паметно и имам повеќе енергија во текот на денот.",
      ),
      const TestimonialCard(
        name: "Јелена К.",
        review: "Прецизноста на внесувањето ме восхити. Конечно имам контрола над калориите без стрес и броење.",
      ),
      const TestimonialCard(
        name: "Емир С.",
        review: "Совршено за секојдневна рутина. Брзо ги скенирам оброците и чувствувам напредок веќе по една недела.",
      ),
    ],
    'bg': [
      const TestimonialCard(
        name: "Георги П.",
        review: "Приложението е невероятно точно. Най-накрая знам колко ям и се чувствам много по-добре през деня.",
      ),
      const TestimonialCard(
        name: "Марко П.",
        review: "Откакто използвам приложението, съм наясно с порциите. Ям по-умно и имам повече енергия през деня.",
      ),
      const TestimonialCard(
        name: "Елена К.",
        review: "Точността на въвеждането ме възхити. Най-накрая имам контрол върху калориите без стрес и броене.",
      ),
      const TestimonialCard(
        name: "Емир С.",
        review: "Перфектно за ежедневната рутина. Бързо сканирам ястията и чувствам напредък още след седмица.",
      ),
    ],
    'sl': [
      const TestimonialCard(
        name: "Luka J.",
        review: "Aplikacija je neverjetno natančna. Končno vem, koliko jem in se počutim veliko bolje skozi dan.",
      ),
      const TestimonialCard(
        name: "Marko P.",
        review: "Odkar uporabljam aplikacijo, sem seznanjen s porcijami. Jem pametneje in imam več energije čez dan.",
      ),
      const TestimonialCard(
        name: "Jelena K.",
        review: "Natančnost vnosa me je navdušila. Končno imam nadzor nad kalorijami brez stresa in štetja.",
      ),
      const TestimonialCard(
        name: "Emir S.",
        review: "Popolno za dnevno rutino. Hitro skeniram obroke in čutim napredek že po tednu.",
      ),
    ],
    'hu': [
      const TestimonialCard(
        name: "Bence J.",
        review: "Az alkalmazás hihetetlenül pontos. Végre tudom, mennyit eszem és sokkal jobban érzem magam a nap folyamán.",
      ),
      const TestimonialCard(
        name: "Márk P.",
        review: "Mióta használom az alkalmazást, tudatos vagyok az adagokkal. Okosabban eszem és több energiám van napközben.",
      ),
      const TestimonialCard(
        name: "Jelena K.",
        review: "A bevitelek pontossága lenyűgözött. Végre kontroll alatt tartom a kalóriákat stressz és számolás nélkül.",
      ),
      const TestimonialCard(
        name: "Emir S.",
        review: "Tökéletes a napi rutinomhoz. Gyorsan szkenneltem az ételeket és már egy hét után érzem a fejlődést.",
      ),
    ],
    'ro': [
      const TestimonialCard(
        name: "Andrei P.",
        review: "Aplicația este incredibil de precisă. În sfârșit știu cât mănânc și mă simt mult mai bine pe parcursul zilei.",
      ),
      const TestimonialCard(
        name: "Mihai P.",
        review: "De când folosesc aplicația, sunt conștient de porții. Mănânc mai inteligent și am mai multă energie pe parcursul zilei.",
      ),
      const TestimonialCard(
        name: "Elena K.",
        review: "Precizia introducerii m-a impresionat. În sfârșit am control asupra caloriilor fără stres și numărare.",
      ),
      const TestimonialCard(
        name: "Emir S.",
        review: "Perfect pentru rutina zilnică. Scanez rapid mesele și simt progresul deja după o săptămână.",
      ),
    ],
  };

  List<TestimonialCard> get _duplicatedReviews {
    final currentLanguage = _languageController.currentLocale.languageCode;
    final reviews = _languageReviews[currentLanguage] ?? _languageReviews['en']!;
    return [...reviews, ...reviews];
  }

  @override
  void initState() {
    _controller = Get.put(OnboardingController());
    _languageController = Get.find<LanguageProvider>();

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
                
                  // Centered image placeholder (will be provided by you)
                  SizedBox(
                    // width: 300,
                    // height: 300,
                    child: Image.asset(
                      "assets/images/reviewer_1.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                          itemCount: _duplicatedReviews.length,
                          itemBuilder: (context, index) {
                            return _duplicatedReviews[index];
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


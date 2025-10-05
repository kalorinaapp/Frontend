import 'package:flutter/cupertino.dart';
import '../../../providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart' show AppLocalizations;

class BenefitsContentPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  final String userName;

  const BenefitsContentPage({
    super.key,
    required this.themeProvider,
    required this.userName,
  });

  @override
  State<BenefitsContentPage> createState() => _BenefitsContentPageState();
}

class _BenefitsContentPageState extends State<BenefitsContentPage>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemBackground,
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    
                    // Main title
                    Text(
                      l10n.smarterWayTitle,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 80),
                    
                    // Benefits timeline
                    _buildBenefitSection(
                      title: l10n.noCalorieMath,
                      description: l10n.noCalorieMathDesc,
                      showLine: true,
                    ),
                    
                    const SizedBox(height: 60),
                    
                    _buildBenefitSection(
                      title: l10n.scanTrackDone,
                      description: l10n.scanTrackDoneDesc,
                      showLine: true,
                    ),
                    
                    const SizedBox(height: 60),
                    
                    _buildBenefitSection(
                      title: l10n.stayOnTopEffortlessly,
                      description: l10n.stayOnTopEffortlesslyDesc,
                      showLine: false,
                    ),
                    
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBenefitSection({
    required String title,
    required String description,
    required bool showLine,
  }) {
    return Column(
      children: [
        // Title
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.black,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // Description
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        
        // Vertical line
        if (showLine) ...[
          const SizedBox(height: 40),
          Container(
            width: 2,
            height: 60,
            color: CupertinoColors.black,
          ),
        ],
      ],
    );
  }
}

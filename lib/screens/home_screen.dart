import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../l10n/app_localizations.dart' show AppLocalizations;
import '../onboarding/screens/stage4_personalization/settings_page.dart' show SettingsPage;
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../utils/theme_helper.dart' show ThemeHelper;
import 'dashboard_screen.dart';
import 'log.screen.dart' show LogScreen;
import 'progress_screen.dart';
import '../camera/scan_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/home_screen_controller.dart';

class HomeScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  final LanguageProvider languageProvider;

  const HomeScreen({
    super.key, 
    required this.themeProvider,
    required this.languageProvider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeScreenController _controller;
  // Use GlobalKey to preserve dashboard state when switching tabs
  final GlobalKey _dashboardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Only register if not already registered (avoid duplicates)
    if (!Get.isRegistered<HomeScreenController>()) {
      _controller = Get.put(HomeScreenController());
    } else {
      _controller = Get.find<HomeScreenController>();
    }
  }

  @override
  void dispose() {
    Get.delete<HomeScreenController>();
    super.dispose();
  }

  Widget _buildDashboardScreen() {
    // Use Obx to reactively update props, but IndexedStack will preserve the widget state
    return Obx(() => DashboardScreen(
      key: _dashboardKey,
      themeProvider: widget.themeProvider,
      selectedImage: _controller.selectedImage.value,
      isAnalyzing: _controller.isAnalyzing.value,
      hasScanError: _controller.hasScanError.value,
      isLoadingInitialData: _controller.isLoadingInitialData.value,
      isLoadingMeals: _controller.isLoadingMeals.value,
      isLoadingProgress: _controller.isLoadingProgress.value,
      scanResult: _controller.scanResult.value,
      todayTotals: _controller.todayTotals.value,
      todayCreatedAt: _controller.todayCreatedAt.value,
      todayEntries: _controller.todayEntries.toList(),
      todayMeals: _controller.todayMeals.toList(),
      todayExercises: _controller.todayExercises.toList(),
      dailyProgress: _controller.dailyProgress.value,
      dailySummary: _controller.dailySummary.value,
      onRetryScan: () => _controller.retryScan(context),
      onCloseError: _controller.closeErrorCard,
    ));
  }

  void _navigateToScan() async {
    _controller.hideAddOptions();
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      CupertinoPageRoute(
        builder: (context) => const ScanPage(),
      ),
    );
    
    // Process the captured image like gallery upload
    if (result != null && result['imagePath'] != null) {
      final imagePath = result['imagePath'] as String;
      _controller.setSelectedImage(File(imagePath));
      _controller.setIsAnalyzing(true);
      // Refresh today totals after logging from camera
      _controller.fetchTodayTotals();
      
      // Send to backend for analysis
      await _controller.analyzeImage(imagePath, context);
    }
  }
  

  void _navigateToGallery() async {
    _controller.hideAddOptions();
    try {
      final XFile? image = await _controller.picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        _controller.setSelectedImage(File(image.path));
        _controller.setIsAnalyzing(true);
        // Refresh today totals after logging from gallery
        _controller.fetchTodayTotals();
        
        // Send to backend for analysis
        await _controller.analyzeImage(image.path, context);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // Center button (Add)
      _controller.showAddOptions();
      return;
    }
    final int newIndex = index > 2 ? index - 1 : index;
    if (newIndex != _controller.currentIndex.value) {
      HapticFeedback.lightImpact();
      _controller.setCurrentIndex(newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
        return Obx(() => Stack(
          children: [
            CupertinoPageScaffold(
              backgroundColor: ThemeHelper.background,
              child: Stack(
                children: [
                  // Main content - Use IndexedStack to preserve state when switching tabs
                  Positioned.fill(
                    child: Obx(() => IndexedStack(
                      index: _controller.currentIndex.value,
                      children: [
                        _buildDashboardScreen(),
                        LogScreen(
                          themeProvider: widget.themeProvider,
                          onExerciseLogged: () {
                            _controller.fetchTodayTotals();
                          },
                        ),
                        ProgressScreen(
                          themeProvider: widget.themeProvider, 
                          healthProvider: _controller.healthProvider,
                          onWeightLogged: _controller.refreshWeighInStatus,
                        ),
                        SettingsPage(
                          themeProvider: widget.themeProvider,
                        ),
                      ],
                    )),
                  ),
                  // Custom Bottom Navigation Bar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: ThemeHelper.cardBackground,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x19000000),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(
                              iconAsset: 'assets/icons/home.png',
                              label: l10n.home,
                              index: 0,
                              isActive: _controller.currentIndex.value == 0,
                            ),
                            _buildNavItem(
                              iconAsset: 'assets/icons/pencil.png',
                              label: l10n.log,
                              index: 1,
                              isActive: _controller.currentIndex.value == 1,
                            ),
                            // Center Add Button
                            GestureDetector(
                              onTap: () => _onTabTapped(2),
                              child: Container(
                                width: 37,
                                height: 37,
                                decoration: ShapeDecoration(
                                  color: ThemeHelper.textPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Icon(
                                  CupertinoIcons.add,
                                  color: ThemeHelper.background,
                                  size: 24,
                                ),
                              ),
                            ),
                            _buildNavItem(
                              iconAsset: 'assets/icons/graph.png',
                              label: l10n.progress,
                              index: 3,
                              isActive: _controller.currentIndex.value == 2,
                              showDot: _controller.isWeighInDueToday.value,
                            ),
                            _buildNavItem(
                              iconAsset: 'assets/icons/settings.png',
                              label: l10n.settings,
                              index: 4,
                              isActive: _controller.currentIndex.value == 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Add Options Modal
            if (_controller.showAddModal.value) _buildAddOptionsModal(),
          ],
        ));
      },
    );
  }

  Widget _buildAddOptionsModal() {
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: _controller.hideAddOptions,
      child: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: CupertinoColors.black.withOpacity(0.6),
              ),
            ),
          ),
          // Modal content
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // Prevent tap from bubbling up
              child: Container(
                margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildOptionCard(
                            imageAsset: "assets/icons/gallery.png",
                            title: l10n.gallery,
                            onTap: _navigateToGallery,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildOptionCard(
                            imageAsset: "assets/icons/camera.png",
                            title: l10n.scanFood,
                            onTap: _navigateToScan,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String imageAsset,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: ThemeHelper.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.textPrimary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imageAsset,
                width: 24,
                height: 24,
                color: widget.themeProvider.isLightMode ? null : Colors.white,
              ),
              if (title.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeHelper.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String iconAsset,
    required String label,
    required int index,
    required bool isActive,
    bool showDot = false,
  }) {
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  iconAsset,
                  width: 20,
                  height: 20,
                  color: isActive 
                      ? ThemeHelper.textPrimary 
                      : ThemeHelper.textSecondary,
                ),
                if (showDot)
                  Positioned(
                    right: -4,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive 
                    ? ThemeHelper.textPrimary 
                    : ThemeHelper.textSecondary,
                fontSize: 8,
                fontFamily: 'Instrument Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

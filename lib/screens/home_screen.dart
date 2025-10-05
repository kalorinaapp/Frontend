import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../l10n/app_localizations.dart' show AppLocalizations;
import '../onboarding/screens/stage4_personalization/settings_page.dart' show SettingsPage;
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import 'dashboard_screen.dart';
import 'log.screen.dart' show LogScreen;
import 'progress_screen.dart';
import '../camera/scan_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../constants/app_constants.dart';
import '../network/http_helper.dart';
import '../camera/scan_result_page.dart';
import '../services/meals_service.dart';
import '../services/progress_service.dart';

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
  final List<Widget> _screens = [];
  bool _showAddModal = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _scanResult;
  Map<String, int>? _todayTotals; // calories, protein, fats, carbs
  String? _todayCreatedAt;
  List<Map<String, dynamic>> _todayEntries = const [];
  List<Map<String, dynamic>> _todayMeals = const [];
  Map<String, dynamic>? _dailyProgress;

  @override
  void initState() {
    super.initState();
    _updateScreens();
    _fetchTodayTotals();
    _fetchDailyProgress();
  }

  void _updateScreens() {
    _screens.clear();
    _screens.addAll([
      DashboardScreen(
        themeProvider: widget.themeProvider,
        selectedImage: _selectedImage,
        isAnalyzing: _isAnalyzing,
        scanResult: _scanResult,
        todayTotals: _todayTotals,
        todayCreatedAt: _todayCreatedAt,
        todayEntries: _todayEntries,
        todayMeals: _todayMeals,
        dailyProgress: _dailyProgress,
      ),
      LogScreen(themeProvider: widget.themeProvider),
      ProgressScreen(themeProvider: widget.themeProvider), // Analytics
      SettingsPage(
        themeProvider: widget.themeProvider,
      ), // Settings
    ]);
  }

  void _showAddOptions() {
    setState(() {
      _showAddModal = true;
    });
  }

  void _hideAddOptions() {
    setState(() {
      _showAddModal = false;
    });
  }

  void _navigateToScan() {
    _hideAddOptions();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const ScanPage(),
      ),
    );
  }

  void _navigateToGallery() async {
    _hideAddOptions();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isAnalyzing = true;
        });
        _updateScreens();
        // Refresh today totals after logging from gallery
        _fetchTodayTotals();
        
        // Send to backend for analysis
        await _analyzeImage(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _analyzeImage(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Data = base64Encode(bytes);
      final payload = {
        'imageData': 'data:image/jpeg;base64,$base64Data',
        'mealType': 'lunch',
        'userId': AppConstants.userId,
      };
      
      final reqInfo = '${AppConstants.baseUrl}/api/scanning/scan-image';
      await multiPostAPINew(
        methodName: 'api/scanning/scan-image',
        param: payload,
        callback: (resp) async {
          Map<String, dynamic> result;
          try {
            result = jsonDecode(resp.response) as Map<String, dynamic>;
          } catch (_) {
            result = {'message': resp.response, 'status': resp.code};
          }
          
          if (!mounted) return;
          
          // Wait for percentage animation to complete (3 seconds)
          await Future.delayed(const Duration(seconds: 3));
          
          // Stop analyzing animation and store result
          setState(() {
            _isAnalyzing = false;
            _scanResult = result; // Store the scan result
          });
          _updateScreens();
          // Refresh today totals after scanning
          _fetchTodayTotals();
          
          // Navigate to results
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => ScanResultPage(
                result: result,
                imagePath: imagePath,
                rawResponse: resp.response,
                statusCode: resp.code,
                requestInfo: reqInfo,
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Analysis error: $e');
      setState(() {
        _isAnalyzing = false;
      });
      _updateScreens();
    }
  }

  Future<void> _fetchTodayTotals() async {
    try {
      final now = DateTime.now();
      final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final userId = AppConstants.userId;
      final service = MealsService();
      final decoded = await service.fetchTodayMeals(userId: userId, dateYYYYMMDD: dateStr, mealType: 'lunch');
      if (decoded != null) {
        debugPrint('GET today totals response: $decoded');
        final meals = ((decoded['meals'] as List?) ?? []).whereType<Map<String, dynamic>>().toList();
        if (meals.isNotEmpty) {
          final first = meals.first;
          setState(() {
            _todayTotals = {
              'totalCalories': (first['totalCalories'] ?? 0) as int,
              'totalProtein': (first['totalProtein'] ?? 0) as int,
              'totalCarbs': (first['totalCarbs'] ?? 0) as int,
              'totalFat': (first['totalFat'] ?? 0) as int,
            };
            _todayCreatedAt = first['createdAt'] as String?;
            _todayEntries = ((first['entries'] as List?) ?? [])
                .whereType<Map<String, dynamic>>()
                .toList();
            _todayMeals = meals;
          });
          _updateScreens();
        } else {
          setState(() {
            _todayTotals = null;
            _todayCreatedAt = null;
            _todayEntries = const [];
            _todayMeals = const [];
          });
          _updateScreens();
        }
      }
    } catch (e) {
      debugPrint('Error fetching today totals: $e');
    }
  }

  Future<void> _fetchDailyProgress() async {
    try {
      final now = DateTime.now();
      final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final service = ProgressService();
      final decoded = await service.fetchDailyProgress(dateYYYYMMDD: dateStr);
      if (decoded != null) {
        setState(() {
          _dailyProgress = decoded['progress'] as Map<String, dynamic>?;
        });
        _updateScreens();
      }
    } catch (e) {
      debugPrint('Error fetching daily progress: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, child) {
        return Stack(
          children: [
            CupertinoTabScaffold(
          backgroundColor: const Color(0xFFFAFAFA), // Very light accent background
          tabBar: CupertinoTabBar(
            height: 60,
            backgroundColor: CupertinoColors.white.withOpacity(0.9),
            activeColor: CupertinoColors.black,
            inactiveColor: CupertinoColors.systemGrey,
            border: Border(
              top: BorderSide(
                color: CupertinoColors.systemGrey5,
                width: 0.5,
              ),
            ),
            items: [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: l10n.home,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.pencil),
                label: l10n.log,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chart_bar),
                label: l10n.analytics,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                label: l10n.settings,
              ),
            ],
          ),
          tabBuilder: (context, index) {
            return Stack(
              children: [
                _screens[index],
                // Floating Action Button
                if (index == 0) // Only show on Home tab
                  Positioned(
                    right: 20,
                    bottom: 100, // Above the tab bar
                    child: GestureDetector(
                      onTap: _showAddOptions,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: CupertinoColors.black,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          CupertinoIcons.add,
                          color: CupertinoColors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
            ),
            // Add Options Modal
            if (_showAddModal) _buildAddOptionsModal(),
          ],
        );
      },
    );
  }

  Widget _buildAddOptionsModal() {
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: _hideAddOptions,
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
                // 2x2 Grid of options
                Row(
                  children: [
                    // Top Left - Database
                    // Expanded(
                    //   child: _buildOptionCard(
                    //     imageAsset: "assets/icons/bookmark.png",
                    //     title: l10n.database,
                    //     onTap: _navigateToDatabase,
                    //   ),
                    // ),
                    
                    // Top Right - Gallery
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
                // const SizedBox(height: 12),
                // Row(
                //   children: [
                //     // Bottom Left - Health
                //     Expanded(
                //       child: _buildOptionCard(
                //         imageAsset: "assets/icons/workout.png",
                //         title: l10n.workout,
                //         onTap: _navigateToHealth,
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     // Bottom Right - Scan Food
                //     Expanded(
                //       child: _buildOptionCard(
                //         imageAsset: "assets/icons/camera.png",
                //         title: l10n.scanFood,
                //         onTap: _navigateToScan,
                //       ),
                //     ),
                //   ],
                // ),
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
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
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
              ),
              if (title.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
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
}

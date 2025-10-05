import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_helper.dart';
import '../../controller/onboarding.controller.dart';

class ProgressMotivationPage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const ProgressMotivationPage({super.key, required this.themeProvider});

  @override
  State<ProgressMotivationPage> createState() => _ProgressMotivationPageState();
}

class _ProgressMotivationPageState extends State<ProgressMotivationPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
  }

  // Get current weight for categorization
  double _getCurrentWeight() {
    final int? currentWeightInt = _controller.getIntData('weight');
    final bool isLbs = _controller.getBoolData('weight_unit_lbs') ?? true;
    
    if (currentWeightInt != null) {
      double weight = currentWeightInt.toDouble();
      // Convert to kg for consistent categorization
      if (isLbs) {
        weight = weight * 0.453592; // Convert lbs to kg
      }
      return weight;
    }
    return 70.0; // Default fallback
  }

  // Get personalized title based on weight category
  String _getPersonalizedTitle() {
    final double currentWeight = _getCurrentWeight();
    
    if (currentWeight < 60) {
      return 'Imaš veliki potencijal ostvariti svoj cilj';
    } else if (currentWeight < 80) {
      return 'Imaš veliki potencijal ostvariti svoj cilj';
    } else if (currentWeight < 100) {
      return 'Tvoj put ka boljem zdravlju počinje sada';
    } else {
      return 'Napravio si prvi korak ka zdravijoj verziji sebe';
    }
  }

  // Get personalized tip cards based on weight category
  List<Map<String, String>> _getPersonalizedTips() {
    final double currentWeight = _getCurrentWeight();
    
    if (currentWeight < 60) {
      return [
        {'icon': 'assets/icons/track.png', 'text': 'Track your food and exercise'},
        {'icon': 'assets/icons/cutlery.png', 'text': 'Focus on nutrient-dense foods'},
        {'icon': 'assets/icons/apple.png', 'text': 'Maintain your healthy habits'},
        {'icon': 'assets/icons/up.png', 'text': 'Stay consistent, see results'},
      ];
    } else if (currentWeight < 80) {
      return [
        {'icon': 'assets/icons/track.png', 'text': 'Track your food and exercise'},
        {'icon': 'assets/icons/cutlery.png', 'text': 'Balance carbs, protein and fats'},
        {'icon': 'assets/icons/apple.png', 'text': 'Stick to your personalized plan'},
        {'icon': 'assets/icons/up.png', 'text': 'Stay consistent, see real results'},
      ];
    } else if (currentWeight < 100) {
      return [
        {'icon': 'assets/icons/track.png', 'text': 'Track your food and exercise'},
        {'icon': 'assets/icons/cutlery.png', 'text': 'Focus on whole, unprocessed foods'},
        {'icon': 'assets/icons/apple.png', 'text': 'Follow your personalized meal plan'},
        {'icon': 'assets/icons/up.png', 'text': 'Stay consistent, see real results'},
      ];
    } else {
      return [
        {'icon': 'assets/icons/track.png', 'text': 'Track your food and exercise'},
        {'icon': 'assets/icons/cutlery.png', 'text': 'Focus on portion control and nutrition'},
        {'icon': 'assets/icons/apple.png', 'text': 'Follow your personalized plan'},
        {'icon': 'assets/icons/up.png', 'text': 'Stay consistent, see real results'},
      ];
    }
  }

  // Get personalized progress description based on weight category
  String _getPersonalizedProgressDescription() {
    final double currentWeight = _getCurrentWeight();
    
    if (currentWeight < 60) {
      return 'During the first few days, your body is adapting and your metabolism is finding its rhythm. Based on Kalorina\'s data, by around day 10, fat burning starts to accelerate and your progress really starts to show!';
    } else if (currentWeight < 80) {
      return 'During the first few days, your body is adapting and your metabolism is finding its rhythm. Based on Kalorina\'s data, by around day 10, fat burning starts to accelerate and your progress really starts to show!';
    } else if (currentWeight < 100) {
      return 'Your body will need time to adjust to the new routine. During the first week, focus on building healthy habits. Based on Kalorina\'s data, by around day 10, you\'ll start seeing consistent progress!';
    } else {
      return 'Your journey to better health starts with small, consistent changes. During the first few days, your body is adapting. Based on Kalorina\'s data, by around day 10, you\'ll begin to see meaningful progress!';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            
            // Main title
            Text(
              _getPersonalizedTitle(),
              style: ThemeHelper.title1.copyWith(
                color: CupertinoColors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Tip cards
            ..._getPersonalizedTips().asMap().entries.map((entry) {
              final int index = entry.key;
              final Map<String, String> tip = entry.value;
              return Column(
                children: [
                  if (index > 0) const SizedBox(height: 16),
                  _buildTipCard(
                    icon: tip['icon']!,
                    text: tip['text']!,
                  ),
                ],
              );
            }).toList(),
            
            const SizedBox(height: 40),
            
            // Progress section
            Image.asset('assets/images/progress.png'),
         
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard({
    required String icon,
    required String text,
  }) {
    // Check if this is the apple icon to make it bigger
    final bool isAppleIcon = icon.contains('apple.png');
    
    return Container(
      width: 250,
      height: 36, // Increased from 30 to 35
      decoration: const ShapeDecoration(
        color: Color(0xFFF8F7FC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Image.asset(
              icon,
              width: isAppleIcon ? 20 : 16, // Apple icon is bigger
              height: isAppleIcon ? 20 : 16, // Apple icon is bigger
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Text
          Expanded(
            child: Text(
              text,
              style: ThemeHelper.body1.copyWith(
                color: CupertinoColors.black,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    return Column(
      children: [
        // Chart bars
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBar(height: 40, color: CupertinoColors.systemGrey4),
              _buildBar(height: 60, color: CupertinoColors.systemGrey4),
              _buildBar(height: 80, color: CupertinoColors.systemGrey4),
              _buildBar(height: 120, color: CupertinoColors.systemOrange),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Chart labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLabel('Day 3'),
            _buildLabel('Day 7'),
            _buildLabel('Day 10'),
            _buildLabel('Day 30'),
          ],
        ),
      ],
    );
  }

  Widget _buildBar({required double height, required Color color}) {
    return Container(
      width: 30,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: ThemeHelper.body1.copyWith(
        color: CupertinoColors.black,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}

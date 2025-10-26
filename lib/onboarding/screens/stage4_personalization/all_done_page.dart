import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../providers/theme_provider.dart';
import '../../controller/onboarding.controller.dart';
import '../../../utils/theme_helper.dart';

class AllDonePage extends StatelessWidget {
  final ThemeProvider themeProvider;
  
  const AllDonePage({Key? key, required this.themeProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, child) {
        return CupertinoPageScaffold(
          backgroundColor: ThemeHelper.background,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              width: 393,
              decoration: BoxDecoration(color: ThemeHelper.background),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with checkmark
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 35,
                          height: 32,
                          decoration: BoxDecoration(
                            color: ThemeHelper.textPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.check_mark,
                            color: ThemeHelper.background,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'All done',
                          style: TextStyle(
                            color: ThemeHelper.textPrimary,
                            fontSize: 28,
                            fontFamily: 'Instrument Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Weight cards section
                    _buildWeightCards(controller),
                    
                    SizedBox(height: 20),
                    
                    // Weight loss goal
                    _buildWeightLossGoal(controller),
                    
                    SizedBox(height: 32),
                    
                    // Daily plan section
                    _buildDailyPlanSection(controller),
                    
                    SizedBox(height: 32),
                    
                    // Did you know section
                    _buildDidYouKnowSection(),
                    
                    SizedBox(height: 32),
                    
                    // Sources section
                    _buildSourcesSection(),
                    
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeightCards(OnboardingController controller) {
    final currentWeight = _getCurrentWeight(controller);
    final targetWeight = _getTargetWeight(controller);
    final isMetric = controller.getBoolData('isMetric') ?? true;
    
    return Center(
      child: Column(
        children: [
          // My Weight card
          Container(
            width: 335,
            height: 72,
            decoration: ShapeDecoration(
              color: ThemeHelper.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              shadows: [
                BoxShadow(
                  color: ThemeHelper.isLightMode
                      ? const Color(0x3F000000)
                      : CupertinoColors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: Offset(0, 0),
                  spreadRadius: 1,
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Image.asset('assets/icons/export.png', width: 44, height: 44),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'My Weight',
                        style: TextStyle(
                          color: ThemeHelper.textSecondary,
                          fontSize: 10,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${currentWeight} ${isMetric ? 'kg' : 'lbs'}',
                        style: TextStyle(
                          color: ThemeHelper.textPrimary,
                          fontSize: 14,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 12),
          
          // Target Weight card
          Container(
            width: 335,
            height: 72,
            decoration: ShapeDecoration(
              color: ThemeHelper.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              shadows: [
                BoxShadow(
                  color: ThemeHelper.isLightMode
                      ? const Color(0x3F000000)
                      : CupertinoColors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: Offset(0, 0),
                  spreadRadius: 1,
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Image.asset('assets/icons/trophy.png', width: 44, height: 44),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Target Weight',
                        style: TextStyle(
                          color: ThemeHelper.textSecondary,
                          fontSize: 10,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${targetWeight} ${isMetric ? 'kg' : 'lbs'}',
                        style: TextStyle(
                          color: ThemeHelper.textPrimary,
                          fontSize: 14,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightLossGoal(OnboardingController controller) {
    final goal = controller.getStringData('goal') ?? 'maintain';
    final weightLossGoal = _getWeightLossGoal(controller);
    
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            goal == 'lose' ? 'You should lose:' : 
            goal == 'gain' ? 'You should gain:' : 
            'You should maintain:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeHelper.textPrimary,
              fontSize: 18,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: ShapeDecoration(
              color: ThemeHelper.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              weightLossGoal,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeHelper.textPrimary,
                fontSize: 14,
                fontFamily: 'Instrument Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPlanSection(OnboardingController controller) {
    final dailyCalories = _calculateDailyCalories(controller);
    final proteinGoal = _calculateProteinGoal(controller);
    final carbsGoal = _calculateCarbsGoal(controller);
    final fatGoal = _calculateFatGoal(controller);
    
    return Container(
      width: 377,
      padding: EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: ThemeHelper.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your daily plan is ready!',
            style: TextStyle(
              color: ThemeHelper.textPrimary,
              fontSize: 16,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You can adjust these anytime inside the app',
            style: TextStyle(
              color: ThemeHelper.textPrimary,
              fontSize: 12,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 20),
        
        // Main plan container - Dashboard style
        Container(
          margin: EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Calories Card (Dashboard style)
              Expanded(
                flex: 2,
                child: Container(
                  height: 264, // Match macro stack height (3×80 + 2×12)
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeHelper.background,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeHelper.isLightMode
                            ? CupertinoColors.black.withOpacity(0.05)
                            : CupertinoColors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'Calories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeHelper.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Progress ring with apple icon
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Progress circle
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value: 0.0, // 0/dailyCalories
                                  strokeWidth: 6,
                                  backgroundColor: ThemeHelper.divider,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ThemeHelper.textPrimary,
                                  ),
                                ),
                              ),
                              // Center apple icon
                              Image.asset('assets/icons/apple.png', width: 24, height: 24, color: ThemeHelper.textPrimary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Calories numbers
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '0',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeHelper.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: '/$dailyCalories',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeHelper.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Info message
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.info_circle,
                              size: 12,
                              color: ThemeHelper.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                '$dailyCalories Calories more to go!',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: ThemeHelper.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Right side - Macro Cards (stacked vertically)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildCompactMacroCard('Fats', 0, fatGoal, CupertinoColors.systemRed),
                    const SizedBox(height: 12),
                    _buildCompactMacroCard('Protein', 0, proteinGoal, CupertinoColors.systemBlue),
                    const SizedBox(height: 12),
                    _buildCompactMacroCard('Carbohydrates', 0, carbsGoal, CupertinoColors.systemOrange),
                  ],
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }


  Widget _buildDidYouKnowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Did you know',
          style: TextStyle(
            color: ThemeHelper.textPrimary,
            fontSize: 18,
            fontFamily: 'Instrument Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Taking a ',
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: '5–15 minute',
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ' walk after meals activates the soleus muscle in your calves and helps reduce blood sugar spikes:\n\n',
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: 'Direct glucose uptake:',
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ' The soleus muscle pulls sugar from the blood into the muscle without needing as much insulin.\n\n',
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: 'Improving insulin sensitivity:',
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ' Your body\'s insulin works more effectively after activity.\n\n',
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: 'Flattening spikes:',
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ' A walk after eating can lower the size and length of a blood sugar spike.\n\n',
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: 'Supporting long-term health:',
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ' Regular post-meal walking helps reduce risks linked to repeated blood sugar spikes, such as type 2 diabetes, insulin resistance, and cardiovascular disease.',
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sources',
          style: TextStyle(
            color: ThemeHelper.textPrimary,
            fontSize: 18,
            fontFamily: 'Instrument Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Our recommendations are inspired by leading nutrition research and guided by publicly available dietary guidelines, including work published by:\n\n',
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: 'The Dietary Guidelines for Americans\nHarvard T.H. Chan School of Public Health\nThe New England Journal of Medicine\nBritish Medical Journal',
                style: TextStyle(
                  color: const Color(0xFF5790F9),
                  fontSize: 12,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Calculation methods
  int _calculateDailyCalories(OnboardingController controller) {
    final weight = controller.getIntData('weight') ?? 70;
    final height = controller.getIntData('height') ?? 170;
    final age = controller.getIntData('age') ?? 25;
    final goal = controller.getStringData('goal') ?? 'maintain';
    final isMetric = controller.getBoolData('isMetric') ?? true;
    
    // Convert to metric if needed
    double weightKg = isMetric ? weight.toDouble() : weight * 0.453592;
    double heightCm = isMetric ? height.toDouble() : height * 2.54;
    
    // BMR calculation (Mifflin-St Jeor Equation)
    double bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    
    // TDEE (assuming moderate activity level)
    double tdee = bmr * 1.55;
    
    // Adjust based on goal
    switch (goal) {
      case 'lose':
        return (tdee - 500).round(); // 500 calorie deficit
      case 'maintain':
        return tdee.round();
      case 'gain':
        return (tdee + 500).round(); // 500 calorie surplus
      default:
        return tdee.round();
    }
  }

  int _calculateProteinGoal(OnboardingController controller) {
    final weight = controller.getIntData('weight') ?? 70;
    final isMetric = controller.getBoolData('isMetric') ?? true;
    double weightKg = isMetric ? weight.toDouble() : weight * 0.453592;
    return (weightKg * 1.6).round(); // 1.6g per kg
  }

  int _calculateCarbsGoal(OnboardingController controller) {
    final dailyCalories = _calculateDailyCalories(controller);
    return (dailyCalories * 0.45 / 4).round(); // 45% of calories from carbs
  }

  int _calculateFatGoal(OnboardingController controller) {
    final dailyCalories = _calculateDailyCalories(controller);
    return (dailyCalories * 0.25 / 9).round(); // 25% of calories from fat
  }

  // Helper methods for dynamic data
  int _getCurrentWeight(OnboardingController controller) {
    return controller.getIntData('weight') ?? 70;
  }

  int _getTargetWeight(OnboardingController controller) {
    // Try to get the desired weight from the desired weight page
    final desiredWeight = controller.getIntData('desiredWeight');
    if (desiredWeight != null) {
      return desiredWeight;
    }
    
    // Fallback to calculated target based on goal
    final currentWeight = _getCurrentWeight(controller);
    final goal = controller.getStringData('goal') ?? 'maintain';
    
    switch (goal) {
      case 'lose':
        return currentWeight - 5; // Default 5kg loss
      case 'gain':
        return currentWeight + 5; // Default 5kg gain
      case 'maintain':
      default:
        return currentWeight;
    }
  }

  String _getWeightLossGoal(OnboardingController controller) {
    final currentWeight = _getCurrentWeight(controller);
    final targetWeight = _getTargetWeight(controller);
    final weightLoss = currentWeight - targetWeight;
    final isMetric = controller.getBoolData('isMetric') ?? true;
    final unit = isMetric ? 'kg' : 'lbs';
    
    if (weightLoss > 0) {
      return '$weightLoss $unit by 18 october';
    } else if (weightLoss < 0) {
      return '${weightLoss.abs()} $unit to gain by 18 october';
    } else {
      return 'Maintain current weight';
    }
  }

  // Dashboard-style compact macro card
  Widget _buildCompactMacroCard(String label, int current, int total, Color color) {
    double progress = current / total;
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: ThemeHelper.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.isLightMode
                ? CupertinoColors.black.withOpacity(0.05)
                : CupertinoColors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress circle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress circle
                  CustomPaint(
                    size: Size(48, 48),
                    painter: CircleProgressPainter(
                      progress: progress,
                      color: color,
                      strokeWidth: 4,
                    ),
                  ),
                  // Center icon based on label
                  _getIconForMacro(label),
                ],
              ),
            ),
          ),
          // Table-like container with label and amount
          Expanded(
            child: Container(
              height: 80,
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ThemeHelper.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ThemeHelper.isLightMode
                        ? CupertinoColors.black.withOpacity(0.03)
                        : CupertinoColors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Label as table header with gray background
                  Container(
                    width: double.infinity,
                    height: 28,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: ThemeHelper.divider,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.textSecondary,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
                  // Values as table content with white background
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ThemeHelper.cardBackground,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$current',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeHelper.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: '/$total',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeHelper.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get icon for macro based on label
  Widget _getIconForMacro(String label) {
    if (label.toLowerCase().contains('carb')) {
      return Image.asset('assets/icons/carbs.png', width: 16, height: 16);
    } else if (label.toLowerCase().contains('protein')) {
      return Image.asset('assets/icons/drumstick.png', width: 16, height: 16);
    } else if (label.toLowerCase().contains('fat')) {
      return Image.asset('assets/icons/fat.png', width: 16, height: 16);
    } else {
      return Icon(CupertinoIcons.circle_fill, size: 16, color: CupertinoColors.systemGrey);
    }
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle (using divider color)
    final backgroundPaint = Paint()
      ..color = ThemeHelper.divider
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc (colored outline only)
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * 3.14159 * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is CircleProgressPainter &&
        (oldDelegate.progress != progress ||
            oldDelegate.color != color ||
            oldDelegate.strokeWidth != strokeWidth);
  }
}

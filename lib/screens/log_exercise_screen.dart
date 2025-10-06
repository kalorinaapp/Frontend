import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;

import '../providers/theme_provider.dart' show ThemeProvider;
import '../services/exercise_service.dart';

class LogExerciseScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  final int initialTabIndex;
  const LogExerciseScreen({
    super.key, 
    required this.themeProvider,
    this.initialTabIndex = 0,
  });

  @override
  State<LogExerciseScreen> createState() => _LogExerciseScreenState();
}

class _LogExerciseScreenState extends State<LogExerciseScreen> {
  late int _selectedTabIndex;
  
  final List<String> _tabs = ['Cardio', 'Weight Training', 'Describe', 'Direct Input'];
  
  // Cardio tab state
  int _selectedIntensity = 1; // 0: Low, 1: Medium, 2: High
  double _duration = 27.0; // Duration in minutes
  bool _isLoggingCardio = false;
  Map<String, dynamic>? _cardioResult;
  
  // Direct Input tab state
  final TextEditingController _caloriesController = TextEditingController();
  
  // Describe tab state
  final TextEditingController _describeController = TextEditingController();
  bool _isEstimating = false;
  Map<String, dynamic>? _estimate;
  
  final List<String> _intensityLabels = ['Low', 'Medium', 'High'];
  final List<String> _intensityDescriptions = [
    'Near sprinting, hard to sustain for long',
    'Steady run, manageable effort',
    'Brisk walk, comfortable breathing'
  ];
  final List<String> _weightIntensityDescriptions = [
    'Heavy weights, close to max effort',
    'Moderate weights, breaking a sweat',
    'Light weights, no sweat',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

  Widget _buildCardioResultCard() {
    final res = (_cardioResult?['log'] as Map<String, dynamic>?) ?? (_cardioResult ?? const {});
    final type = res['type']?.toString() ?? 'exercise';
    final duration = res['durationMinutes']?.toString() ?? '0';
    final intensity = res['intensity']?.toString() ?? '';
    final calories = res['caloriesBurned']?.toString() ?? (_cardioResult?['estimatedCalories']?.toString() ?? '0');
    final startedAt = res['startedAt']?.toString();

    String timeStr = '';
    if (startedAt != null && startedAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(startedAt);
        timeStr = '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1.5),
        boxShadow: [
          BoxShadow(color: CupertinoColors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0,4)),
          BoxShadow(color: CupertinoColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0,2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.flame, size: 18, color: CupertinoColors.black),
              const SizedBox(width: 8),
              Text(type[0].toUpperCase() + type.substring(1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('$calories kcal', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _pill('Duration: $duration min'),
            if (intensity.isNotEmpty) _pill('Intensity: $intensity'),
            if (timeStr.isNotEmpty) _pill('Start: $timeStr'),
          ]),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _describeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      'assets/icons/back.svg',
                      width: 24,
                      height: 24,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Log Exercise',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24), // Balance the back button
                ],
              ),
            ),
            
            // Custom Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  _buildCustomTabBar(),
                  // Full horizontal line below all tabs
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: const Color(0xFFE8E8E8),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tab Content
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == _selectedTabIndex;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? CupertinoColors.black : const Color(0x00000000),
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? CupertinoColors.black : const Color(0xFF999999),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildCardioTab();
      case 1:
        return _buildWeightTrainingTab();
      case 2:
        return _buildDescribeTab();
      case 3:
        return _buildDirectInputTab();
      default:
        return _buildCardioTab();
    }
  }

  Widget _buildCardioTab() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Intensity Section
                const Text(
                  'Intensity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // Intensity Options
                Column(
                  children: [
                    for (int i = 0; i < _intensityLabels.length; i++)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIntensity = i;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedIntensity == i 
                                  ? const Color(0xFFF5F5F5) 
                                  : CupertinoColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _selectedIntensity == i 
                                    ? CupertinoColors.black 
                                    : const Color(0xFFE8E8E8),
                                width: _selectedIntensity == i ? 2 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.black.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: CupertinoColors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _intensityLabels[i],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.black,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '- ${_intensityDescriptions[i]}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Duration Section
                const Text(
                  'Duration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // Duration Labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('15 min', style: TextStyle(fontSize: 14, color: CupertinoColors.black)),
                    Text('30 min', style: TextStyle(fontSize: 14, color: CupertinoColors.black)),
                    Text('45 min', style: TextStyle(fontSize: 14, color: CupertinoColors.black)),
                    Text('60 min', style: TextStyle(fontSize: 14, color: CupertinoColors.black)),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Duration Slider
                Material(
                  color: Colors.transparent,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: CupertinoColors.black,
                      inactiveTrackColor: const Color(0xFFE8E8E8),
                      thumbColor: CupertinoColors.black,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      trackHeight: 6,
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    ),
                    child: Slider(
                      value: _duration,
                      min: 15,
                      max: 60,
                      divisions: 45,
                      onChanged: (value) {
                        setState(() {
                          _duration = value;
                        });
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Duration Input Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: CupertinoTextField(
                    controller: TextEditingController(text: _duration.round().toString()),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.black,
                    ),
                    decoration: const BoxDecoration(),
                    padding: EdgeInsets.zero,
                    onChanged: (value) {
                      final intValue = int.tryParse(value);
                      if (intValue != null && intValue >= 15 && intValue <= 60) {
                        setState(() {
                          _duration = intValue.toDouble();
                        });
                      }
                    },
                  ),
                ),
                
                const SizedBox(height: 12),

                if (_isLoggingCardio)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CupertinoActivityIndicator(),
                        SizedBox(width: 8),
                        Text('Logging...', style: TextStyle(color: Color(0xFF666666))),
                      ],
                    ),
                  ),

                if (_cardioResult != null) ...[
                  const SizedBox(height: 12),
                  _buildCardioResultCard(),
                  const SizedBox(height: 80),
                ] else ...[
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ],
            ),
          ),
        ),
        
        // Bottom Add Button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  _isLoggingCardio = true;
                  _cardioResult = null;
                });
                final service = ExerciseService();
                // API expects the tab name as the type (e.g., Cardio, Weight Training)
                final type = _tabs[_selectedTabIndex];
                final intensity = ['low','moderate','high'][_selectedIntensity.clamp(0,2)];
                final startedAt = DateTime.now().toIso8601String();
                final res = await service.logExercise(
                  
                  type: type,
                  durationMinutes: _duration.round(),
                  intensity: intensity,
                  startedAtIso: startedAt,
                );
                setState(() {
                  _isLoggingCardio = false;
                  _cardioResult = res;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  _isLoggingCardio ? 'Logging...' : 'Add',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightTrainingTab() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Intensity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    for (int i = 0; i < _intensityLabels.length; i++)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIntensity = i;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedIntensity == i 
                                  ? const Color(0xFFF5F5F5) 
                                  : CupertinoColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _selectedIntensity == i 
                                    ? CupertinoColors.black 
                                    : const Color(0xFFE8E8E8),
                                width: _selectedIntensity == i ? 2 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.black.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: CupertinoColors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _intensityLabels[i],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.black,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '- ${_weightIntensityDescriptions[i]}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  'Duration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('15 min', style: TextStyle(fontSize: 14, color: CupertinoColors.black)),
                    Text('30 min', style: TextStyle(fontSize: 14, color: CupertinoColors.black)),
                    Text('45 min', style: TextStyle(fontSize: 14, color: CupertinoColors.black)),
                    Text('60 min', style: TextStyle(fontSize: 14, color: CupertinoColors.black)),
                  ],
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.transparent,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: CupertinoColors.black,
                      inactiveTrackColor: const Color(0xFFE8E8E8),
                      thumbColor: CupertinoColors.black,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      trackHeight: 6,
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    ),
                    child: Slider(
                      value: _duration,
                      min: 15,
                      max: 60,
                      divisions: 45,
                      onChanged: (value) {
                        setState(() {
                          _duration = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: CupertinoTextField(
                    controller: TextEditingController(text: _duration.round().toString()),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.black,
                    ),
                    decoration: const BoxDecoration(),
                    padding: EdgeInsets.zero,
                    onChanged: (value) {
                      final intValue = int.tryParse(value);
                      if (intValue != null && intValue >= 15 && intValue <= 60) {
                        setState(() {
                          _duration = intValue.toDouble();
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 12),

                if (_isLoggingCardio)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CupertinoActivityIndicator(),
                        SizedBox(width: 8),
                        Text('Logging...', style: TextStyle(color: Color(0xFF666666))),
                      ],
                    ),
                  ),

                if (_cardioResult != null) ...[
                  const SizedBox(height: 12),
                  _buildCardioResultCard(),
                  const SizedBox(height: 80),
                ] else ...[
                  const SizedBox(height: 100),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  _isLoggingCardio = true;
                  _cardioResult = null;
                });
                try {
                  final service = ExerciseService();
                  final type = _tabs[_selectedTabIndex];
                  final intensity = ['low','moderate','high'][_selectedIntensity.clamp(0,2)];
                  final startedAt = DateTime.now().toLocal().toIso8601String();
                  final res = await service.logExercise(
                    type: type,
                    durationMinutes: _duration.round(),
                    intensity: intensity,
                    startedAtIso: startedAt,
                  );
                  if (!mounted) return;
                  setState(() {
                    _cardioResult = res;
                  });
                } catch (e) {
                  if (!mounted) return;
                  setState(() {
                    _cardioResult = {'success': false, 'error': e.toString()};
                  });
                } finally {
                  if (!mounted) return;
                  setState(() {
                    _isLoggingCardio = false;
                  });
                }
              },
              child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: CupertinoColors.black,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                _isLoggingCardio ? 'Logging...' : 'Add',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ),
        )
      ],
    );
  }

  // Removed unused _buildEmptyTab

  Widget _buildDescribeTab() {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // AI Powered Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/Spark.svg',
                        width: 16,
                        height: 16,
                        color: CupertinoColors.black,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'AI Powered',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Description Input Field
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: CupertinoTextField(
                    controller: _describeController,
                    placeholder: 'Explain workout duration, effort, etc.',
                    maxLines: 1,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.black,
                    ),
                    placeholderStyle: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF999999),
                    ),
                    decoration: const BoxDecoration(),
                    padding: EdgeInsets.zero,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Example Text
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 40,
                    child: const Text(
                      'Example: "Upper body session, 45 mins, medium effort"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                const Spacer(),

                if (_isEstimating) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CupertinoActivityIndicator(),
                          SizedBox(width: 8),
                          Text('Estimating...', style: TextStyle(color: Color(0xFF666666))),
                        ],
                      ),
                    ),
                  ),
                ] else if (_estimate != null) ...[
                  _buildEstimateCard(),
                  const SizedBox(height: 80),
                ],
              ],
            ),
          ),
          
          // Bottom Add Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () async {
                  if (_describeController.text.trim().isEmpty) return;
                  setState(() {
                    _isEstimating = true;
                    _estimate = null;
                  });
                  final service = ExerciseService();
                  final res = await service.estimateFromDescription(
                    description: _describeController.text.trim(),
                    intensity: ['low','medium','high'][_selectedIntensity],
                    durationMinutes: _duration.round(),
                    autolog: true,
                  );
                  setState(() {
                    _isEstimating = false;
                    _estimate = res;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.black,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    _isEstimating ? 'Estimating...' : 'Add',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimateCard() {
    final est = _estimate ?? const {};
    final estimated = est['estimatedCalories']?.toString() ?? '0';
    final rationale = est['rationale'] as String? ?? 'No rationale provided.';
    final input = (est['input'] as Map<String, dynamic>?) ?? const {};
    final desc = input['description'] as String? ?? '';
    final intensity = input['intensity']?.toString() ?? '';
    final duration = input['durationMinutes']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1.5),
        boxShadow: [
          BoxShadow(color: CupertinoColors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0,4)),
          BoxShadow(color: CupertinoColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0,2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.flame, size: 18, color: CupertinoColors.black),
              const SizedBox(width: 8),
              const Text('AI Estimate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('$estimated kcal', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, width: double.infinity, color: const Color(0xFFE8E8E8)),
          const SizedBox(height: 12),
          if (desc.isNotEmpty) ...[
            Text(desc, style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (intensity.isNotEmpty)
                _pill('Intensity: $intensity'),
              if (duration.isNotEmpty)
                _pill('Duration: $duration min'),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Why this estimate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(rationale, style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.3)),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF333333))),
    );
  }

  Widget _buildDirectInputTab() {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              const SizedBox(height: 0),
              
              // Calories Input Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE8E8E8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Flame icon
                    Image.asset(
                      'assets/icons/flame_black.png',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 12),
                    
                    // Description text and input
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Type in calories burned yourself',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Calories input field
                          CupertinoTextField(
                            controller: _caloriesController,
                            placeholder: '0',
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.black,
                            ),
                            placeholderStyle: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF999999),
                            ),
                            decoration: const BoxDecoration(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
        
        // Bottom Add Button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () async {
                final text = _caloriesController.text.trim();
                final value = int.tryParse(text) ?? 0;
                if (value <= 0) return;
                setState(() {
                  _isLoggingCardio = true;
                  _cardioResult = null;
                });
                try {
                  final service = ExerciseService();
                  final startedAt = DateTime.now().toLocal().toIso8601String();
                  final res = await service.logDirectCalories(caloriesBurned: value, startedAtIso: startedAt);
                  if (!mounted) return;
                  setState(() {
                    _cardioResult = res;
                  });
                } catch (e) {
                  if (!mounted) return;
                  setState(() {
                    _cardioResult = {'success': false, 'error': e.toString()};
                  });
                } finally {
                  if (!mounted) return;
                  setState(() {
                    _isLoggingCardio = false;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  _isLoggingCardio ? 'Logging...' : 'Add',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

}

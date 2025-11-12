import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../services/exercise_service.dart';
import '../utils/theme_helper.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> exerciseData;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseData,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final ExerciseService _exerciseService = const ExerciseService();
  late final Map<String, dynamic> _exercise;
  late final int _initialCalories;
  late final TextEditingController _caloriesController;

  @override
  void initState() {
    super.initState();
    _exercise = Map<String, dynamic>.from(widget.exerciseData);
    _initialCalories = _intFrom(_exercise['caloriesBurned']);
    _caloriesController = TextEditingController(text: _initialCalories.toString());
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  int _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    return 0;
  }

  String? _extractExerciseId(Map<String, dynamic> exercise) {
    final dynamic id = exercise['id'] ?? exercise['_id'] ?? exercise['exerciseId'];
    if (id == null) return null;
    return id.toString();
  }

  String _formatLoggedAt(AppLocalizations l10n) {
    final loggedAtRaw = _exercise['loggedAt'] as String?;
    if (loggedAtRaw == null || loggedAtRaw.isEmpty) return 'Unknown time';
    try {
      final date = DateTime.parse(loggedAtRaw).toLocal();
      return DateFormat('MMM d, yyyy – h:mm a').format(date);
    } catch (_) {
      return loggedAtRaw;
    }
  }

  Future<void> _handleSave() async {
    final rawText = _caloriesController.text.trim();
    final parsedCalories = int.tryParse(rawText.isEmpty ? '0' : rawText);
    if (parsedCalories == null || parsedCalories < 0) {
      return;
    }

    final updated = Map<String, dynamic>.from(_exercise)
      ..['caloriesBurned'] = parsedCalories;

    Navigator.of(context).pop(updated);

    final exerciseId = _extractExerciseId(updated);
    if (exerciseId != null) {
      final Map<String, dynamic> payload = Map<String, dynamic>.from(updated)
        ..remove('id')
        ..remove('_id')
        ..remove('exerciseId')
        ..remove('__v');

      _exerciseService
          .updateExercise(
        exerciseId: exerciseId,
        payload: payload,
      )
          .catchError((error) {
        debugPrint('ExerciseDetailScreen: Failed to update exercise $exerciseId - $error');
        return null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final type = (_exercise['type'] as String?) ?? l10n.exercise;
    final notes = (_exercise['notes'] as String?)?.trim();
    final intensity = (_exercise['intensity'] as String?)?.trim();
    final duration = _intFrom(_exercise['durationMinutes']);
    final loggedAtLabel = _formatLoggedAt(l10n);
    final displayName = (notes != null && notes.isNotEmpty) ? notes : type;

    return CupertinoPageScaffold(
      backgroundColor: ThemeHelper.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      CupertinoIcons.back,
                      color: ThemeHelper.textPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ThemeHelper.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  if (intensity != null && intensity.isNotEmpty) ...[
                    Text(
                      '${l10n.intensity}: $intensity',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (duration > 0) ...[
                    Text(
                      '${l10n.duration}: $duration min',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (notes != null && notes.isNotEmpty) ...[
                    Text(
                      notes,
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ThemeHelper.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ThemeHelper.divider,
                    width: 1.5,
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: ThemeHelper.textPrimary.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: ThemeHelper.textPrimary.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/flame_black.png',
                      width: 28,
                      height: 28,
                      color: ThemeHelper.textPrimary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.typeCaloriesBurned,
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeHelper.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CupertinoTextField(
                            controller: _caloriesController,
                            keyboardType: TextInputType.number,
                            placeholder: l10n.zeroPlaceholder,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: ThemeHelper.textPrimary,
                            ),
                            placeholderStyle: TextStyle(
                              fontSize: 18,
                              color: ThemeHelper.textSecondary,
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
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: _handleSave,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: ThemeHelper.textPrimary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    l10n.save,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.background,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



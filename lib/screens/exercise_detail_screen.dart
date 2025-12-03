// ignore_for_file: unused_element

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

  Future<void> _handleDeleteExerciseInBackground() async {
    final exerciseId = _extractExerciseId(_exercise);
    if (exerciseId != null) {
      // Make API call in background - fire and forget
      _exerciseService.deleteExercise(exerciseId: exerciseId).catchError((error) {
        debugPrint('ExerciseDetailScreen: Failed to delete exercise $exerciseId - $error');
        // Note: We don't show error to user since we've already optimistically removed it
        // The exercise will be removed from UI immediately, and if API fails,
        // it might reappear on next refresh, but that's acceptable for optimistic UI
        return false;
      });
    }
  }

  void _showDeleteExerciseConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Show confirmation dialog
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 320,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: ThemeHelper.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Header with title and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.deleteExerciseTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.textPrimary,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Icon(
                          CupertinoIcons.xmark_circle,
                          color: ThemeHelper.textPrimary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    l10n.exerciseWillBePermanentlyDeleted,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ThemeHelper.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Buttons
                  Row(
                    children: [
                      // No button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: ThemeHelper.cardBackground,
                              border: Border.all(
                                color: ThemeHelper.divider,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                l10n.no,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeHelper.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Yes button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Close the dialog
                            Navigator.of(context).pop();
                            // Immediately navigate back with deleted flag (optimistic)
                            if (context.mounted) {
                              Navigator.of(context).pop({'deleted': true});
                            }
                            // Make API call in background (fire and forget)
                            _handleDeleteExerciseInBackground();
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCD5C5C), // Matching the red color from delete account dialog
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                l10n.yes,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final type = (_exercise['type'] as String?) ?? l10n.exercise;
    final notes = (_exercise['notes'] as String?)?.trim();
    // final intensity = (_exercise['intensity'] as String?)?.trim();
    // final duration = _intFrom(_exercise['durationMinutes']);
    // final loggedAtLabel = _formatLoggedAt(l10n);
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
                  // const SizedBox(width: 16),
                  // Expanded(
                  //   child: Text(
                  //     displayName,
                  //     style: TextStyle(
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.w700,
                  //       color: ThemeHelper.textPrimary,
                  //     ),
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ),
                  // const SizedBox(width: 16),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showDeleteExerciseConfirmation(context),
                    child: Image.asset(
                      'assets/icons/trash.png',
                      width: 20,
                      height: 20,
                      color: ThemeHelper.textPrimary,
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
                 
                  Center(
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
            const SizedBox(height: 32),
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
                      'assets/icons/apple.png',
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



// ignore_for_file: use_build_context_synchronously

import 'dart:convert' show base64Encode;
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import '../services/progress_service.dart';
import 'progress_photos_screen.dart' show ProgressPhotosScreen, ProgressPhotoItem;
import '../utils/user.prefs.dart' show UserPrefs;
import '../utils/theme_helper.dart';
import 'package:get/get.dart';
import '../providers/theme_provider.dart' show ThemeProvider;
import '../controllers/progress_photos_card_controller.dart';

class ConfirmWeightScreen extends StatefulWidget {
  final String weightLabel; // e.g. "64.7 kg"
  final List<String> imagePaths; // local file paths

  const ConfirmWeightScreen({super.key, required this.weightLabel, required this.imagePaths});

  @override
  State<ConfirmWeightScreen> createState() => _ConfirmWeightScreenState();
}

class _ConfirmWeightScreenState extends State<ConfirmWeightScreen> {
  late final TextEditingController _weightController;
  final ProgressService _progressService = ProgressService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.weightLabel);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ThemeHelper.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      'assets/icons/back.svg',
                      width: 24,
                      height: 24,
                      color: ThemeHelper.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

        

            Text(
              'Confirm your weight',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeHelper.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 30),

            // Weight box
            Center(
              child: Container(
                width: 335,
                height: 60,
                decoration: ShapeDecoration(
                  color: ThemeHelper.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  shadows: [
                    BoxShadow(
                      color: ThemeHelper.isLightMode 
                          ? Colors.black.withOpacity(0.25)
                          : Colors.transparent,
                      blurRadius: 5,
                      offset: const Offset(0, 0),
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Center(
                  child: CupertinoTextField(
                    controller: _weightController,
                    textAlign: TextAlign.center,
                    placeholder: 'Current weight',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const BoxDecoration(color: Colors.transparent),
                    placeholderStyle: TextStyle(
                      color: ThemeHelper.textSecondary,
                    ),
                    style: TextStyle(
                      color: ThemeHelper.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Progress Photo label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Progress Photo',
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Images grid (88x120 tiles)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.imagePaths.map((p) {
                  return Container(
                    width: 88,
                    height: 120,
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                        image: FileImage(File(p)),
                        fit: BoxFit.cover,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Spacer(),

            // Bottom confirm bar
            Container(
              width: double.infinity,
              height: 76,
              decoration: BoxDecoration(
                color: ThemeHelper.background,
                boxShadow: [
                  BoxShadow(
                    color: ThemeHelper.isLightMode 
                        ? Colors.black.withOpacity(0.1)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Center(
                child: GestureDetector(
                  onTap: _saving ? null : () async {
                    final String weightText = _weightController.text.trim();
                    final double? weight = double.tryParse(weightText);
                    final String takenAt = DateTime.now().toIso8601String();
                    setState(() { _saving = true; });
                    try {
                      // Read files and encode to base64
                      final List<String> b64 = <String>[];
                      for (final p in widget.imagePaths) {
                        try {
                          final bytes = await File(p).readAsBytes();
                          b64.add(base64Encode(bytes));
                        } catch (_) {}
                      }
                      final res = await _progressService.uploadProgressPhotos(
                        base64Images: b64,
                        weight: weight,
                        unit: 'kg',
                        takenAtIsoLocal: takenAt,
                      );
                      final bool ok = (res != null && (res['success'] == true || res['message'] == 'ok'));
                      if (ok) {
                        await UserPrefs.setLastWeighInNow();
                        // Clear local images to prevent duplicates after successful upload
                        try {
                          if (Get.isRegistered<ProgressPhotosCardController>()) {
                            final controller = Get.find<ProgressPhotosCardController>();
                            controller.clearLocalImages();
                            // Reload server photos to show the newly uploaded ones
                            controller.loadServerPhotos();
                          }
                        } catch (_) {}
                        // Trigger a rebuild of ProgressScreen via theme provider listener
                        try {
                          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                          Get.find<ThemeProvider>().notifyListeners();
                        } catch (_) {}
                        // Build photo items with simple label
                        final String dateLabel = _formatDateLabel(DateTime.now());
                        final String label = ((weight ?? 0) > 0) ? '${weight!.toStringAsFixed(1)} kg - $dateLabel' : dateLabel;
                        final now = DateTime.now().toLocal().toIso8601String();
                        final items = widget.imagePaths
                            .map((p) => ProgressPhotoItem(
                              imagePath: p,
                              label: label,
                              isNetwork: false,
                              weight: weight,
                              takenAt: now,
                            ))
                            .toList();
                        await Navigator.of(context).pushReplacement(CupertinoPageRoute(
                          builder: (_) => ProgressPhotosScreen(photos: items, shouldFetchFromServer: true),
                        ));
                      } else {
                        if (mounted) Navigator.of(context).pop({'confirmed': false});
                      }
                    } finally {
                      if (mounted) setState(() { _saving = false; });
                    }
                  },
                  child: Container(
                    width: 293,
                    height: 43,
                    decoration: ShapeDecoration(
                      color: ThemeHelper.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Center(
                      child: _saving
                          ? CupertinoActivityIndicator(color: ThemeHelper.background)
                          : Text(
                              'Confirm',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ThemeHelper.background,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
String _formatDateLabel(DateTime d) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${months[d.month-1]} ${d.day}, ${d.year}';
}



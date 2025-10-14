// ignore_for_file: use_build_context_synchronously

import 'dart:convert' show base64Encode;
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import '../services/progress_service.dart';
import 'progress_photos_screen.dart' show ProgressPhotosScreen, ProgressPhotoItem;

class ConfirmWeightScreen extends StatefulWidget {
  final String weightLabel; // e.g. "64.7 kg"
  final List<String> imagePaths; // local file paths

  const ConfirmWeightScreen({super.key, required this.weightLabel, required this.imagePaths});

  @override
  State<ConfirmWeightScreen> createState() => _ConfirmWeightScreenState();
}

class _ConfirmWeightScreenState extends State<ConfirmWeightScreen> {
  late final TextEditingController _weightController;
  final ProgressService _progressService = const ProgressService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.weightLabel);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
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
                      color: CupertinoColors.black,
                    ),
                  ),
                ],
              ),
            ),

        

            const Text(
              textAlign: TextAlign.center,
                    'Confirm your weight',
                    style: TextStyle(
                      color: Color(0xFF1E1822),
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
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 5,
                      offset: Offset(0, 0),
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
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Progress Photo label
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Progress Photo',
                style: TextStyle(
                  color: Color(0xFF1E1822),
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
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 10,
                    offset: Offset(0, -2),
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
                        // Build photo items with simple label
                        final String dateLabel = _formatDateLabel(DateTime.now());
                        final String label = ((weight ?? 0) > 0) ? '${weight!.toStringAsFixed(1)} kg - $dateLabel' : dateLabel;
                        final items = widget.imagePaths
                            .map((p) => ProgressPhotoItem(imagePath: p, label: label, isNetwork: false))
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
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Center(
                      child: _saving
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : const Text(
                              'Confirm',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
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



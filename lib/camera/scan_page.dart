import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Icons; // For overlay painting & icons
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart' show AppLocalizations;
import '../utils/user.prefs.dart';
import 'scan_tutorial_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeFuture;
  List<CameraDescription>? _cameras;
  bool _isRear = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _checkAndShowTutorial();
  }

  Future<void> _checkAndShowTutorial() async {
    // Wait for the first frame to be rendered
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    
    final tutorialShown = await UserPrefs.getScanTutorialShown();
    if (!tutorialShown) {
      // Show tutorial as full screen dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showTutorialDialog();
        }
      });
    }
  }

  void _showTutorialDialog() {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: CupertinoColors.systemBackground,
          child: const ScanTutorialPage(),
        );
      },
    ).then((_) {
      // Save flag after tutorial is dismissed
      UserPrefs.setScanTutorialShown(true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      // Dispose any existing controller before re-initializing
      final oldController = _controller;
      _controller = null;
      await oldController?.dispose();

      _cameras ??= await availableCameras();
      final desired = _isRear
          ? _cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras!.first)
          : _cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras!.first);

      final controller = CameraController(
        desired,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
      );
      _controller = controller;
      // Eagerly initialize and wait, then rebuild so preview shows immediately
      _initializeFuture = controller.initialize();
      await _initializeFuture;
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }


  Future<void> _capture() async {
    if (_controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      await _initializeFuture;
      final file = await _controller!.takePicture();
      if (!mounted) return;
      // Return image path to previous screen to reuse the same analyzing flow
      Navigator.of(context).pop(<String, dynamic>{'imagePath': file.path});
    } catch (e) {
      debugPrint('Capture error: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      if (!mounted) return;
      // Return image path to previous screen to reuse the same analyzing flow
      Navigator.of(context).pop(<String, dynamic>{'imagePath': picked.path});
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: null,
      child: Stack(
        children: [
          // Fullscreen camera preview
          Positioned.fill(
            child: (_controller != null && (_controller!.value.isInitialized))
                ? CameraPreview(_controller!)
                : const Center(child: CupertinoActivityIndicator()),
          ),
          
          // Overlay with cutout and corners
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ScannerOverlayPainter(),
              ),
            ),
          ),
          
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Back button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: CupertinoColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          weight: 30.0,
                          CupertinoIcons.xmark_circle,
                          color: CupertinoColors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Title
                    Text(
                      l10n.scanFood,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Switch camera button
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              fullscreenDialog: true,
                              builder: (_) => const ScanTutorialPage(),
                            ),
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: CupertinoColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.info_circle,
                            color: CupertinoColors.black,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Gallery button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _isBusy ? null : _pickFromGallery,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: CupertinoColors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    
                    // Capture button - make it more prominent like in screenshot
                    GestureDetector(
                      onTap: _isBusy ? null : _capture,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CupertinoColors.white,
                            width: 5,
                          ),
                          color: Colors.transparent,
                        ),
                        child: _isBusy
                            ? const CupertinoActivityIndicator(
                                color: CupertinoColors.white,
                              )
                            : Container(
                                margin: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CupertinoColors.white,
                                ),
                                child: Image.asset('assets/icons/shutter.png'),
                              ),
                      ),
                    ),
                    
                    // Flash button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: null, 
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.flash_on,
                          color: CupertinoColors.black,
                          size: 24,
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
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Use a layer so BlendMode.clear reveals the camera preview
    canvas.saveLayer(Offset.zero & size, Paint());

    // ignore: deprecated_member_use
    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    
    // Make the cutout more square and centered like in the screenshot
    final cutoutSize = Size(size.width * 0.75, size.width * 0.75); // Square aspect ratio
    final dx = (size.width - cutoutSize.width) / 2;
    final dy = (size.height - cutoutSize.height) / 2;
    final cutoutRect = Rect.fromLTWH(dx, dy, cutoutSize.width, cutoutSize.height);

    // Dimmed background
    canvas.drawRect(Offset.zero & size, paint);

    // Clear cutout - make it more curved/rounded
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutoutRect, const Radius.circular(32)),
      clearPaint,
    );

    // Restore to apply clear blend
    canvas.restore();

    // Corner brackets - match the thick, bold design from screenshot
    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 80.0;
    const cornerOffset = 0.0; // Right at the corner edge like in screenshot
    final r = RRect.fromRectAndRadius(cutoutRect, const Radius.circular(32)).outerRect;

    // Top-left corner bracket
    canvas.drawLine(
      Offset(r.left - cornerOffset, r.top + cornerLen), 
      Offset(r.left - cornerOffset, r.top - cornerOffset), 
      cornerPaint
    );
    canvas.drawLine(
      Offset(r.left - cornerOffset, r.top - cornerOffset), 
      Offset(r.left + cornerLen, r.top - cornerOffset), 
      cornerPaint
    );
    
    // Top-right corner bracket
    canvas.drawLine(
      Offset(r.right - cornerLen, r.top - cornerOffset), 
      Offset(r.right + cornerOffset, r.top - cornerOffset), 
      cornerPaint
    );
    canvas.drawLine(
      Offset(r.right + cornerOffset, r.top - cornerOffset), 
      Offset(r.right + cornerOffset, r.top + cornerLen), 
      cornerPaint
    );
    
    // Bottom-left corner bracket
    canvas.drawLine(
      Offset(r.left - cornerOffset, r.bottom - cornerLen), 
      Offset(r.left - cornerOffset, r.bottom + cornerOffset), 
      cornerPaint
    );
    canvas.drawLine(
      Offset(r.left - cornerOffset, r.bottom + cornerOffset), 
      Offset(r.left + cornerLen, r.bottom + cornerOffset), 
      cornerPaint
    );
    
    // Bottom-right corner bracket
    canvas.drawLine(
      Offset(r.right - cornerLen, r.bottom + cornerOffset), 
      Offset(r.right + cornerOffset, r.bottom + cornerOffset), 
      cornerPaint
    );
    canvas.drawLine(
      Offset(r.right + cornerOffset, r.bottom + cornerOffset), 
      Offset(r.right + cornerOffset, r.bottom - cornerLen), 
      cornerPaint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

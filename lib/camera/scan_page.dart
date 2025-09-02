import 'dart:io';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Icons; // For overlay painting & icons
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart' show AppConstants;
import '../network/http_helper.dart';

import 'scan_result_page.dart';

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
      _initializeFuture = controller.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _toggleCamera() async {
    _isRear = !_isRear;
    await _controller?.dispose();
    await _initCamera();
  }

  Future<void> _capture() async {
    if (_controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      await _initializeFuture;
      final file = await _controller!.takePicture();
      if (!mounted) return;
      await _sendToBackend(file.path);
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
      await _sendToBackend(picked.path);
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  Future<void> _sendToBackend(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final base64Data = base64Encode(bytes);
      final payload = {
        'imageData': 'data:image/jpeg;base64,$base64Data',
        'mealType': 'lunch',
      };
      final imgPath = path;
      final reqInfo = '${AppConstants.baseUrl}/api/scanning/scan-image';
      await multiPostAPINew(
        methodName: '/api/scanning/scan-image',
        param: payload,
        callback: (resp) {
          Map<String, dynamic> result;
          try {
            result = jsonDecode(resp.response) as Map<String, dynamic>;
          } catch (_) {
            result = {'message': resp.response, 'status': resp.code};
          }
          if (!mounted) return;
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => ScanResultPage(
                result: result,
                imagePath: imgPath,
                rawResponse: resp.response,
                statusCode: resp.code,
                requestInfo: reqInfo,
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Scan send error: $e');
      if (!mounted) return;
      await showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Scan Error'),
          content: Text('$e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
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
          // Top bar with title and switch camera
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Scan Food', style: TextStyle(color: CupertinoColors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _toggleCamera,
                    child: const Icon(Icons.cameraswitch, color: CupertinoColors.white),
                  ),
                ],
              ),
            ),
          ),
          // Bottom controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gallery button
                  CupertinoButton(
                    padding: const EdgeInsets.all(12),
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(28),
                    onPressed: _isBusy ? null : _pickFromGallery,
                    child: const Icon(Icons.photo_library, color: CupertinoColors.black),
                  ),
                  // Capture button
                  GestureDetector(
                    onTap: _isBusy ? null : _capture,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: CupertinoColors.white, width: 6),
                        color: _isBusy ? CupertinoColors.systemGrey : CupertinoColors.white,
                      ),
                    ),
                  ),
                  // Torch placeholder (optional)
                  CupertinoButton(
                    padding: const EdgeInsets.all(12),
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(28),
                    onPressed: null,
                    child: const Icon(Icons.flash_on, color: CupertinoColors.black),
                  ),
                ],
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

    final paint = Paint()..color = Colors.black.withOpacity(0.5);
    final cutoutSize = Size(size.width * 0.8, size.height * 0.4);
    final dx = (size.width - cutoutSize.width) / 2;
    final dy = (size.height - cutoutSize.height) / 2;
    final cutoutRect = Rect.fromLTWH(dx, dy, cutoutSize.width, cutoutSize.height);

    // Dimmed background
    canvas.drawRect(Offset.zero & size, paint);

    // Clear cutout
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutoutRect, const Radius.circular(20)),
      clearPaint,
    );

    // Restore to apply clear blend
    canvas.restore();

    // Corner accents
    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const cornerLen = 24.0;
    final r = RRect.fromRectAndRadius(cutoutRect, const Radius.circular(20)).outerRect;

    // Top-left
    canvas.drawLine(Offset(r.left, r.top), Offset(r.left + cornerLen, r.top), cornerPaint);
    canvas.drawLine(Offset(r.left, r.top), Offset(r.left, r.top + cornerLen), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(r.right, r.top), Offset(r.right - cornerLen, r.top), cornerPaint);
    canvas.drawLine(Offset(r.right, r.top), Offset(r.right, r.top + cornerLen), cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(r.left, r.bottom), Offset(r.left + cornerLen, r.bottom), cornerPaint);
    canvas.drawLine(Offset(r.left, r.bottom), Offset(r.left, r.bottom - cornerLen), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(r.right, r.bottom), Offset(r.right - cornerLen, r.bottom), cornerPaint);
    canvas.drawLine(Offset(r.right, r.bottom), Offset(r.right, r.bottom - cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

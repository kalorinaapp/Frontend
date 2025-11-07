import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:get/get.dart';
import '../utils/theme_helper.dart';
import 'progress_photo_detail_screen.dart' show ProgressPhotoDetailScreen;
import '../controllers/progress_photos_controller.dart';

class ProgressPhotoItem {
  final String imagePath; // can be file path or url
  final String label; // e.g., "66.4 kg - Sep 25, 2025"
  final bool isNetwork;
  final double? weight;
  final String? takenAt; // ISO date string
  final String? photoId; // Photo ID from server
  const ProgressPhotoItem({
    required this.imagePath,
    required this.label,
    this.isNetwork = false,
    this.weight,
    this.takenAt,
    this.photoId,
  });
  
  // Get date only (without time) for grouping
  DateTime? get dateOnly {
    if (takenAt == null) return null;
    try {
      final d = DateTime.tryParse(takenAt!)?.toLocal();
      if (d != null) {
        return DateTime(d.year, d.month, d.day);
      }
    } catch (_) {}
    return null;
  }
}

class ProgressPhotosScreen extends StatefulWidget {
  final List<ProgressPhotoItem> photos;
  final bool shouldFetchFromServer;
  const ProgressPhotosScreen({super.key, required this.photos, this.shouldFetchFromServer = false});

  @override
  State<ProgressPhotosScreen> createState() => _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState extends State<ProgressPhotosScreen> {
  late final ProgressPhotosController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ProgressPhotosController());
    _controller.initializePhotos(widget.photos);
    if (widget.shouldFetchFromServer) {
      _controller.loadFromServer();
    }
  }

  @override
  void dispose() {
    Get.delete<ProgressPhotosController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ThemeHelper.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Progress Photos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeHelper.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value && _controller.photos.isEmpty) {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 18,
                      childAspectRatio: 102 / 160, // image 102x139 + label
                    ),
                    itemCount: _controller.photos.length,
                    itemBuilder: (context, index) {
                      final p = _controller.photos[index];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => ProgressPhotoDetailScreen(
                                photos: _controller.photos.toList(),
                                initialIndex: index,
                                onLoadMore: widget.shouldFetchFromServer 
                                    ? _controller.loadMorePhotos 
                                    : null,
                                onPhotoDeleted: (photoId) {
                                  // Refresh photos from server when a photo is deleted
                                  if (widget.shouldFetchFromServer) {
                                    _controller.loadFromServer();
                                  }
                                },
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 102,
                              child: Text(
                                p.label,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: ThemeHelper.textPrimary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 102,
                              height: 139,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                  image: p.isNetwork
                                      ? NetworkImage(p.imagePath) as ImageProvider
                                      : FileImage(File(p.imagePath)),
                                  fit: BoxFit.cover,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

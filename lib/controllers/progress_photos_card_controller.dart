import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/progress_photos_screen.dart' show ProgressPhotoItem;
import '../services/progress_service.dart';

class ProgressPhotosCardController extends GetxController {
  final ProgressService service = ProgressService();
  final ImagePicker _picker = ImagePicker();

  // Observable state
  final serverPhotos = <ProgressPhotoItem>[].obs;
  final localImages = <XFile>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadServerPhotos();
  }

  Future<void> loadServerPhotos() async {
    try {
      final res = await service.fetchProgressPhotos(page: 1, limit: 60);
      if (res != null && res['success'] == true) {
        final List<dynamic> photosData = (res['photos'] as List<dynamic>? ?? <dynamic>[]);
        final List<ProgressPhotoItem> mapped = photosData.map((p) {
          final Map<String, dynamic> m = Map<String, dynamic>.from(p as Map);
          final double? w = (m['weight'] as num?)?.toDouble();
          final String takenAt = (m['takenAt'] ?? '') as String;
          final String photoId = (m['id'] ?? m['_id'] ?? '') as String;
          const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
          String dateLabel = '';
          try {
            final d = DateTime.tryParse(takenAt)?.toLocal();
            if (d != null) {
              dateLabel = '${months[d.month-1]} ${d.day}, ${d.year}';
            }
          } catch (_) {}
          final String label = w != null ? '${w.toStringAsFixed(1)} kg - $dateLabel' : dateLabel;
          return ProgressPhotoItem(
            imagePath: (m['imageUrl'] ?? '') as String,
            label: label,
            isNetwork: true,
            weight: w,
            takenAt: takenAt,
            photoId: photoId,
          );
        }).toList();
        serverPhotos.value = mapped;
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void optimisticallyRemovePhoto(String photoId) {
    serverPhotos.removeWhere((photo) => photo.photoId == photoId);
  }

  void addLocalImage(XFile image) {
    localImages.add(image);
  }

  void addLocalImages(List<XFile> images) {
    localImages.addAll(images);
  }

  void clearLocalImages() {
    localImages.clear();
  }

  ImagePicker get picker => _picker;
}


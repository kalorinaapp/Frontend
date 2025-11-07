import 'package:get/get.dart';
import '../screens/progress_photos_screen.dart' show ProgressPhotoItem;
import '../services/progress_service.dart';

class ProgressPhotosController extends GetxController {
  final ProgressService _service = ProgressService();
  static const int _pageSize = 60;

  // Observable state
  final photos = <ProgressPhotoItem>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void initializePhotos(List<ProgressPhotoItem> initialPhotos) {
    photos.value = List<ProgressPhotoItem>.from(initialPhotos);
  }

  Future<void> loadFromServer() async {
    isLoading.value = true;
    try {
      final res = await _service.fetchProgressPhotos(page: 1, limit: _pageSize);
      if (res != null && res['success'] == true) {
        final List<dynamic> photosData = (res['photos'] as List<dynamic>? ?? <dynamic>[]);
        final List<ProgressPhotoItem> mapped = photosData.map((p) {
          final Map<String, dynamic> m = Map<String, dynamic>.from(p as Map);
          final double? w = (m['weight'] as num?)?.toDouble();
          final String takenAt = (m['takenAt'] ?? '') as String;
          final String photoId = (m['id'] ?? m['_id'] ?? '') as String;
          final String label = _composeLabel(w, takenAt);
          return ProgressPhotoItem(
            imagePath: (m['imageUrl'] ?? '') as String,
            label: label,
            isNetwork: true,
            weight: w,
            takenAt: takenAt,
            photoId: photoId,
          );
        }).toList();
        photos.value = mapped;
      }
    } catch (e) {
      // Handle error silently
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ProgressPhotoItem>> loadMorePhotos(int page) async {
    try {
      final res = await _service.fetchProgressPhotos(page: page, limit: _pageSize);
      if (res != null && res['success'] == true) {
        final List<dynamic> photosData = (res['photos'] as List<dynamic>? ?? <dynamic>[]);
        final List<ProgressPhotoItem> mapped = photosData.map((p) {
          final Map<String, dynamic> m = Map<String, dynamic>.from(p as Map);
          final double? w = (m['weight'] as num?)?.toDouble();
          final String takenAt = (m['takenAt'] ?? '') as String;
          final String photoId = (m['id'] ?? m['_id'] ?? '') as String;
          final String label = _composeLabel(w, takenAt);
          return ProgressPhotoItem(
            imagePath: (m['imageUrl'] ?? '') as String,
            label: label,
            isNetwork: true,
            weight: w,
            takenAt: takenAt,
            photoId: photoId,
          );
        }).toList();
        return mapped;
      }
    } catch (e) {
      // Handle error silently
    }
    return [];
  }

  String _composeLabel(double? weight, String iso) {
    String dateLabel;
    try {
      final d = DateTime.tryParse(iso)?.toLocal();
      if (d != null) {
        const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        dateLabel = '${months[d.month-1]} ${d.day}, ${d.year}';
      } else {
        dateLabel = '';
      }
    } catch (_) {
      dateLabel = '';
    }
    if (weight != null) {
      return '${weight.toStringAsFixed(1)} kg - $dateLabel';
    }
    return dateLabel;
  }
}


import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import '../services/progress_service.dart';

class ProgressPhotoItem {
  final String imagePath; // can be file path or url
  final String label; // e.g., "66.4 kg - Sep 25, 2025"
  final bool isNetwork;
  const ProgressPhotoItem({required this.imagePath, required this.label, this.isNetwork = false});
}

class ProgressPhotosScreen extends StatefulWidget {
  final List<ProgressPhotoItem> photos;
  final bool shouldFetchFromServer;
  const ProgressPhotosScreen({super.key, required this.photos, this.shouldFetchFromServer = false});

  @override
  State<ProgressPhotosScreen> createState() => _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState extends State<ProgressPhotosScreen> {
  final ProgressService _service = ProgressService();
  late List<ProgressPhotoItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List<ProgressPhotoItem>.from(widget.photos);
    if (widget.shouldFetchFromServer) {
      _loadFromServer();
    }
  }

  Future<void> _loadFromServer() async {
    final res = await _service.fetchProgressPhotos(page: 1, limit: 60);
    if (!mounted) return;
    if (res != null && res['success'] == true) {
      final List<dynamic> photos = (res['photos'] as List<dynamic>? ?? <dynamic>[]);
      final List<ProgressPhotoItem> mapped = photos.map((p) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(p as Map);
        final double? w = (m['weight'] as num?)?.toDouble();
        final String takenAt = (m['takenAt'] ?? '') as String;
        final String label = _composeLabel(w, takenAt);
        return ProgressPhotoItem(imagePath: (m['imageUrl'] ?? '') as String, label: label, isNetwork: true);
      }).toList();
      setState(() {
        _items = mapped;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
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
                      color: CupertinoColors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Progress Photos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1E1822),
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 18,
                    childAspectRatio: 102 / 160, // image 102x139 + label
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final p = _items[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         SizedBox(
                          width: 102,
                          child: Text(
                            p.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1E1822),
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



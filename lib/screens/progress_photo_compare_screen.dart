// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'progress_photos_screen.dart' show ProgressPhotoItem;
import '../utils/theme_helper.dart';

class ProgressPhotoCompareScreen extends StatefulWidget {
  final List<ProgressPhotoItem> photos;
  final int initialIndex;
  
  const ProgressPhotoCompareScreen({
    super.key,
    required this.photos,
    this.initialIndex = 0,
  });

  @override
  State<ProgressPhotoCompareScreen> createState() => _ProgressPhotoCompareScreenState();
}

class _ProgressPhotoCompareScreenState extends State<ProgressPhotoCompareScreen> {
  late int _leftPhotoIndex;
  late int _rightPhotoIndex;
  late List<ProgressPhotoItem> _sortedPhotos;
  bool _isLeftActive = false; // Track which comparison photo is active for replacement
  
  @override
  void initState() {
    super.initState();
    _sortedPhotos = List<ProgressPhotoItem>.from(widget.photos);
    _sortPhotos();
    _initializeComparison();
  }
  
  void _sortPhotos() {
    // Sort all photos by takenAt (newest first)
    _sortedPhotos.sort((a, b) {
      if (a.takenAt == null && b.takenAt == null) return 0;
      if (a.takenAt == null) return 1;
      if (b.takenAt == null) return -1;
      final da = DateTime.tryParse(a.takenAt!)?.millisecondsSinceEpoch ?? 0;
      final db = DateTime.tryParse(b.takenAt!)?.millisecondsSinceEpoch ?? 0;
      return db.compareTo(da); // Descending order (newest first)
    });
  }
  
  void _initializeComparison() {
    if (_sortedPhotos.isEmpty) {
      _leftPhotoIndex = 0;
      _rightPhotoIndex = 0;
      return;
    }
    
    // Find the initial photo in sorted list
    final initialPhoto = widget.photos[widget.initialIndex];
    final sortedIndex = _sortedPhotos.indexWhere((p) => 
      p.imagePath == initialPhoto.imagePath && 
      p.takenAt == initialPhoto.takenAt
    );
    
    final selectedIndex = sortedIndex != -1 ? sortedIndex : 0;
    
    // Set left photo to selected, right photo to adjacent (next one, or previous if at end)
    _leftPhotoIndex = selectedIndex;
    if (selectedIndex + 1 < _sortedPhotos.length) {
      _rightPhotoIndex = selectedIndex + 1;
    } else if (selectedIndex > 0) {
      _rightPhotoIndex = selectedIndex - 1;
    } else {
      _rightPhotoIndex = selectedIndex; // Only one photo
    }
  }
  
  void _selectThumbnail(int index) {
    if (index >= 0 && index < _sortedPhotos.length) {
      setState(() {
        // If clicking on a photo that's already selected, do nothing
        if (_leftPhotoIndex == index || _rightPhotoIndex == index) {
          return;
        }
        // Replace the active comparison photo with the selected thumbnail
        if (_isLeftActive) {
          _leftPhotoIndex = index;
        } else {
          _rightPhotoIndex = index;
        }
      });
    }
  }
  
  void _selectLeftPhoto() {
    // When left photo is tapped, make it active for replacement
    setState(() {
      _isLeftActive = true;
    });
  }
  
  void _selectRightPhoto() {
    // When right photo is tapped, make it active for replacement
    setState(() {
      _isLeftActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sortedPhotos.isEmpty) {
      return CupertinoPageScaffold(
        backgroundColor: ThemeHelper.background,
        child: const Center(child: Text('No photos available')),
      );
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = (screenWidth - 48) / 2; // Two images with spacing
    final imageHeight = imageWidth * (247 / 182); // Maintain aspect ratio
    
    return CupertinoPageScaffold(
      backgroundColor: ThemeHelper.background,
      child: Stack(
        children: [
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with back button at top
                  Padding(
                    padding: const EdgeInsets.only(left: 19, top: 18, right: 19, bottom: 18),
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
                  
                  // Title
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Text(
                        'Comparison Photos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ThemeHelper.textPrimary,
                          fontSize: 20,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Comparison images side by side
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left photo
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Left photo tap - selection is already synced with thumbnail list
                              _selectLeftPhoto();
                            },
                            child: Column(
                              children: [
                                // Label
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    _sortedPhotos[_leftPhotoIndex].label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: ThemeHelper.textPrimary,
                                      fontSize: 12,
                                      fontFamily: 'Instrument Sans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Image
                                Container(
                                  width: imageWidth,
                                  height: imageHeight,
                                  decoration: BoxDecoration(
                                    color: ThemeHelper.cardBackground,
                                    border: Border.all(
                                      color: ThemeHelper.textPrimary,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ThemeHelper.isLightMode
                                            ? Colors.black.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.3),
                                        blurRadius: 0,
                                        offset: const Offset(0, 0),
                                        spreadRadius: 1,
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: _sortedPhotos[_leftPhotoIndex].isNetwork
                                          ? NetworkImage(_sortedPhotos[_leftPhotoIndex].imagePath) as ImageProvider
                                          : FileImage(File(_sortedPhotos[_leftPhotoIndex].imagePath)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 24),
                        
                        // Right photo
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Right photo tap - selection is already synced with thumbnail list
                              _selectRightPhoto();
                            },
                            child: Column(
                              children: [
                                // Label
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    _sortedPhotos[_rightPhotoIndex].label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: ThemeHelper.textPrimary,
                                      fontSize: 12,
                                      fontFamily: 'Instrument Sans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Image
                                Container(
                                  width: imageWidth,
                                  height: imageHeight,
                                  decoration: BoxDecoration(
                                    color: ThemeHelper.cardBackground,
                                    border: Border.all(
                                      color: ThemeHelper.textPrimary,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ThemeHelper.isLightMode
                                            ? Colors.black.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.3),
                                        blurRadius: 0,
                                        offset: const Offset(0, 0),
                                        spreadRadius: 1,
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: _sortedPhotos[_rightPhotoIndex].isNetwork
                                          ? NetworkImage(_sortedPhotos[_rightPhotoIndex].imagePath) as ImageProvider
                                          : FileImage(File(_sortedPhotos[_rightPhotoIndex].imagePath)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Bottom padding to prevent content from being hidden behind thumbnails
                  SizedBox(height: 120),
                ],
              ),
            ),
          ),
            
          // Thumbnail gallery positioned at bottom of screen
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 95,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                itemCount: _sortedPhotos.length,
                itemBuilder: (context, index) {
                  final photo = _sortedPhotos[index];
                  final isLeftSelected = index == _leftPhotoIndex;
                  final isRightSelected = index == _rightPhotoIndex;
                  final isSelected = isLeftSelected || isRightSelected;
                  
                  // Selected thumbnails are 10% bigger
                  const baseWidth = 64.0;
                  const baseHeight = 86.0;
                  const selectedWidth = baseWidth * 1.1; // 10% bigger = 70.4
                  const selectedHeight = baseHeight * 1.1; // 10% bigger = 94.6
                  
                  return GestureDetector(
                    onTap: () => _selectThumbnail(index),
                    child: Container(
                      width: isSelected ? selectedWidth : baseWidth,
                      height: isSelected ? selectedHeight : baseHeight,
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 8,
                        right: index == _sortedPhotos.length - 1 ? 0 : 8,
                      ),
                      decoration: ShapeDecoration(
                        color: ThemeHelper.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: isSelected 
                                ? ThemeHelper.textPrimary 
                                : Colors.transparent,
                            width: isSelected ? 2 : 0,
                          ),
                        ),
                        shadows: isSelected ? [
                          BoxShadow(
                            color: ThemeHelper.isLightMode
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.5),
                            blurRadius: 0,
                            offset: const Offset(0, 0),
                            spreadRadius: 1,
                          ),
                        ] : [],
                        image: DecorationImage(
                          image: photo.isNetwork
                              ? NetworkImage(photo.imagePath) as ImageProvider
                              : FileImage(File(photo.imagePath)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'progress_photos_screen.dart' show ProgressPhotoItem;
import '../utils/theme_helper.dart';
import 'progress_photo_compare_screen.dart';
import '../services/progress_service.dart';

class ProgressPhotoDetailScreen extends StatefulWidget {
  final List<ProgressPhotoItem> photos;
  final int initialIndex;
  final Future<List<ProgressPhotoItem>> Function(int page)? onLoadMore;
  final void Function(String photoId)? onPhotoDeleted;
  
  const ProgressPhotoDetailScreen({
    super.key,
    required this.photos,
    this.initialIndex = 0,
    this.onLoadMore,
    this.onPhotoDeleted,
  });

  @override
  State<ProgressPhotoDetailScreen> createState() => _ProgressPhotoDetailScreenState();
}

class _ProgressPhotoDetailScreenState extends State<ProgressPhotoDetailScreen> {
  late int _selectedIndex;
  late List<ProgressPhotoItem> _allPhotos;
  final ScrollController _scrollController = ScrollController();
  final ProgressService _progressService = ProgressService();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isDeleting = false;
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _allPhotos = List<ProgressPhotoItem>.from(widget.photos);
    _sortPhotos();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _sortPhotos() {
    // Sort all photos by takenAt (newest first)
    _allPhotos.sort((a, b) {
      if (a.takenAt == null && b.takenAt == null) return 0;
      if (a.takenAt == null) return 1;
      if (b.takenAt == null) return -1;
      final da = DateTime.tryParse(a.takenAt!)?.millisecondsSinceEpoch ?? 0;
      final db = DateTime.tryParse(b.takenAt!)?.millisecondsSinceEpoch ?? 0;
      return db.compareTo(da); // Descending order (newest first)
    });
    
    // Ensure selected photo is visible in thumbnails
    if (_selectedIndex < _allPhotos.length) {
      final selectedPhoto = _allPhotos[_selectedIndex];
      final selectedIndex = _allPhotos.indexWhere((p) => 
        p.imagePath == selectedPhoto.imagePath && 
        p.takenAt == selectedPhoto.takenAt
      );
      if (selectedIndex != -1 && selectedIndex != _selectedIndex) {
        _selectedIndex = selectedIndex;
      }
    }
  }
  
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      // Near the end, load more
      _loadMorePhotos();
    }
  }
  
  Future<void> _loadMorePhotos() async {
    if (_isLoadingMore || !_hasMore || widget.onLoadMore == null) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      final newPhotos = await widget.onLoadMore!(_currentPage + 1);
      if (newPhotos.isEmpty) {
        setState(() {
          _hasMore = false;
        });
      } else {
        setState(() {
          _allPhotos.addAll(newPhotos);
          _currentPage++;
          _sortPhotos();
        });
      }
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }
  
  void _selectPhoto(int index) {
    if (index >= 0 && index < _allPhotos.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  
  void _selectThumbnail(int thumbnailIndex) {
    if (thumbnailIndex >= 0 && thumbnailIndex < _allPhotos.length) {
      _selectPhoto(thumbnailIndex);
    }
  }
  
  void _handleCompare() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => ProgressPhotoCompareScreen(
          photos: _allPhotos,
          initialIndex: _selectedIndex,
        ),
      ),
    );
  }
  
  void _handleDelete() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ThemeHelper.textPrimary,
              ),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              await _deletePhoto();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deletePhoto() async {
    if (_isDeleting || _selectedIndex >= _allPhotos.length) return;
    
    final selectedPhoto = _allPhotos[_selectedIndex];
    final photoId = selectedPhoto.photoId;
    
    if (photoId == null || photoId.isEmpty) {
      // If no photo ID, just remove from local list and close
      setState(() {
        _allPhotos.removeAt(_selectedIndex);
        if (_selectedIndex >= _allPhotos.length && _allPhotos.isNotEmpty) {
          _selectedIndex = _allPhotos.length - 1;
        } else if (_allPhotos.isEmpty) {
          Navigator.of(context).pop(); // Close detail screen if no photos left
          if (photoId != null && photoId.isNotEmpty) {
            widget.onPhotoDeleted?.call(photoId);
          }
          return;
        }
      });
      Navigator.of(context).pop(); // Close detail screen
      if (photoId != null && photoId.isNotEmpty) {
        widget.onPhotoDeleted?.call(photoId);
      }
      return;
    }
    
    setState(() {
      _isDeleting = true;
    });
    
    try {
      // Optimistically remove from local list
      setState(() {
        _allPhotos.removeAt(_selectedIndex);
        if (_selectedIndex >= _allPhotos.length && _allPhotos.isNotEmpty) {
          _selectedIndex = _allPhotos.length - 1;
        } else if (_allPhotos.isEmpty) {
          Navigator.of(context).pop(); // Close detail screen if no photos left
          widget.onPhotoDeleted?.call(photoId);
          return;
        }
      });
      
      // Call delete API
      final result = await _progressService.deleteProgressPhoto(photoId: photoId);
      
      if (result != null && result['success'] == true) {
        // Success - already removed optimistically
        Navigator.of(context).pop(); // Close detail screen
        widget.onPhotoDeleted?.call(photoId);
      } else {
        // If delete failed, we could reload the photo, but for now just close
        Navigator.of(context).pop(); // Close detail screen
        widget.onPhotoDeleted?.call(photoId);
      }
    } catch (e) {
      // On error, still close and refresh (photo was already removed optimistically)
      Navigator.of(context).pop(); // Close detail screen
      widget.onPhotoDeleted?.call(photoId);
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_allPhotos.isEmpty) {
      return CupertinoPageScaffold(
        backgroundColor: ThemeHelper.background,
        child: const Center(child: Text('No photos available')),
      );
    }
    
    if (_selectedIndex >= _allPhotos.length) {
      _selectedIndex = 0;
    }
    
    final selectedPhoto = _allPhotos[_selectedIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    final mainImageHeight = screenWidth * (535 / 393) * 0.85; // 15% smaller
    
    return CupertinoPageScaffold(
      backgroundColor: ThemeHelper.background,
      child: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Header with back button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 18),
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
                
                // Weight and date label
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Text(
                      selectedPhoto.label,
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
                
                const SizedBox(height: 12),
                
                // Main image
                Container(
                  width: screenWidth,
                  height: mainImageHeight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: selectedPhoto.isNetwork
                          ? NetworkImage(selectedPhoto.imagePath) as ImageProvider
                          : FileImage(File(selectedPhoto.imagePath)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Thumbnail gallery (all photos)
                if (_allPhotos.length > 1) ...[
                  SizedBox(
                    height: 95,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      itemCount: _allPhotos.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _allPhotos.length) {
                          // Loading indicator at the end
                          return Container(
                            width: 64,
                            height: 86,
                            margin: const EdgeInsets.only(left: 8),
                            child: const Center(
                              child: CupertinoActivityIndicator(),
                            ),
                          );
                        }
                        
                        final photo = _allPhotos[index];
                        final isSelected = index == _selectedIndex;
                        
                        return GestureDetector(
                          onTap: () => _selectThumbnail(index),
                          child: Container(
                            width: isSelected ? 72 : 64,
                            height: isSelected ? 97 : 86,
                            margin: EdgeInsets.only(
                              left: index == 0 ? 0 : 8,
                              right: index == _allPhotos.length - 1 ? 0 : 8,
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
                    const SizedBox(height: 20),
                  ] else ...[
                    const SizedBox(height: 100),
                  ],
                  
                  // Bottom padding to prevent content from being hidden behind buttons
                  SizedBox(height: 100 + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          
            // Bottom buttons
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: 31,
                  right: 31,
                  top: 20,
                  bottom: 20 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: ThemeHelper.background,
                  boxShadow: [
                    BoxShadow(
                      color: ThemeHelper.isLightMode
                          ? Colors.black.withOpacity(0.1)
                          : Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Compare button
                  Expanded(
                    child: GestureDetector(
                      onTap: _handleCompare,
                      child: Container(
                        height: 40,
                        decoration: ShapeDecoration(
                          color: ThemeHelper.cardBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          shadows: [
                            BoxShadow(
                              color: ThemeHelper.isLightMode
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.4),
                              blurRadius: 5,
                              offset: const Offset(0, 0),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Compare',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ThemeHelper.textPrimary,
                              fontSize: 16,
                              fontFamily: 'Instrument Sans',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 32),
                  
                  // Delete button
                  Expanded(
                    child: GestureDetector(
                      onTap: _handleDelete,
                      child: Container(
                        height: 40,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFDB5B5B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          shadows: [
                            BoxShadow(
                              color: ThemeHelper.isLightMode
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.4),
                              blurRadius: 5,
                              offset: const Offset(0, 0),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Delete',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Instrument Sans',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
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


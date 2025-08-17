import 'package:flutter/material.dart';
import 'dart:io';
import '../services/firebase_storage_service.dart';
import '../../core/constants/theme_constants.dart';

class ImageUploadWidget extends StatefulWidget {
  final String folder;
  final String? currentImageUrl;
  final Function(String) onImageUploaded;
  final Function()? onImageDeleted;
  final double width;
  final double height;
  final String? label;
  final bool showDeleteButton;

  const ImageUploadWidget({
    super.key,
    required this.folder,
    this.currentImageUrl,
    required this.onImageUploaded,
    this.onImageDeleted,
    this.width = 120,
    this.height = 120,
    this.label,
    this.showDeleteButton = true,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final FirebaseStorageService _storageService = FirebaseStorageService();
  bool _isUploading = false;
  String? _tempImagePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeConstants.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: _buildImageContent(),
          ),
        ),
        if (widget.showDeleteButton && 
            (widget.currentImageUrl != null || _tempImagePath != null)) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _deleteImage,
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Futa Picha'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageContent() {
    if (_isUploading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text(
              'Inaweka...',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (_tempImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(_tempImagePath!),
          fit: BoxFit.cover,
          width: widget.width,
          height: widget.height,
        ),
      );
    }

    if (widget.currentImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          widget.currentImageUrl!,
          fit: BoxFit.cover,
          width: widget.width,
          height: widget.height,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: 32,
          color: ThemeConstants.primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          'Weka Picha',
          style: TextStyle(
            fontSize: 12,
            color: ThemeConstants.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    if (_isUploading) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chagua Picha',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ThemeConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 30,
              color: ThemeConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    setState(() => _isUploading = true);
    
    try {
      final imageUrl = await _storageService.pickAndUploadFromCamera(widget.folder);
      if (imageUrl != null) {
        widget.onImageUploaded(imageUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Picha imewekwa kikamilifu!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hitilafu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() => _isUploading = true);
    
    try {
      final imageUrl = await _storageService.pickAndUploadFromGallery(widget.folder);
      if (imageUrl != null) {
        widget.onImageUploaded(imageUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Picha imewekwa kikamilifu!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hitilafu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteImage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Futa Picha'),
        content: const Text('Una uhakika unataka kufuta picha hii?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ghairi'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Futa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isUploading = true);
      
      try {
        if (widget.currentImageUrl != null) {
          await _storageService.deleteImage(widget.currentImageUrl!);
        }
        
        setState(() {
          _tempImagePath = null;
        });
        
        if (widget.onImageDeleted != null) {
          widget.onImageDeleted!();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Picha imefutwa!'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hitilafu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Get the app's documents directory for storing images
  Future<Directory> get _appDocumentsDir async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  /// Save image from file to local storage
  Future<String?> saveImageFromFile(File imageFile) async {
    try {
      final imagesDir = await _appDocumentsDir;
      final fileName = _generateFileName(imageFile.path);
      final savedFile = await imageFile.copy('${imagesDir.path}/$fileName');
      return savedFile.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  /// Save image from bytes to local storage
  Future<String?> saveImageFromBytes(
    Uint8List imageBytes,
    String extension,
  ) async {
    try {
      final imagesDir = await _appDocumentsDir;
      final fileName = _generateFileName('image.$extension');
      final file = File('${imagesDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      print('Error saving image from bytes: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return await saveImageFromFile(File(image.path));
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return await saveImageFromFile(File(image.path));
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Get image file from path
  Future<File?> getImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error getting image file: $e');
      return null;
    }
  }

  /// Delete image from local storage
  Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Get all stored images
  Future<List<String>> getAllStoredImages() async {
    try {
      final imagesDir = await _appDocumentsDir;
      final files = imagesDir.listSync();
      return files
          .where((file) => file is File && _isImageFile(file.path))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      print('Error getting stored images: $e');
      return [];
    }
  }

  /// Clear all stored images
  Future<bool> clearAllImages() async {
    try {
      final imagesDir = await _appDocumentsDir;
      final files = imagesDir.listSync();
      for (final file in files) {
        if (file is File && _isImageFile(file.path)) {
          await file.delete();
        }
      }
      return true;
    } catch (e) {
      print('Error clearing images: $e');
      return false;
    }
  }

  /// Generate unique filename based on timestamp and hash
  String _generateFileName(String originalPath) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = md5.convert(utf8.encode(originalPath + timestamp.toString()));
    final extension = originalPath.split('.').last;
    return '${timestamp}_${hash.toString().substring(0, 8)}.$extension';
  }

  /// Check if file is an image
  bool _isImageFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// Get storage size info
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final imagesDir = await _appDocumentsDir;
      final files = imagesDir.listSync();
      int totalSize = 0;
      int imageCount = 0;

      for (final file in files) {
        if (file is File && _isImageFile(file.path)) {
          totalSize += await file.length();
          imageCount++;
        }
      }

      return {
        'totalSize': totalSize,
        'imageCount': imageCount,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      print('Error getting storage info: $e');
      return {'totalSize': 0, 'imageCount': 0, 'totalSizeMB': '0.00'};
    }
  }
}

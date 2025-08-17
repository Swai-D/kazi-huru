import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseStorageService {
  static final FirebaseStorageService _instance =
      FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Upload image from file to Firebase Storage
  Future<String?> uploadImageFromFile(File imageFile, String folder) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        return null;
      }

      final fileName = _generateFileName(imageFile.path);
      final storageRef = _storage.ref().child('$folder/${user.uid}/$fileName');

      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload image from bytes to Firebase Storage
  Future<String?> uploadImageFromBytes(
    Uint8List imageBytes,
    String folder,
    String extension,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        return null;
      }

      final fileName = _generateFileName('image.$extension');
      final storageRef = _storage.ref().child('$folder/${user.uid}/$fileName');

      final uploadTask = storageRef.putData(imageBytes);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image from bytes: $e');
      return null;
    }
  }

  /// Pick and upload image from camera
  Future<String?> pickAndUploadFromCamera(String folder) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return await uploadImageFromFile(File(image.path), folder);
      }
      return null;
    } catch (e) {
      print('Error picking and uploading from camera: $e');
      return null;
    }
  }

  /// Pick and upload image from gallery
  Future<String?> pickAndUploadFromGallery(String folder) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return await uploadImageFromFile(File(image.path), folder);
      }
      return null;
    } catch (e) {
      print('Error picking and uploading from gallery: $e');
      return null;
    }
  }

  /// Delete image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('Image deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Get all images for a user in a specific folder
  Future<List<String>> getUserImages(String folder) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        return [];
      }

      final storageRef = _storage.ref().child('$folder/${user.uid}');
      final result = await storageRef.listAll();

      final urls = <String>[];
      for (final item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      print('Error getting user images: $e');
      return [];
    }
  }

  /// Upload profile picture
  Future<String?> uploadProfilePicture(File imageFile) async {
    return await uploadImageFromFile(imageFile, 'profile_pictures');
  }

  /// Upload job image
  Future<String?> uploadJobImage(File imageFile) async {
    return await uploadImageFromFile(imageFile, 'job_images');
  }

  /// Upload ID verification document
  Future<String?> uploadIdDocument(File imageFile) async {
    return await uploadImageFromFile(imageFile, 'id_documents');
  }

  /// Upload company logo
  Future<String?> uploadCompanyLogo(File imageFile) async {
    return await uploadImageFromFile(imageFile, 'company_logos');
  }

  /// Upload chat image
  Future<String?> uploadChatImage(File imageFile) async {
    return await uploadImageFromFile(imageFile, 'chat_images');
  }

  /// Generate unique filename
  String _generateFileName(String originalPath) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalPath.split('.').last;
    return '${timestamp}_${DateTime.now().microsecondsSinceEpoch}.$extension';
  }

  /// Get storage usage info for current user
  Future<Map<String, dynamic>> getStorageUsage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'totalSize': 0, 'totalSizeMB': '0.00', 'fileCount': 0};
      }

      int totalSize = 0;
      int fileCount = 0;

      // Check all folders
      final folders = [
        'profile_pictures',
        'job_images',
        'id_documents',
        'company_logos',
        'chat_images',
      ];

      for (final folder in folders) {
        try {
          final storageRef = _storage.ref().child('$folder/${user.uid}');
          final result = await storageRef.listAll();

          for (final item in result.items) {
            final metadata = await item.getMetadata();
            totalSize += metadata.size ?? 0;
            fileCount++;
          }
        } catch (e) {
          // Folder might not exist, continue
          continue;
        }
      }

      return {
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'fileCount': fileCount,
      };
    } catch (e) {
      print('Error getting storage usage: $e');
      return {'totalSize': 0, 'totalSizeMB': '0.00', 'fileCount': 0};
    }
  }

  /// Clear all user images (for account deletion)
  Future<bool> clearAllUserImages() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        return false;
      }

      final folders = [
        'profile_pictures',
        'job_images',
        'id_documents',
        'company_logos',
        'chat_images',
      ];

      for (final folder in folders) {
        try {
          final storageRef = _storage.ref().child('$folder/${user.uid}');
          final result = await storageRef.listAll();

          for (final item in result.items) {
            await item.delete();
          }
        } catch (e) {
          // Folder might not exist, continue
          continue;
        }
      }

      print('All user images cleared successfully');
      return true;
    } catch (e) {
      print('Error clearing user images: $e');
      return false;
    }
  }
}

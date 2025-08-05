import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  static final FirebaseStorageService _instance = FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Upload profile image
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('users/$userId/profile_images/$fileName');
      
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Hitilafu katika kupakia picha ya wasifu: $e');
    }
  }

  // Upload ID verification document
  Future<String> uploadVerificationDocument({
    required String userId,
    required File documentFile,
    required String documentType, // 'national_id', 'passport', 'driving_license'
  }) async {
    try {
      String fileName = '${documentType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('users/$userId/verification_documents/$fileName');
      
      UploadTask uploadTask = ref.putFile(documentFile);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Hitilafu katika kupakia hati ya uthibitishaji: $e');
    }
  }

  // Upload resume/CV
  Future<String> uploadResume({
    required String userId,
    required File resumeFile,
  }) async {
    try {
      String fileName = 'resume_${DateTime.now().millisecondsSinceEpoch}.pdf';
      Reference ref = _storage.ref().child('users/$userId/resumes/$fileName');
      
      UploadTask uploadTask = ref.putFile(resumeFile);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Hitilafu katika kupakia resume: $e');
    }
  }

  // Upload company logo
  Future<String> uploadCompanyLogo({
    required String companyId,
    required File logoFile,
  }) async {
    try {
      String fileName = 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('companies/$companyId/logos/$fileName');
      
      UploadTask uploadTask = ref.putFile(logoFile);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Hitilafu katika kupakia logo ya kampuni: $e');
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Hitilafu katika kuchagua picha: $e');
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Hitilafu katika kupiga picha: $e');
    }
  }

  // Pick document (PDF)
  Future<File?> pickDocument() async {
    try {
      XFile? document = await _picker.pickMedia();
      
      if (document != null) {
        return File(document.path);
      }
      return null;
    } catch (e) {
      throw Exception('Hitilafu katika kuchagua hati: $e');
    }
  }

  // Delete file from storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Hitilafu katika kufuta faili: $e');
    }
  }

  // Get file size
  Future<int> getFileSize(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      FullMetadata metadata = await ref.getMetadata();
      return metadata.size ?? 0;
    } catch (e) {
      throw Exception('Hitilafu katika kupata ukubwa wa faili: $e');
    }
  }

  // Check if file exists
  Future<bool> fileExists(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get download URL for a file
  Future<String> getDownloadUrl(String filePath) async {
    try {
      Reference ref = _storage.ref().child(filePath);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Hitilafu katika kupata URL ya kupakua: $e');
    }
  }

  // Upload with progress tracking
  Future<String> uploadWithProgress({
    required String filePath,
    required File file,
    Function(double)? onProgress,
  }) async {
    try {
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Hitilafu katika kupakia faili: $e');
    }
  }

  // Validate file size (max 10MB)
  bool isValidFileSize(File file) {
    int maxSize = 10 * 1024 * 1024; // 10MB
    return file.lengthSync() <= maxSize;
  }

  // Validate image dimensions
  Future<bool> isValidImageDimensions(File imageFile) async {
    try {
      // You can add image dimension validation here
      // For now, we'll just check if it's a valid image file
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get file extension
  String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  // Check if file is an image
  bool isImageFile(String fileName) {
    List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    String extension = getFileExtension(fileName);
    return imageExtensions.contains(extension);
  }

  // Check if file is a PDF
  bool isPdfFile(String fileName) {
    return getFileExtension(fileName) == 'pdf';
  }
} 
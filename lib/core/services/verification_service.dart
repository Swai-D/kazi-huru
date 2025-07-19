import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/verification_model.dart';

class VerificationService {
  static final VerificationService _instance = VerificationService._internal();
  factory VerificationService() => _instance;
  VerificationService._internal();

  // Mock data for demonstration
  final Map<String, VerificationModel> _verifications = {};

  // Get verification status for a user
  VerificationModel? getVerificationStatus(String userId) {
    return _verifications[userId];
  }

  // Submit ID verification
  Future<bool> submitVerification({
    required String userId,
    required String idNumber,
    required String fullName,
    required File idImage,
  }) async {
    try {
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));
      
      final verification = VerificationModel(
        userId: userId,
        idNumber: idNumber,
        fullName: fullName,
        idImageUrl: 'mock_image_url_$userId.jpg', // In real app, upload to storage
        status: VerificationStatus.pending,
        submittedAt: DateTime.now(),
      );
      
      _verifications[userId] = verification;
      return true;
    } catch (e) {
      print('Error submitting verification: $e');
      return false;
    }
  }

  // Admin: Verify a user's ID
  Future<bool> verifyUser(String userId, String adminId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final verification = _verifications[userId];
      if (verification != null) {
        _verifications[userId] = verification.copyWith(
          status: VerificationStatus.verified,
          verifiedAt: DateTime.now(),
          verifiedBy: adminId,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error verifying user: $e');
      return false;
    }
  }

  // Admin: Reject a user's ID
  Future<bool> rejectUser(String userId, String reason, String adminId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final verification = _verifications[userId];
      if (verification != null) {
        _verifications[userId] = verification.copyWith(
          status: VerificationStatus.rejected,
          rejectionReason: reason,
          verifiedAt: DateTime.now(),
          verifiedBy: adminId,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error rejecting user: $e');
      return false;
    }
  }

  // Get all pending verifications (for admin)
  List<VerificationModel> getPendingVerifications() {
    return _verifications.values
        .where((v) => v.status == VerificationStatus.pending)
        .toList();
  }

  // Check if user is verified
  bool isUserVerified(String userId) {
    final verification = _verifications[userId];
    return verification?.status == VerificationStatus.verified;
  }

  // Pick image from camera or gallery
  Future<File?> pickImage({bool fromCamera = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
} 
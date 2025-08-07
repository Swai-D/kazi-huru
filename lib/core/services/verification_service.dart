import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'notification_service.dart';
import '../models/verification_model.dart';

enum VerificationStatus {
  pending,
  approved,
  rejected,
}

class VerificationService {
  static final VerificationService _instance = VerificationService._internal();
  factory VerificationService() => _instance;
  VerificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // Submit ID verification
  Future<bool> submitVerification({
    required String userId,
    required String idNumber,
    required String idType,
    required String frontImageUrl,
    required String backImageUrl,
    String? selfieImageUrl,
  }) async {
    try {
      await _firestore.collection('verifications').add({
        'userId': userId,
        'idNumber': idNumber,
        'idType': idType,
        'frontImageUrl': frontImageUrl,
        'backImageUrl': backImageUrl,
        'selfieImageUrl': selfieImageUrl,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error submitting verification: $e');
      return false;
    }
  }

  // Update verification status (admin function)
  Future<bool> updateVerificationStatus({
    required String verificationId,
    required String userId,
    required VerificationStatus status,
    String? rejectionReason,
  }) async {
    try {
      await _firestore.collection('verifications').doc(verificationId).update({
        'status': status.name,
        'rejectionReason': rejectionReason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to user
      await _notificationService.sendVerificationNotification(
        userId: userId,
        isApproved: status == VerificationStatus.approved,
      );

      return true;
    } catch (e) {
      print('Error updating verification status: $e');
      return false;
    }
  }

  // Get verification status for a user
  Future<Map<String, dynamic>?> getVerificationStatus(String userId) async {
    try {
      final query = await _firestore
          .collection('verifications')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        data['id'] = query.docs.first.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting verification status: $e');
      return null;
    }
  }

  // Get all pending verifications (admin function) as List<VerificationModel>
  Stream<List<VerificationModel>> getPendingVerifications() {
    return _firestore
        .collection('verifications')
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return VerificationModel.fromMap(data, doc.id);
            }).toList());
  }

  // Get all verifications for admin
  Stream<QuerySnapshot> getAllVerifications() {
    return _firestore
        .collection('verifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Check if user is verified
  Future<bool> isUserVerified(String userId) async {
    try {
      final verification = await getVerificationStatus(userId);
      return verification != null && verification['status'] == 'approved';
    } catch (e) {
      print('Error checking if user is verified: $e');
      return false;
    }
  }

  // Get verification by ID
  Future<Map<String, dynamic>?> getVerificationById(String verificationId) async {
    try {
      final doc = await _firestore.collection('verifications').doc(verificationId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting verification by ID: $e');
      return null;
    }
  }

  // Delete verification
  Future<bool> deleteVerification(String verificationId) async {
    try {
      await _firestore.collection('verifications').doc(verificationId).delete();
      return true;
    } catch (e) {
      print('Error deleting verification: $e');
      return false;
    }
  }

  // Get verification statistics
  Future<Map<String, int>> getVerificationStats() async {
    try {
      final pendingQuery = await _firestore
          .collection('verifications')
          .where('status', isEqualTo: 'pending')
          .get();

      final approvedQuery = await _firestore
          .collection('verifications')
          .where('status', isEqualTo: 'approved')
          .get();

      final rejectedQuery = await _firestore
          .collection('verifications')
          .where('status', isEqualTo: 'rejected')
          .get();

      return {
        'pending': pendingQuery.docs.length,
        'approved': approvedQuery.docs.length,
        'rejected': rejectedQuery.docs.length,
        'total': pendingQuery.docs.length + approvedQuery.docs.length + rejectedQuery.docs.length,
      };
    } catch (e) {
      print('Error getting verification stats: $e');
      return {
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'total': 0,
      };
    }
  }

  // Verify user (admin function)
  Future<bool> verifyUser(String userId, String adminId) async {
    try {
      final verification = await getVerificationStatus(userId);
      if (verification != null) {
        return await updateVerificationStatus(
          verificationId: verification['id'],
          userId: userId,
          status: VerificationStatus.approved,
        );
      }
      return false;
    } catch (e) {
      print('Error verifying user: $e');
      return false;
    }
  }

  // Reject user (admin function)
  Future<bool> rejectUser(String userId, String reason, String adminId) async {
    try {
      final verification = await getVerificationStatus(userId);
      if (verification != null) {
        return await updateVerificationStatus(
          verificationId: verification['id'],
          userId: userId,
          status: VerificationStatus.rejected,
          rejectionReason: reason,
        );
      }
      return false;
    } catch (e) {
      print('Error rejecting user: $e');
      return false;
    }
  }

  // Pick image from camera or gallery
  Future<File?> pickImage({bool fromCamera = false}) async {
    // Mock implementation - in real app, use image_picker package
    return null;
  }
} 
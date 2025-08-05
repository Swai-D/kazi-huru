import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthStatusChecker {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check current authentication status and log details
  static Future<void> checkAuthStatus() async {
    final user = _auth.currentUser;
    
    print('🔐 === AUTHENTICATION STATUS CHECK ===');
    print('Current user: ${user?.uid ?? 'None'}');
    print('Email: ${user?.email ?? 'None'}');
    print('Phone: ${user?.phoneNumber ?? 'None'}');
    print('Display name: ${user?.displayName ?? 'None'}');
    print('Email verified: ${user?.emailVerified ?? 'N/A'}');
    print('Phone verified: ${user?.phoneNumber != null}');
    
    if (user != null) {
      // Check if user profile exists in Firestore
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          print('✅ User profile exists in Firestore');
          print('Role: ${userData?['role'] ?? 'None'}');
          print('Name: ${userData?['name'] ?? 'None'}');
          print('Phone: ${userData?['phoneNumber'] ?? 'None'}');
          print('Created at: ${userData?['createdAt'] ?? 'None'}');
        } else {
          print('❌ User profile does not exist in Firestore');
        }
      } catch (e) {
        print('❌ Error checking user profile: $e');
      }
    }
    print('=====================================');
  }

  /// Check if user has complete profile
  static Future<bool> hasCompleteProfile(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return false;
      
      final userData = userDoc.data();
      return userData?['role'] != null && 
             userData?['name'] != null && 
             userData?['phoneNumber'] != null;
    } catch (e) {
      print('Error checking complete profile: $e');
      return false;
    }
  }

  /// Get user role from Firestore
  static Future<String?> getUserRole(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;
      
      return userDoc.data()?['role'];
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }
} 
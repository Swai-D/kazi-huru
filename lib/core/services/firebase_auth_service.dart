import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Phone number authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationCompleted,
    required Function(String) onVerificationFailed,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          onVerificationCompleted('Msimbo umetumwa kwenye simu yako');
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = 'Hitilafu katika uthibitishaji';
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Namba ya simu si sahihi';
              break;
            case 'too-many-requests':
              errorMessage = 'Umejaribu mara nyingi sana. Jaribu tena baada ya dakika chache';
              break;
            case 'quota-exceeded':
              errorMessage = 'Kikomo cha SMS kimekamilika. Jaribu tena kesho';
              break;
          }
          onVerificationFailed(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onVerificationFailed('Hitilafu ya mfumo: $e');
    }
  }

  // Verify SMS code
  Future<UserCredential?> verifySMSCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Msimbo si sahihi. Jaribu tena');
    }
  }

  // Email and password authentication
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Hitilafu katika kuingia';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Hakuna mtumiaji na barua pepe hii';
          break;
        case 'wrong-password':
          errorMessage = 'Nywila si sahihi';
          break;
        case 'invalid-email':
          errorMessage = 'Barua pepe si sahihi';
          break;
        case 'user-disabled':
          errorMessage = 'Akaunti imezimwa';
          break;
        case 'too-many-requests':
          errorMessage = 'Umejaribu mara nyingi sana. Jaribu tena baada ya dakika chache';
          break;
      }
      throw Exception(errorMessage);
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Hitilafu katika kujiregistrisha';
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Nywila ni dhaifu sana';
          break;
        case 'email-already-in-use':
          errorMessage = 'Barua pepe tayari inatumika';
          break;
        case 'invalid-email':
          errorMessage = 'Barua pepe si sahihi';
          break;
      }
      throw Exception(errorMessage);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Hitilafu katika kutoka');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      if (photoURL != null) {
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw Exception('Hitilafu katika kusasisha wasifu');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Hitilafu katika kutuma barua pepe ya kurejesha nywila';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Hakuna mtumiaji na barua pepe hii';
          break;
        case 'invalid-email':
          errorMessage = 'Barua pepe si sahihi';
          break;
      }
      throw Exception(errorMessage);
    }
  }

  // Delete user account
  Future<void> deleteUserAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      throw Exception('Hitilafu katika kufuta akaunti');
    }
  }
} 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'sms_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a random 6-digit OTP
  String _generateOTP() {
    Random random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // Send OTP via custom SMS service
  Future<String?> sendOTP(String phoneNumber) async {
    try {
      // Generate OTP
      String otp = _generateOTP();
      
      // Store OTP in Firestore with timestamp
      await _firestore.collection('otps').add({
        'phoneNumber': phoneNumber,
        'otp': otp,
        'timestamp': FieldValue.serverTimestamp(),
        'verified': false,
        'verifiedAt': null,
        'isUsed': false
      });

      // Send OTP via custom SMS service
      final smsSent = await SMSService.sendOTP(phoneNumber, otp);
      
      if (smsSent) {
        return otp;
      } else {
        throw Exception('Failed to send SMS');
      }
    } catch (e) {
      print('Error sending OTP: $e');
      rethrow;
    }
  }

  // Sign in with phone number
  Future<UserCredential> signInWithPhoneNumber(
    String phoneNumber,
    String? name,
    String? role,
  ) async {
    try {
      // First, check if user exists with this phone number
      final userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      UserCredential userCredential;

      if (userQuery.docs.isEmpty) {
        // Check if user exists with email
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          // User is already authenticated with email
          // Update user data in Firestore
          final userData = {
            'phoneNumber': phoneNumber,
            'isPhoneVerified': true,
            'updatedAt': FieldValue.serverTimestamp(),
          };
          
          await _firestore.collection('users').doc(currentUser.uid).update(userData);
          
          // Return a new credential for the current user
          return await _auth.signInWithEmailAndPassword(
            email: currentUser.email!,
            password: phoneNumber,
          );
        } else {
          // Create new user with email/password
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: '$phoneNumber@kazihuru.com',
            password: phoneNumber, // Use phone number as password
          );

          if (userCredential.user == null) {
            throw Exception('Failed to create user account');
          }

          // Store user data in Firestore
          final userData = {
            'phoneNumber': phoneNumber,
            'name': name ?? '',
            'role': role ?? 'job_seeker',
            'createdAt': FieldValue.serverTimestamp(),
            'isProfileComplete': false,
            'isPhoneVerified': true,
            'email': '$phoneNumber@kazihuru.com',
            'uid': userCredential.user!.uid,
          };

          await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);
        }
      } else {
        // Get the existing user document
        final userDoc = userQuery.docs.first;
        final userData = userDoc.data();
        final userEmail = userData['email'] as String? ?? '$phoneNumber@kazihuru.com';

        // Sign in existing user
        userCredential = await _auth.signInWithEmailAndPassword(
          email: userEmail,
          password: phoneNumber,
        );

        if (userCredential.user == null) {
          throw Exception('Failed to sign in user');
        }

        // Update phone verification status
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'isPhoneVerified': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Akaunti hii tayari inatumika';
          break;
        case 'invalid-email':
          errorMessage = 'Barua pepe si sahihi';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Operesheni hii haijaruhusiwa';
          break;
        case 'weak-password':
          errorMessage = 'Nywila ni dhaifu sana';
          break;
        case 'user-not-found':
          errorMessage = 'Mtumiaji hajapatikana';
          break;
        case 'wrong-password':
          errorMessage = 'Nywila si sahihi';
          break;
        default:
          errorMessage = 'Hitilafu imetokea. Tafadhali jaribu tena';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Error in signInWithPhoneNumber: $e');
      throw Exception('Hitilafu imetokea. Tafadhali jaribu tena');
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    try {
      // Query for the most recent OTP document for this phone number
      final otpQuery = await _firestore
          .collection('otps')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (otpQuery.docs.isEmpty) {
        return false;
      }

      final otpDoc = otpQuery.docs.first;
      final data = otpDoc.data();
      
      // Check if OTP matches and is not expired (5 minutes validity)
      if (data['otp'] != otp || 
          data['timestamp'] == null ||
          DateTime.now().difference((data['timestamp'] as Timestamp).toDate()).inMinutes >= 5) {
        return false;
      }

      // Mark OTP as verified
      await otpDoc.reference.update({
        'verified': true,
        'verifiedAt': FieldValue.serverTimestamp()
      });

      return true;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('Starting user creation with email: $email');
      print('Attempting to create user in Firebase Auth...');
      
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User created successfully with UID: ${userCredential.user?.uid}');
      
      if (userCredential.user == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'Imeshindwa kuunda akaunti. Tafadhali jaribu tena',
        );
      }

      // Verify user was created successfully
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != userCredential.user!.uid) {
        throw FirebaseAuthException(
          code: 'user-verification-failed',
          message: 'Imeshindwa kuthibitisha akaunti. Tafadhali jaribu tena',
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception in createUserWithEmailAndPassword: ${e.code} - ${e.message}');
      String errorMessage;
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Barua pepe hii tayari inatumika';
          break;
        case 'invalid-email':
          errorMessage = 'Barua pepe si sahihi';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Kusajiliwa na barua pepe hakijaruhusiwa';
          break;
        case 'weak-password':
          errorMessage = 'Nywila ni dhaifu sana';
          break;
        default:
          errorMessage = e.message ?? 'Hitilafu imetokea. Tafadhali jaribu tena';
      }
      
      throw FirebaseAuthException(
        code: e.code,
        message: errorMessage,
      );
    } catch (e) {
      print('Unexpected error in createUserWithEmailAndPassword: $e');
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: 'Hitilafu isiyotarajiwa imetokea. Tafadhali jaribu tena',
      );
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Save user data to Firestore
  Future<void> saveUserData(String uid, Map<String, dynamic> userData) async {
    try {
      print('Saving user data to Firestore for UID: $uid');
      print('User data: $userData');

      // Verify user exists in Firebase Auth
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != uid) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Mtumiaji hajapatikana. Tafadhali jaribu tena',
        );
      }

      // Check if user document already exists
      final userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (userDoc.exists) {
        print('Updating existing user document...');
        // Update existing user document
        await _firestore.collection('users').doc(uid).update({
          ...userData,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        print('Creating new user document...');
        // Create new user document
        await _firestore.collection('users').doc(uid).set({
          ...userData,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      print('User data saved successfully');
    } on FirebaseException catch (e) {
      print('Firebase Exception in saveUserData: ${e.code} - ${e.message}');
      throw FirebaseAuthException(
        code: e.code,
        message: 'Imeshindwa kuhifadhi taarifa za mtumiaji. Tafadhali jaribu tena',
      );
    } catch (e) {
      print('Unexpected error in saveUserData: $e');
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: 'Hitilafu isiyotarajiwa imetokea. Tafadhali jaribu tena',
      );
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data');
    }
  }

  // Check if username is taken
  Future<bool> isUsernameTaken(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  // Handle Firebase Auth exceptions
  FirebaseAuthException _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'weak-password':
        message = 'Nywila ni dhaifu sana';
        break;
      case 'email-already-in-use':
        message = 'Barua pepe tayari inatumika';
        break;
      case 'invalid-email':
        message = 'Barua pepe si sahihi';
        break;
      case 'operation-not-allowed':
        message = 'Operesheni hii haijaruhusiwa';
        break;
      case 'user-disabled':
        message = 'Akaunti hii imezimwa';
        break;
      case 'user-not-found':
        message = 'Hakuna akaunti inayopatikana';
        break;
      case 'wrong-password':
        message = 'Nywila si sahihi';
        break;
      case 'invalid-verification-code':
        message = 'Namba ya uthibitishaji si sahihi';
        break;
      case 'invalid-verification-id':
        message = 'Kitambulisho cha uthibitishaji si sahihi';
        break;
      default:
        message = 'Hitilafu imetokea. Tafadhali jaribu tena';
    }
    return FirebaseAuthException(
      code: e.code,
      message: message,
    );
  }
} 
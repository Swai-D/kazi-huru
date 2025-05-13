import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'sms_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a random 6-digit OTP
  String _generateOTP() {
    Random random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // Format phone number to +255 format
  String _formatPhoneNumber(String phoneNumber) {
    String formatted = phoneNumber.trim();
    
    // Remove any spaces or special characters
    formatted = formatted.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Handle different formats
    if (formatted.startsWith('0')) {
      // Convert 07... to +2557...
      formatted = '+255${formatted.substring(1)}';
    } else if (!formatted.startsWith('+255')) {
      // Add +255 if no country code
      formatted = '+255$formatted';
    }
    
    return formatted;
  }

  // Send OTP via custom SMS service
  Future<String?> sendOTP(String phoneNumber) async {
    try {
      // Format phone number
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      print('Sending OTP to formatted number: $formattedPhone');
      
      // Generate OTP
      String otp = _generateOTP();
      
      // Store OTP in Firestore with timestamp
      await _firestore.collection('otps').add({
        'phoneNumber': formattedPhone,
        'otp': otp,
        'timestamp': FieldValue.serverTimestamp(),
        'verified': false,
        'verifiedAt': null,
        'isUsed': false
      });

      // Send OTP via custom SMS service
      final smsSent = await SMSService.sendOTP(formattedPhone, otp);
      
      if (smsSent) {
        return 'success';
      } else {
        throw Exception('Imeshindwa kutuma SMS');
      }
    } catch (e) {
      print('Error sending OTP: $e');
      rethrow;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    try {
      // Query for the most recent OTP document for this phone number
      final otpQuery = await _firestore
          .collection('otps')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('isUsed', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (otpQuery.docs.isEmpty) {
        throw Exception('Namba ya uthibitishaji haijapatikana au imeisha muda wake');
      }

      final otpDoc = otpQuery.docs.first;
      final data = otpDoc.data();
      
      // Check if OTP matches and is not expired (5 minutes validity)
      if (data['otp'] != otp) {
        throw Exception('Namba ya uthibitishaji si sahihi');
      }

      if (data['timestamp'] == null ||
          DateTime.now().difference((data['timestamp'] as Timestamp).toDate()).inMinutes >= 5) {
        throw Exception('Namba ya uthibitishaji imeisha muda wake');
      }

      // Mark OTP as verified and used
      await otpDoc.reference.update({
        'verified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
        'isUsed': true
      });

      return true;
    } catch (e) {
      print('Error verifying OTP: $e');
      rethrow;
    }
  }

  // Register new user
  Future<UserCredential> registerUser({
    required String phoneNumber,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      print('Starting user registration...');
      
      // Format phone number
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      print('Registering user with formatted number: $formattedPhone');
      
      // Create user with email (using phone number as email)
      final email = '$formattedPhone@kazihuru.com';
      print('Creating user with email: $email');
      
      // Check if user already exists
      final existingUser = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        throw Exception('Namba ya simu hii tayari inatumika');
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User created successfully with UID: ${userCredential.user?.uid}');

      if (userCredential.user == null) {
        throw Exception('Imeshindwa kuunda akaunti. Tafadhali jaribu tena');
      }

      // Store user data in Firestore
      final userData = {
        'phoneNumber': formattedPhone,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'isProfileComplete': false,
        'email': email,
        'uid': userCredential.user!.uid,
      };

      print('Saving user data to Firestore...');
      await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);
      print('User data saved successfully');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception in registerUser: ${e.code} - ${e.message}');
      String errorMessage;
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Namba ya simu hii tayari inatumika';
          break;
        case 'invalid-email':
          errorMessage = 'Namba ya simu si sahihi';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Kusajiliwa na namba ya simu hakijaruhusiwa';
          break;
        case 'weak-password':
          errorMessage = 'Nywila ni dhaifu sana';
          break;
        default:
          errorMessage = e.message ?? 'Hitilafu imetokea. Tafadhali jaribu tena';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      print('Error in registerUser: $e');
      throw Exception('Hitilafu imetokea. Tafadhali jaribu tena');
    }
  }

  // Sign in with phone number and password
  Future<UserCredential> signInWithPhoneNumber(String phoneNumber, String password) async {
    try {
      print('Starting sign in process...');
      
      // Format phone number
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      print('Signing in with formatted number: $formattedPhone');
      
      // First check if user exists in Firestore
      final userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('Hakuna akaunti inayopatikana na namba hii ya simu');
      }

      final userData = userQuery.docs.first.data();
      final email = userData['email'] as String? ?? '$formattedPhone@kazihuru.com';

      print('Found user with email: $email');
      
      // Sign in with email and password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Sign in successful for user: ${userCredential.user?.uid}');

      if (userCredential.user == null) {
        throw Exception('Imeshindwa kuingia. Tafadhali jaribu tena');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception in signInWithPhoneNumber: ${e.code} - ${e.message}');
      String errorMessage;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Hakuna akaunti inayopatikana na namba hii ya simu';
          break;
        case 'wrong-password':
          errorMessage = 'Nywila si sahihi';
          break;
        case 'invalid-email':
          errorMessage = 'Namba ya simu si sahihi';
          break;
        case 'user-disabled':
          errorMessage = 'Akaunti hii imezimwa';
          break;
        default:
          errorMessage = e.message ?? 'Hitilafu imetokea. Tafadhali jaribu tena';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      print('Error in signInWithPhoneNumber: $e');
      throw Exception('Hitilafu imetokea. Tafadhali jaribu tena');
    }
  }

  // Get user role
  Future<String> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      return userDoc.data()?['role'] as String? ?? 'job_seeker';
    } catch (e) {
      print('Error getting user role: $e');
      rethrow;
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

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        // Create new user document if it doesn't exist
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'photoURL': userCredential.user!.photoURL,
          'role': 'job_seeker', // Default role
          'createdAt': FieldValue.serverTimestamp(),
          'isProfileComplete': false,
          'uid': userCredential.user!.uid,
        });
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign in with Facebook
  Future<UserCredential> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.token,
        );

        // Sign in to Firebase with the Facebook credential
        final userCredential = await _auth.signInWithCredential(credential);

        // Check if user exists in Firestore
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

        if (!userDoc.exists) {
          // Create new user document if it doesn't exist
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'name': userCredential.user!.displayName,
            'email': userCredential.user!.email,
            'photoURL': userCredential.user!.photoURL,
            'role': 'job_seeker', // Default role
            'createdAt': FieldValue.serverTimestamp(),
            'isProfileComplete': false,
            'uid': userCredential.user!.uid,
          });
        }

        return userCredential;
      } else {
        throw Exception('Facebook sign in was cancelled');
      }
    } catch (e) {
      print('Error signing in with Facebook: $e');
      rethrow;
    }
  }
} 
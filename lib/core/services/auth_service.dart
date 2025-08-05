import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'sms_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SMSService _smsService = SMSService();

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

  // Send OTP and return the actual OTP for development testing
  Future<String?> sendOTP(String phoneNumber) async {
    try {
      print('Sending OTP to formatted number: $phoneNumber');
      
      // Generate and send OTP via SMS service
      final otp = await _smsService.generateAndSendOTP(phoneNumber);
      
      if (otp != null) {
        print('✅ OTP sent successfully! OTP: $otp');
        print('📱 Check your phone for SMS');
        print('🔍 For debugging: This OTP should match what you receive via SMS');
        print('📋 OTP stored in Firestore with phone: ${phoneNumber.replaceAll('+', '').replaceAll(' ', '').startsWith('0') ? '255${phoneNumber.replaceAll('+', '').replaceAll(' ', '').substring(1)}' : phoneNumber.replaceAll('+', '').replaceAll(' ', '')}');
        return otp; // Return the actual OTP for development testing
      } else {
        print('❌ Failed to send OTP');
        return null;
      }
    } catch (e) {
      print('❌ Error in sendOTP: $e');
      return null;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    try {
      print('🔍 Verifying OTP: $otp for phone: $phoneNumber');
      
      // Format phone number consistently
      String formattedPhone = phoneNumber.replaceAll('+', '').replaceAll(' ', '');
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '255${formattedPhone.substring(1)}';
      } else if (formattedPhone.startsWith('255')) {
        // Already formatted
      } else if (formattedPhone.length == 9) {
        formattedPhone = '255$formattedPhone';
      }
      
      print('📱 Formatted phone for verification: $formattedPhone');
      
      // Query for OTP documents for this phone number
      final otpQuery = await _firestore
          .collection('otps')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .where('isUsed', isEqualTo: false)
          .get();

      print('📋 Found ${otpQuery.docs.length} OTP documents');

      if (otpQuery.docs.isEmpty) {
        print('❌ No OTP found for phone number: $formattedPhone');
        return false;
      }

      // Find the most recent OTP
      var otpDocs = otpQuery.docs;
      otpDocs.sort((a, b) {
        final aData = a.data();
        final bData = b.data();
        final aCreatedAt = aData['createdAt'] as Timestamp?;
        final bCreatedAt = bData['createdAt'] as Timestamp?;
        
        if (aCreatedAt == null || bCreatedAt == null) return 0;
        return bCreatedAt.compareTo(aCreatedAt);
      });

      final otpDoc = otpDocs.first;
      final data = otpDoc.data();
      
      print('📋 Found OTP document: ${data['otp']}');
      print('📋 Expected OTP: $otp');
      print('📋 Phone in document: ${data['phoneNumber']}');
      print('📋 Is used: ${data['isUsed']}');
      
      // Check if OTP matches (case insensitive)
      final storedOTP = data['otp']?.toString() ?? '';
      final inputOTP = otp.toString();
      
      if (storedOTP != inputOTP) {
        print('❌ OTP mismatch!');
        print('❌ Stored OTP: "$storedOTP"');
        print('❌ Input OTP: "$inputOTP"');
        print('❌ Length comparison: ${storedOTP.length} vs ${inputOTP.length}');
        return false;
      }

      if (data['createdAt'] == null ||
          DateTime.now().difference((data['createdAt'] as Timestamp).toDate()).inMinutes >= 5) {
        print('❌ OTP expired');
        return false;
      }

      // Mark OTP as verified and used
      await otpDoc.reference.update({
        'verified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
        'isUsed': true
      });

      print('✅ OTP verified successfully!');
      return true;
    } catch (e) {
      print('❌ Error verifying OTP: $e');
      return false;
    }
  }

  // Register user
  Future<bool> registerUser({
    required String phoneNumber,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Create user with email (using phone number as email)
      final email = '$phoneNumber@kazihuru.com';
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'phoneNumber': phoneNumber,
        'name': name,
        'role': role,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': true,
      });

      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  // Sign in with phone number
  Future<bool> signInWithPhoneNumber(String phoneNumber, String password) async {
    try {
      final email = '$phoneNumber@kazihuru.com';
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user != null;
    } catch (e) {
      print('Error signing in: $e');
      return false;
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
      print('Firebase Auth Exception in signInWithEmailAndPassword: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Unexpected error in signInWithEmailAndPassword: $e');
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: 'Hitilafu isiyotarajiwa imetokea. Tafadhali jaribu tena',
      );
    }
  }

  // Simple login method that returns boolean
  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      print('Login failed: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Unexpected login error: $e');
      return false;
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

  // Check if user exists by phone number
  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      print('🔍 Checking if user exists for phone: $phoneNumber');
      
      // Format phone number for storage (without +)
      String formattedPhone = phoneNumber.replaceAll('+', '');
      
      final query = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .limit(1)
          .get();
      
      bool exists = query.docs.isNotEmpty;
      print('🔍 User exists: $exists');
      
      return exists;
    } catch (e) {
      print('❌ Error checking user existence: $e');
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

  // Sign in with Google (to be implemented later)
  Future<UserCredential> signInWithGoogle() async {
    throw UnimplementedError('Google sign in not implemented yet');
  }

  // Sign in with Facebook (to be implemented later)
  Future<UserCredential> signInWithFacebook() async {
    throw UnimplementedError('Facebook sign in not implemented yet');
  }
} 
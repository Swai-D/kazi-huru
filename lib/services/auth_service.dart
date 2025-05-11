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
      await _firestore.collection('otps').doc(phoneNumber).set({
        'otp': otp,
        'timestamp': FieldValue.serverTimestamp(),
        'verified': false,
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
          await _firestore.collection('users').doc(currentUser.uid).update({
            'phoneNumber': phoneNumber,
            'isPhoneVerified': true,
          });
          
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

          // Store user data in Firestore
          await _firestore.collection('users').doc(userCredential.user?.uid).set({
            'phoneNumber': phoneNumber,
            'name': name ?? '',
            'role': role ?? 'job_seeker',
            'createdAt': FieldValue.serverTimestamp(),
            'isProfileComplete': false,
            'isPhoneVerified': true,
            'email': '$phoneNumber@kazihuru.com',
          });
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

        // Update phone verification status
        await _firestore.collection('users').doc(userCredential.user?.uid).update({
          'isPhoneVerified': true,
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
      throw Exception('Hitilafu imetokea. Tafadhali jaribu tena');
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('otps')
          .doc(phoneNumber)
          .get();

      if (!doc.exists) {
        return false;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // Check if OTP matches and is not expired (5 minutes validity)
      if (data['otp'] != otp || 
          data['timestamp'] == null ||
          DateTime.now().difference((data['timestamp'] as Timestamp).toDate()).inMinutes >= 5) {
        return false;
      }

      // Mark OTP as verified
      await _firestore.collection('otps').doc(phoneNumber).update({
        'verified': true
      });

      return true;
    } catch (e) {
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

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Mtumiaji hajapatikana';
          break;
        case 'wrong-password':
          message = 'Nywila si sahihi';
          break;
        case 'invalid-email':
          message = 'Barua pepe si sahihi';
          break;
        case 'user-disabled':
          message = 'Akaunti hii imezimwa';
          break;
        default:
          message = 'Hitilafu imetokea: ${e.message}';
      }
      throw Exception(message);
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
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
        default:
          message = 'Hitilafu imetokea: ${e.message}';
      }
      throw Exception(message);
    }
  }
} 
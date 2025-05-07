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

  // Send OTP via SMS
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      // Generate OTP
      String otp = _generateOTP();
      
      // Store OTP in Firestore with timestamp
      await _firestore.collection('otps').doc(phoneNumber).set({
        'otp': otp,
        'timestamp': FieldValue.serverTimestamp(),
        'verified': false,
      });

      // Send OTP via SMS
      return await SMSService.sendOTP(phoneNumber, otp);
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('otps')
          .doc(phoneNumber)
          .get();

      if (!doc.exists) return false;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // Check if OTP matches and is not expired (5 minutes validity)
      if (data['otp'] == otp && 
          data['timestamp'] != null &&
          DateTime.now().difference((data['timestamp'] as Timestamp).toDate()).inMinutes < 5) {
        
        // Mark OTP as verified
        await _firestore.collection('otps').doc(phoneNumber).update({
          'verified': true
        });
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  // Register user with phone number
  Future<UserCredential?> registerWithPhone(String phoneNumber, String name, String role) async {
    try {
      // Create user with email/password (using phone as email)
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: '$phoneNumber@kazihuru.com',
        password: phoneNumber, // You might want to generate a more secure password
      );

      // Update user profile
      await userCredential.user?.updateDisplayName(name);

      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'phone': phoneNumber,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  // Sign in with phone number
  Future<UserCredential?> signInWithPhone(String phoneNumber) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: '$phoneNumber@kazihuru.com',
        password: phoneNumber,
      );
    } catch (e) {
      print('Error signing in: $e');
      return null;
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
} 
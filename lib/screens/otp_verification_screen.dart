import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'dart:async';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String otp;
  final String email;
  final String password;
  final bool isNewUser;
  final String? name;
  final String? role;

  const OTPVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.otp,
    required this.email,
    required this.password,
    this.isNewUser = false,
    this.name,
    this.role,
  }) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _otpController.text = widget.otp; // Pre-fill the OTP
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      setState(() {
        _errorMessage = 'Tafadhali weka namba sahihi ya uthibitishaji';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verify OTP
      final isValid = await _authService.verifyOTP(
        widget.phoneNumber,
        _otpController.text,
      );

      if (!isValid) {
        throw Exception('Namba ya uthibitishaji si sahihi au imeisha muda wake');
      }

      UserCredential userCredential;
      
      if (widget.isNewUser) {
        // Create new user
        userCredential = await _authService.createUserWithEmailAndPassword(
          widget.email,
          widget.password,
        );
        
        // Create user document in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': widget.email,
          'name': widget.name ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'isProfileComplete': false,
          'role': widget.role ?? 'job_seeker',
          'phoneNumber': widget.phoneNumber,
          'isPhoneVerified': true,
          'uid': userCredential.user!.uid,
        });
      } else {
        // Sign in existing user
        userCredential = await _authService.signInWithEmailAndPassword(
          widget.email,
          widget.password,
        );

        // Update user's phone verification status
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'isPhoneVerified': true,
          'phoneNumber': widget.phoneNumber,
        });
      }

      if (userCredential.user == null) {
        throw Exception('Imeshindwa kuingia. Tafadhali jaribu tena');
      }

      // Navigate to appropriate dashboard based on role
      if (mounted) {
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        final userData = userDoc.data() as Map<String, dynamic>;
        final userRole = userData['role'] as String? ?? 'job_seeker';

        if (userRole == 'job_provider') {
          Navigator.pushReplacementNamed(context, '/job_provider_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/job_seeker_dashboard');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final otp = await _authService.sendOTP(widget.phoneNumber);
      if (otp != null) {
        _startResendTimer();
        setState(() {
          _otpController.text = otp;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Namba mpya ya uthibitishaji imetumwa'),
          ),
        );
      } else {
        throw Exception('Imeshindwa kutuma namba ya uthibitishaji');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thibitisha Namba'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Weka namba ya uthibitishaji iliyotumwa kwenye namba yako ya simu',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Namba ya Uthibitishaji',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOTP,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Thibitisha'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _canResend ? _resendOTP : null,
              child: Text(
                _canResend
                    ? 'Tuma tena namba ya uthibitishaji'
                    : 'Tuma tena baada ya sekunde $_resendCountdown',
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
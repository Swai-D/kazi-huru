import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final AuthService _authService = AuthService();

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if user exists first
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: widget.phoneNumber)
          .get();

      if (userDoc.docs.isNotEmpty) {
        setState(() {
          _errorMessage = 'Mtumiaji tayari ameshasajiriwa. Tafadhali ingia kwa njia nyingine.';
          _isLoading = false;
        });
        return;
      }

      // Get the OTP document using the phone number as document ID
      final otpDoc = await FirebaseFirestore.instance
          .collection('otps')
          .doc(widget.phoneNumber)
          .get();

      if (!otpDoc.exists) {
        setState(() {
          _errorMessage = 'OTP haipo. Tafadhali omba OTP mpya.';
          _isLoading = false;
        });
        return;
      }

      final otpData = otpDoc.data()!;
      final storedOTP = otpData['otp'] as String;
      final timestamp = (otpData['timestamp'] as Timestamp).toDate();
      final now = DateTime.now();

      // Check if OTP is expired (5 minutes)
      if (now.difference(timestamp).inMinutes > 5) {
        setState(() {
          _errorMessage = 'OTP imeisha muda wake. Tafadhali omba mpya.';
          _isLoading = false;
        });
        return;
      }

      // Verify OTP
      if (storedOTP == _otpController.text) {
        // Mark OTP as verified
        await otpDoc.reference.update({'verified': true});
        
        // Navigate to role selection
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/role_selection');
        }
      } else {
        setState(() {
          _errorMessage = 'OTP si sahihi. Tafadhali jaribu tena.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error during OTP verification: $e');
      setState(() {
        _errorMessage = 'Kuna tatizo. Tafadhali jaribu tena.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thibitisha OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Weka OTP uliotumiwa',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'OTP imetumwa kwa: ${widget.phoneNumber}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
                hintText: 'Mfano: 123456',
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOTP,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Thibitisha'),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
} 
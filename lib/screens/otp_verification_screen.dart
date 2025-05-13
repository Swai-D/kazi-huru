import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'dart:async';
import '../core/constants/theme_constants.dart';
import '../screens/role_selection_screen.dart';

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
  final FocusNode _otpFocusNode = FocusNode();
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
    // Remove autofill of OTP
    // _otpController.text = widget.otp;
    // Request focus after a short delay to ensure widget is built
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _otpFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
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
        _errorMessage = 'Tafadhali weka namba ya uthibitishaji kamili';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Verifying OTP...');
      final isVerified = await _authService.verifyOTP(
        widget.phoneNumber,
        _otpController.text,
      );

      print('OTP verification result: $isVerified');

      if (isVerified) {
        print('OTP verified successfully');
        if (mounted) {
          // Navigate to role selection screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RoleSelectionScreen(
                phoneNumber: widget.phoneNumber,
                password: widget.password,
                name: widget.name ?? '',
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Namba ya uthibitishaji si sahihi';
        });
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
                focusNode: _otpFocusNode,
              keyboardType: TextInputType.number,
              maxLength: 6,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _verifyOTP(),
                decoration: InputDecoration(
                labelText: 'Namba ya Uthibitishaji',
                  border: const OutlineInputBorder(),
                counterText: '',
                  prefixIcon: const Icon(Icons.lock_outline),
                  // Add clear button
                  suffixIcon: _otpController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _otpController.clear();
                            _otpFocusNode.requestFocus();
                          },
                        )
                      : null,
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOTP,
              style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Thibitisha',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _canResend ? _resendOTP : null,
                style: TextButton.styleFrom(
                  foregroundColor: ThemeConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              child: Text(
                _canResend
                    ? 'Tuma tena namba ya uthibitishaji'
                    : 'Tuma tena baada ya sekunde $_resendCountdown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            ),
        ),
      ),
    );
  }
} 
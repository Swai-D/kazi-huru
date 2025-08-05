import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/firestore_service.dart';
import 'role_selection_screen.dart';
import 'dart:async';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String otp;
  final String email;
  final String password;
  final bool isNewUser;
  final String name;
  final String role;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.otp,
    required this.email,
    required this.password,
    required this.isNewUser,
    required this.name,
    required this.role,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
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
  String _currentOTP = ''; // Store current OTP

  @override
  void initState() {
    super.initState();
    _currentOTP = widget.otp;
    
    // Debug information
    print('🔍 OTP Verification Screen Debug Info:');
    print('📱 Phone Number: ${widget.phoneNumber}');
    print('🔢 Initial OTP: ${widget.otp}');
    print('📧 Email: ${widget.email}');
    print('👤 Is New User: ${widget.isNewUser}');
    print('👤 Name: ${widget.name}');
    print('🔢 Current OTP: $_currentOTP');
    
    // Start countdown
    _startResendTimer();
    
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
        _errorMessage = 'Tafadhali weka namba 6 za uthibitishaji';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final enteredOTP = _otpController.text.trim();
      
      print('🔍 OTP Verification Debug:');
      print('📱 Phone Number: ${widget.phoneNumber}');
      print('🔢 Entered OTP: $enteredOTP');
      print('🔢 Current OTP: $_currentOTP');
      print('🔢 Widget OTP: ${widget.otp}');
      
      // Use current OTP if available, otherwise use widget OTP
      final expectedOTP = _currentOTP.isNotEmpty ? _currentOTP : widget.otp;
      
      print('🔢 Expected OTP: $expectedOTP');
      print('✅ OTP Match: ${enteredOTP == expectedOTP}');

      if (enteredOTP == expectedOTP) {
        print('✅ OTP verification successful!');
        
        if (widget.isNewUser) {
          print('👤 Creating new user...');
          await _createNewUser();
        } else {
          print('👤 Logging in existing user...');
          await _loginExistingUser();
        }
      } else {
        print('❌ OTP verification failed!');
        setState(() {
          _errorMessage = 'Namba ya uthibitishaji si sahihi. Jaribu tena.';
        });
      }
    } catch (e) {
      print('❌ Error during OTP verification: $e');
      setState(() {
        _errorMessage = 'Kuna shida. Jaribu tena.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createNewUser() async {
    try {
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      if (userCredential != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': widget.name,
          'phoneNumber': widget.phoneNumber.replaceAll('+', ''),
          'role': widget.role,
          'email': widget.email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await userCredential.user!.updateDisplayName(widget.name);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RoleSelectionScreen(
                phoneNumber: widget.phoneNumber,
                password: widget.password,
                name: widget.name,
              ),
            ),
          );
        }
      } else {
        throw Exception('Imeshindwa kuunda akaunti. Tafadhali jaribu tena.');
      }
    } catch (e) {
      print('❌ Error creating new user: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loginExistingUser() async {
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      if (userCredential != null) {
        final profileDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        
        if (profileDoc.exists) {
          final profile = profileDoc.data()!;
          final role = profile['role'] ?? 'job_seeker';
          if (role == 'job_seeker') {
            Navigator.pushReplacementNamed(context, '/job_seeker_dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/job_provider_dashboard');
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RoleSelectionScreen(
                phoneNumber: widget.phoneNumber,
                password: widget.password,
                name: userCredential.user!.displayName ?? '',
              ),
            ),
          );
        }
      } else {
        throw Exception('Imeshindwa kuingia. Tafadhali jaribu tena.');
      }
    } catch (e) {
      print('❌ Error logging in existing user: $e');
      setState(() {
        _errorMessage = e.toString();
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
      print('🔄 Resending OTP to: ${widget.phoneNumber}');
      final otp = await _authService.sendOTP(widget.phoneNumber);
      if (otp != null) {
        print('✅ New OTP sent: $otp');
        // Update current OTP
        setState(() {
          _currentOTP = otp;
        });
        _startResendTimer();
        setState(() {
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Imeshindwa kutuma OTP. Tafadhali jaribu tena.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Hitilafu: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thibitisha Namba'),
        backgroundColor: ThemeConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Icon(
              Icons.phone_android,
              size: 60,
              color: ThemeConstants.primaryColor,
            ),
            const SizedBox(height: 15),
            Text(
              'Tuma namba ya uthibitishaji',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Namba ya uthibitishaji imetumwa kwenye ${widget.phoneNumber}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _otpController,
              focusNode: _otpFocusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              maxLength: 6,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Thibitisha',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Haujapokea? ',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                TextButton(
                  onPressed: _canResend ? _resendOTP : null,
                  child: Text(
                    _canResend ? 'Tuma tena' : 'Tuma tena (${_resendCountdown}s)',
                    style: TextStyle(
                      color: _canResend ? ThemeConstants.primaryColor : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
} 
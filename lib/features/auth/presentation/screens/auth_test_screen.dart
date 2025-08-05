import 'package:flutter/material.dart';
import '../../../../core/utils/phone_number_validator.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/theme_constants.dart';

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  String? _testResult;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _testPhoneNumberValidation() async {
    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      final testNumbers = [
        '0712345678',
        '712345678',
        '+255712345678',
        '255712345678',
        '07123456789', // Invalid (too long)
        '123456789',   // Invalid (wrong prefix)
      ];

      StringBuffer result = StringBuffer();
      result.writeln('🧪 Testing Phone Number Validation:');
      result.writeln('');

      for (String number in testNumbers) {
        try {
          String formatted = PhoneNumberValidator.formatTanzanianPhoneNumber(number);
          bool isValid = PhoneNumberValidator.isValidTanzanianPhoneNumber(number);
          result.writeln('✅ $number -> $formatted (valid: $isValid)');
        } catch (e) {
          result.writeln('❌ $number -> ERROR: ${e.toString()}');
        }
      }

      setState(() {
        _testResult = result.toString();
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testUserExistence() async {
    if (_phoneController.text.isEmpty) {
      setState(() {
        _testResult = 'Please enter a phone number to test';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      String phoneNumber = _phoneController.text.trim();
      
      if (!PhoneNumberValidator.isValidTanzanianPhoneNumber(phoneNumber)) {
        setState(() {
          _testResult = 'Invalid phone number format';
        });
        return;
      }

      phoneNumber = PhoneNumberValidator.formatTanzanianPhoneNumber(phoneNumber);
      final exists = await _authService.checkUserExists(phoneNumber);

      setState(() {
        _testResult = '🔍 User existence test for $phoneNumber:\n'
            'User exists: $exists';
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error testing user existence: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testErrorHandling() async {
    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      StringBuffer result = StringBuffer();
      result.writeln('🧪 Testing Error Handling:');
      result.writeln('');

      final testErrors = [
        'invalid-phone-number',
        'user-exists',
        'user-not-found',
        'network-request-failed',
        'sms-send-failed',
        'unknown',
      ];

      for (String errorCode in testErrors) {
        String message = AuthErrorHandler.getLocalizedErrorMessage(errorCode);
        bool isRetryable = AuthErrorHandler.isRetryableError(errorCode);
        int retryDelay = AuthErrorHandler.getRetryDelay(errorCode);
        
        result.writeln('Error: $errorCode');
        result.writeln('Message: $message');
        result.writeln('Retryable: $isRetryable');
        result.writeln('Retry Delay: ${retryDelay}s');
        result.writeln('---');
      }

      setState(() {
        _testResult = result.toString();
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error testing error handling: $e';
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
        title: const Text('Authentication Test'),
        backgroundColor: ThemeConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phone Number Input Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '0712345678',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        return PhoneNumberValidator.validatePhoneInput(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _testUserExistence,
                            child: const Text('Test User Existence'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Validation Tests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _testPhoneNumberValidation,
                            child: const Text('Test Phone Validation'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _testErrorHandling,
                            child: const Text('Test Error Handling'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_testResult != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _testResult!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Testing...'),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 
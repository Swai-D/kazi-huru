import 'package:flutter/services.dart';

class PhoneNumberValidator {
  /// Validates and formats Tanzanian phone numbers
  /// Supports formats: 0712345678, 712345678, +255712345678, 255712345678
  static String formatTanzanianPhoneNumber(String phoneNumber) {
    // Remove all non-digits and spaces
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Handle different formats
    if (cleaned.startsWith('0')) {
      // Convert 07... to +2557...
      return '+255${cleaned.substring(1)}';
    } else if (cleaned.startsWith('255')) {
      // Convert 255... to +255...
      return '+$cleaned';
    } else if (cleaned.length == 9) {
      // Convert 9-digit to +255...
      return '+255$cleaned';
    } else if (cleaned.length == 10 && cleaned.startsWith('255')) {
      // Already in correct format, just add +
      return '+$cleaned';
    } else if (cleaned.length == 12 && cleaned.startsWith('255')) {
      // Already in correct format, just add +
      return '+$cleaned';
    }
    
    throw FormatException('Invalid Tanzanian phone number format: $phoneNumber');
  }

  /// Validates if a phone number is a valid Tanzanian number
  static bool isValidTanzanianPhoneNumber(String phoneNumber) {
    try {
      String formatted = formatTanzanianPhoneNumber(phoneNumber);
      // Check if it's a valid Tanzanian mobile number
      return formatted.startsWith('+255') && 
             formatted.length == 13 &&
             ['7', '6', '5'].contains(formatted.substring(4, 5));
    } catch (e) {
      return false;
    }
  }

  /// Returns a formatted phone number for display
  static String formatForDisplay(String phoneNumber) {
    try {
      String formatted = formatTanzanianPhoneNumber(phoneNumber);
      // Format as +255 7XX XXX XXX
      return '${formatted.substring(0, 5)} ${formatted.substring(5, 8)} ${formatted.substring(8, 11)} ${formatted.substring(11)}';
    } catch (e) {
      return phoneNumber;
    }
  }

  /// Returns a clean phone number for storage (without +)
  static String formatForStorage(String phoneNumber) {
    try {
      String formatted = formatTanzanianPhoneNumber(phoneNumber);
      return formatted.replaceAll('+', '');
    } catch (e) {
      return phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    }
  }

  /// Validates phone number input in real-time
  static String? validatePhoneInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tafadhali weka namba ya simu';
    }
    
    if (value.length < 9) {
      return 'Namba ya simu ni fupi sana';
    }
    
    if (value.length > 15) {
      return 'Namba ya simu ni ndefu sana';
    }
    
    // Check if it contains only digits, spaces, +, and -
    if (!RegExp(r'^[\d\s\+\-\(\)]+$').hasMatch(value)) {
      return 'Namba ya simu ina herufi zisizoruhusiwa';
    }
    
    return null;
  }

  /// Test function to validate various phone number formats
  static void testPhoneNumberFormats() {
    final testNumbers = [
      '0712345678',    // Should become +255712345678
      '712345678',     // Should become +255712345678
      '+255712345678', // Should remain +255712345678
      '255712345678',  // Should become +255712345678
      '07123456789',   // Invalid (too long)
      '123456789',     // Invalid (wrong prefix)
    ];
    
    print('🧪 Testing phone number formats:');
    for (String number in testNumbers) {
      try {
        String formatted = formatTanzanianPhoneNumber(number);
        bool isValid = isValidTanzanianPhoneNumber(number);
        print('  $number -> $formatted (valid: $isValid)');
      } catch (e) {
        print('  $number -> ERROR: ${e.toString()}');
      }
    }
  }
} 
import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorHandler {
  /// Converts Firebase auth error codes to user-friendly Swahili messages
  static String getLocalizedErrorMessage(String errorCode, [String? additionalInfo]) {
    switch (errorCode) {
      // Phone number related errors
      case 'invalid-phone-number':
        return 'Namba ya simu si sahihi. Tafadhali weka namba sahihi ya Tanzania';
      case 'invalid-verification-code':
        return 'Namba ya uthibitishaji si sahihi. Tafadhali jaribu tena';
      case 'invalid-verification-id':
        return 'Uthibitishaji umekwisha. Tafadhali omba namba mpya';
      
      // User existence errors
      case 'user-exists':
        return 'Akaunti hii ipo tayari. Tafadhali ingia';
      case 'user-not-found':
        return 'Akaunti haipo. Tafadhali jiregister';
      
      // Network and timeout errors
      case 'network-request-failed':
        return 'Hitilafu ya mtandao. Tafadhali angalia muungano wa internet';
      case 'timeout':
        return 'Muda umekwisha. Tafadhali jaribu tena';
      
      // SMS related errors
      case 'sms-send-failed':
        return 'Imeshindwa kutuma SMS. Tafadhali jaribu tena';
      case 'sms-quota-exceeded':
        return 'Idadi ya SMS imekwisha. Tafadhali jaribu kesho';
      
      // Firebase specific errors
      case 'too-many-requests':
        return 'Umejaribu mara nyingi. Tafadhali subiri kidogo';
      case 'operation-not-allowed':
        return 'Operesheni hii hairuhusiwi. Tafadhali wasiliana na msaada';
      case 'app-not-authorized':
        return 'Programu haijaruhusiwa. Tafadhali angalia usanidi';
      
      // General errors
      case 'unknown':
        return 'Hitilafu isiyojulikana imetokea. Tafadhali jaribu tena';
      case 'cancelled':
        return 'Operesheni imekatishwa';
      case 'permission-denied':
        return 'Hakuna ruhusa. Tafadhali angalia ruhusa za programu';
      
      // Custom app errors
      case 'invalid-phone-format':
        return 'Muundo wa namba ya simu si sahihi. Tafadhali weka namba sahihi ya Tanzania';
      case 'phone-number-required':
        return 'Tafadhali weka namba ya simu';
      case 'otp-required':
        return 'Tafadhali weka namba ya uthibitishaji';
      case 'otp-expired':
        return 'Namba ya uthibitishaji imekwisha. Tafadhali omba mpya';
      case 'profile-incomplete':
        return 'Wasifu wako haujakamilika. Tafadhali kamilisha';
      case 'role-required':
        return 'Tafadhali chagua jukumu lako';
      case 'name-required':
        return 'Tafadhali weka jina lako';
      case 'invalid-credentials':
        return 'Namba ya simu au password si sahihi. Tafadhali jaribu tena';
      
      default:
        if (additionalInfo != null) {
          return 'Hitilafu: $additionalInfo';
        }
        return 'Hitilafu imetokea. Tafadhali jaribu tena';
    }
  }

  /// Handles Firebase Auth exceptions
  static String handleFirebaseAuthException(dynamic exception) {
    if (exception is FirebaseAuthException) {
      return getLocalizedErrorMessage(exception.code);
    } else if (exception is FormatException) {
      return getLocalizedErrorMessage('invalid-phone-format');
    } else {
      return getLocalizedErrorMessage('unknown', exception.toString());
    }
  }

  /// Validates if an error is retryable
  static bool isRetryableError(String errorCode) {
    final retryableErrors = [
      'network-request-failed',
      'timeout',
      'too-many-requests',
      'unknown',
    ];
    return retryableErrors.contains(errorCode);
  }

  /// Gets retry delay based on error type
  static int getRetryDelay(String errorCode) {
    switch (errorCode) {
      case 'too-many-requests':
        return 60; // 1 minute
      case 'network-request-failed':
        return 5; // 5 seconds
      case 'timeout':
        return 10; // 10 seconds
      default:
        return 3; // 3 seconds
    }
  }

  /// Logs error for debugging
  static void logError(String errorCode, [String? additionalInfo, StackTrace? stackTrace]) {
    print('❌ Auth Error: $errorCode');
    if (additionalInfo != null) {
      print('   Additional Info: $additionalInfo');
    }
    if (stackTrace != null) {
      print('   Stack Trace: $stackTrace');
    }
  }

  /// Creates a user-friendly error message with action
  static Map<String, String> createErrorWithAction(String errorCode) {
    final message = getLocalizedErrorMessage(errorCode);
    
    switch (errorCode) {
      case 'user-exists':
        return {
          'message': message,
          'action': 'Ingia',
          'actionCode': 'navigate_to_login'
        };
      case 'user-not-found':
        return {
          'message': message,
          'action': 'Jiregister',
          'actionCode': 'navigate_to_register'
        };
      case 'network-request-failed':
        return {
          'message': message,
          'action': 'Jaribu Tena',
          'actionCode': 'retry'
        };
      case 'otp-expired':
        return {
          'message': message,
          'action': 'Oomba Mpya',
          'actionCode': 'resend_otp'
        };
      default:
        return {
          'message': message,
          'action': 'Sawa',
          'actionCode': 'dismiss'
        };
    }
  }
} 
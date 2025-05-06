class AppConstants {
  // App Info
  static const String appName = 'Kazi Huru';
  static const String appVersion = '1.0.0';
  
  // API Constants
  static const int apiTimeout = 30000; // 30 seconds
  
  // Cache Constants
  static const int cacheTimeout = 7; // 7 days
  
  // User Roles
  static const String roleJobSeeker = 'job_seeker';
  static const String roleJobProvider = 'job_provider';
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection.';
  
  // Validation Messages
  static const String requiredFieldMessage = 'This field is required';
  static const String invalidPhoneMessage = 'Please enter a valid phone number';
  static const String invalidEmailMessage = 'Please enter a valid email address';
} 
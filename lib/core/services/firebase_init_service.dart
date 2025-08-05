import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseInitService {
  static final FirebaseInitService _instance = FirebaseInitService._internal();
  factory FirebaseInitService() => _instance;
  FirebaseInitService._internal();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        await Firebase.initializeApp();
        _isInitialized = true;
        
        if (kDebugMode) {
          print('Firebase initialized successfully');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization failed: $e');
      }
      rethrow;
    }
  }

  Future<void> initializeWithOptions({
    required String apiKey,
    required String appId,
    required String messagingSenderId,
    required String projectId,
    String? storageBucket,
    String? iosClientId,
    String? androidClientId,
  }) async {
    try {
      if (!_isInitialized) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: apiKey,
            appId: appId,
            messagingSenderId: messagingSenderId,
            projectId: projectId,
            storageBucket: storageBucket,
            iosClientId: iosClientId,
            androidClientId: androidClientId,
          ),
        );
        _isInitialized = true;
        
        if (kDebugMode) {
          print('Firebase initialized successfully with custom options');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization failed: $e');
      }
      rethrow;
    }
  }

  // Check if Firebase is properly configured
  bool isFirebaseConfigured() {
    try {
      // Try to access Firebase app
      Firebase.app();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get Firebase app instance
  FirebaseApp? getFirebaseApp() {
    try {
      return Firebase.app();
    } catch (e) {
      return null;
    }
  }
} 
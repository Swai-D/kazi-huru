import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_status_checker.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _currentUser;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Getters
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;
  String? get userRole => _userProfile?['role'];

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      _currentUser = _authService.currentUser;
      
      if (_currentUser != null) {
        print('🔐 Found existing user: ${_currentUser!.uid}');
        await _loadUserProfile();
      } else {
        print('🔐 No existing user found');
      }
      
      // Listen to auth state changes
      _authService.authStateChanges.listen((User? user) async {
        _currentUser = user;
        if (user != null) {
          print('🔐 User authenticated: ${user.uid}');
          await _loadUserProfile();
          // Log auth status for debugging
          AuthStatusChecker.checkAuthStatus();
        } else {
          _userProfile = null;
          print('🔐 User signed out');
        }
        _error = null;
        _isInitialized = true;
        notifyListeners();
      });
    } catch (e) {
      print('❌ Error initializing auth: $e');
      _error = 'Hitilafu katika kuanzisha: $e';
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser != null) {
      try {
        print('🔐 Loading user profile for: ${_currentUser!.uid}');
        _userProfile = await _firestoreService.getUserProfile(_currentUser!.uid);
        if (_userProfile != null) {
          print('🔐 User profile loaded: ${_userProfile!['name']} (${_userProfile!['role']})');
        } else {
          print('🔐 No user profile found for user: ${_currentUser!.uid}');
        }
        notifyListeners();
      } catch (e) {
        _error = 'Hitilafu katika kupata wasifu: $e';
        print('❌ Error loading user profile: $e');
        notifyListeners();
      }
    }
  }

  // Phone number authentication
  Future<bool> signInWithPhone({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationCompleted,
    required Function(String) onVerificationFailed,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
        onVerificationCompleted: onVerificationCompleted,
        onVerificationFailed: (error) {
          _setError(error);
          onVerificationFailed(error);
        },
      );
      return true;
    } catch (e) {
      _setError('Hitilafu katika uthibitishaji: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifySMSCode({
    required String verificationId,
    required String smsCode,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.verifySMSCode(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      // Load user profile after successful verification
      await _loadUserProfile();
      
      print('✅ SMS code verified successfully');
      return true;
    } catch (e) {
      _setError('Msimbo si sahihi. Jaribu tena');
      print('❌ Error verifying SMS code: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Email and password authentication
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Load user profile after successful login
      await _loadUserProfile();
      
      print('✅ User signed in successfully: $email');
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      print('❌ Error signing in: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔐 Creating user with email: $email');
      
      // Check if user already exists
      final existingUser = await checkExistingUser(email);
      if (existingUser != null) {
        _setError('Mtumiaji tayar yupo na barua pepe hii');
        return false;
      }

      // Check if phone number is already registered
      final phoneExists = await isPhoneNumberRegistered(phoneNumber);
      if (phoneExists) {
        _setError('Namba ya simu tayar imesajiliwa');
        return false;
      }

      UserCredential userCredential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('🔐 User created in Firebase Auth: ${userCredential.user!.uid}');

      // Update user display name
      await _authService.updateUserProfile(displayName: name);

      // Create user profile in Firestore
      await _firestoreService.createUserProfile(
        userId: userCredential.user!.uid,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
        email: email,
      );

      print('🔐 User profile created in Firestore');

      // Load the created profile
      await _loadUserProfile();

      print('✅ User created successfully: $name ($role)');
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      print('❌ Error creating user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create user profile after phone authentication
  Future<bool> createUserProfileAfterPhoneAuth({
    required String name,
    required String phoneNumber,
    required String role,
    String? email,
  }) async {
    if (_currentUser == null) {
      _setError('Hakuna mtumiaji wa sasa');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      // Check if user profile already exists
      final existingProfile = await _firestoreService.getUserProfile(_currentUser!.uid);
      if (existingProfile != null) {
        // Check if the existing profile has complete data
        final hasCompleteData = existingProfile['name'] != null && 
                               existingProfile['name'].toString().isNotEmpty &&
                               existingProfile['phoneNumber'] != null && 
                               existingProfile['phoneNumber'].toString().isNotEmpty;
        
        if (hasCompleteData) {
          // User profile already exists with complete data - just load it
          _userProfile = existingProfile;
          notifyListeners();
          print('✅ Existing user profile loaded: ${existingProfile['name']} (${existingProfile['role']})');
          return true;
        } else {
          // User profile exists but has incomplete data - fix it
          print('🔧 Fixing incomplete user profile for: ${_currentUser!.uid}');
          await _firestoreService.fixExistingUserProfile(
            userId: _currentUser!.uid,
            name: name,
            phoneNumber: phoneNumber,
            email: email,
          );
          
          // Update user display name
          await _authService.updateUserProfile(displayName: name);
          
          // Reload user profile
          await _loadUserProfile();
          
          print('✅ User profile fixed successfully: $name ($role)');
          return true;
        }
      }

      // Create new user profile
      await _firestoreService.createUserProfile(
        userId: _currentUser!.uid,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
        email: email,
      );

      // Update user display name
      await _authService.updateUserProfile(displayName: name);

      // Reload user profile
      await _loadUserProfile();

      print('✅ User profile created successfully: $name ($role)');
      return true;
    } catch (e) {
      _setError('Hitilafu katika kuunda wasifu: $e');
      print('❌ Error creating user profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fix existing user profile with proper data
  Future<bool> fixExistingUserProfile({
    required String name,
    required String phoneNumber,
    String? email,
  }) async {
    if (_currentUser == null) {
      _setError('Hakuna mtumiaji wa sasa');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _firestoreService.fixExistingUserProfile(
        userId: _currentUser!.uid,
        name: name,
        phoneNumber: phoneNumber,
        email: email,
      );

      // Update user display name
      await _authService.updateUserProfile(displayName: name);

      // Reload user profile
      await _loadUserProfile();

      print('✅ User profile fixed successfully: $name');
      return true;
    } catch (e) {
      _setError('Hitilafu katika kusasisha wasifu: $e');
      print('❌ Error fixing user profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if user exists and get their profile
  Future<Map<String, dynamic>?> checkExistingUser(String email) async {
    try {
      // Check by email in Firestore
      final userQuery = await _firestoreService.getUserByEmail(email);
      return userQuery;
    } catch (e) {
      print('Error checking existing user: $e');
      return null;
    }
  }

  // Check if phone number is already registered
  Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    try {
      final userQuery = await _firestoreService.getUserByPhone(phoneNumber);
      return userQuery != null;
    } catch (e) {
      print('Error checking phone number: $e');
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? email,
    String? profileImageUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    if (_currentUser == null) {
      _setError('Hakuna mtumiaji wa sasa');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      Map<String, dynamic> updateData = {};
      
      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (email != null) updateData['email'] = email;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;
      if (additionalData != null) updateData.addAll(additionalData);

      await _firestoreService.updateUserProfile(
        userId: _currentUser!.uid,
        updateData: updateData,
      );

      // Update Firebase Auth display name if name is provided
      if (name != null) {
        await _authService.updateUserProfile(displayName: name);
      }

      // Reload user profile
      await _loadUserProfile();

      return true;
    } catch (e) {
      _setError('Hitilafu katika kusasisha wasifu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<bool> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      _currentUser = null;
      _userProfile = null;
      print('🔐 User signed out successfully');
      return true;
    } catch (e) {
      _setError('Hitilafu katika kutoka: $e');
      print('❌ Error signing out: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete user account
  Future<bool> deleteUserAccount() async {
    if (_currentUser == null) {
      _setError('Hakuna mtumiaji wa sasa');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _authService.deleteUserAccount();
      _currentUser = null;
      _userProfile = null;
      return true;
    } catch (e) {
      _setError('Hitilafu katika kufuta akaunti: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Public method to clear error
  void clearError() {
    _clearError();
  }

  // Convert Firebase error messages to Swahili
  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'Mtumiaji hajapatikana';
    } else if (error.contains('wrong-password')) {
      return 'Nywila si sahihi';
    } else if (error.contains('email-already-in-use')) {
      return 'Barua pepe tayar imetumika';
    } else if (error.contains('weak-password')) {
      return 'Nywila ni dhaifu sana';
    } else if (error.contains('invalid-email')) {
      return 'Barua pepe si sahihi';
    } else if (error.contains('too-many-requests')) {
      return 'Majaribio mengi sana. Jaribu baadae';
    } else if (error.contains('network-request-failed')) {
      return 'Hitilafu ya mtandao. Hakikisha una internet';
    } else {
      return error;
    }
  }

  // Check if user is verified
  bool get isUserVerified => _userProfile?['isVerified'] ?? false;

  // Check if user is a job seeker
  bool get isJobSeeker => userRole == 'job_seeker';

  // Check if user is a job provider
  bool get isJobProvider => userRole == 'job_provider';

  // Check if user is an admin
  bool get isAdmin => userRole == 'admin';

  // Get user's name
  String? get userName => _userProfile?['name'];

  // Get user's phone number
  String? get userPhoneNumber => _userProfile?['phoneNumber'];

  // Get user's email
  String? get userEmail => _userProfile?['email'] ?? _currentUser?.email;

  // Get user's profile image URL
  String? get userProfileImageUrl => _userProfile?['profileImageUrl'];

  // Refresh user profile
  Future<void> refreshUserProfile() async {
    await _loadUserProfile();
  }

  // Check if user has complete profile
  bool get hasCompleteProfile {
    if (_userProfile == null) return false;
    return _userProfile!['name'] != null && 
           _userProfile!['name'].toString().isNotEmpty &&
           _userProfile!['role'] != null && 
           _userProfile!['phoneNumber'] != null &&
           _userProfile!['phoneNumber'].toString().isNotEmpty;
  }

  // Check if current user profile needs to be fixed (has empty data)
  bool get needsProfileFix {
    if (_userProfile == null) return false;
    return _userProfile!['name'] == null || 
           _userProfile!['name'].toString().isEmpty ||
           _userProfile!['phoneNumber'] == null || 
           _userProfile!['phoneNumber'].toString().isEmpty;
  }

  // Get incomplete profile fields
  List<String> get incompleteProfileFields {
    List<String> fields = [];
    if (_userProfile == null) return ['name', 'phoneNumber', 'role'];
    
    if (_userProfile!['name'] == null || _userProfile!['name'].toString().isEmpty) {
      fields.add('name');
    }
    if (_userProfile!['phoneNumber'] == null || _userProfile!['phoneNumber'].toString().isEmpty) {
      fields.add('phoneNumber');
    }
    if (_userProfile!['role'] == null || _userProfile!['role'].toString().isEmpty) {
      fields.add('role');
    }
    
    return fields;
  }
} 
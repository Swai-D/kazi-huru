import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_page.dart';
import '../../features/job_seeker/presentation/screens/job_seeker_dashboard_screen.dart';
import '../../features/job_provider/presentation/screens/job_provider_dashboard_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../services/auth_status_checker.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Wait a bit for Firebase to initialize and auth state to be determined
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading indicator while initializing
        if (_isInitializing || authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Inapakia...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        // User is not authenticated - go to login
        if (!authProvider.isLoggedIn) {
          print('🔐 User not authenticated - redirecting to login');
          return const LoginPage();
        }

        // User is authenticated but no profile - go to role selection
        if (authProvider.userProfile == null) {
          print('🔐 User authenticated but no profile - redirecting to role selection');
          
          // Get user info from Firebase Auth
          final currentUser = authProvider.currentUser;
          String phoneNumber = '';
          String name = '';
          
          if (currentUser != null) {
            // Extract phone number from email (if it's a phone-based email)
            if (currentUser.email != null && currentUser.email!.contains('@kazihuru.com')) {
              phoneNumber = currentUser.email!.replaceAll('@kazihuru.com', '');
            }
            
            // Get display name if available
            name = currentUser.displayName ?? '';
          }
          
          return RoleSelectionScreen(
            phoneNumber: phoneNumber,
            password: '', // Not needed for role selection
            name: name,
          );
        }

        // User is authenticated and has profile - check if it's complete
        if (!authProvider.hasCompleteProfile) {
          print('🔐 User authenticated but profile is incomplete - redirecting to role selection');
          
          // Get user info from Firebase Auth
          final currentUser = authProvider.currentUser;
          String phoneNumber = '';
          String name = '';
          
          if (currentUser != null) {
            // Extract phone number from email (if it's a phone-based email)
            if (currentUser.email != null && currentUser.email!.contains('@kazihuru.com')) {
              phoneNumber = currentUser.email!.replaceAll('@kazihuru.com', '');
            }
            
            // Get display name if available
            name = currentUser.displayName ?? '';
          }
          
          return RoleSelectionScreen(
            phoneNumber: phoneNumber,
            password: '', // Not needed for role selection
            name: name,
          );
        }

        // User is authenticated and has complete profile - navigate to appropriate dashboard
        final userRole = authProvider.userRole;
        print('🔐 User authenticated with role: $userRole');
        
        if (userRole == 'job_seeker') {
          return const JobSeekerDashboardScreen();
        } else if (userRole == 'job_provider') {
          return const JobProviderDashboardScreen();
        } else {
          // Unknown role - go to role selection
          print('🔐 Unknown user role: $userRole - redirecting to role selection');
          
          // Get user info from Firebase Auth
          final currentUser = authProvider.currentUser;
          String phoneNumber = '';
          String name = '';
          
          if (currentUser != null) {
            // Extract phone number from email (if it's a phone-based email)
            if (currentUser.email != null && currentUser.email!.contains('@kazihuru.com')) {
              phoneNumber = currentUser.email!.replaceAll('@kazihuru.com', '');
            }
            
            // Get display name if available
            name = currentUser.displayName ?? '';
          }
          
          return RoleSelectionScreen(
            phoneNumber: phoneNumber,
            password: '', // Not needed for role selection
            name: name,
          );
        }
      },
    );
  }
} 
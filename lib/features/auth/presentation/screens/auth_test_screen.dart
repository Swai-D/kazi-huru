import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Debug'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Authentication Status
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Authentication Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Is Logged In: ${authProvider.isLoggedIn}'),
                        Text('Is Loading: ${authProvider.isLoading}'),
                        Text('Has Error: ${authProvider.error != null}'),
                        if (authProvider.error != null)
                          Text('Error: ${authProvider.error}'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Current User Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current User',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('UID: ${authProvider.currentUser?.uid ?? 'null'}'),
                        Text('Email: ${authProvider.currentUser?.email ?? 'null'}'),
                        Text('Display Name: ${authProvider.currentUser?.displayName ?? 'null'}'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // User Profile Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Profile Found: ${authProvider.userProfile != null}'),
                        Text('Has Complete Profile: ${authProvider.hasCompleteProfile}'),
                        Text('User Role: ${authProvider.userRole ?? 'null'}'),
                        Text('User Name: ${authProvider.userName ?? 'null'}'),
                        Text('User Phone: ${authProvider.userPhoneNumber ?? 'null'}'),
                        if (authProvider.userProfile != null) ...[
                          const SizedBox(height: 8),
                          const Text('Profile Data:'),
                          Text(authProvider.userProfile.toString()),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await authProvider.refreshUserProfile();
                          setState(() {});
                        },
                        child: const Text('Refresh Profile'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await authProvider.debugUserProfile();
                          setState(() {});
                        },
                        child: const Text('Debug Profile'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                ElevatedButton(
                  onPressed: () async {
                    final recovered = await authProvider.tryRecoverUserProfile();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(recovered ? 'Profile recovered!' : 'Could not recover profile'),
                        backgroundColor: recovered ? Colors.green : Colors.red,
                      ),
                    );
                    setState(() {});
                  },
                  child: const Text('Try Recover Profile'),
                ),
                
                const SizedBox(height: 8),
                
                ElevatedButton(
                  onPressed: () async {
                    await authProvider.forceRefreshAuthState();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Auth state refreshed'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                    setState(() {});
                  },
                  child: const Text('Force Refresh Auth State'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 
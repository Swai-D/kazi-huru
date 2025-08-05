import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/firebase_init_service.dart';
import '../../../../core/services/firestore_service.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  String _testResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
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
                      'Firebase Connection Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Firebase Initialized: ${FirebaseInitService().isInitialized}'),
                    Text('Firebase Configured: ${FirebaseInitService().isFirebaseConfigured()}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _testFirestoreConnection,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Test Firestore Connection'),
                    ),
                    if (_testResult.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _testResult.contains('successful')
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_testResult),
                      ),
                    ],
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
                      'Authentication Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Logged In: ${authProvider.isLoggedIn}'),
                            if (authProvider.currentUser != null) ...[
                              Text('User ID: ${authProvider.currentUser!.uid}'),
                              Text('Email: ${authProvider.currentUser!.email ?? 'N/A'}'),
                              Text('Phone: ${authProvider.currentUser!.phoneNumber ?? 'N/A'}'),
                            ],
                            if (authProvider.userProfile != null) ...[
                              Text('Name: ${authProvider.userProfile!['name'] ?? 'N/A'}'),
                              Text('Role: ${authProvider.userProfile!['role'] ?? 'N/A'}'),
                              Text('Verified: ${authProvider.userProfile!['isVerified'] ?? false}'),
                            ],
                          ],
                        );
                      },
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
                      'Quick Actions',
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
                            onPressed: () => _testCreateUser(),
                            child: const Text('Test Create User'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _testCreateJob(),
                            child: const Text('Test Create Job'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testFirestoreConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      // Try to read from Firestore
      _firestoreService.getJobs();
      setState(() {
        _testResult = '✅ Firestore connection successful!';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Firestore connection failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCreateUser() async {
    try {
      await _firestoreService.createUserProfile(
        userId: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test User',
        phoneNumber: '+255123456789',
        role: 'job_seeker',
        email: 'test@example.com',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Test user created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to create test user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testCreateJob() async {
    try {
      await _firestoreService.createJob(
        jobProviderId: 'test_provider_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Job',
        description: 'This is a test job for Firebase testing',
        location: 'Dar es Salaam',
        salary: 50000.0,
        salaryType: 'monthly',
        requirements: ['Experience', 'Education'],
        jobType: 'full_time',
        companyName: 'Test Company',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Test job created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to create test job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 
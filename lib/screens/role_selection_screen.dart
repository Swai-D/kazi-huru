import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _selectRole(BuildContext context, String role) async {
    try {
      // Get current user's phone number from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final userId = userDoc.docs.first.id;
        // Update user's role
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'role': role});

        // Navigate to appropriate dashboard
        Navigator.of(context).pushReplacementNamed(
          role == 'job_seeker' ? '/job_seeker_dashboard' : '/job_provider_dashboard',
        );
      }
    } catch (e) {
      print('Error selecting role: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kuna tatizo. Tafadhali jaribu tena.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chagua Jukumu Lako'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Chagua jukumu lako kwenye Kazi Huru',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _selectRole(context, 'job_seeker'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mtafuta Kazi'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectRole(context, 'job_provider'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mtoa Kazi'),
            ),
          ],
        ),
      ),
    );
  }
} 
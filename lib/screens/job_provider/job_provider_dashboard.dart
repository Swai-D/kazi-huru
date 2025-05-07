import 'package:flutter/material.dart';

class JobProviderDashboard extends StatelessWidget {
  const JobProviderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard ya Mtoa Kazi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Karibu kwenye Dashboard ya Mtoa Kazi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement post job functionality
              },
              child: const Text('Tuma Kazi Mpya'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement view applications functionality
              },
              child: const Text('Ona Maombi'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement manage jobs functionality
              },
              child: const Text('Dhibiti Kazi'),
            ),
          ],
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mipangilio'), // Settings in Swahili
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Lugha'), // Language
            onTap: () {
              // TODO: Implement language selection
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Arifa'), // Notifications
            onTap: () {
              // TODO: Implement notification settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Usalama'), // Security
            onTap: () {
              // TODO: Implement security settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Usaidizi'), // Help
            onTap: () {
              // TODO: Implement help section
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Toka'), // Logout
            onTap: () {
              // TODO: Implement logout functionality
            },
          ),
        ],
      ),
    );
  }
} 
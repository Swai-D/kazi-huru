import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String userId;
  const ChatScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Center(child: Text('Chat with user: $userId')),
    );
  }
} 
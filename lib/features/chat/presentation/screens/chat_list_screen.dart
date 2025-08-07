import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/chat_model.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/chat_service.dart';
import '../../../../core/providers/auth_provider.dart';
import 'chat_detail_screen.dart';
import 'chat_users_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late ChatService _chatService;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.tr('messages')),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('messages')),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getChatRooms(_currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading messages',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try again later',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatRoomsDocs = snapshot.data!.docs;
          
          if (chatRoomsDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('no_messages_yet'),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('start_conversation'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Get user role from AuthProvider
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      final userRole = authProvider.userProfile?['role'] ?? 'job_seeker';
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatUsersScreen(userRole: userRole),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Find People to Chat'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: chatRoomsDocs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final chatRoomData = chatRoomsDocs[index].data() as Map<String, dynamic>;
              final chatRoom = ChatRoom(
                id: chatRoomsDocs[index].id,
                participant1Id: chatRoomData['participants'][0] ?? '',
                participant2Id: chatRoomData['participants'][1] ?? '',
                participant1Name: chatRoomData['participantNames'][0] ?? '',
                participant2Name: chatRoomData['participantNames'][1] ?? '',
                participant1Avatar: chatRoomData['participantAvatars']?[0],
                participant2Avatar: chatRoomData['participantAvatars']?[1],
                lastMessage: chatRoomData['lastMessage'] ?? '',
                lastMessageTime: (chatRoomData['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
                unreadCount: chatRoomData['unreadCount'] ?? 0,
                isActive: chatRoomData['isActive'] ?? true,
              );
              final otherUserName = chatRoom.getOtherParticipantName(_currentUserId!);
              final otherUserAvatar = chatRoom.getOtherParticipantAvatar(_currentUserId!);
              final hasUnread = chatRoom.unreadCount > 0;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        chatRoom: chatRoom,
                        currentUserId: _currentUserId!,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: hasUnread 
                        ? ThemeConstants.primaryColor.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasUnread 
                          ? ThemeConstants.primaryColor.withOpacity(0.3)
                          : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: ThemeConstants.primaryColor,
                        backgroundImage: otherUserAvatar != null 
                            ? NetworkImage(otherUserAvatar) 
                            : null,
                        child: otherUserAvatar == null
                            ? Text(
                                otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    otherUserName,
                                    style: TextStyle(
                                      fontWeight: hasUnread 
                                          ? FontWeight.bold 
                                          : FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _formatTime(chatRoom.lastMessageTime),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chatRoom.lastMessage,
                              style: TextStyle(
                                color: hasUnread 
                                    ? Colors.black87 
                                    : Colors.grey,
                                fontWeight: hasUnread 
                                    ? FontWeight.w500 
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeConstants.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chatRoom.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Get user role from AuthProvider
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final userRole = authProvider.userProfile?['role'] ?? 'job_seeker';
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatUsersScreen(userRole: userRole),
            ),
          );
        },
        backgroundColor: ThemeConstants.primaryColor,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inDays}d';
    }
  }
} 
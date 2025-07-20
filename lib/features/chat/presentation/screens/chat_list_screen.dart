import 'package:flutter/material.dart';
import '../../../../core/models/chat_model.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/chat_service.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late ChatService _chatService;
  final String _currentUserId = 'user1'; // Mock current user ID

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
  }

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder<List<ChatRoom>>(
        stream: _chatService.chatRoomsStream,
        builder: (context, snapshot) {
          final chatRooms = _chatService.getChatRoomsForUser(_currentUserId);
          
          if (chatRooms.isEmpty) {
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
                ],
              ),
            );
          }

          return ListView.separated(
        padding: const EdgeInsets.all(16),
            itemCount: chatRooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final otherUserName = chatRoom.getOtherParticipantName(_currentUserId);
              final otherUserAvatar = chatRoom.getOtherParticipantAvatar(_currentUserId);
              final hasUnread = chatRoom.unreadCount > 0;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                        chatRoom: chatRoom,
                        currentUserId: _currentUserId,
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
                                otherUserName[0].toUpperCase(),
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
                            Text(
                                  otherUserName,
                              style: TextStyle(
                                    fontWeight: hasUnread 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                fontSize: 16,
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
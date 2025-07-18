import 'package:flutter/material.dart';
import '../../../../core/models/chat_model.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late List<ChatModel> chats;

  @override
  void initState() {
    super.initState();
    chats = [
      ChatModel(
        id: '1',
        jobTitle: 'Kusafisha Nyumba',
        otherUserName: 'John Doe',
        lastMessage: 'Niko njiani, nitaweka dakika 10',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      ChatModel(
        id: '2',
        jobTitle: 'Kufua Nguo',
        otherUserName: 'Jane Smith',
        lastMessage: 'Kazi imekamilika, unaweza kuja kuangalia',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
      ),
      ChatModel(
        id: '3',
        jobTitle: 'Kubeba Mizigo',
        otherUserName: 'Mike Johnson',
        lastMessage: 'Asante kwa kazi nzuri',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('messages')),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: chats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    chatId: chat.id,
                    jobTitle: chat.jobTitle,
                    otherUserName: chat.otherUserName,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: chat.isRead ? Colors.white : ThemeConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: chat.isRead ? Colors.grey.shade200 : ThemeConstants.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: ThemeConstants.primaryColor,
                    child: Text(
                      chat.otherUserName[0],
                      style: const TextStyle(color: Colors.white),
                    ),
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
                              chat.otherUserName,
                              style: TextStyle(
                                fontWeight: chat.isRead ? FontWeight.normal : FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _formatTime(chat.lastMessageTime),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chat.jobTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chat.lastMessage,
                          style: TextStyle(
                            color: chat.isRead ? Colors.grey : Colors.black87,
                            fontWeight: chat.isRead ? FontWeight.normal : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!chat.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: ThemeConstants.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
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
class ChatModel {
  final String id;
  final String jobTitle;
  final String otherUserName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isRead;
  final String otherUserAvatar;

  ChatModel({
    required this.id,
    required this.jobTitle,
    required this.otherUserName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isRead = false,
    this.otherUserAvatar = '',
  });
}

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
} 
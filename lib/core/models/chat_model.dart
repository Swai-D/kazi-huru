class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? attachmentUrl;
  final String? attachmentType;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.status,
    this.attachmentUrl,
    this.attachmentType,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
      attachmentUrl: json['attachmentUrl'],
      attachmentType: json['attachmentType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    String? attachmentUrl,
    String? attachmentType,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
    );
  }
}

class ChatRoom {
  final String id;
  final String participant1Id;
  final String participant2Id;
  final String participant1Name;
  final String participant2Name;
  final String? participant1Avatar;
  final String? participant2Avatar;
  final DateTime lastMessageTime;
  final String lastMessage;
  final int unreadCount;
  final bool isActive;

  ChatRoom({
    required this.id,
    required this.participant1Id,
    required this.participant2Id,
    required this.participant1Name,
    required this.participant2Name,
    this.participant1Avatar,
    this.participant2Avatar,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.unreadCount,
    required this.isActive,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? '',
      participant1Id: json['participant1Id'] ?? '',
      participant2Id: json['participant2Id'] ?? '',
      participant1Name: json['participant1Name'] ?? '',
      participant2Name: json['participant2Name'] ?? '',
      participant1Avatar: json['participant1Avatar'],
      participant2Avatar: json['participant2Avatar'],
      lastMessageTime: DateTime.parse(json['lastMessageTime'] ?? DateTime.now().toIso8601String()),
      lastMessage: json['lastMessage'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant1Id': participant1Id,
      'participant2Id': participant2Id,
      'participant1Name': participant1Name,
      'participant2Name': participant2Name,
      'participant1Avatar': participant1Avatar,
      'participant2Avatar': participant2Avatar,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'isActive': isActive,
    };
  }

  String getOtherParticipantName(String currentUserId) {
    if (currentUserId == participant1Id) {
      return participant2Name;
    }
    return participant1Name;
  }

  String? getOtherParticipantAvatar(String currentUserId) {
    if (currentUserId == participant1Id) {
      return participant2Avatar;
    }
    return participant1Avatar;
  }

  String getOtherParticipantId(String currentUserId) {
    if (currentUserId == participant1Id) {
      return participant2Id;
    }
    return participant1Id;
  }
}

enum MessageType {
  text,
  image,
  document,
  location,
  jobApplication,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class ChatUser {
  final String id;
  final String name;
  final String? avatar;
  final String role;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatUser({
    required this.id,
    required this.name,
    this.avatar,
    required this.role,
    required this.isOnline,
    this.lastSeen,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      role: json['role'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null 
          ? DateTime.parse(json['lastSeen']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'role': role,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }
} 
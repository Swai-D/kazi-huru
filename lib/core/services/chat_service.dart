import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';

class ChatService extends ChangeNotifier {
  // Mock data for development
  final List<ChatRoom> _chatRooms = [];
  final Map<String, List<ChatMessage>> _messages = {};
  final List<ChatUser> _users = [];
  
  // Stream controllers for real-time updates
  final StreamController<List<ChatRoom>> _chatRoomsController = 
      StreamController<List<ChatRoom>>.broadcast();
  final StreamController<List<ChatMessage>> _messagesController = 
      StreamController<List<ChatMessage>>.broadcast();
  final StreamController<ChatMessage> _newMessageController = 
      StreamController<ChatMessage>.broadcast();

  // Getters
  List<ChatRoom> get chatRooms => List.unmodifiable(_chatRooms);
  List<ChatUser> get users => List.unmodifiable(_users);
  Stream<List<ChatRoom>> get chatRoomsStream => _chatRoomsController.stream;
  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;
  Stream<ChatMessage> get newMessageStream => _newMessageController.stream;

  ChatService() {
    _initializeMockData();
    // Emit initial data
    _chatRoomsController.add(_chatRooms);
  }

  void _initializeMockData() {
    // Mock users
    _users.addAll([
      ChatUser(
        id: 'user1',
        name: 'John Doe',
        avatar: null,
        role: 'job_seeker',
        isOnline: true,
        lastSeen: DateTime.now(),
      ),
      ChatUser(
        id: 'user2',
        name: 'Tanzania Tech Solutions',
        avatar: null,
        role: 'job_provider',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      ChatUser(
        id: 'user3',
        name: 'Sarah Johnson',
        avatar: null,
        role: 'job_seeker',
        isOnline: true,
        lastSeen: DateTime.now(),
      ),
    ]);

    // Mock chat rooms
    _chatRooms.addAll([
      ChatRoom(
        id: 'room1',
        participant1Id: 'user1',
        participant2Id: 'user2',
        participant1Name: 'John Doe',
        participant2Name: 'Tanzania Tech Solutions',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        lastMessage: 'Thank you for the opportunity!',
        unreadCount: 2,
        isActive: true,
      ),
      ChatRoom(
        id: 'room2',
        participant1Id: 'user1',
        participant2Id: 'user3',
        participant1Name: 'John Doe',
        participant2Name: 'Sarah Johnson',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        lastMessage: 'How is the job search going?',
        unreadCount: 0,
        isActive: true,
      ),
    ]);

    // Mock messages
    _messages['room1'] = [
      ChatMessage(
        id: 'msg1',
        senderId: 'user2',
        receiverId: 'user1',
        content: 'Hello! We received your application for the Software Developer position.',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg2',
        senderId: 'user1',
        receiverId: 'user2',
        content: 'Thank you for considering my application. I\'m very interested in this position.',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg3',
        senderId: 'user2',
        receiverId: 'user1',
        content: 'Great! We would like to schedule an interview. Are you available tomorrow?',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        status: MessageStatus.delivered,
      ),
      ChatMessage(
        id: 'msg4',
        senderId: 'user1',
        receiverId: 'user2',
        content: 'Thank you for the opportunity!',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        status: MessageStatus.sent,
      ),
    ];

    _messages['room2'] = [
      ChatMessage(
        id: 'msg5',
        senderId: 'user3',
        receiverId: 'user1',
        content: 'Hi John! How is the job search going?',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg6',
        senderId: 'user1',
        receiverId: 'user3',
        content: 'It\'s going well! I have a few interviews lined up.',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: MessageStatus.read,
      ),
    ];

    _notifyListeners();
  }

  // Get chat rooms for a user
  List<ChatRoom> getChatRoomsForUser(String userId) {
    return _chatRooms.where((room) => 
      room.participant1Id == userId || room.participant2Id == userId
    ).toList();
  }

  // Get messages for a chat room
  List<ChatMessage> getMessagesForRoom(String roomId) {
    return _messages[roomId] ?? [];
  }

  // Send a message
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
    );

    // Add to local storage
    if (!_messages.containsKey(roomId)) {
      _messages[roomId] = [];
    }
    _messages[roomId]!.add(message);

    // Update chat room
    final roomIndex = _chatRooms.indexWhere((room) => room.id == roomId);
    if (roomIndex != -1) {
      final room = _chatRooms[roomIndex];
      _chatRooms[roomIndex] = ChatRoom(
        id: room.id,
        participant1Id: room.participant1Id,
        participant2Id: room.participant2Id,
        participant1Name: room.participant1Name,
        participant2Name: room.participant2Name,
        participant1Avatar: room.participant1Avatar,
        participant2Avatar: room.participant2Avatar,
        lastMessageTime: DateTime.now(),
        lastMessage: content,
        unreadCount: room.unreadCount + (senderId != room.participant1Id ? 1 : 0),
        isActive: room.isActive,
      );
    }

    // Simulate message sending
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Update message status
    final updatedMessage = message.copyWith(status: MessageStatus.sent);
    final messageIndex = _messages[roomId]!.indexWhere((m) => m.id == message.id);
    if (messageIndex != -1) {
      _messages[roomId]![messageIndex] = updatedMessage;
    }

    _notifyListeners();
    _newMessageController.add(updatedMessage);
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String roomId, String userId) async {
    final messages = _messages[roomId];
    if (messages != null) {
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].receiverId == userId && messages[i].status != MessageStatus.read) {
          messages[i] = messages[i].copyWith(status: MessageStatus.read);
        }
      }
    }

    // Reset unread count
    final roomIndex = _chatRooms.indexWhere((room) => room.id == roomId);
    if (roomIndex != -1) {
      final room = _chatRooms[roomIndex];
      _chatRooms[roomIndex] = ChatRoom(
        id: room.id,
        participant1Id: room.participant1Id,
        participant2Id: room.participant2Id,
        participant1Name: room.participant1Name,
        participant2Name: room.participant2Name,
        participant1Avatar: room.participant1Avatar,
        participant2Avatar: room.participant2Avatar,
        lastMessageTime: room.lastMessageTime,
        lastMessage: room.lastMessage,
        unreadCount: 0,
        isActive: room.isActive,
      );
    }

    _notifyListeners();
  }

  // Create a new chat room
  Future<ChatRoom> createChatRoom({
    required String participant1Id,
    required String participant2Id,
    required String participant1Name,
    required String participant2Name,
    String? participant1Avatar,
    String? participant2Avatar,
  }) async {
    final roomId = 'room_${DateTime.now().millisecondsSinceEpoch}';
    
    final room = ChatRoom(
      id: roomId,
      participant1Id: participant1Id,
      participant2Id: participant2Id,
      participant1Name: participant1Name,
      participant2Name: participant2Name,
      participant1Avatar: participant1Avatar,
      participant2Avatar: participant2Avatar,
      lastMessageTime: DateTime.now(),
      lastMessage: '',
      unreadCount: 0,
      isActive: true,
    );

    _chatRooms.add(room);
    _messages[roomId] = [];
    
    _notifyListeners();
    return room;
  }

  // Get user by ID
  ChatUser? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Get total unread count for a user
  int getTotalUnreadCount(String userId) {
    return _chatRooms
        .where((room) => 
          (room.participant1Id == userId || room.participant2Id == userId) &&
          room.unreadCount > 0
        )
        .fold(0, (sum, room) => sum + room.unreadCount);
  }

  // Delete a chat room
  Future<void> deleteChatRoom(String roomId) async {
    _chatRooms.removeWhere((room) => room.id == roomId);
    _messages.remove(roomId);
    _notifyListeners();
  }

  // Clear all messages in a room
  Future<void> clearMessages(String roomId) async {
    _messages[roomId]?.clear();
    _notifyListeners();
  }

  void _notifyListeners() {
    notifyListeners();
    _chatRoomsController.add(_chatRooms);
    // Note: messages stream would need room-specific implementation
  }

  @override
  void dispose() {
    _chatRoomsController.close();
    _messagesController.close();
    _newMessageController.close();
    super.dispose();
  }
} 
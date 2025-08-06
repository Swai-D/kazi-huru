import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_model.dart';

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Stream controllers for real-time updates
  final StreamController<List<ChatRoom>> _chatRoomsController = 
      StreamController<List<ChatRoom>>.broadcast();
  final StreamController<List<ChatMessage>> _messagesController = 
      StreamController<List<ChatMessage>>.broadcast();
  final StreamController<ChatMessage> _newMessageController = 
      StreamController<ChatMessage>.broadcast();

  // Getters
  Stream<List<ChatRoom>> get chatRoomsStream => _chatRoomsController.stream;
  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;
  Stream<ChatMessage> get newMessageStream => _newMessageController.stream;

  // Current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  ChatService() {
    _initializeChatRoomsStream();
  }

  void _initializeChatRoomsStream() {
    if (currentUserId == null) return;
    
    _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .listen((snapshot) {
      final chatRooms = snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatRoom(
          id: doc.id,
          participant1Id: data['participant1Id'] ?? '',
          participant2Id: data['participant2Id'] ?? '',
          participant1Name: data['participant1Name'] ?? '',
          participant2Name: data['participant2Name'] ?? '',
          participant1Avatar: data['participant1Avatar'],
          participant2Avatar: data['participant2Avatar'],
                     lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastMessage: data['lastMessage'] ?? '',
          unreadCount: data['unreadCount'] ?? 0,
          isActive: data['isActive'] ?? true,
        );
      }).toList();
      
      _chatRoomsController.add(chatRooms);
    });
  }

  // Get chat rooms for a user
  List<ChatRoom> getChatRoomsForUser(String userId) {
    // This will be handled by the stream
    return [];
  }

  // Get messages for a chat room
  List<ChatMessage> getMessagesForRoom(String roomId) {
    // This will be handled by the stream
    return [];
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
    try {
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

      // Add message to Firestore
      await _firestore
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'type': type.toString().split('.').last,
        'timestamp': FieldValue.serverTimestamp(),
        'status': MessageStatus.sent.toString().split('.').last,
        'attachmentUrl': attachmentUrl,
        'attachmentType': attachmentType,
      });

      // Update chat room with last message
      await _firestore.collection('chatRooms').doc(roomId).update({
        'lastMessage': content,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': FieldValue.increment(1),
      });

      // Get sender info for notification
      final senderDoc = await _firestore.collection('users').doc(senderId).get();
      final senderName = senderDoc.exists ? senderDoc.data()!['name'] ?? 'Unknown User' : 'Unknown User';

      // Send push notification
      await _sendPushNotification(
        receiverId: receiverId,
        senderName: senderName,
        message: content,
        chatRoomId: roomId,
      );

      // Emit new message
      _newMessageController.add(message);
      
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Send push notification for chat message
  Future<void> _sendPushNotification({
    required String receiverId,
    required String senderName,
    required String message,
    required String chatRoomId,
  }) async {
    try {
      // Get receiver's FCM token
      final receiverDoc = await _firestore.collection('users').doc(receiverId).get();
      if (!receiverDoc.exists) return;

      final receiverData = receiverDoc.data()!;
      final fcmToken = receiverData['fcmToken'];

      if (fcmToken == null) return;

      // Send notification via Cloud Functions or your backend
      await _firestore.collection('notifications').add({
        'receiverId': receiverId,
        'senderId': _auth.currentUser?.uid,
        'senderName': senderName,
        'message': message,
        'chatRoomId': chatRoomId,
        'type': 'chat_message',
        'fcmToken': fcmToken,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String roomId, String userId) async {
    try {
      // Update unread messages
      final messagesQuery = await _firestore
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('status', isEqualTo: MessageStatus.delivered.toString().split('.').last)
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesQuery.docs) {
        batch.update(doc.reference, {
          'status': MessageStatus.read.toString().split('.').last,
        });
      }
      await batch.commit();

      // Reset unread count
      await _firestore.collection('chatRooms').doc(roomId).update({
        'unreadCount': 0,
      });

    } catch (e) {
      print('Error marking messages as read: $e');
    }
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
    try {
      // Check if chat room already exists
      final existingRoom = await _firestore
          .collection('chatRooms')
          .where('participants', arrayContains: participant1Id)
          .get();

      for (final doc in existingRoom.docs) {
        final data = doc.data();
        if (data['participants'].contains(participant2Id)) {
          // Room already exists, return it
          return ChatRoom(
            id: doc.id,
            participant1Id: data['participant1Id'] ?? '',
            participant2Id: data['participant2Id'] ?? '',
            participant1Name: data['participant1Name'] ?? '',
            participant2Name: data['participant2Name'] ?? '',
            participant1Avatar: data['participant1Avatar'],
            participant2Avatar: data['participant2Avatar'],
            lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
            lastMessage: data['lastMessage'] ?? '',
            unreadCount: data['unreadCount'] ?? 0,
            isActive: data['isActive'] ?? true,
          );
        }
      }

      // Create new chat room
      final roomRef = await _firestore.collection('chatRooms').add({
        'participant1Id': participant1Id,
        'participant2Id': participant2Id,
        'participant1Name': participant1Name,
        'participant2Name': participant2Name,
        'participant1Avatar': participant1Avatar,
        'participant2Avatar': participant2Avatar,
        'participants': [participant1Id, participant2Id],
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'unreadCount': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return ChatRoom(
        id: roomRef.id,
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
    } catch (e) {
      print('Error creating chat room: $e');
      rethrow;
    }
  }

  // Create chat room from job application
  Future<ChatRoom?> createChatRoomFromJobApplication({
    required String jobId,
    required String jobSeekerId,
    required String jobProviderId,
    required String jobSeekerName,
    required String jobProviderName,
    String? jobSeekerAvatar,
    String? jobProviderAvatar,
  }) async {
    try {
      // Check if chat room already exists for this job application
      final existingRoom = await _firestore
          .collection('chatRooms')
          .where('jobId', isEqualTo: jobId)
          .where('participants', arrayContains: jobSeekerId)
          .get();

      if (existingRoom.docs.isNotEmpty) {
        final doc = existingRoom.docs.first;
        final data = doc.data();
        return ChatRoom(
          id: doc.id,
          participant1Id: data['participant1Id'] ?? '',
          participant2Id: data['participant2Id'] ?? '',
          participant1Name: data['participant1Name'] ?? '',
          participant2Name: data['participant2Name'] ?? '',
          participant1Avatar: data['participant1Avatar'],
          participant2Avatar: data['participant2Avatar'],
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastMessage: data['lastMessage'] ?? '',
          unreadCount: data['unreadCount'] ?? 0,
          isActive: data['isActive'] ?? true,
        );
      }

      // Create new chat room for job application
      final roomRef = await _firestore.collection('chatRooms').add({
        'participant1Id': jobSeekerId,
        'participant2Id': jobProviderId,
        'participant1Name': jobSeekerName,
        'participant2Name': jobProviderName,
        'participant1Avatar': jobSeekerAvatar,
        'participant2Avatar': jobProviderAvatar,
        'participants': [jobSeekerId, jobProviderId],
        'jobId': jobId,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'unreadCount': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'job_application',
      });

      return ChatRoom(
        id: roomRef.id,
        participant1Id: jobSeekerId,
        participant2Id: jobProviderId,
        participant1Name: jobSeekerName,
        participant2Name: jobProviderName,
        participant1Avatar: jobSeekerAvatar,
        participant2Avatar: jobProviderAvatar,
        lastMessageTime: DateTime.now(),
        lastMessage: '',
        unreadCount: 0,
        isActive: true,
      );
    } catch (e) {
      print('Error creating chat room from job application: $e');
      return null;
    }
  }

  // Get messages stream for a specific room
  Stream<List<ChatMessage>> getMessagesStream(String roomId) {
    return _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          id: doc.id,
          senderId: data['senderId'] ?? '',
          receiverId: data['receiverId'] ?? '',
          content: data['content'] ?? '',
          type: MessageType.values.firstWhere(
            (e) => e.toString() == 'MessageType.${data['type']}',
            orElse: () => MessageType.text,
          ),
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          status: MessageStatus.values.firstWhere(
            (e) => e.toString() == 'MessageStatus.${data['status']}',
            orElse: () => MessageStatus.sent,
          ),
          attachmentUrl: data['attachmentUrl'],
          attachmentType: data['attachmentType'],
        );
      }).toList();
    });
  }

  // Get user by ID
  Future<ChatUser?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return ChatUser(
          id: doc.id,
          name: data['name'] ?? '',
          avatar: data['avatar'],
          role: data['role'] ?? '',
          isOnline: data['isOnline'] ?? false,
          lastSeen: data['lastSeen'] != null 
              ? (data['lastSeen'] as Timestamp).toDate() 
              : null,
        );
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Get total unread count for a user
  Future<int> getTotalUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('chatRooms')
          .where('participants', arrayContains: userId)
          .get();

             int totalUnread = 0;
       for (final doc in snapshot.docs) {
         totalUnread += (doc.data()['unreadCount'] ?? 0) as int;
       }
      return totalUnread;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Delete a chat room
  Future<void> deleteChatRoom(String roomId) async {
    try {
      await _firestore.collection('chatRooms').doc(roomId).delete();
    } catch (e) {
      print('Error deleting chat room: $e');
    }
  }

  // Clear all messages in a room
  Future<void> clearMessages(String roomId) async {
    try {
      final messages = await _firestore
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Update room
      await _firestore.collection('chatRooms').doc(roomId).update({
        'lastMessage': '',
        'unreadCount': 0,
      });
    } catch (e) {
      print('Error clearing messages: $e');
    }
  }

  // Update user online status
  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  @override
  void dispose() {
    _chatRoomsController.close();
    _messagesController.close();
    _newMessageController.close();
    super.dispose();
  }
} 
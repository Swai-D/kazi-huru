import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // Send a message
  Future<bool> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String message,
    String? receiverId,
  }) async {
    try {
      // Add message to chat room
      await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').add({
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update chat room last message
      await _firestore.collection('chat_rooms').doc(chatRoomId).update({
        'lastMessage': message,
        'lastMessageSender': senderName,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to receiver if provided
      if (receiverId != null && receiverId != senderId) {
        await _notificationService.sendChatNotification(
          receiverId: receiverId,
          senderName: senderName,
          message: message,
          chatRoomId: chatRoomId,
        );
      }

      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Create or get chat room
  Future<String?> createChatRoom({
    required String participant1Id,
    required String participant1Name,
    required String participant2Id,
    required String participant2Name,
  }) async {
    try {
      // Check if chat room already exists
      final existingRoom = await _firestore
          .collection('chat_rooms')
          .where('participants', arrayContains: participant1Id)
          .get();

      for (final doc in existingRoom.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        if (participants.contains(participant2Id)) {
          return doc.id;
        }
      }

      // Create new chat room
      final docRef = await _firestore.collection('chat_rooms').add({
        'participants': [participant1Id, participant2Id],
        'participantNames': [participant1Name, participant2Name],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error creating chat room: $e');
      return null;
    }
  }

  // Get chat rooms for a user
  Stream<QuerySnapshot> getChatRooms(String userId) {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // Get messages for a chat room
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    try {
      final messages = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Get unread message count for a user
  Future<int> getUnreadMessageCount(String userId) async {
    try {
      final chatRooms = await _firestore
          .collection('chat_rooms')
          .where('participants', arrayContains: userId)
          .get();

      int totalUnread = 0;
      for (final roomDoc in chatRooms.docs) {
        final unreadMessages = await _firestore
            .collection('chat_rooms')
            .doc(roomDoc.id)
            .collection('messages')
            .where('senderId', isNotEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .get();

        totalUnread += unreadMessages.docs.length;
      }

      return totalUnread;
    } catch (e) {
      print('Error getting unread message count: $e');
      return 0;
    }
  }

  // Delete chat room
  Future<bool> deleteChatRoom(String chatRoomId) async {
    try {
      // Delete all messages in the chat room
      final messages = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat room
      batch.delete(_firestore.collection('chat_rooms').doc(chatRoomId));
      await batch.commit();

      return true;
    } catch (e) {
      print('Error deleting chat room: $e');
      return false;
    }
  }

  // Get chat room details
  Future<Map<String, dynamic>?> getChatRoomDetails(String chatRoomId) async {
    try {
      final doc = await _firestore.collection('chat_rooms').doc(chatRoomId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting chat room details: $e');
      return null;
    }
  }

  // Get other participant in chat room
  Future<String?> getOtherParticipant(String chatRoomId, String currentUserId) async {
    try {
      final roomData = await getChatRoomDetails(chatRoomId);
      if (roomData != null) {
        final participants = List<String>.from(roomData['participants'] ?? []);
        final participantNames = List<String>.from(roomData['participantNames'] ?? []);
        
        final currentUserIndex = participants.indexOf(currentUserId);
        if (currentUserIndex != -1 && currentUserIndex < participantNames.length) {
          return participantNames[currentUserIndex];
        }
      }
      return null;
    } catch (e) {
      print('Error getting other participant: $e');
      return null;
    }
  }

  // Clear all messages in a chat room
  Future<bool> clearMessages(String chatRoomId) async {
    try {
      final messages = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      return true;
    } catch (e) {
      print('Error clearing messages: $e');
      return false;
    }
  }
} 
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';

class FirestoreNotificationService extends ChangeNotifier {
  static final FirestoreNotificationService _instance = FirestoreNotificationService._internal();
  factory FirestoreNotificationService() => _instance;
  FirestoreNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<NotificationModel> _notifications = [];
  bool _isInitialized = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Simple query without composite indexes
        _firestore
            .collection('notifications')
            .where('receiverId', isEqualTo: user.uid)
            .snapshots()
            .listen((snapshot) {
          _notifications = snapshot.docs.map((doc) {
            final data = doc.data();
            return NotificationModel(
              id: doc.id,
              title: data['title'] ?? '',
              body: data['body'] ?? '',
              timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              type: _parseNotificationType(data['type'] ?? 'system'),
              isRead: data['isRead'] ?? false,
              data: data['data'] ?? {},
            );
          }).toList();
          
          // Sort by timestamp in memory instead of in query
          _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          
          _isInitialized = true;
          notifyListeners();
        });
      }
    } catch (e) {
      print('Error initializing Firestore notification service: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'jobApplication':
        return NotificationType.jobApplication;
      case 'jobAccepted':
        return NotificationType.jobAccepted;
      case 'jobRejected':
        return NotificationType.jobRejected;
      case 'payment':
        return NotificationType.payment;
      case 'verification':
        return NotificationType.verification;
      case 'chat':
        return NotificationType.chat;
      default:
        return NotificationType.system;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final batch = _firestore.batch();
        final notifications = await _firestore
            .collection('notifications')
            .where('receiverId', isEqualTo: user.uid)
            .where('isRead', isEqualTo: false)
            .get();

        for (final doc in notifications.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final batch = _firestore.batch();
        final notifications = await _firestore
            .collection('notifications')
            .where('receiverId', isEqualTo: user.uid)
            .get();

        for (final doc in notifications.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      print('Error deleting all notifications: $e');
    }
  }

  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((notification) => notification.type == type).toList();
  }

  Future<void> sendJobApplicationNotification({
    required String jobProviderId,
    required String jobTitle,
    required String applicantName,
    required String jobId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'receiverId': jobProviderId,
        'title': 'Maombi Mapya',
        'body': '$applicantName ameomba kazi: $jobTitle',
        'type': 'jobApplication',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'data': {
          'jobId': jobId,
          'applicantName': applicantName,
          'jobTitle': jobTitle,
        },
      });
    } catch (e) {
      print('Error sending job application notification: $e');
    }
  }

  Future<void> sendVerificationNotification({
    required String userId,
    required bool isApproved,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'receiverId': userId,
        'title': isApproved ? 'Verification Approved' : 'Verification Rejected',
        'body': isApproved 
            ? 'Your account verification has been approved!'
            : 'Your account verification has been rejected. Please try again.',
        'type': 'verification',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'data': {
          'isApproved': isApproved,
        },
      });
    } catch (e) {
      print('Error sending verification notification: $e');
    }
  }

  Future<void> sendChatNotification({
    required String receiverId,
    required String senderName,
    required String message,
    required String chatRoomId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'receiverId': receiverId,
        'title': 'Ujumbe Mpya',
        'body': '$senderName: $message',
        'type': 'chat',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'data': {
          'chatRoomId': chatRoomId,
          'senderName': senderName,
        },
      });
    } catch (e) {
      print('Error sending chat notification: $e');
    }
  }

  Future<void> sendJobStatusNotification({
    required String jobSeekerId,
    required String jobTitle,
    required bool isAccepted,
    required String jobId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'receiverId': jobSeekerId,
        'title': isAccepted ? 'Kazi Imeanza' : 'Kazi Imekataliwa',
        'body': isAccepted 
            ? 'Kazi ya $jobTitle imeanza.'
            : 'Ombi lako la kazi ya $jobTitle limekataliwa.',
        'type': isAccepted ? 'jobAccepted' : 'jobRejected',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'data': {
          'jobId': jobId,
          'jobTitle': jobTitle,
          'isAccepted': isAccepted,
        },
      });
    } catch (e) {
      print('Error sending job status notification: $e');
    }
  }

  Future<void> sendPaymentNotification({
    required String userId,
    required double amount,
    required String transactionId,
    required String paymentType,
  }) async {
    try {
      String title = '';
      String body = '';

      switch (paymentType) {
        case 'received':
          title = 'Malipo Yamepokelewa';
          body = 'Umefanikiwa kupokea TZS ${amount.toStringAsFixed(0)}.';
          break;
        case 'sent':
          title = 'Malipo Yamefanyika';
          body = 'Umefanikiwa kutuma TZS ${amount.toStringAsFixed(0)}.';
          break;
        case 'bonus':
          title = 'Bonus Yamepokelewa';
          body = 'Umepokea bonus ya TZS ${amount.toStringAsFixed(0)}.';
          break;
      }

      await _firestore.collection('notifications').add({
        'receiverId': userId,
        'title': title,
        'body': body,
        'type': 'payment',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'data': {
          'amount': amount,
          'transactionId': transactionId,
          'paymentType': paymentType,
        },
      });
    } catch (e) {
      print('Error sending payment notification: $e');
    }
  }

  Future<void> sendSystemNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'receiverId': userId,
        'title': title,
        'body': body,
        'type': 'system',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'data': data ?? {},
      });
    } catch (e) {
      print('Error sending system notification: $e');
    }
  }

  Future<void> sendNotificationToMultipleUsers({
    required List<String> receiverIds,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final batch = _firestore.batch();
      
      for (final receiverId in receiverIds) {
        final docRef = _firestore.collection('notifications').doc();
        batch.set(docRef, {
          'receiverId': receiverId,
          'title': title,
          'body': body,
          'type': _notificationTypeToString(type),
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'data': data ?? {},
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error sending notifications to multiple users: $e');
    }
  }

  NotificationModel? getNotificationById(String notificationId) {
    try {
      return _notifications.firstWhere((n) => n.id == notificationId);
    } catch (e) {
      return null;
    }
  }

  String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.jobApplication:
        return 'jobApplication';
      case NotificationType.jobAccepted:
        return 'jobAccepted';
      case NotificationType.jobRejected:
        return 'jobRejected';
      case NotificationType.payment:
        return 'payment';
      case NotificationType.verification:
        return 'verification';
      case NotificationType.chat:
        return 'chat';
      case NotificationType.system:
      default:
        return 'system';
    }
  }
} 
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import 'push_notification_service.dart';

enum NotificationType {
  jobApplication,
  jobAccepted,
  jobRejected,
  payment,
  system,
  verification,
  chat,
}

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  List<NotificationModel> _notifications = [];
  bool _isInitialized = false;
  final PushNotificationService _pushNotificationService = PushNotificationService();

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isInitialized => _isInitialized;

  // Initialize with sample data
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Initialize push notification service
    await _pushNotificationService.initialize();
    
    _notifications = [
      NotificationModel(
        id: '1',
        title: 'Ombi Jipya la Kazi',
        body: 'John ameomba kazi yako ya Usafi.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: NotificationType.jobApplication,
        data: {'jobId': 'job_123', 'applicantId': 'user_456'},
      ),
      NotificationModel(
        id: '2',
        title: 'Kazi Imeanza',
        body: 'Kazi ya Kufua Nguo imeanza.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
        type: NotificationType.jobAccepted,
        data: {'jobId': 'job_789'},
      ),
      NotificationModel(
        id: '3',
        title: 'Malipo Yamepokelewa',
        body: 'Umefanikiwa kupokea TZS 20,000.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.payment,
        data: {'amount': 20000, 'transactionId': 'txn_123'},
      ),
      NotificationModel(
        id: '4',
        title: 'Uthibitishaji wa ID',
        body: 'ID yako imethibitishwa na timu yetu.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.verification,
        data: {'verificationId': 'ver_456'},
      ),
      NotificationModel(
        id: '5',
        title: 'Ujumbe Mpya',
        body: 'Una ujumbe mpya kutoka kwa John.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: NotificationType.chat,
        data: {'chatId': 'chat_789', 'senderId': 'user_456'},
      ),
    ];
    
    _isInitialized = true;
    notifyListeners();
  }

  // Add new notification
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
    
    // Show push notification
    _pushNotificationService.showNotification(notification);
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  // Delete notification
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  // Delete all notifications
  void deleteAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Create notification by type
  NotificationModel createNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      data: data,
    );
  }

  // Simulate real-time notifications with push notifications
  void simulateJobApplication(String jobTitle, String applicantName) {
    final notification = createNotification(
      title: 'Ombi Jipya la Kazi',
      body: '$applicantName ameomba kazi yako ya $jobTitle.',
      type: NotificationType.jobApplication,
      data: {
        'jobTitle': jobTitle,
        'applicantName': applicantName,
      },
    );
    addNotification(notification);
  }

  void simulatePaymentReceived(double amount) {
    final notification = createNotification(
      title: 'Malipo Yamepokelewa',
      body: 'Umefanikiwa kupokea TZS ${amount.toStringAsFixed(0)}.',
      type: NotificationType.payment,
      data: {'amount': amount},
    );
    addNotification(notification);
  }

  void simulateVerificationUpdate(bool isApproved) {
    final notification = createNotification(
      title: isApproved ? 'Uthibitishaji wa ID' : 'Uthibitishaji wa ID Umekataliwa',
      body: isApproved 
        ? 'ID yako imethibitishwa na timu yetu.'
        : 'ID yako haijathibitishwa. Tafadhali jaribu tena.',
      type: NotificationType.verification,
      data: {'isApproved': isApproved},
    );
    addNotification(notification);
  }

  void simulateChatMessage(String senderName, String message) {
    final notification = createNotification(
      title: 'Ujumbe Mpya',
      body: '$senderName: $message',
      type: NotificationType.chat,
      data: {
        'senderName': senderName,
        'message': message,
      },
    );
    addNotification(notification);
  }

  // Request notification permissions
  Future<void> requestPermissions() async {
    await _pushNotificationService.requestPermissions();
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await _pushNotificationService.areNotificationsEnabled();
  }

  // Get notification by ID
  Future<NotificationModel?> getNotification(String notificationId) async {
    try {
      final notification = _notifications.firstWhere((n) => n.id == notificationId);
      return notification;
    } catch (e) {
      return null;
    }
  }

  // Clear all data
  void clear() {
    _notifications.clear();
    _isInitialized = false;
    notifyListeners();
  }
} 
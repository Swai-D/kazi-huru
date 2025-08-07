import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import 'push_notification_service.dart';
import 'firestore_notification_service.dart';

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

  final FirestoreNotificationService _firestoreService = FirestoreNotificationService();
  final PushNotificationService _pushNotificationService = PushNotificationService();

  List<NotificationModel> get notifications => _firestoreService.notifications;
  int get unreadCount => _firestoreService.unreadCount;
  bool get isInitialized => _firestoreService.isInitialized;

  // Initialize with real data from Firestore
  Future<void> initialize() async {
    try {
      // Initialize push notification service
      await _pushNotificationService.initialize();
      
      // Initialize Firestore notification service
      await _firestoreService.initialize();
      
      // Listen to changes in the Firestore service
      _firestoreService.addListener(() {
        notifyListeners();
      });
    } catch (e) {
      print('Error initializing notification service: $e');
      // Continue without notifications if there's an error
    }
  }

  // Add new notification (delegates to Firestore service)
  void addNotification(NotificationModel notification) {
    // This is now handled by the Firestore service
    // Local notifications are shown via push notification service
    _pushNotificationService.showNotification(notification);
  }

  // Mark notification as read (delegates to Firestore service)
  Future<void> markAsRead(String notificationId) async {
    await _firestoreService.markAsRead(notificationId);
  }

  // Mark all notifications as read (delegates to Firestore service)
  Future<void> markAllAsRead() async {
    await _firestoreService.markAllAsRead();
  }

  // Delete notification (delegates to Firestore service)
  Future<void> deleteNotification(String notificationId) async {
    await _firestoreService.deleteNotification(notificationId);
  }

  // Delete all notifications (delegates to Firestore service)
  Future<void> deleteAllNotifications() async {
    await _firestoreService.deleteAllNotifications();
  }

  // Get notifications by type (delegates to Firestore service)
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _firestoreService.getNotificationsByType(type);
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

  // Send job application notification
  Future<void> sendJobApplicationNotification({
    required String jobProviderId,
    required String jobTitle,
    required String applicantName,
    required String jobId,
  }) async {
    await _firestoreService.sendJobApplicationNotification(
      jobProviderId: jobProviderId,
      jobTitle: jobTitle,
      applicantName: applicantName,
      jobId: jobId,
    );
  }

  // Send job status notification
  Future<void> sendJobStatusNotification({
    required String jobSeekerId,
    required String jobTitle,
    required bool isAccepted,
    required String jobId,
  }) async {
    await _firestoreService.sendJobStatusNotification(
      jobSeekerId: jobSeekerId,
      jobTitle: jobTitle,
      isAccepted: isAccepted,
      jobId: jobId,
    );
  }

  // Send payment notification
  Future<void> sendPaymentNotification({
    required String userId,
    required double amount,
    required String transactionId,
    required String paymentType,
  }) async {
    await _firestoreService.sendPaymentNotification(
      userId: userId,
      amount: amount,
      transactionId: transactionId,
      paymentType: paymentType,
    );
  }

  // Send verification notification
  Future<void> sendVerificationNotification({
    required String userId,
    required bool isApproved,
  }) async {
    await _firestoreService.sendVerificationNotification(
      userId: userId,
      isApproved: isApproved,
    );
  }

  // Send chat notification
  Future<void> sendChatNotification({
    required String receiverId,
    required String senderName,
    required String message,
    required String chatRoomId,
  }) async {
    await _firestoreService.sendChatNotification(
      receiverId: receiverId,
      senderName: senderName,
      message: message,
      chatRoomId: chatRoomId,
    );
  }

  // Send system notification
  Future<void> sendSystemNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _firestoreService.sendSystemNotification(
      userId: userId,
      title: title,
      body: body,
      data: data,
    );
  }

  // Send notification to multiple users
  Future<void> sendNotificationToMultipleUsers({
    required List<String> receiverIds,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    await _firestoreService.sendNotificationToMultipleUsers(
      receiverIds: receiverIds,
      title: title,
      body: body,
      type: type,
      data: data,
    );
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
  NotificationModel? getNotificationById(String notificationId) {
    return _firestoreService.getNotificationById(notificationId);
  }

  // Clear all data
  void clear() {
    // This is now handled by the Firestore service
    // The service will automatically clear when user logs out
  }

  // Simulation methods for testing
  void simulateJobApplication(String jobTitle, String applicantName) {
    addNotification(
      createNotification(
        title: 'Ombi la Kazi Mpya',
        body: '$applicantName ameweka ombi la kazi: $jobTitle',
        type: NotificationType.jobApplication,
        data: {'jobTitle': jobTitle, 'applicantName': applicantName},
      ),
    );
  }

  void simulatePaymentReceived(double amount) {
    addNotification(
      createNotification(
        title: 'Malipo Yamepokelewa',
        body: 'TZS ${amount.toStringAsFixed(0)} yamepokelewa kwenye account yako',
        type: NotificationType.payment,
        data: {'amount': amount},
      ),
    );
  }

  void simulateVerificationUpdate(bool isVerified) {
    addNotification(
      createNotification(
        title: isVerified ? 'Account Imethibitishwa' : 'Account Haijathibitishwa',
        body: isVerified 
          ? 'Account yako imethibitishwa na sasa unaweza kutumia huduma zote'
          : 'Account yako haijathibitishwa. Tafadhali subiri au wasiliana na support',
        type: NotificationType.verification,
        data: {'isVerified': isVerified},
      ),
    );
  }

  @override
  void dispose() {
    _firestoreService.dispose();
    super.dispose();
  }
} 
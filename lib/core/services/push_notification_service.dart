import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';
import '../../main.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize settings for iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    _isInitialized = true;
  }

  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      // Job Applications Channel
      const AndroidNotificationChannel jobApplicationsChannel =
          AndroidNotificationChannel(
        'job_applications',
        'Job Applications',
        description: 'Notifications for new job applications',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Job Updates Channel
      const AndroidNotificationChannel jobUpdatesChannel =
          AndroidNotificationChannel(
        'job_updates',
        'Job Updates',
        description: 'Notifications for job status updates',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Payments Channel
      const AndroidNotificationChannel paymentsChannel =
          AndroidNotificationChannel(
        'payments',
        'Payments',
        description: 'Notifications for payment transactions',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Verification Channel
      const AndroidNotificationChannel verificationChannel =
          AndroidNotificationChannel(
        'verification',
        'Verification',
        description: 'Notifications for ID verification status',
        importance: Importance.none,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Chat Channel
      const AndroidNotificationChannel chatChannel =
          AndroidNotificationChannel(
        'chat',
        'Chat Messages',
        description: 'Notifications for new chat messages',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // System Channel
      const AndroidNotificationChannel systemChannel =
          AndroidNotificationChannel(
        'system',
        'System Notifications',
        description: 'System and general notifications',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      );

      // Create all channels
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(jobApplicationsChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(jobUpdatesChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(paymentsChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(verificationChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(chatChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(systemChannel);
    }
  }

  String _getChannelId(NotificationType type) {
    switch (type) {
      case NotificationType.jobApplication:
        return 'job_applications';
      case NotificationType.jobAccepted:
      case NotificationType.jobRejected:
        return 'job_updates';
      case NotificationType.payment:
        return 'payments';
      case NotificationType.verification:
        return 'verification';
      case NotificationType.chat:
        return 'chat';
      case NotificationType.system:
      default:
        return 'system';
    }
  }

  Future<void> showNotification(NotificationModel notification) async {
    if (!_isInitialized) await initialize();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _getChannelId(notification.type),
      _getChannelId(notification.type),
      channelDescription: 'Notifications for ${notification.type.name}',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      when: notification.timestamp.millisecondsSinceEpoch,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(notification.body),
      category: AndroidNotificationCategory.message,
      actions: [
        const AndroidNotificationAction('mark_read', 'Soma'),
        const AndroidNotificationAction('view', 'Tazama'),
        const AndroidNotificationAction('open_detail', 'Fungua Maelezo'),
      ],
    );

    final DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'message',
      threadIdentifier: notification.type.name,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: notification.id,
    );
  }

  Future<void> showJobApplicationNotification(String jobTitle, String applicantName) async {
    final notification = NotificationService().createNotification(
      title: 'Ombi Jipya la Kazi',
      body: '$applicantName ameomba kazi yako ya $jobTitle.',
      type: NotificationType.jobApplication,
      data: {
        'jobTitle': jobTitle,
        'applicantName': applicantName,
      },
    );

    await showNotification(notification);
  }

  Future<void> showPaymentNotification(double amount) async {
    final notification = NotificationService().createNotification(
      title: 'Malipo Yamepokelewa',
      body: 'Umefanikiwa kupokea TZS ${amount.toStringAsFixed(0)}.',
      type: NotificationType.payment,
      data: {'amount': amount},
    );

    await showNotification(notification);
  }

  Future<void> showVerificationNotification(bool isApproved) async {
    final notification = NotificationService().createNotification(
      title: isApproved ? 'Uthibitishaji wa ID' : 'Uthibitishaji wa ID Umekataliwa',
      body: isApproved 
        ? 'ID yako imethibitishwa na timu yetu.'
        : 'ID yako haijathibitishwa. Tafadhali jaribu tena.',
      type: NotificationType.verification,
      data: {'isApproved': isApproved},
    );

    await showNotification(notification);
  }

  Future<void> showChatNotification(String senderName, String message) async {
    final notification = NotificationService().createNotification(
      title: 'Ujumbe Mpya',
      body: '$senderName: $message',
      type: NotificationType.chat,
      data: {
        'senderName': senderName,
        'message': message,
      },
    );

    await showNotification(notification);
  }

  Future<void> showSystemNotification(String title, String body) async {
    final notification = NotificationService().createNotification(
      title: title,
      body: body,
      type: NotificationType.system,
    );

    await showNotification(notification);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    final notificationId = response.payload;
    final actionId = response.actionId;

    if (actionId == 'mark_read') {
      // Mark notification as read
      if (notificationId != null) {
        NotificationService().markAsRead(notificationId);
      }
    } else if (actionId == 'view') {
      // Navigate to relevant screen based on notification type
      _navigateToRelevantScreen(notificationId);
    } else if (actionId == 'open_detail') {
      // Navigate to notification detail screen
      if (notificationId != null) {
        navigatorKey.currentState?.pushNamed(
          '/notification-detail',
          arguments: {'notificationId': notificationId},
        );
      }
    } else {
      // Default tap action - navigate to notification detail
      if (notificationId != null) {
        navigatorKey.currentState?.pushNamed(
          '/notification-detail',
          arguments: {'notificationId': notificationId},
        );
      }
    }
  }

  void _navigateToRelevantScreen(String? notificationId) async {
    if (notificationId == null) return;

    try {
      // Get notification details
      final notification = await NotificationService().getNotification(notificationId);
      if (notification == null) return;

      // Mark as read
      NotificationService().markAsRead(notificationId);

      // Navigate to notification detail screen for all types
      navigatorKey.currentState?.pushNamed(
        '/notification-detail',
        arguments: {'notificationId': notificationId},
      );
    } catch (e) {
      // If navigation fails, just mark as read
      NotificationService().markAsRead(notificationId);
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      // iOS permissions are handled automatically by the plugin
      // No additional setup needed for iOS
    }
  }

  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    return true; // iOS permissions are handled differently
  }
} 
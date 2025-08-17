import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';
import 'firestore_notification_service.dart';
import '../../main.dart';

class PushNotificationService extends ChangeNotifier {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreNotificationService _firestoreNotificationService = FirestoreNotificationService();
  
  String? _fcmToken;
  bool _isInitialized = false;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

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

    try {
      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        
        // Save token to user's document
        await _saveTokenToUser();
        
        // Listen for token refresh
        _messaging.onTokenRefresh.listen((token) {
          _fcmToken = token;
          _saveTokenToUser();
        });

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _handleForegroundMessage(message);
        });

        // Handle when app is opened from notification
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          _handleNotificationTap(message);
        });

        _isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error initializing push notifications: $e');
    }
  }

  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      // General notifications channel
      const AndroidNotificationChannel generalChannel =
          AndroidNotificationChannel(
        'general',
        'General Notifications',
        description: 'Notifications for general app updates',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Job notifications channel
      const AndroidNotificationChannel jobChannel =
          AndroidNotificationChannel(
        'jobs',
        'Job Notifications',
        description: 'Notifications for job applications and updates',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Payment notifications channel
      const AndroidNotificationChannel paymentChannel =
          AndroidNotificationChannel(
        'payments',
        'Payment Notifications',
        description: 'Notifications for payment updates',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Chat notifications channel
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

      // Create all channels
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(generalChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(jobChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(paymentChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(chatChannel);
    }
  }

  Future<void> _saveTokenToUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null && _fcmToken != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': _fcmToken,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Create notification model from remote message
    final notification = _remoteMessageToNotification(message);
    
    // Show local notification
    showNotification(notification);
    
    // Notify listeners
    notifyListeners();
  }

  NotificationModel _remoteMessageToNotification(RemoteMessage message) {
    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? message.data['title'] ?? '',
      body: message.notification?.body ?? message.data['body'] ?? '',
      timestamp: DateTime.now(),
      type: _stringToNotificationType(message.data['type'] ?? 'system'),
      data: message.data,
    );
  }

  NotificationType _stringToNotificationType(String type) {
    switch (type) {
      case 'job_application':
        return NotificationType.jobApplication;
      case 'job_accepted':
        return NotificationType.jobAccepted;
      case 'job_rejected':
        return NotificationType.jobRejected;
      case 'payment':
        return NotificationType.payment;
      case 'verification':
        return NotificationType.verification;
      case 'chat':
        return NotificationType.chat;
      case 'system':
      default:
        return NotificationType.system;
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigate to appropriate screen based on notification type
    final notificationType = message.data['type'];
    
    switch (notificationType) {
      case 'job_application':
        _navigateToJobApplications();
        break;
      case 'job_accepted':
      case 'job_rejected':
        _navigateToAppliedJobs();
        break;
      case 'payment':
        _navigateToWallet();
        break;
      case 'verification':
        _navigateToVerification();
        break;
      case 'chat':
        _navigateToChat(message.data['chatRoomId']);
        break;
      default:
        _navigateToNotifications();
        break;
    }
  }

  void _navigateToJobApplications() {
    navigatorKey.currentState?.pushNamed('/applications-received');
  }

  void _navigateToAppliedJobs() {
    navigatorKey.currentState?.pushNamed('/applied-jobs');
  }

  void _navigateToWallet() {
    navigatorKey.currentState?.pushNamed('/wallet');
  }

  void _navigateToVerification() {
    navigatorKey.currentState?.pushNamed('/verification-status');
  }

  void _navigateToChat(String? chatRoomId) {
    if (chatRoomId != null) {
      navigatorKey.currentState?.pushNamed('/chat-detail', arguments: {'chatRoomId': chatRoomId});
    } else {
      navigatorKey.currentState?.pushNamed('/chat-list');
    }
  }

  void _navigateToNotifications() {
    navigatorKey.currentState?.pushNamed('/notifications');
  }

  // Send notification to specific user via FCM
  Future<void> sendFCMNotification({
    required String receiverId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get receiver's FCM token
      final receiverDoc = await _firestore.collection('users').doc(receiverId).get();
      if (!receiverDoc.exists) return;

      final receiverData = receiverDoc.data()!;
      final fcmToken = receiverData['fcmToken'];

      if (fcmToken == null) return;

      // Store notification in Firestore
      await _firestore.collection('notifications').add({
        'receiverId': receiverId,
        'title': title,
        'body': body,
        'type': _notificationTypeToString(type),
        'data': data ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'fcmToken': fcmToken,
      });

      // Note: In a real app, you would send the FCM notification via Cloud Functions
      // For now, we'll just store it in Firestore and let the client handle it
      print('Notification stored in Firestore for user: $receiverId');

    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }

  String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.jobApplication:
        return 'job_application';
      case NotificationType.jobAccepted:
        return 'job_accepted';
      case NotificationType.jobRejected:
        return 'job_rejected';
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

  // Show local notification
  Future<void> showNotification(NotificationModel notification) async {
    if (!_isInitialized) await initialize();

    String channelId = 'general';
    String channelName = 'General Notifications';
    String channelDescription = 'Notifications for general app updates';

    // Set channel based on notification type
    switch (notification.type) {
      case NotificationType.jobApplication:
      case NotificationType.jobAccepted:
      case NotificationType.jobRejected:
        channelId = 'jobs';
        channelName = 'Job Notifications';
        channelDescription = 'Notifications for job applications and updates';
        break;
      case NotificationType.payment:
        channelId = 'payments';
        channelName = 'Payment Notifications';
        channelDescription = 'Notifications for payment updates';
        break;
      case NotificationType.chat:
        channelId = 'chat';
        channelName = 'Chat Messages';
        channelDescription = 'Notifications for new chat messages';
        break;
      default:
        break;
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      when: notification.timestamp.millisecondsSinceEpoch,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(notification.body),
      category: AndroidNotificationCategory.message,
    );

    final DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'message',
      threadIdentifier: channelId,
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

  // Request permissions
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

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    return true; // iOS permissions are handled differently
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
      final notification = NotificationService().getNotificationById(notificationId);
      if (notification == null) return;

      // Mark as read
      NotificationService().markAsRead(notificationId);

      // Navigate based on notification type
      switch (notification.type) {
        case NotificationType.jobApplication:
          _navigateToJobApplications();
          break;
        case NotificationType.jobAccepted:
        case NotificationType.jobRejected:
          _navigateToAppliedJobs();
          break;
        case NotificationType.payment:
          _navigateToWallet();
          break;
        case NotificationType.verification:
          _navigateToVerification();
          break;
        case NotificationType.chat:
          _navigateToChat(notification.data?['chatRoomId']);
          break;
        default:
          navigatorKey.currentState?.pushNamed(
            '/notification-detail',
            arguments: {'notificationId': notificationId},
          );
          break;
      }
    } catch (e) {
      // If navigation fails, just mark as read
      NotificationService().markAsRead(notificationId);
    }
  }

}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print('Handling background message: ${message.messageId}');
}

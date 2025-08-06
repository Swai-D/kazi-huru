import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';
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

      // Create chat channel
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
    // Handle chat messages
    if (message.data['type'] == 'chat_message') {
      // Show local notification for chat messages
      _showChatNotification(message);
    }
    
    // Handle other notification types
    notifyListeners();
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigate to appropriate screen based on notification type
    if (message.data['type'] == 'chat_message') {
      // Navigate to chat detail screen
      _navigateToChat(message.data['chatRoomId']);
    }
  }

  void _showChatNotification(RemoteMessage message) {
    // This would typically use a local notification plugin
    // For now, we'll just notify listeners
    notifyListeners();
  }

  void _navigateToChat(String chatRoomId) {
    // This would typically use a navigation service
    // For now, we'll just notify listeners
    notifyListeners();
  }

  // Send chat notification to specific user
  Future<void> sendChatNotification({
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
      print('Error sending chat notification: $e');
    }
  }

  // Subscribe to chat notifications
  Future<void> subscribeToChatNotifications(String chatRoomId) async {
    try {
      await _messaging.subscribeToTopic('chat_$chatRoomId');
    } catch (e) {
      print('Error subscribing to chat notifications: $e');
    }
  }

  // Unsubscribe from chat notifications
  Future<void> unsubscribeFromChatNotifications(String chatRoomId) async {
    try {
      await _messaging.unsubscribeFromTopic('chat_$chatRoomId');
    } catch (e) {
      print('Error unsubscribing from chat notifications: $e');
    }
  }

  // Show notification
  Future<void> showNotification(NotificationModel notification) async {
    if (!_isInitialized) await initialize();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat',
      'Chat Messages',
      channelDescription: 'Notifications for chat messages',
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
      threadIdentifier: 'chat',
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

  @override
  void dispose() {
    super.dispose();
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print('Handling background message: ${message.messageId}');
}

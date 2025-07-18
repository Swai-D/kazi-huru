import 'package:flutter/material.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/constants/theme_constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationModel> notifications;

  @override
  void initState() {
    super.initState();
    notifications = [
      NotificationModel(
        id: '1',
        title: 'Ombi Jipya la Kazi',
        body: 'John ameomba kazi yako ya Usafi.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        id: '2',
        title: 'Kazi Imeanza',
        body: 'Kazi ya Kufua Nguo imeanza.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '3',
        title: 'Malipo Yamepokelewa',
        body: 'Umefanikiwa kupokea TZS 20,000.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  void markAsRead(int index) {
    setState(() {
      notifications[index] = NotificationModel(
        id: notifications[index].id,
        title: notifications[index].title,
        body: notifications[index].body,
        timestamp: notifications[index].timestamp,
        isRead: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arifa Zako'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            tileColor: notification.isRead
                ? Colors.grey.shade100
                : ThemeConstants.primaryColor.withOpacity(0.1),
            leading: Icon(
              notification.isRead ? Icons.notifications_none : Icons.notifications_active,
              color: notification.isRead
                  ? Colors.grey
                  : ThemeConstants.primaryColor,
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Text(notification.body),
            trailing: Text(
              _formatTime(notification.timestamp),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: () => markAsRead(index),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
} 
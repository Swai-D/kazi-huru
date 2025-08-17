import 'package:flutter/material.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/theme_constants.dart';
import 'notification_settings_screen.dart';
import 'notification_test_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  NotificationType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('notifications')),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationTestScreen(),
                  ),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(),

          // Notifications List
          Expanded(
            child: ListenableBuilder(
              listenable: _notificationService,
              builder: (context, child) {
                final notifications = _getFilteredNotifications();

                if (notifications.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _buildNotificationTile(notifications[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(context.tr('all'), null),
            const SizedBox(width: 8),
            _buildFilterChip(
              '💼 ${context.tr('jobs')}',
              NotificationType.jobApplication,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              '💰 ${context.tr('payments')}',
              NotificationType.payment,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              '🆔 ${context.tr('verification')}',
              NotificationType.verification,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              '💬 ${context.tr('messages')}',
              NotificationType.chat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, NotificationType? type) {
    final isSelected = _selectedFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? type : null;
        });
      },
      selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
      checkmarkColor: ThemeConstants.primaryColor,
    );
  }

  List<NotificationModel> _getFilteredNotifications() {
    final notifications = _notificationService.notifications;
    if (_selectedFilter == null) {
      return notifications;
    }
    return notifications.where((n) => n.type == _selectedFilter).toList();
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    return Card(
      elevation: notification.isRead ? 1 : 3,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _getNotificationColor(notification.type),
                width: 4,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(
                    notification.type,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    notification.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight:
                                  notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: ThemeConstants.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(notification.timestamp),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected:
                    (value) => _handleNotificationAction(value, notification),
                itemBuilder:
                    (context) => [
                      if (!notification.isRead)
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(Icons.check, size: 16),
                              SizedBox(width: 8),
                              Text('Soma'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Futa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Hakuna Arifa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hakuna arifa mpya kwa sasa',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.jobApplication:
        return Colors.blue;
      case NotificationType.jobAccepted:
        return Colors.green;
      case NotificationType.jobRejected:
        return Colors.red;
      case NotificationType.payment:
        return Colors.orange;
      case NotificationType.verification:
        return Colors.purple;
      case NotificationType.chat:
        return Colors.cyan;
      case NotificationType.system:
      default:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      _notificationService.markAsRead(notification.id);
    }

    // Navigate to notification detail screen
    Navigator.pushNamed(
      context,
      '/notification-detail',
      arguments: {'notificationId': notification.id},
    );
  }

  void _handleNotificationAction(
    String action,
    NotificationModel notification,
  ) {
    switch (action) {
      case 'mark_read':
        _notificationService.markAsRead(notification.id);
        break;
      case 'delete':
        _notificationService.deleteNotification(notification.id);
        break;
    }
  }

  void _showTestNotificationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Test Arifa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.work),
                  title: const Text('Ombi la Kazi'),
                  onTap: () {
                    Navigator.pop(context);
                    _notificationService.simulateJobApplication(
                      'Usafi',
                      'John Doe',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Malipo'),
                  onTap: () {
                    Navigator.pop(context);
                    _notificationService.simulatePaymentReceived(25000);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: const Text('Uthibitishaji'),
                  onTap: () {
                    Navigator.pop(context);
                    _notificationService.simulateVerificationUpdate(true);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Funga'),
              ),
            ],
          ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m iliyopita';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h iliyopita';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}siku iliyopita';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

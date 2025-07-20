import 'package:flutter/material.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/localization_service.dart';

class NotificationDetailScreen extends StatefulWidget {
  final String notificationId;
  final NotificationModel? notification;

  const NotificationDetailScreen({
    super.key,
    required this.notificationId,
    this.notification,
  });

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  NotificationModel? _notification;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotification();
  }

  Future<void> _loadNotification() async {
    if (widget.notification != null) {
      _notification = widget.notification;
      setState(() {
        _isLoading = false;
      });
    } else {
      // Load notification from service
      final notification = await NotificationService().getNotification(widget.notificationId);
      setState(() {
        _notification = notification;
        _isLoading = false;
      });
    }

    // Mark as read
    if (_notification != null && !_notification!.isRead) {
      NotificationService().markAsRead(widget.notificationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().translate('notification_details')),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notification == null
              ? _buildNotFound()
              : _buildNotificationContent(),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            LocalizationService().translate('notification_not_found'),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationContent() {
    final notification = _notification!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and type
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      notification.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTypeText(notification.type),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Timestamp
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                _formatTimestamp(notification.timestamp),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationService().translate('message'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  notification.body,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          if (notification.data != null && notification.data!.isNotEmpty)
            _buildActionButtons(notification),
        ],
      ),
    );
  }

  Widget _buildActionButtons(NotificationModel notification) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService().translate('actions'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (notification.type == NotificationType.jobApplication)
              _buildActionButton(
                'Tazama Ombi',
                Icons.work,
                () => _navigateToJobApplication(notification),
              ),
            if (notification.type == NotificationType.chat)
              _buildActionButton(
                'Fungua Chat',
                Icons.chat,
                () => _navigateToChat(notification),
              ),
            if (notification.type == NotificationType.payment)
              _buildActionButton(
                'Tazama Malipo',
                Icons.payment,
                () => _navigateToPayment(notification),
              ),
            if (notification.type == NotificationType.verification)
              _buildActionButton(
                'Tazama Uthibitishaji',
                Icons.verified_user,
                () => _navigateToVerification(notification),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _getTypeText(NotificationType type) {
    switch (type) {
      case NotificationType.jobApplication:
        return LocalizationService().translate('job_application');
      case NotificationType.jobAccepted:
        return LocalizationService().translate('job_accepted');
      case NotificationType.jobRejected:
        return LocalizationService().translate('job_rejected');
      case NotificationType.payment:
        return LocalizationService().translate('payment');
      case NotificationType.verification:
        return LocalizationService().translate('verification');
      case NotificationType.chat:
        return LocalizationService().translate('chat');
      case NotificationType.system:
      default:
        return LocalizationService().translate('system');
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${LocalizationService().translate('days_ago')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${LocalizationService().translate('hours_ago')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${LocalizationService().translate('minutes_ago')}';
    } else {
      return LocalizationService().translate('just_now');
    }
  }

  void _navigateToJobApplication(NotificationModel notification) {
    // Navigate to job application details
    Navigator.pushNamed(context, '/job_application_details', arguments: notification.data);
  }

  void _navigateToChat(NotificationModel notification) {
    // Navigate to chat screen
    Navigator.pushNamed(context, '/chat', arguments: notification.data);
  }

  void _navigateToPayment(NotificationModel notification) {
    // Navigate to payment details
    Navigator.pushNamed(context, '/payment_details', arguments: notification.data);
  }

  void _navigateToVerification(NotificationModel notification) {
    // Navigate to verification status
    Navigator.pushNamed(context, '/verification-status');
  }
} 
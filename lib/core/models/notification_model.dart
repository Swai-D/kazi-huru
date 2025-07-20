import '../services/notification_service.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.type = NotificationType.system,
    this.data,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }

  // Get icon based on notification type
  String get icon {
    switch (type) {
      case NotificationType.jobApplication:
        return '💼';
      case NotificationType.jobAccepted:
        return '✅';
      case NotificationType.jobRejected:
        return '❌';
      case NotificationType.payment:
        return '💰';
      case NotificationType.verification:
        return '🆔';
      case NotificationType.chat:
        return '💬';
      case NotificationType.system:
      default:
        return '🔔';
    }
  }

  // Get color based on notification type
  String get color {
    switch (type) {
      case NotificationType.jobApplication:
        return '#2196F3'; // Blue
      case NotificationType.jobAccepted:
        return '#4CAF50'; // Green
      case NotificationType.jobRejected:
        return '#F44336'; // Red
      case NotificationType.payment:
        return '#FF9800'; // Orange
      case NotificationType.verification:
        return '#9C27B0'; // Purple
      case NotificationType.chat:
        return '#00BCD4'; // Cyan
      case NotificationType.system:
      default:
        return '#607D8B'; // Blue Grey
    }
  }
} 
import 'package:flutter/material.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/constants/theme_constants.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeConstants.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: 48,
                    color: ThemeConstants.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Test Push Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bofya notification type ili kuona jinsi inavyofanya kazi',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Notification Types
            const Text(
              'Aina za Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView(
                children: [
                  _buildNotificationTestCard(
                    '💼 Job Application',
                    'Test notification ya ombi jipya la kazi',
                    Icons.work,
                    Colors.blue,
                    () => _testJobApplication(),
                  ),
                  _buildNotificationTestCard(
                    '💰 Payment',
                    'Test notification ya malipo',
                    Icons.payment,
                    Colors.orange,
                    () => _testPayment(),
                  ),
                  _buildNotificationTestCard(
                    '🆔 Verification',
                    'Test notification ya uthibitishaji',
                    Icons.verified_user,
                    Colors.purple,
                    () => _testVerification(),
                  ),
                  _buildNotificationTestCard(
                    '💬 Chat Message',
                    'Test notification ya ujumbe',
                    Icons.chat,
                    Colors.cyan,
                    () => _testChatMessage(),
                  ),
                  _buildNotificationTestCard(
                    '✅ Job Accepted',
                    'Test notification ya kazi iliyokubaliwa',
                    Icons.check_circle,
                    Colors.green,
                    () => _testJobAccepted(),
                  ),
                  _buildNotificationTestCard(
                    '❌ Job Rejected',
                    'Test notification ya kazi iliyokataliwa',
                    Icons.cancel,
                    Colors.red,
                    () => _testJobRejected(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bulk Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testAllNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isLoading ? 'Testing...' : 'Test All Notifications',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTestCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.send),
          onPressed: onTap,
          color: color,
        ),
      ),
    );
  }

  void _testJobApplication() {
    _notificationService.simulateJobApplication('Usafi wa Nyumba', 'John Doe');
    _showSuccessSnackBar('Job Application notification sent!');
    
    // Navigate to notification detail after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final notifications = _notificationService.notifications;
      if (notifications.isNotEmpty) {
        Navigator.pushNamed(
          context,
          '/notification-detail',
          arguments: {'notificationId': notifications.first.id},
        );
      }
    });
  }

  void _testPayment() {
    _notificationService.simulatePaymentReceived(35000);
    _showSuccessSnackBar('Payment notification sent!');
    
    // Navigate to notification detail after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final notifications = _notificationService.notifications;
      if (notifications.isNotEmpty) {
        Navigator.pushNamed(
          context,
          '/notification-detail',
          arguments: {'notificationId': notifications.first.id},
        );
      }
    });
  }

  void _testVerification() {
    _notificationService.simulateVerificationUpdate(true);
    _showSuccessSnackBar('Verification notification sent!');
    
    // Navigate to notification detail after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final notifications = _notificationService.notifications;
      if (notifications.isNotEmpty) {
        Navigator.pushNamed(
          context,
          '/notification-detail',
          arguments: {'notificationId': notifications.first.id},
        );
      }
    });
  }

  void _testChatMessage() {
    _notificationService.simulateChatMessage('Sarah', 'Habari! Una kazi ya usafi?');
    _showSuccessSnackBar('Chat notification sent!');
    
    // Navigate to notification detail after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final notifications = _notificationService.notifications;
      if (notifications.isNotEmpty) {
        Navigator.pushNamed(
          context,
          '/notification-detail',
          arguments: {'notificationId': notifications.first.id},
        );
      }
    });
  }

  void _testJobAccepted() {
    final notification = _notificationService.createNotification(
      title: 'Kazi Imekubaliwa',
      body: 'Ombi lako la kazi ya Usafi limekubaliwa.',
      type: NotificationType.jobAccepted,
      data: {'jobId': 'job_123'},
    );
    _notificationService.addNotification(notification);
    _showSuccessSnackBar('Job Accepted notification sent!');
    
    // Navigate to notification detail after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final notifications = _notificationService.notifications;
      if (notifications.isNotEmpty) {
        Navigator.pushNamed(
          context,
          '/notification-detail',
          arguments: {'notificationId': notifications.first.id},
        );
      }
    });
  }

  void _testJobRejected() {
    final notification = _notificationService.createNotification(
      title: 'Kazi Imekataliwa',
      body: 'Ombi lako la kazi ya Usafi limekataliwa.',
      type: NotificationType.jobRejected,
      data: {'jobId': 'job_123'},
    );
    _notificationService.addNotification(notification);
    _showSuccessSnackBar('Job Rejected notification sent!');
    
    // Navigate to notification detail after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final notifications = _notificationService.notifications;
      if (notifications.isNotEmpty) {
        Navigator.pushNamed(
          context,
          '/notification-detail',
          arguments: {'notificationId': notifications.first.id},
        );
      }
    });
  }

  Future<void> _testAllNotifications() async {
    setState(() {
      _isLoading = true;
    });

    // Test all notifications with delays
    await Future.delayed(const Duration(milliseconds: 500));
    _testJobApplication();
    
    await Future.delayed(const Duration(milliseconds: 1000));
    _testPayment();
    
    await Future.delayed(const Duration(milliseconds: 1000));
    _testVerification();
    
    await Future.delayed(const Duration(milliseconds: 1000));
    _testChatMessage();
    
    await Future.delayed(const Duration(milliseconds: 1000));
    _testJobAccepted();
    
    await Future.delayed(const Duration(milliseconds: 1000));
    _testJobRejected();

    setState(() {
      _isLoading = false;
    });

    _showSuccessSnackBar('All notifications sent successfully!');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
} 
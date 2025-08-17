import 'package:flutter/material.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/job_service.dart';
import '../../../../core/services/wallet_service.dart';
import '../../../../core/services/chat_service.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final NotificationService _notificationService = NotificationService();
  final JobService _jobService = JobService();
  final WalletService _walletService = WalletService();
  // Verification service removed temporarily
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Job Notifications'),
          _buildTestButton(
            'Test Job Application',
            'Send a job application notification',
            Icons.work,
            () => _testJobApplication(),
          ),
          _buildTestButton(
            'Test Job Accepted',
            'Send a job accepted notification',
            Icons.check_circle,
            () => _testJobAccepted(),
          ),
          _buildTestButton(
            'Test Job Rejected',
            'Send a job rejected notification',
            Icons.cancel,
            () => _testJobRejected(),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Payment Notifications'),
          _buildTestButton(
            'Test Payment Received',
            'Send a payment received notification',
            Icons.payment,
            () => _testPaymentReceived(),
          ),
          _buildTestButton(
            'Test Payment Sent',
            'Send a payment sent notification',
            Icons.send,
            () => _testPaymentSent(),
          ),
          _buildTestButton(
            'Test Bonus Received',
            'Send a bonus received notification',
            Icons.card_giftcard,
            () => _testBonusReceived(),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Verification Notifications'),
          _buildTestButton(
            'Test Verification Approved',
            'Send a verification approved notification',
            Icons.verified_user,
            () => _testVerificationApproved(),
          ),
          _buildTestButton(
            'Test Verification Rejected',
            'Send a verification rejected notification',
            Icons.block,
            () => _testVerificationRejected(),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Chat Notifications'),
          _buildTestButton(
            'Test Chat Message',
            'Send a chat message notification',
            Icons.chat,
            () => _testChatMessage(),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('System Notifications'),
          _buildTestButton(
            'Test System Notification',
            'Send a system notification',
            Icons.info,
            () => _testSystemNotification(),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Real Actions'),
          _buildTestButton(
            'Apply for Job (Real)',
            'Actually apply for a job and trigger notification',
            Icons.work_outline,
            () => _applyForJobReal(),
          ),
          _buildTestButton(
            'Top Up Wallet (Real)',
            'Actually top up wallet and trigger notification',
            Icons.account_balance_wallet,
            () => _topUpWalletReal(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTestButton(String title, String subtitle, IconData icon, VoidCallback onPressed) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onPressed,
      ),
    );
  }

  void _testJobApplication() async {
    await _notificationService.sendJobApplicationNotification(
      jobProviderId: 'provider123',
      jobTitle: 'Usafi wa Nyumba',
      applicantName: 'John Doe',
      jobId: 'job_456',
    );
    _showSuccessSnackBar('Job application notification sent!');
  }

  void _testJobAccepted() async {
    await _notificationService.sendJobStatusNotification(
      jobSeekerId: 'seeker123',
      jobTitle: 'Usafi wa Nyumba',
      isAccepted: true,
      jobId: 'job_456',
    );
    _showSuccessSnackBar('Job accepted notification sent!');
  }

  void _testJobRejected() async {
    await _notificationService.sendJobStatusNotification(
      jobSeekerId: 'seeker123',
      jobTitle: 'Usafi wa Nyumba',
      isAccepted: false,
      jobId: 'job_456',
    );
    _showSuccessSnackBar('Job rejected notification sent!');
  }

  void _testPaymentReceived() async {
    await _notificationService.sendPaymentNotification(
      userId: 'user123',
      amount: 25000,
      transactionId: 'txn_789',
      paymentType: 'received',
    );
    _showSuccessSnackBar('Payment received notification sent!');
  }

  void _testPaymentSent() async {
    await _notificationService.sendPaymentNotification(
      userId: 'user123',
      amount: 500,
      transactionId: 'txn_790',
      paymentType: 'sent',
    );
    _showSuccessSnackBar('Payment sent notification sent!');
  }

  void _testBonusReceived() async {
    await _notificationService.sendPaymentNotification(
      userId: 'user123',
      amount: 1000,
      transactionId: 'txn_791',
      paymentType: 'bonus',
    );
    _showSuccessSnackBar('Bonus received notification sent!');
  }

  void _testVerificationApproved() async {
    await _notificationService.sendVerificationNotification(
      userId: 'user123',
      isApproved: true,
    );
    _showSuccessSnackBar('Verification approved notification sent!');
  }

  void _testVerificationRejected() async {
    await _notificationService.sendVerificationNotification(
      userId: 'user123',
      isApproved: false,
    );
    _showSuccessSnackBar('Verification rejected notification sent!');
  }

  void _testChatMessage() async {
    await _notificationService.sendChatNotification(
      receiverId: 'user123',
      senderName: 'Jane Smith',
      message: 'Hello! Are you available for the job?',
      chatRoomId: 'chat_123',
    );
    _showSuccessSnackBar('Chat message notification sent!');
  }

  void _testSystemNotification() async {
    await _notificationService.sendSystemNotification(
      userId: 'user123',
      title: 'Mfumo Mpya',
      body: 'Tunaanza kutumia mfumo mpya wa malipo.',
      data: {'type': 'system_update'},
    );
    _showSuccessSnackBar('System notification sent!');
  }

  void _applyForJobReal() async {
    try {
      final success = await _jobService.applyForJob(
        jobId: 'job_test_123',
        seekerId: 'user123',
        message: 'I am interested in this job',
      );

      if (success) {
        _showSuccessSnackBar('Job application submitted successfully!');
      } else {
        _showErrorSnackBar('Failed to submit job application');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  void _topUpWalletReal() async {
    try {
      final success = _walletService.topUpWallet(
        10000,
        'M-Pesa',
        reference: 'TEST_TOPUP_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (success) {
        _showSuccessSnackBar('Wallet topped up successfully!');
      } else {
        _showErrorSnackBar('Failed to top up wallet');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
} 
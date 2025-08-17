import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/firestore_service.dart';

class AssignedJobsScreen extends StatefulWidget {
  const AssignedJobsScreen({super.key});

  @override
  State<AssignedJobsScreen> createState() => _AssignedJobsScreenState();
}

class _AssignedJobsScreenState extends State<AssignedJobsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _assignedJobs = [];

  @override
  void initState() {
    super.initState();
    _loadAssignedJobs();
  }

  Future<void> _loadAssignedJobs() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final assignmentsQuery = await _firestore
          .collection('job_assignments')
          .where('jobSeekerId', isEqualTo: currentUser.uid)
          .orderBy('assignedAt', descending: true)
          .get();

      final List<Map<String, dynamic>> assignments = [];
      
      for (final doc in assignmentsQuery.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Get job details
        final jobDoc = await _firestore.collection('jobs').doc(data['jobId']).get();
        if (jobDoc.exists) {
          final jobData = jobDoc.data()!;
          data['jobDetails'] = jobData;
        }
        
        // Get provider details
        final providerDoc = await _firestore.collection('users').doc(data['providerId']).get();
        if (providerDoc.exists) {
          final providerData = providerDoc.data()!;
          data['providerDetails'] = providerData;
        }
        
        assignments.add(data);
      }

      setState(() {
        _assignedJobs = assignments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading assigned jobs: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kazi Zangu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAssignedJobs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assignedJobs.isEmpty
              ? _buildEmptyState()
              : _buildAssignedJobsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Hakuna kazi ulizopewa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Endelea kutafuta kazi na kuomba',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedJobsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assignedJobs.length,
      itemBuilder: (context, index) {
        final assignment = _assignedJobs[index];
        return _buildAssignmentCard(assignment);
      },
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final jobDetails = assignment['jobDetails'] as Map<String, dynamic>?;
    final providerDetails = assignment['providerDetails'] as Map<String, dynamic>?;
    final status = assignment['status'] as String?;
    final assignedAt = assignment['assignedAt'] as Timestamp?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobDetails?['title'] ?? 'Kazi Isiyojulikana',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mwenye Kazi: ${providerDetails?['name'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(status ?? 'unknown'),
              ],
            ),
            const SizedBox(height: 12),
            if (jobDetails != null) ...[
              _buildInfoRow('Mahali', jobDetails['location'] ?? '—'),
              _buildInfoRow('Mshahara', _formatSalary(jobDetails)),
              _buildInfoRow('Aina ya Malipo', _getPaymentTypeLabel(jobDetails['paymentType'] ?? '')),
              _buildInfoRow('Muda', _getDurationLabel(jobDetails['duration'] ?? '')),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Ilipewa: ${_formatDate(assignedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactProvider(assignment),
                    icon: const Icon(Icons.message, size: 16),
                    label: const Text('Wasiliana'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeConstants.primaryColor,
                      side: BorderSide(color: ThemeConstants.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewJobDetails(assignment),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Tazama'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'assigned':
        color = Colors.blue;
        label = 'Ilipewa';
        icon = Icons.work;
        break;
      case 'in_progress':
        color = Colors.orange;
        label = 'Inafanywa';
        icon = Icons.pending;
        break;
      case 'completed':
        color = Colors.green;
        label = 'Imekamilika';
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Imefutwa';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        label = 'Haijulikani';
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSalary(Map<String, dynamic> jobDetails) {
    final minPayment = jobDetails['minPayment'] as double? ?? 0;
    final maxPayment = jobDetails['maxPayment'] as double? ?? 0;
    
    if (minPayment == maxPayment) {
      return 'TSh ${_formatCurrency(minPayment)}';
    } else {
      return 'TSh ${_formatCurrency(minPayment)} - ${_formatCurrency(maxPayment)}';
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  String _getPaymentTypeLabel(String paymentType) {
    switch (paymentType) {
      case 'per_job':
        return 'Kwa Kazi';
      case 'per_hour':
        return 'Kwa Saa';
      case 'per_day':
        return 'Kwa Siku';
      default:
        return paymentType;
    }
  }

  String _getDurationLabel(String duration) {
    switch (duration) {
      case '1_hour':
        return 'Saa 1';
      case '2_hours':
        return 'Masaa 2';
      case '3_hours':
        return 'Masaa 3';
      case '4_hours':
        return 'Masaa 4';
      case '6_hours':
        return 'Masaa 6';
      case '8_hours':
        return 'Masaa 8';
      case '1_day':
        return 'Siku 1';
      case '2_days':
        return 'Siku 2';
      case '3_days':
        return 'Siku 3';
      case '1_week':
        return 'Wiki 1';
      case '2_weeks':
        return 'Wiki 2';
      case '1_month':
        return 'Mwezi 1';
      default:
        return duration;
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '—';
    
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Leo ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Jana ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return 'Siku ${difference.inDays} zilizopita';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _contactProvider(Map<String, dynamic> assignment) {
    final providerId = assignment['providerId'];
    if (providerId != null) {
      Navigator.pushNamed(
        context,
        '/chat-detail',
        arguments: {
          'chatRoomId': null,
          'otherUserId': providerId,
        },
      );
    }
  }

  void _viewJobDetails(Map<String, dynamic> assignment) {
    final jobId = assignment['jobId'];
    if (jobId != null) {
      Navigator.pushNamed(
        context,
        '/job-details',
        arguments: {'jobId': jobId},
      );
    }
  }
}

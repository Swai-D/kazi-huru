import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  // Sample data - in real app this would come from API/database
  final List<Map<String, dynamic>> _appliedJobs = [
    {
      'id': '1',
      'title': 'Software Developer',
      'company': 'Tech Solutions Ltd',
      'location': 'Dar es Salaam',
      'salary': 'TZS 2,500,000',
      'status': 'Pending',
      'appliedDate': '2024-01-15',
      'statusColor': Colors.orange,
    },
    {
      'id': '2',
      'title': 'Data Entry Clerk',
      'company': 'Office Solutions',
      'location': 'Dar es Salaam',
      'salary': 'TZS 800,000',
      'status': 'Under Review',
      'appliedDate': '2024-01-12',
      'statusColor': Colors.blue,
    },
    {
      'id': '3',
      'title': 'Marketing Assistant',
      'company': 'Digital Agency',
      'location': 'Dar es Salaam',
      'salary': 'TZS 1,200,000',
      'status': 'Shortlisted',
      'appliedDate': '2024-01-10',
      'statusColor': Colors.purple,
    },
    {
      'id': '4',
      'title': 'Customer Service',
      'company': 'Telecom Company',
      'location': 'Dar es Salaam',
      'salary': 'TZS 900,000',
      'status': 'Rejected',
      'appliedDate': '2024-01-08',
      'statusColor': Colors.red,
    },
    {
      'id': '5',
      'title': 'Graphic Designer',
      'company': 'Creative Studio',
      'location': 'Dar es Salaam',
      'salary': 'TZS 1,500,000',
      'status': 'Pending',
      'appliedDate': '2024-01-05',
      'statusColor': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.tr('applied_jobs')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeConstants.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeConstants.cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Applied',
                    '${_appliedJobs.length}',
                    Icons.work_outline,
                    ThemeConstants.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Pending',
                    '${_appliedJobs.where((job) => job['status'] == 'Pending').length}',
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Under Review',
                    '${_appliedJobs.where((job) => job['status'] == 'Under Review').length}',
                    Icons.search,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          
          // Jobs List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _appliedJobs.length,
              itemBuilder: (context, index) {
                final job = _appliedJobs[index];
                return _buildJobCard(job);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  job['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: job['statusColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job['status'],
                  style: TextStyle(
                    color: job['statusColor'],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Company and location
          Row(
            children: [
              Icon(Icons.business, color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              Text(
                job['company'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              Text(
                job['location'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Salary and applied date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.green[600], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    job['salary'],
                    style: TextStyle(
                      color: Colors.green[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                'Applied: ${job['appliedDate']}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // View job details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${context.tr('viewing')} ${job['title']}')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ThemeConstants.primaryColor),
                  ),
                  child: Text(
                    context.tr('view_details'),
                    style: TextStyle(color: ThemeConstants.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Withdraw application
                    _showWithdrawDialog(job);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    context.tr('withdraw'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('withdraw_application')),
          content: Text('${context.tr('withdraw_confirmation')} ${job['title']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Remove job from list
                setState(() {
                  _appliedJobs.removeWhere((j) => j['id'] == job['id']);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('application_withdrawn'))),
                );
              },
              child: Text(
                context.tr('withdraw'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
} 
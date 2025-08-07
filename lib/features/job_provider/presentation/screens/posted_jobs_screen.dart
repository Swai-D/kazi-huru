import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/job_service.dart';
import '../../../../core/models/job_model.dart';
import '../../../../core/providers/auth_provider.dart';
import 'post_job_screen.dart';
import 'dart:async';

class PostedJobsScreen extends StatefulWidget {
  const PostedJobsScreen({super.key});

  @override
  State<PostedJobsScreen> createState() => _PostedJobsScreenState();
}

class _PostedJobsScreenState extends State<PostedJobsScreen> {
  final JobService _jobService = JobService();
  List<JobModel> _jobs = [];
  StreamSubscription<List<JobModel>>? _jobsSubscription;
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String? _selectedJobId;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _jobsSubscription?.cancel();
    super.dispose();
  }

  void _loadJobs() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final providerId = authProvider.currentUser?.uid ?? '';
    
    _jobsSubscription = _jobService.getJobsByProvider(providerId).listen((jobs) {
      if (mounted) {
        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      }
    });
  }

  List<JobModel> get _filteredJobs {
    switch (_selectedFilter) {
      case 'active':
        return _jobs.where((job) => job.status == JobStatus.active).toList();
      case 'paused':
        return _jobs.where((job) => job.status == JobStatus.paused).toList();
      case 'completed':
        return _jobs.where((job) => job.status == JobStatus.completed).toList();
      default:
        return _jobs;
    }
  }

  Future<void> _updateJobStatus(String jobId, JobStatus status) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _jobService.updateJobStatus(jobId, status.toString().split('.').last);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job status updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteJob(String jobId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _jobService.deleteJob(jobId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showJobOptions(JobModel job) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: ThemeConstants.primaryColor),
              title: Text('Edit Job'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostJobScreen(jobToEdit: job),
                  ),
                );
              },
            ),
            if (job.status == JobStatus.active)
              ListTile(
                leading: const Icon(Icons.pause, color: Colors.orange),
                title: Text('Pause Job'),
                onTap: () {
                  Navigator.pop(context);
                  _updateJobStatus(job.id, JobStatus.paused);
                },
              ),
            if (job.status == JobStatus.paused)
              ListTile(
                leading: const Icon(Icons.play_arrow, color: Colors.green),
                title: Text('Resume Job'),
                onTap: () {
                  Navigator.pop(context);
                  _updateJobStatus(job.id, JobStatus.active);
                },
              ),
            if (job.status == JobStatus.active)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text('Mark as Completed'),
                onTap: () {
                  Navigator.pop(context);
                  _updateJobStatus(job.id, JobStatus.completed);
                },
              ),
            ListTile(
              leading: const Icon(Icons.people, color: ThemeConstants.primaryColor),
              title: Text('View Applications (${job.applicationsCount})'),
              onTap: () {
                Navigator.pop(context);
                _showApplications(job);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Job'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(job);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(JobModel job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Job'),
        content: Text('Are you sure you want to delete "${job.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteJob(job.id);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showApplications(JobModel job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobApplicationsScreen(jobId: job.id, jobTitle: job.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          context.tr('posted_jobs'),
          style: const TextStyle(
            color: ThemeConstants.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeConstants.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: ThemeConstants.primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostJobScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: Text(context.tr('all')),
                    selected: _selectedFilter == 'all',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = 'all';
                      });
                    },
                    selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
                    checkmarkColor: ThemeConstants.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilterChip(
                    label: Text(context.tr('active')),
                    selected: _selectedFilter == 'active',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = 'active';
                      });
                    },
                    selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
                    checkmarkColor: ThemeConstants.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilterChip(
                    label: Text(context.tr('paused')),
                    selected: _selectedFilter == 'paused',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = 'paused';
                      });
                    },
                    selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
                    checkmarkColor: ThemeConstants.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilterChip(
                    label: Text(context.tr('completed')),
                    selected: _selectedFilter == 'completed',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = 'completed';
                      });
                    },
                    selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
                    checkmarkColor: ThemeConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Jobs List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredJobs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No jobs found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Post your first job to get started',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PostJobScreen()),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Post Job'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeConstants.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredJobs.length,
                        itemBuilder: (context, index) {
                          final job = _filteredJobs[index];
                          return _JobCard(
                            job: job,
                            onTap: () => _showJobOptions(job),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (job.status) {
      case JobStatus.active:
        return Colors.green;
      case JobStatus.paused:
        return Colors.orange;
      case JobStatus.completed:
        return Colors.blue;
      case JobStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (job.status) {
      case JobStatus.active:
        return 'Active';
      case JobStatus.paused:
        return 'Paused';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.title,
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
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor()),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    job.location,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                                     Text(
                     job.formattedPayment,
                     style: TextStyle(
                       fontSize: 14,
                       color: Colors.grey[600],
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${job.applicationsCount} applications',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Posted ${_formatDate(job.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

class JobApplicationsScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const JobApplicationsScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  final JobService _jobService = JobService();
  List<Map<String, dynamic>> _applications = [];
  StreamSubscription<List<Map<String, dynamic>>>? _applicationsSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  @override
  void dispose() {
    _applicationsSubscription?.cancel();
    super.dispose();
  }

  void _loadApplications() {
    _applicationsSubscription = _jobService
        .getJobApplicationsWithDetails(widget.jobId)
        .listen((applications) {
      if (mounted) {
        setState(() {
          _applications = applications;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _handleApplicationAction(String applicationId, String action) async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (action == 'accept') {
        await _jobService.acceptApplication(widget.jobId, applicationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (action == 'reject') {
        await _jobService.rejectApplication(widget.jobId, applicationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Applications - ${widget.jobTitle}',
          style: const TextStyle(
            color: ThemeConstants.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeConstants.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No applications yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Applications will appear here when people apply',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _applications.length,
                  itemBuilder: (context, index) {
                    final application = _applications[index];
                    return _ApplicationCard(
                      application: application,
                      onAccept: () => _handleApplicationAction(application['id'], 'accept'),
                      onReject: () => _handleApplicationAction(application['id'], 'reject'),
                    );
                  },
                ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Map<String, dynamic> application;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ApplicationCard({
    required this.application,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final status = application['status'] ?? 'pending';
    final isAccepted = status == 'accepted';
    final isRejected = status == 'rejected';

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
                CircleAvatar(
                  radius: 24,
                  backgroundImage: application['applicantProfileImage'] != null
                      ? NetworkImage(application['applicantProfileImage'])
                      : null,
                  child: application['applicantProfileImage'] == null
                      ? Text(
                          application['applicantName']?.substring(0, 1).toUpperCase() ?? 'A',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['applicantName'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeConstants.textColor,
                        ),
                      ),
                      Text(
                        application['applicantPhone'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAccepted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      'Accepted',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  )
                else if (isRejected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red),
                    ),
                    child: const Text(
                      'Rejected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            if (application['message'] != null) ...[
              const SizedBox(height: 12),
              Text(
                application['message'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
            if (!isAccepted && !isRejected) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
} 
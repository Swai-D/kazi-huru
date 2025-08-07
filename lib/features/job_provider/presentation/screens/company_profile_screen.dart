import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/job_service.dart';
import '../../../../core/models/job_model.dart';
import 'dart:async';
import 'posted_jobs_screen.dart';
import 'applications_screen.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  String _selectedLanguage = 'sw';
  final JobService _jobService = JobService();
  
  List<JobModel> _recentJobs = [];
  List<Map<String, dynamic>> _recentApplications = [];
  Map<String, dynamic> _statistics = {
    'totalJobs': 0,
    'activeJobs': 0,
    'completedJobs': 0,
    'totalApplications': 0,
  };
  bool _isLoadingStats = true;
  bool _isLoadingJobs = true;
  bool _isLoadingApplications = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadStatistics(),
      _loadRecentJobs(),
      _loadRecentApplications(),
    ]);
  }

  Future<void> _loadStatistics() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final providerId = authProvider.currentUser?.uid ?? '';
      
      final stats = await _jobService.getJobStatistics(providerId);
      if (mounted) {
        setState(() {
          _statistics = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  Future<void> _loadRecentJobs() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final providerId = authProvider.currentUser?.uid ?? '';
      
      final jobsSnapshot = await _jobService.getJobsByProvider(providerId).first;
      if (mounted) {
        setState(() {
          _recentJobs = jobsSnapshot.take(3).toList(); // Get latest 3 jobs
          _isLoadingJobs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingJobs = false;
        });
      }
    }
  }

  Future<void> _loadRecentApplications() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final providerId = authProvider.currentUser?.uid ?? '';
      
      final applications = await _jobService.getProviderApplications(providerId).first;
      if (mounted) {
        setState(() {
          _recentApplications = applications.take(3).toList(); // Get latest 3 applications
          _isLoadingApplications = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingApplications = false;
        });
      }
    }
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'paused':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          context.tr('profile'),
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
          // Debug button for profile refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.refreshUserProfile();
              await _loadData(); // Reload data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile refreshed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            tooltip: 'Refresh Profile',
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header with Stats
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: ThemeConstants.primaryColor,
                        child: Text(
                          (authProvider.userProfile?['name'] ?? authProvider.currentUser?.displayName ?? 'J')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        authProvider.userProfile?['name'] ?? authProvider.currentUser?.displayName ?? 'Job Provider',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ThemeConstants.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('job_provider'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                            title: context.tr('jobs_posted'),
                            value: _isLoadingStats ? '...' : '${_statistics['totalJobs']}',
                          ),
                          _StatItem(
                            title: context.tr('completed_jobs'),
                            value: _isLoadingStats ? '...' : '${_statistics['completedJobs']}',
                          ),
                          _StatItem(
                            title: context.tr('applications'),
                            value: _isLoadingStats ? '...' : '${_statistics['totalApplications']}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Company Information Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              context.tr('personal_information'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ThemeConstants.textColor,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: ThemeConstants.primaryColor),
                            onPressed: () {
                              // TODO: Navigate to edit profile screen
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.email,
                        label: context.tr('email'),
                        value: authProvider.currentUser?.email ?? 'No email',
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.phone,
                        label: context.tr('phone'),
                        value: authProvider.userProfile?['phoneNumber'] ?? 'No phone',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Posted Jobs Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              context.tr('posted_jobs'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ThemeConstants.textColor,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PostedJobsScreen(),
                                ),
                              );
                            },
                            child: Text(
                              context.tr('view_all'),
                              style: const TextStyle(
                                color: ThemeConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingJobs)
                        const Center(child: CircularProgressIndicator())
                      else if (_recentJobs.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.work_outline, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'No jobs posted yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._recentJobs.map((job) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _JobCard(
                            title: job.title,
                            company: authProvider.userProfile?['name'] ?? authProvider.currentUser?.displayName ?? 'Job Provider',
                            location: job.location,
                            salary: job.formattedPayment,
                            status: job.status.toString().split('.').last,
                            statusColor: _getStatusColor(job.status.toString().split('.').last),
                            postedDate: _formatDate(job.createdAt),
                          ),
                        )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Applications Received Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              context.tr('applications_received'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ThemeConstants.textColor,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ApplicationsScreen(),
                                ),
                              );
                            },
                            child: Text(
                              context.tr('view_all'),
                              style: const TextStyle(
                                color: ThemeConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingApplications)
                        const Center(child: CircularProgressIndicator())
                      else if (_recentApplications.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'No applications yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._recentApplications.map((application) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ApplicationCard(
                            applicantName: application['applicantName'] ?? 'Unknown',
                            jobTitle: application['jobTitle'] ?? 'Unknown Job',
                            appliedDate: _formatDate(DateTime.parse(application['appliedAt'] ?? DateTime.now().toIso8601String())),
                            status: application['status'] ?? 'pending',
                            statusColor: _getStatusColor(application['status'] ?? 'pending'),
                          ),
                        )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Language Settings Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('language'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeConstants.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilterChip(
                              label: const Text('Swahili'),
                              selected: _selectedLanguage == 'sw',
                              onSelected: (selected) {
                                setState(() {
                                  _selectedLanguage = 'sw';
                                });
                                // Change language
                              },
                              selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
                              checkmarkColor: ThemeConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilterChip(
                              label: const Text('English'),
                              selected: _selectedLanguage == 'en',
                              onSelected: (selected) {
                                setState(() {
                                  _selectedLanguage = 'en';
                                });
                                // Change language
                              },
                              selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
                              checkmarkColor: ThemeConstants.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.signOut();
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(context.tr('logout')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ThemeConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String salary;
  final String status;
  final Color statusColor;
  final String postedDate;

  const _JobCard({
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.status,
    required this.statusColor,
    required this.postedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
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
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  salary,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                postedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final String applicantName;
  final String jobTitle;
  final String appliedDate;
  final String status;
  final Color statusColor;

  const _ApplicationCard({
    required this.applicantName,
    required this.jobTitle,
    required this.appliedDate,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: ThemeConstants.primaryColor,
                child: Text(
                  applicantName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicantName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ThemeConstants.textColor,
                      ),
                    ),
                    Text(
                      jobTitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                appliedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 
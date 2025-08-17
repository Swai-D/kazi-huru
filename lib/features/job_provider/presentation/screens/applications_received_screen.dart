import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';

class ApplicationsReceivedScreen extends StatefulWidget {
  const ApplicationsReceivedScreen({super.key});

  @override
  State<ApplicationsReceivedScreen> createState() =>
      _ApplicationsReceivedScreenState();
}

class _ApplicationsReceivedScreenState
    extends State<ApplicationsReceivedScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          context.tr('applications_received'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: ThemeConstants.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                    label: Text(context.tr('pending')),
                    selected: _selectedFilter == 'pending',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = 'pending';
                      });
                    },
                    selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
                    checkmarkColor: ThemeConstants.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilterChip(
                    label: Text(context.tr('accepted')),
                    selected: _selectedFilter == 'accepted',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = 'accepted';
                      });
                    },
                    selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
                    checkmarkColor: ThemeConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Applications List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ApplicationCard(
                  applicantName: 'Sarah Mwambene',
                  applicantPhone: '+255 712 123 456',
                  jobTitle: 'Usafi wa Nyumba',
                  jobLocation: 'Dar es Salaam, Mbezi Beach',
                  jobSalary: 'TSh 50,000',
                  appliedDate: '2 hours ago',
                  status: 'Pending',
                  statusColor: Colors.orange,
                  rating: 4.5,
                  completedJobs: 12,
                ),
                const SizedBox(height: 16),
                _ApplicationCard(
                  applicantName: 'Juma Hassan',
                  applicantPhone: '+255 713 234 567',
                  jobTitle: 'Kubeba Mizigo',
                  jobLocation: 'Mwanza, City Centre',
                  jobSalary: 'TSh 30,000',
                  appliedDate: '1 day ago',
                  status: 'Accepted',
                  statusColor: Colors.green,
                  rating: 4.8,
                  completedJobs: 25,
                ),
                const SizedBox(height: 16),
                _ApplicationCard(
                  applicantName: 'Fatima Ali',
                  applicantPhone: '+255 714 345 678',
                  jobTitle: 'Kupanda Miti',
                  jobLocation: 'Arusha, Njiro',
                  jobSalary: 'TSh 80,000',
                  appliedDate: '3 days ago',
                  status: 'Rejected',
                  statusColor: Colors.red,
                  rating: 3.9,
                  completedJobs: 8,
                ),
                const SizedBox(height: 16),
                _ApplicationCard(
                  applicantName: 'Peter Mwangi',
                  applicantPhone: '+255 715 456 789',
                  jobTitle: 'Kusafisha Ofisi',
                  jobLocation: 'Dodoma, CBD',
                  jobSalary: 'TSh 40,000',
                  appliedDate: '4 hours ago',
                  status: 'Pending',
                  statusColor: Colors.orange,
                  rating: 4.2,
                  completedJobs: 15,
                ),
                const SizedBox(height: 16),
                _ApplicationCard(
                  applicantName: 'Grace Mwende',
                  applicantPhone: '+255 716 567 890',
                  jobTitle: 'Kubeba Maji',
                  jobLocation: 'Tanga, Mzizima',
                  jobSalary: 'TSh 25,000',
                  appliedDate: '6 hours ago',
                  status: 'Pending',
                  statusColor: Colors.orange,
                  rating: 4.7,
                  completedJobs: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final String applicantName;
  final String applicantPhone;
  final String jobTitle;
  final String jobLocation;
  final String jobSalary;
  final String appliedDate;
  final String status;
  final Color statusColor;
  final double rating;
  final int completedJobs;

  const _ApplicationCard({
    required this.applicantName,
    required this.applicantPhone,
    required this.jobTitle,
    required this.jobLocation,
    required this.jobSalary,
    required this.appliedDate,
    required this.status,
    required this.statusColor,
    required this.rating,
    required this.completedJobs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  applicantName,
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                applicantPhone,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        jobLocation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Text(
                      jobSalary,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ThemeConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.star, size: 16, color: Colors.amber[600]),
              const SizedBox(width: 4),
              Text(
                '$rating',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.work, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '$completedJobs ${context.tr('completed_jobs')}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const Spacer(),
              Text(
                appliedDate,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // View profile
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: ThemeConstants.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    context.tr('view_profile'),
                    style: const TextStyle(
                      color: ThemeConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (status == 'Pending')
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Accept application
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            context.tr('accept'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Reject application
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            context.tr('reject'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

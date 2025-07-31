import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';

class PostedJobsScreen extends StatefulWidget {
  const PostedJobsScreen({super.key});

  @override
  State<PostedJobsScreen> createState() => _PostedJobsScreenState();
}

class _PostedJobsScreenState extends State<PostedJobsScreen> {
  String _selectedFilter = 'all';

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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PostedJobCard(
                  title: 'Usafi wa Nyumba',
                  location: 'Dar es Salaam, Mbezi Beach',
                  salary: 'TSh 50,000',
                  status: 'Active',
                  statusColor: Colors.green,
                  applicants: 5,
                  postedDate: '2 days ago',
                  description: 'Tafadhali safisha nyumba yangu ya chumba 2. Kazi itafanywa leo.',
                ),
                const SizedBox(height: 16),
                _PostedJobCard(
                  title: 'Kubeba Mizigo',
                  location: 'Mwanza, City Centre',
                  salary: 'TSh 30,000',
                  status: 'Active',
                  statusColor: Colors.green,
                  applicants: 3,
                  postedDate: '1 day ago',
                  description: 'Ninahitaji mtu wa kubeba mizigo kutoka duka kwenda nyumbani.',
                ),
                const SizedBox(height: 16),
                _PostedJobCard(
                  title: 'Kupanda Miti',
                  location: 'Arusha, Njiro',
                  salary: 'TSh 80,000',
                  status: 'Completed',
                  statusColor: Colors.blue,
                  applicants: 8,
                  postedDate: '1 week ago',
                  description: 'Kupanda miti 20 kwenye shamba langu. Kazi imekamilika.',
                ),
                const SizedBox(height: 16),
                _PostedJobCard(
                  title: 'Kusafisha Ofisi',
                  location: 'Dodoma, CBD',
                  salary: 'TSh 40,000',
                  status: 'Active',
                  statusColor: Colors.green,
                  applicants: 2,
                  postedDate: '3 days ago',
                  description: 'Safisha ofisi yangu ya chumba 1. Kazi itafanywa kesho.',
                ),
                const SizedBox(height: 16),
                _PostedJobCard(
                  title: 'Kubeba Maji',
                  location: 'Tanga, Mzizima',
                  salary: 'TSh 25,000',
                  status: 'Active',
                  statusColor: Colors.green,
                  applicants: 4,
                  postedDate: '4 days ago',
                  description: 'Ninahitaji mtu wa kubeba maji kutoka kisima kwenda nyumbani.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostedJobCard extends StatelessWidget {
  final String title;
  final String location;
  final String salary;
  final String status;
  final Color statusColor;
  final int applicants;
  final String postedDate;
  final String description;

  const _PostedJobCard({
    required this.title,
    required this.location,
    required this.salary,
    required this.status,
    required this.statusColor,
    required this.applicants,
    required this.postedDate,
    required this.description,
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
                  title,
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
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              Text(
                salary,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '$applicants ${context.tr('applicants')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                postedDate,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // View applicants
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: ThemeConstants.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    context.tr('view_applicants'),
                    style: const TextStyle(
                      color: ThemeConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Edit job
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    context.tr('edit'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 
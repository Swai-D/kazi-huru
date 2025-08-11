import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';

class CompletedJobsScreen extends StatefulWidget {
  const CompletedJobsScreen({super.key});

  @override
  State<CompletedJobsScreen> createState() => _CompletedJobsScreenState();
}

class _CompletedJobsScreenState extends State<CompletedJobsScreen> {
  // Sample data - in real app this would come from API/database
  final List<Map<String, dynamic>> _completedJobs = [
    {
      'id': '1',
      'title': 'Website Development',
      'company': 'Digital Agency',
      'location': 'Dar es Salaam',
      'earnings': 'TZS 500,000',
      'rating': 4.8,
      'completedDate': '2024-01-20',
      'duration': '2 weeks',
    },
    {
      'id': '2',
      'title': 'Mobile App Testing',
      'company': 'Tech Startup',
      'location': 'Dar es Salaam',
      'earnings': 'TZS 300,000',
      'rating': 4.5,
      'completedDate': '2024-01-18',
      'duration': '1 week',
    },
    {
      'id': '3',
      'title': 'Data Entry Project',
      'company': 'Office Solutions',
      'location': 'Dar es Salaam',
      'earnings': 'TZS 200,000',
      'rating': 4.2,
      'completedDate': '2024-01-15',
      'duration': '3 days',
    },
    {
      'id': '4',
      'title': 'Graphic Design',
      'company': 'Creative Studio',
      'location': 'Dar es Salaam',
      'earnings': 'TZS 400,000',
      'rating': 4.9,
      'completedDate': '2024-01-12',
      'duration': '1 week',
    },
    {
      'id': '5',
      'title': 'Content Writing',
      'company': 'Marketing Agency',
      'location': 'Dar es Salaam',
      'earnings': 'TZS 250,000',
      'rating': 4.6,
      'completedDate': '2024-01-10',
      'duration': '5 days',
    },
  ];
  List<Map<String, dynamic>> _filteredJobs = [];
  String _selectedFilter = 'all'; // 'all', 'recent', 'high_rating', 'high_earnings'

  @override
  void initState() {
    super.initState();
    _filteredJobs = List.from(_completedJobs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Kazi Zilizokamilika - Showcase'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeConstants.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: ThemeConstants.primaryColor),
            onPressed: () {
              // TODO: Share showcase functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing functionality coming soon!')),
              );
            },
          ),
        ],
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Jumla ya Kazi',
                        '${_filteredJobs.length}',
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Mapato Jumla',
                        'TZS ${_calculateTotalEarnings()}',
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Ukadiriaji Mwanya',
                        _calculateAverageRating(),
                        Icons.star,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hizi ni kazi zote ulizokamilisha. Unaweza kuzitumia kama portfolio/showcase yako.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Jobs List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredJobs.length,
              itemBuilder: (context, index) {
                final job = _filteredJobs[index];
                return _buildJobCard(job);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalEarnings() {
    int total = 0;
    for (var job in _filteredJobs) {
      String earnings = job['earnings'].toString().replaceAll('TZS ', '').replaceAll(',', '');
      total += int.parse(earnings);
    }
    return total.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _calculateAverageRating() {
    if (_filteredJobs.isEmpty) return '0.0';
    double total = 0;
    for (var job in _filteredJobs) {
      total += job['rating'];
    }
    return (total / _filteredJobs.length).toStringAsFixed(1);
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
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
          // Header with title and rating
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
              Row(
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    job['rating'].toString(),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
          
          // Earnings and completion date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.green[600], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    job['earnings'],
                    style: TextStyle(
                      color: Colors.green[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                'Completed: ${job['completedDate']}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // Duration
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              Text(
                'Duration: ${job['duration']}',
                style: TextStyle(
                  color: Colors.grey[600],
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
                child: OutlinedButton.icon(
                  onPressed: () {
                    // View job details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tazama maelezo ya ${job['title']}')),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ThemeConstants.primaryColor),
                  ),
                  label: const Text(
                    'Tazama Maelezo',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Share this job
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sharing ${job['title']}...')),
                    );
                  },
                  icon: const Icon(Icons.share, size: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.primaryColor,
                  ),
                  label: const Text(
                    'Shiriki',
                    style: TextStyle(fontSize: 12, color: Colors.white),
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
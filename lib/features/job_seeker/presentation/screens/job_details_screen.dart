import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/wallet_service.dart';
import '../../../../core/services/maps_service.dart';

class JobDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> job;
  
  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isApplying = false;
  final WalletService _walletService = WalletService();
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('job_details')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? ThemeConstants.primaryColor : null,
            ),
            onPressed: () {
              setState(() {
                _isSaved = !_isSaved;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isSaved 
                    ? context.tr('job_saved') 
                    : context.tr('job_removed_from_saved')),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // Share job functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('job_shared'))),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Header
            _buildJobHeader(),
            
            // Job Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Description
                  _buildJobDescription(),
                  const SizedBox(height: 24),
                  
                  // Requirements
                  _buildRequirements(),
                  const SizedBox(height: 24),
                  
                  // Job Provider Info
                  _buildProviderInfo(),
                  const SizedBox(height: 24),
                  
                  // Location & Schedule
                  _buildLocationAndSchedule(),
                  const SizedBox(height: 24),
                  
                  // Payment Details
                  _buildPaymentDetails(),
                  const SizedBox(height: 24),
                  
                  // Similar Jobs
                  _buildSimilarJobs(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildJobHeader() {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Stack(
        children: [
          // Full width background image
          SizedBox(
            width: double.infinity,
            height: 300,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image.asset(
                widget.job['image'] ?? 'assets/images/image_1.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: ThemeConstants.primaryColor.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        Icons.work,
                        color: ThemeConstants.primaryColor,
                        size: 64,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Gradient overlay for better text readability
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Content overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job title
                  Text(
                    widget.job['title'] ?? 'Job Title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Location and job type
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.job['location'] ?? 'Location',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Category and type badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ThemeConstants.primaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.job['category'] ?? 'General',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.job['type'] ?? 'Full-time',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Payment amount
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.job['payment'] ?? 'TZS 0',
                          style: const TextStyle(
                            color: ThemeConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('job_description'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.job['description'] ?? 'No description available',
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('requirements'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          (widget.job['requirements'] as List?)?.length ?? 0,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: ThemeConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.job['requirements'][index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

    Widget _buildProviderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('about_provider'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: ThemeConstants.primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: ThemeConstants.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job['provider_name'] ?? 'John Doe',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.job['provider_location'] ?? 'Dar es Salaam',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Rating stars
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < 4 ? Icons.star : Icons.star_border,
                              size: 16,
                              color: index < 4 ? Colors.amber : Colors.grey[400],
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            '4.2',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    // Navigate to provider profile
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening ${widget.job['provider_name'] ?? 'Provider'}\'s profile...'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationAndSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('location_and_schedule'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildLocationRow(),
                const Divider(),
                _buildInfoRow(
                  Icons.schedule_outlined,
                  context.tr('schedule'),
                  widget.job['schedule'] ?? 'Flexible',
                ),
                const Divider(),
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  context.tr('start_date'),
                  widget.job['start_date'] ?? 'Immediate',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('location'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  widget.job['location'] ?? 'Not specified',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Navigation Button
          Container(
            decoration: BoxDecoration(
              color: ThemeConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.directions_outlined,
                color: ThemeConstants.primaryColor,
              ),
              onPressed: () => _openNavigation(),
              tooltip: context.tr('get_directions'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openNavigation() async {
    // Mock coordinates for demo - in real app, get from job data
    const double jobLat = -6.8235; // Dar es Salaam coordinates
    const double jobLng = 39.2695;
    
    final success = await MapsService.openNavigation(
      jobLat, 
      jobLng, 
      destinationName: widget.job['title'],
    );
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('navigation_failed')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('payment_details'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('payment_amount'),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      widget.job['payment'] ?? 'TZS 0',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('payment_method'),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      widget.job['payment_method'] ?? 'Cash',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarJobs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('similar_jobs'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Similar Job ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'TZS 15,000',
                          style: TextStyle(
                            color: ThemeConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Contact provider functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('contacting_provider'))),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ThemeConstants.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  context.tr('contact_provider'),
                  style: TextStyle(
                    color: ThemeConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isApplying ? null : _applyForJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isApplying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        context.tr('apply_now'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyForJob() async {
    // Check if user has enough balance
    if (!_walletService.hasEnoughBalanceForApplication()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(context.tr('insufficient_balance')),
            content: Text(context.tr('insufficient_balance_message')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.tr('cancel')),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to wallet screen
                  Navigator.pushNamed(context, '/wallet');
                },
                child: Text(context.tr('top_up')),
              ),
            ],
          );
        },
      );
      return;
    }

    // Confirm application fee
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('application_fee')),
          content: Text(context.tr('application_fee_confirmation')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.tr('apply')),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isApplying = true;
    });

    // Deduct application fee
    final success = _walletService.deductApplicationFee(
      widget.job['title'],
      widget.job['id'],
    );

    if (!success) {
      setState(() {
        _isApplying = false;
      });
      return;
    }

    // Simulate application process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isApplying = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(context.tr('application_sent')),
            content: Text(context.tr('application_sent_message')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to job list
                },
                child: Text(context.tr('ok')),
              ),
            ],
          );
        },
      );
    }
  }
} 
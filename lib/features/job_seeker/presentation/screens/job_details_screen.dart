import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/wallet_service.dart';
import '../../../../core/services/maps_service.dart';
import '../../../../core/services/job_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/models/job_model.dart';

class JobDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isApplying = false;
  final WalletService _walletService = WalletService();
  final JobService _jobService = JobService();
  final NotificationService _notificationService = NotificationService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSaved = false;

  List<JobModel> _similarJobs = [];
  Map<String, Map<String, dynamic>> _providerDetails = {};
  bool _isLoadingSimilarJobs = true;

  @override
  void initState() {
    super.initState();
    _loadSimilarJobs();
  }

  Future<void> _loadSimilarJobs() async {
    try {
      setState(() {
        _isLoadingSimilarJobs = true;
      });

      // Get current job category
      final currentJobCategory = widget.job['category'] ?? '';

      // Load all jobs and filter by category on client side
      final jobsSnapshot = await _firestoreService.getJobsSimple().first;
      final jobsData = jobsSnapshot.docs;

      // Convert to JobModel and filter by category
      final similarJobsData =
          jobsData
              .map(
                (doc) => JobModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .where(
                (job) =>
                    job.category == currentJobCategory &&
                    job.id != widget.job['id'],
              )
              .take(5)
              .toList();

      if (mounted) {
        setState(() {
          _similarJobs = similarJobsData;
          _isLoadingSimilarJobs = false;
        });

        // Load provider details for similar jobs
        _loadProviderDetailsInBackground();
      }
    } catch (e) {
      print('Error loading similar jobs: $e');
      if (mounted) {
        setState(() {
          _isLoadingSimilarJobs = false;
        });
      }
    }
  }

  Future<void> _loadProviderDetailsInBackground() async {
    if (_similarJobs.isEmpty) return;

    try {
      final missingProviderIds =
          _similarJobs
              .where(
                (job) =>
                    job.providerId.isNotEmpty &&
                    !_providerDetails.containsKey(job.providerId),
              )
              .map((job) => job.providerId)
              .toSet();

      if (missingProviderIds.isEmpty) return;

      print(
        'Loading provider details for: ${missingProviderIds.length} providers',
      );

      for (final providerId in missingProviderIds) {
        try {
          final providerData = await _firestoreService.getUserProfile(
            providerId,
          );
          if (mounted && providerData != null) {
            setState(() {
              _providerDetails[providerId] = providerData;
            });
          }
        } catch (e) {
          print('Error loading provider $providerId: $e');
        }
      }
    } catch (e) {
      print('Error loading provider details: $e');
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          context.tr('job_details'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: ThemeConstants.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? Colors.amber : Colors.white,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _isSaved = !_isSaved;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isSaved
                        ? context.tr('job_saved')
                        : context.tr('job_removed_from_saved'),
                  ),
                  backgroundColor: _isSaved ? Colors.green : Colors.orange,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('job_shared')),
                  backgroundColor: ThemeConstants.primaryColor,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Header with Hero Image
            _buildJobHeader(),

            // Job Details
            Padding(
              padding: const EdgeInsets.all(20.0),
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
                  const SizedBox(height: 100), // Space for bottom bar
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
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ThemeConstants.primaryColor,
            ThemeConstants.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Image with Overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
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
                        color: Colors.white.withOpacity(0.3),
                        size: 80,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job title
                  Text(
                    widget.job['title'] ?? 'Job Title',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Location
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.job['location'] ?? 'Location',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category and type badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.job['category'] ?? 'General',
                          style: TextStyle(
                            color: ThemeConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.description,
                  color: ThemeConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('job_description'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.job['description'] ?? 'No description available',
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirements() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.checklist,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('requirements'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            (widget.job['requirements'] as List?)?.length ?? 0,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: ThemeConstants.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.job['requirements'][index],
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('about_provider'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: ThemeConstants.primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: ThemeConstants.primaryColor,
                  size: 30,
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
                        fontSize: 18,
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
                        Expanded(
                          child: Text(
                            widget.job['provider_location'] ?? 'Dar es Salaam',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < 4 ? Icons.star : Icons.star_border,
                            size: 16,
                            color: index < 4 ? Colors.amber : Colors.grey[400],
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '4.2',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: ThemeConstants.primaryColor,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAndSchedule() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('location_and_schedule'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLocationRow(),
          const Divider(height: 32),
          _buildInfoRow(
            Icons.schedule_outlined,
            context.tr('schedule'),
            widget.job['schedule'] ?? 'Flexible',
          ),
          const Divider(height: 32),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            context.tr('start_date'),
            widget.job['start_date'] ?? 'Immediate',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ThemeConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.location_on_outlined,
            color: ThemeConstants.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('location'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.job['location'] ?? 'Not specified',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ThemeConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.directions_outlined,
            color: ThemeConstants.primaryColor,
            size: 20,
          ),
        ),
      ],
    );
  }

  Future<void> _openNavigation() async {
    const double jobLat = -6.8235;
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ThemeConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ThemeConstants.primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payment, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('payment_details'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeConstants.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeConstants.primaryColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Price at the top
                Text(
                  widget.job['payment'] ?? 'TZS 0',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Payment method at the bottom
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    widget.job['payment_method'] ?? 'Cash',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarJobs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.work_outline,
                color: Colors.purple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              context.tr('similar_jobs'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child:
              _isLoadingSimilarJobs
                  ? const Center(child: CircularProgressIndicator())
                  : _similarJobs.isEmpty
                  ? Center(
                    child: Text(
                      'No similar jobs found',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _similarJobs.length,
                    itemBuilder: (context, index) {
                      final job = _similarJobs[index];
                      final providerData = _providerDetails[job.providerId];
                      final providerName =
                          providerData?['name'] ??
                          (job.providerId.isNotEmpty
                              ? 'Provider ${job.providerId.substring(0, 8)}...'
                              : 'Unknown Provider');
                      final providerImage = providerData?['profileImageUrl'];

                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with provider info and category
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage:
                                          providerImage != null
                                              ? NetworkImage(providerImage)
                                              : null,
                                      backgroundColor: ThemeConstants
                                          .primaryColor
                                          .withOpacity(0.1),
                                      child:
                                          providerImage == null
                                              ? Icon(
                                                Icons.person,
                                                color:
                                                    ThemeConstants.primaryColor,
                                                size: 20,
                                              )
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            providerName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            job.location,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ThemeConstants.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        job.category,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: ThemeConstants.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Content section
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Job title and payment
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.attach_money,
                                              size: 16,
                                              color:
                                                  ThemeConstants.primaryColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              job.formattedPayment,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    ThemeConstants.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Posted time info
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatTimeAgo(job.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Applicants count info
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Watu ${job.applicationsCount} walio omba',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Action button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/job-details',
                                            arguments: job.toMap(),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.work_outline,
                                          size: 18,
                                        ),
                                        label: Text('Oomba'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              ThemeConstants.primaryColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Go back to previous page or home
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Rudi', style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ThemeConstants.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isApplying ? null : _applyForJob,
                icon:
                    _isApplying
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.work_outline),
                label: Text(
                  _isApplying ? 'Applying...' : context.tr('apply_now'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
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
      ),
    );
  }

  Future<void> _applyForJob() async {
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

    try {
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

      final applicationSuccess = await _jobService.applyForJob(
        jobId: widget.job['id'],
        seekerId: 'user123',
        message: 'I am interested in this job',
      );

      if (mounted) {
        setState(() {
          _isApplying = false;
        });

        if (applicationSuccess) {
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
                      Navigator.of(context).pop();
                    },
                    child: Text(context.tr('ok')),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text(
                  'Failed to apply for job. Please try again.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.tr('ok')),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                'An error occurred while applying for the job. Please try again.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.tr('ok')),
                ),
              ],
            );
          },
        );
      }
    }
  }
}

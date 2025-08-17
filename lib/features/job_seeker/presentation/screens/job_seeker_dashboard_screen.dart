import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/wallet_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/job_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/models/job_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import 'job_details_screen.dart';

class JobSeekerDashboardScreen extends StatefulWidget {
  const JobSeekerDashboardScreen({super.key});

  @override
  State<JobSeekerDashboardScreen> createState() =>
      _JobSeekerDashboardScreenState();
}

class _JobSeekerDashboardScreenState extends State<JobSeekerDashboardScreen> {
  final WalletService _walletService = WalletService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  final JobService _jobService = JobService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLocationEnabled = false;
  String? _currentLocation;
  bool _isVerified = false;
  List<JobModel> _recentJobs = [];
  bool _isLoading = true;
  bool _hasLoadedJobs = false;
  Map<String, Map<String, dynamic>> _providerDetails = {};

  @override
  void initState() {
    super.initState();
    _loadRecentJobs();
    _checkLocationPermission();
    _checkVerificationStatus();
  }

  Future<void> _loadRecentJobs() async {
    if (_hasLoadedJobs && _recentJobs.isNotEmpty) {
      return;
    }

    try {
      setState(() => _isLoading = true);

      final jobsStream = _jobService.getActiveJobs();
      jobsStream
          .timeout(
            const Duration(seconds: 10),
            onTimeout: (sink) {
              sink.addError(TimeoutException('Jobs loading timeout'));
            },
          )
          .listen(
            (jobs) async {
              if (mounted) {
                final recentJobs = jobs.take(5).toList();

                // Load real application counts for each job
                for (final job in recentJobs) {
                  try {
                    final applicationsSnapshot =
                        await _firestoreService
                            .getApplicationsForJob(job.id)
                            .first;
                    // The JobModel already has applicationsCount from Firestore
                    // This is just to ensure we have the latest data
                  } catch (e) {
                    print('Error loading applications for job ${job.id}: $e');
                  }
                }

                setState(() {
                  _recentJobs = recentJobs;
                  _isLoading = false;
                  _hasLoadedJobs = true;
                });
                _loadProviderDetailsInBackground();
              }
            },
            onError: (error) {
              if (mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error loading jobs: $error')),
                );
              }
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading jobs: $e')));
      }
    }
  }

  Future<void> _loadProviderDetailsInBackground() async {
    final providerIds = _recentJobs.map((job) => job.providerId).toSet();

    final futures = providerIds
        .where((providerId) => !_providerDetails.containsKey(providerId))
        .map((providerId) async {
          try {
            final providerData = await _firestoreService.getUserProfile(
              providerId,
            );
            return {'id': providerId, 'data': providerData};
          } catch (e) {
            print('Error loading provider details for $providerId: $e');
            return null;
          }
        });

    final results = await Future.wait(futures);

    if (mounted) {
      setState(() {
        for (final result in results) {
          if (result != null && result['data'] != null) {
            _providerDetails[result['id'] as String] =
                result['data'] as Map<String, dynamic>;
          }
        }
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool isEnabled = await _locationService.isLocationServiceEnabled();
      if (isEnabled) {
        bool hasPermission = await _locationService.requestLocationPermission();
        if (hasPermission) {
          var locationData = await _locationService
              .getCurrentLocationWithAddress()
              .timeout(const Duration(seconds: 5));
          if (locationData != null) {
            setState(() {
              _currentLocation = locationData['address'];
              _isLocationEnabled = true;
            });
          }
        }
      }
    } catch (e) {
      print('Error checking location permission: $e');
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isVerified = false;
    });
  }

  String _formatTimeSinceCreation(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} siku zilizopita';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saa zilizopita';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika zilizopita';
    } else {
      return 'Hivi karibuni';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userName = authProvider.userName ?? 'User';

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: ThemeConstants.primaryColor,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  context.tr('welcome_message'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            actions: [
              // Chat Button
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatListScreen(),
                      ),
                    );
                  },
                  tooltip: context.tr('messages'),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),

              // Notifications Button
              ListenableBuilder(
                listenable: _notificationService,
                builder: (context, child) {
                  final unreadCount = _notificationService.unreadCount;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const NotificationsScreen(),
                              ),
                            );
                          },
                          tooltip: context.tr('notifications'),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[500],
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                unreadCount > 99
                                    ? '99+'
                                    : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ThemeConstants.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: ThemeConstants.primaryColor.withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${context.tr('balance')}: TZS ${_walletService.currentBalance.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ThemeConstants.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: ThemeConstants.primaryColor,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WalletScreen(),
                            ),
                          );
                        },
                        child: Text(
                          context.tr('add_balance'),
                          style: const TextStyle(
                            color: ThemeConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Location Indicator
                if (_isLocationEnabled && _currentLocation != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ThemeConstants.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: ThemeConstants.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${context.tr('near')}: $_currentLocation',
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeConstants.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                Text(
                  'Kazi za Karibu Yako',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Job List
                Expanded(
                  child:
                      _isLoading
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading jobs...',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : _recentJobs.isEmpty
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
                                  'Hakuna kazi za karibu',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Kazi mpya zitaonekana hapa',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: _recentJobs.length,
                            itemBuilder: (context, index) {
                              final job = _recentJobs[index];
                              final providerData =
                                  _providerDetails[job.providerId];
                              final providerName =
                                  providerData?['name'] ?? 'Unknown Provider';
                              final providerImage =
                                  providerData?['profileImageUrl'];

                              return Column(
                                children: [
                                  _JobCard(
                                    title: job.title,
                                    location: job.location,
                                    pay: job.formattedPayment,
                                    distance:
                                        _isLocationEnabled ? '2.5 km' : null,
                                    estimatedTime:
                                        _isLocationEnabled ? '12 min' : null,
                                    image:
                                        job.imageUrl ??
                                        'assets/images/image_1.jpg',
                                    category: job.categoryDisplayName,
                                    providerName: providerName,
                                    providerImage: providerImage,
                                    description: job.description,
                                    postedTime: _formatTimeSinceCreation(
                                      job.createdAt,
                                    ),
                                    applicantsCount: job.applicationsCount,
                                    onPressed: () {
                                      final jobData = {
                                        'id': job.id,
                                        'title': job.title,
                                        'location': job.location,
                                        'payment': job.formattedPayment,
                                        'category': job.categoryDisplayName,
                                        'type': 'Temporary',
                                        'description': job.description,
                                        'requirements':
                                            job.requirements
                                                .split(',')
                                                .map((e) => e.trim())
                                                .toList(),
                                        'provider_name': providerName,
                                        'provider_location': job.location,
                                        'schedule': 'Flexible',
                                        'start_date': job.formattedDate,
                                        'payment_method': 'Cash',
                                        'latitude': 0.0,
                                        'longitude': 0.0,
                                        'image':
                                            job.imageUrl ??
                                            'assets/images/image_1.jpg',
                                      };
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => JobDetailsScreen(
                                                job: jobData,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: ThemeConstants.primaryColor,
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomNavItem(
                      icon: Icons.home,
                      label: context.tr('home'),
                      selected: true,
                      color: Colors.white,
                      onTap: () {},
                    ),
                    _BottomNavItem(
                      icon: Icons.work,
                      label: context.tr('search_jobs'),
                      selected: false,
                      color: Colors.white,
                      onTap: () {
                        Navigator.pushNamed(context, '/job_search');
                      },
                    ),
                    _BottomNavItem(
                      icon: Icons.person,
                      label: context.tr('profile'),
                      selected: false,
                      color: Colors.white,
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String location;
  final String pay;
  final String? distance;
  final String? estimatedTime;
  final String? image;
  final String? category;
  final String providerName;
  final String? providerImage;
  final String? description;
  final String? postedTime;
  final int? applicantsCount;
  final VoidCallback onPressed;

  const _JobCard({
    required this.title,
    required this.location,
    required this.pay,
    this.distance,
    this.estimatedTime,
    this.image,
    this.category,
    required this.providerName,
    this.providerImage,
    this.description,
    this.postedTime,
    this.applicantsCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                          ? NetworkImage(providerImage!)
                          : null,
                  backgroundColor: ThemeConstants.primaryColor.withOpacity(0.1),
                  child:
                      providerImage == null
                          ? Icon(
                            Icons.person,
                            color: ThemeConstants.primaryColor,
                            size: 20,
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        location,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category!,
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

          // Main image
          SizedBox(
            width: double.infinity,
            height: 200,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(
                image ?? 'assets/images/image_1.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: ThemeConstants.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.work,
                      color: ThemeConstants.primaryColor,
                      size: 48,
                    ),
                  );
                },
              ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
                          color: ThemeConstants.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pay,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Location and distance/time
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
                        location,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                    if (distance != null || estimatedTime != null) ...[
                      Row(
                        children: [
                          if (distance != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeConstants.primaryColor.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                distance!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ThemeConstants.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (estimatedTime != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                estimatedTime!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Job description
                if (description != null && description!.isNotEmpty) ...[
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],

                // Posted time info
                if (postedTime != null && postedTime!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        postedTime!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Applicants count info
                if (applicantsCount != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Watu ${applicantsCount.toString()} walio omba',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Kazi imehifadhiwa'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: Icon(Icons.bookmark_border, size: 18),
                        label: Text('Hifadhi'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ThemeConstants.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: onPressed,
                        icon: Icon(Icons.work_outline, size: 18),
                        label: Text('Oomba'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConstants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? Colors.white : Colors.white70, size: 28),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

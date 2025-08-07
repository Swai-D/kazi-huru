import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/verification_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/wallet_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/job_service.dart';
import '../../../../core/models/job_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import '../../../auth/presentation/screens/user_profile_screen.dart';
import 'location_permission_screen.dart';
import 'job_search_screen.dart';
import 'applied_jobs_screen.dart';
import 'completed_jobs_screen.dart';
import 'job_details_screen.dart';

class JobSeekerDashboardScreen extends StatefulWidget {
  const JobSeekerDashboardScreen({super.key});

  @override
  State<JobSeekerDashboardScreen> createState() => _JobSeekerDashboardScreenState();
}

class _JobSeekerDashboardScreenState extends State<JobSeekerDashboardScreen> {
  final WalletService _walletService = WalletService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final LocationService _locationService = LocationService();
  final VerificationService _verificationService = VerificationService();
  final NotificationService _notificationService = NotificationService();
  final JobService _jobService = JobService();
  bool _isLocationEnabled = false;
  String? _currentLocation;
  bool _isVerified = false;
  List<JobModel> _recentJobs = [];
  StreamSubscription<List<JobModel>>? _jobsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _checkVerificationStatus();
    _listenToJobs();
  }

  @override
  void dispose() {
    _jobsSubscription?.cancel();
    super.dispose();
  }

  void _listenToJobs() {
    _jobsSubscription = _jobService.getActiveJobs().listen((jobs) {
      if (mounted) {
        setState(() {
          _recentJobs = jobs.take(5).toList(); // Show latest 5 jobs
        });
        
        // Show notification for new jobs
        if (jobs.isNotEmpty && _recentJobs.length < jobs.length) {
          final newJobs = jobs.where((job) => 
            !_recentJobs.any((existingJob) => existingJob.id == job.id)
          ).toList();
          
          for (final job in newJobs) {
            _notificationService.addNotification(
              _notificationService.createNotification(
                title: 'Kazi Mpya',
                body: '${job.title} - ${job.formattedPayment}',
                type: NotificationType.jobApplication,
                data: {'jobId': job.id, 'jobTitle': job.title},
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _initializeLocation() async {
    try {
      // Check if location services are enabled
      bool isEnabled = await _locationService.isLocationServiceEnabled();
      if (isEnabled) {
        // Request location permission
        bool hasPermission = await _locationService.requestLocationPermission();
        if (hasPermission) {
          // Get current location
          var locationData = await _locationService.getCurrentLocationWithAddress();
          if (locationData != null) {
            setState(() {
              _currentLocation = locationData['address'];
              _isLocationEnabled = true;
            });
          }
        }
      }
    } catch (e) {
      print('Error initializing location: $e');
    }
  }

  Future<void> _checkVerificationStatus() async {
    const userId = 'user_123'; // Mock user ID
    final isVerified = await _verificationService.isUserVerified(userId);
    setState(() {
      _isVerified = isVerified;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userName = authProvider.userName ?? 'User';
        
    return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ThemeConstants.primaryColor.withOpacity(0.1),
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
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              'Karibu tena! 👋',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.chat_bubble_outline,
                color: Colors.grey[700],
                size: 20,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatListScreen()),
                );
              },
              tooltip: 'Messages',
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
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: Colors.grey[700],
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                        );
                      },
                      tooltip: 'Notifications',
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
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
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
                border: Border.all(color: ThemeConstants.primaryColor.withOpacity(0.15)),
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
                      side: const BorderSide(color: ThemeConstants.primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ThemeConstants.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 16, color: ThemeConstants.primaryColor),
                    const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                      'Near: $_currentLocation',
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
                  child: _recentJobs.isEmpty
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
                          return Column(
                            children: [
                  _JobCard(
                                title: job.title,
                                location: job.location,
                                pay: job.formattedPayment,
                                distance: _isLocationEnabled ? '2.5 km' : null,
                                image: job.imageUrl ?? 'assets/images/image_1.jpg',
                                category: job.categoryDisplayName,
                    onPressed: () {
                                  // Convert JobModel to Map for JobDetailsScreen
                                  final jobData = {
                                    'id': job.id,
                                    'title': job.title,
                                    'location': job.location,
                                    'payment': job.formattedPayment,
                                    'category': job.categoryDisplayName,
                                    'type': 'Temporary',
                                    'description': job.description,
                                    'requirements': job.requirements.split(',').map((e) => e.trim()).toList(),
                                    'provider_name': 'Job Provider',
                                    'provider_location': job.location,
                                    'schedule': 'Flexible',
                                    'start_date': job.formattedDate,
                                    'payment_method': 'Cash',
                                    'latitude': 0.0,
                                    'longitude': 0.0,
                                    'image': job.imageUrl ?? 'assets/images/image_1.jpg',
                      };
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                                      builder: (context) => JobDetailsScreen(job: jobData),
                        ),
                      );
                    },
                  ),
                              if (index < _recentJobs.length - 1) const SizedBox(height: 12),
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
          color: ThemeConstants.cardBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BottomNavItem(
                  icon: Icons.home,
                  label: context.tr('home'),
                  selected: true,
                  color: ThemeConstants.primaryColor,
                  onTap: () {},
                ),
                _BottomNavItem(
                  icon: Icons.work,
                  label: context.tr('search_jobs'),
                  selected: false,
                  color: ThemeConstants.textColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/job_search');
                  },
                ),
                _BottomNavItem(
                  icon: Icons.person,
                  label: context.tr('profile'),
                  selected: false,
                  color: ThemeConstants.textColor,
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
  final String? image;
  final String? category;
  final VoidCallback onPressed;

  const _JobCard({
    required this.title,
    required this.location,
    required this.pay,
    this.distance,
    this.image,
    this.category,
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
          // Header with user info and category
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: ThemeConstants.primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.business,
                    color: ThemeConstants.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kazi Huru',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      pay,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Location and distance
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    if (distance != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ThemeConstants.primaryColor.withOpacity(0.1),
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
                    ],
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Action buttons
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: ThemeConstants.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              // Save/bookmark functionality
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bookmark_border, size: 18),
                                const SizedBox(width: 4),
                                Text('Save', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeConstants.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: onPressed,
                            child: Text(
                              context.tr('apply'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
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
          Icon(
            icon,
            color: selected ? color : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: selected ? color : Colors.grey,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/wallet_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/verification_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';

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
  bool _isLocationEnabled = false;
  String? _currentLocation;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _checkVerificationStatus();
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
    final isVerified = _verificationService.isUserVerified(userId);
    setState(() {
      _isVerified = isVerified;
    });
  }

  void _showTestNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Job Application'),
              onTap: () {
                Navigator.pop(context);
                _notificationService.simulateJobApplication('Usafi', 'John Doe');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payment'),
              onTap: () {
                Navigator.pop(context);
                _notificationService.simulatePaymentReceived(25000);
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Verification'),
              onTap: () {
                Navigator.pop(context);
                _notificationService.simulateVerificationUpdate(true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat Message'),
              onTap: () {
                Navigator.pop(context);
                _notificationService.simulateChatMessage('John', 'Habari! Una kazi?');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              backgroundColor: const Color(0xFFF5F7FA), // Light grey/off-white like wallet screen
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222B45),
              ),
            ),
            Text(
              'Karibu tena!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/images/logo.png',
            width: 32,
            height: 32,
          ),
        ),
        actions: [
          // Chat Button
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: ThemeConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.chat_outlined, color: ThemeConstants.primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListScreen()),
              );
            },
              tooltip: 'Messages',
            ),
          ),
          
          // Notifications Button
          ListenableBuilder(
            listenable: _notificationService,
            builder: (context, child) {
              final unreadCount = _notificationService.unreadCount;
              return Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
          IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: ThemeConstants.primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
                      tooltip: 'Notifications',
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
                    Text(
                      'Near: $_currentLocation',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeConstants.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            Text(
              context.tr('available_jobs'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.textColor,
              ),
            ),
            const SizedBox(height: 12),
            // Job List
            Expanded(
              child: ListView(
                children: [
                  _JobCard(
                    title: 'Kumuhamisha Mtu',
                    location: 'Dar es Salaam',
                    pay: 'TZS 20,000',
                    distance: _isLocationEnabled ? '2.5 km' : null,
                    onPressed: () {
                      // Navigate to job details
                      final job = {
                        'id': '1',
                        'title': 'Kumuhamisha Mtu',
                        'location': 'Dar es Salaam',
                        'payment': 'TZS 20,000',
                        'category': 'Transport',
                        'type': 'Part-time',
                        'description': 'Need someone to help move furniture from one house to another.',
                        'requirements': ['Physical strength', 'Reliable transportation', 'Good communication'],
                        'provider_name': 'Moving Services Ltd',
                        'provider_location': 'Dar es Salaam',
                        'schedule': 'Flexible',
                        'start_date': 'Immediate',
                        'payment_method': 'M-Pesa',
                        'latitude': -6.8235,
                        'longitude': 39.2695,
                      };
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobDetailsScreen(job: job),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _JobCard(
                    title: 'Kusafisha Compound',
                    location: 'Dar es Salaam',
                    pay: 'TZS 15,000',
                    distance: _isLocationEnabled ? '1.2 km' : null,
                    onPressed: () {
                      // Navigate to job details
                      final job = {
                        'id': '2',
                        'title': 'Kusafisha Compound',
                        'location': 'Dar es Salaam',
                        'payment': 'TZS 15,000',
                        'category': 'Cleaning',
                        'type': 'One-time',
                        'description': 'Cleaning services needed for a residential compound.',
                        'requirements': ['Cleaning experience', 'Attention to detail', 'Reliable'],
                        'provider_name': 'Clean Pro Services',
                        'provider_location': 'Dar es Salaam',
                        'schedule': 'Morning',
                        'start_date': 'Tomorrow',
                        'payment_method': 'M-Pesa',
                        'latitude': -6.7924,
                        'longitude': 39.2083,
                      };
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobDetailsScreen(job: job),
                        ),
                      );
                    },
                  ),
                ],
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
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String location;
  final String pay;
  final String? distance;
  final VoidCallback onPressed;

  const _JobCard({
    required this.title,
    required this.location,
    required this.pay,
    this.distance,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeConstants.primaryColor.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                    ),
                    if (distance != null) ...[
                      const SizedBox(width: 8),
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
                Text(
                  pay,
                  style: const TextStyle(
                    fontSize: 15,
                    color: ThemeConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: ThemeConstants.primaryColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
            onPressed: onPressed,
            child: Text(
              context.tr('apply'),
              style: const TextStyle(
                color: ThemeConstants.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
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
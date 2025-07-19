import 'package:flutter/material.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/wallet_service.dart';
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

  @override
  Widget build(BuildContext context) {
    // Color palette
    const primaryColor = Color(0xFF2196F3); // Blue
    const accentColor = Color(0xFFFF9800); // Orange
    const backgroundColor = Color(0xFFF5F7FA); // Light
    const cardColor = Colors.white;
    const textColor = Color(0xFF222B45); // Dark blue/gray

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(context.tr('job_seeker_dashboard')),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
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
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primaryColor.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  Text(
                    '${context.tr('balance')}: TZS ${_walletService.currentBalance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryColor, width: 2),
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
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              context.tr('available_jobs'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
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
          color: cardColor,
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
                  color: primaryColor,
                  onTap: () {},
                ),
                _BottomNavItem(
                  icon: Icons.work,
                  label: context.tr('search_jobs'),
                  selected: false,
                  color: textColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/job_search');
                  },
                ),
                _BottomNavItem(
                  icon: Icons.person,
                  label: context.tr('profile'),
                  selected: false,
                  color: textColor,
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
  final VoidCallback onPressed;

  const _JobCard({
    required this.title,
    required this.location,
    required this.pay,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2196F3);
    const textColor = Color(0xFF222B45);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withOpacity(0.12)),
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
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  pay,
                  style: const TextStyle(
                    fontSize: 15,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: primaryColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
            onPressed: onPressed,
            child: Text(
              context.tr('apply'),
              style: const TextStyle(
                color: primaryColor,
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
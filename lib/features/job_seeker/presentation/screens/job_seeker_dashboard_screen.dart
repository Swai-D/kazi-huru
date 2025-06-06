import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class JobSeekerDashboardScreen extends StatelessWidget {
  const JobSeekerDashboardScreen({super.key});

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
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Kazi za Chap',   style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        automaticallyImplyLeading: false,
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
                  const Text(
                    'Salio Lako: TZS 5,000',
                    style: TextStyle(
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
                    onPressed: () {},
                    child: const Text(
                      'Ongeza Salio',
                      style: TextStyle(
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
            const Text(
              'Kazi Zilizopo',
              style: TextStyle(
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
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  _JobCard(
                    title: 'Kusafisha Compound',
                    location: 'Dar es Salaam',
                    pay: 'TZS 15,000',
                    onPressed: () {},
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
                  iconPath: 'assets/icons/home.svg',
                  label: 'Mwanzo',
                  selected: true,
                  color: primaryColor,
                  onTap: () {},
                ),
                _BottomNavItem(
                  iconPath: 'assets/icons/job.svg',
                  label: 'Tuma Kazi',
                  selected: false,
                  color: textColor,
                  onTap: () {},
                ),
                _BottomNavItem(
                  iconPath: 'assets/icons/profile.svg',
                  label: 'Kazi Zangu',
                  selected: false,
                  color: textColor,
                  onTap: () {},
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
            child: const Text(
              'Omba',
              style: TextStyle(
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
  final String iconPath;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.iconPath,
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
          SvgPicture.asset(
            iconPath,
            color: selected ? color : Colors.grey,
            width: 28,
            height: 28,
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
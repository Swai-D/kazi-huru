import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';
import 'company_profile_screen.dart';
import 'post_job_screen.dart';

class JobProviderDashboardScreen extends StatefulWidget {
  const JobProviderDashboardScreen({super.key});

  @override
  State<JobProviderDashboardScreen> createState() => _JobProviderDashboardScreenState();
}

class _JobProviderDashboardScreenState extends State<JobProviderDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        
        // Prevent going back to login/register pages
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          // If no previous pages, go to role selection
          Navigator.pushReplacementNamed(context, '/role_selection');
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
          title: Text(_selectedIndex == 2 ? context.tr('applications') : context.tr('job_provider_dashboard')),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
          leading: _selectedIndex == 2 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedIndex = 0),
              )
            : null,
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
        body: _selectedIndex == 2 ? _AllApplicationsScreen() : _DashboardContent(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BottomNavItem(
                  icon: Icons.dashboard_outlined,
                  label: context.tr('dashboard'),
                  selected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _BottomNavItem(
                  icon: Icons.add_circle_outline,
                  label: context.tr('post_job'),
                  selected: _selectedIndex == 1,
                    onTap: () {
                      setState(() => _selectedIndex = 1);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PostJobScreen()),
                      );
                    },
                ),
                _BottomNavItem(
                  icon: Icons.people_outline,
                  label: context.tr('applications'),
                  selected: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                _BottomNavItem(
                  icon: Icons.person_outline,
                  label: context.tr('profile'),
                  selected: _selectedIndex == 3,
                  onTap: () {
                      setState(() => _selectedIndex = 3);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompanyProfileScreen(),
                      ),
                    );
                  },
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: context.tr('active_jobs'),
                  value: '5',
                  icon: Icons.work_outline,
                  color: ThemeConstants.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: context.tr('total_applications'),
                  value: '23',
                  icon: Icons.people_outline,
                  color: Colors.orange,
            ),
          ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: context.tr('completed_jobs'),
                  value: '12',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
            ),
          ),
        ],
      ),
          const SizedBox(height: 24),
          
          // Post Job Button
                      ElevatedButton.icon(
              onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostJobScreen()),
              );
              },
            icon: const Icon(Icons.add),
            label: Text(context.tr('post_new_job')),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // My Posted Jobs
          Text(
            'Kazi Zangu Zilizopostwa',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // My Posted Job Cards
                _JobCard(
                  title: 'Kusafisha Office',
                  location: 'Dar es Salaam',
                  pay: 'TZS 25,000',
                  status: 'active',
                  applications: 8,
            onTap: () => _showSimpleJobDialog(context, 'Kusafisha Office'),
                ),
                const SizedBox(height: 12),
                _JobCard(
                  title: 'Kusafisha Compound',
                  location: 'Dar es Salaam',
                  pay: 'TZS 15,000',
                  status: 'completed',
                  applications: 5,
            onTap: () => _showSimpleJobDialog(context, 'Kusafisha Compound'),
                ),
                const SizedBox(height: 12),
                _JobCard(
                  title: 'Kumuhamisha Mtu',
                  location: 'Dar es Salaam',
                  pay: 'TZS 20,000',
                  status: 'active',
                  applications: 12,
            onTap: () => _showSimpleJobDialog(context, 'Kumuhamisha Mtu'),
          ),
        ],
      ),
    );
  }

  void _showSimpleJobDialog(BuildContext context, String jobTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(jobTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: Text(context.tr('view_applications')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobApplicationsScreen(jobTitle: jobTitle),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(context.tr('edit_job')),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${context.tr('edit_job')} - $jobTitle')),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('close')),
            ),
          ],
        );
      },
    );
  }
}

class JobApplicationsScreen extends StatelessWidget {
  final String jobTitle;

  const JobApplicationsScreen({
    super.key,
    required this.jobTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waombaji - $jobTitle'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Job Info Card
            Container(
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
                  Text(
                    jobTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Dar es Salaam', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      Icon(Icons.attach_money, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('TZS 25,000', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Filter Chips
            Row(
              children: [
                Expanded(
                  child: _FilterChip(
                    label: context.tr('all'),
                    selected: true,
                    onSelected: (value) {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                    label: context.tr('pending'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                    label: context.tr('accepted'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Applications List for this specific job
            _ApplicationCard(
              name: 'John Doe',
              job: jobTitle,
              status: 'pending',
              rating: 4.5,
              onAccept: () => _showAcceptDialog(context, 'John Doe'),
              onReject: () => _showRejectDialog(context, 'John Doe'),
            ),
            const SizedBox(height: 12),
            _ApplicationCard(
              name: 'Jane Smith',
              job: jobTitle,
              status: 'accepted',
              rating: 4.8,
              onAccept: () => _showAcceptDialog(context, 'Jane Smith'),
              onReject: () => _showRejectDialog(context, 'Jane Smith'),
            ),
            const SizedBox(height: 12),
            _ApplicationCard(
              name: 'Mike Johnson',
              job: jobTitle,
              status: 'pending',
              rating: 4.2,
              onAccept: () => _showAcceptDialog(context, 'Mike Johnson'),
              onReject: () => _showRejectDialog(context, 'Mike Johnson'),
            ),
            const SizedBox(height: 12),
            _ApplicationCard(
              name: 'Sarah Wilson',
              job: jobTitle,
              status: 'pending',
              rating: 4.7,
              onAccept: () => _showAcceptDialog(context, 'Sarah Wilson'),
              onReject: () => _showRejectDialog(context, 'Sarah Wilson'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, String applicantName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('accept_application')),
          content: Text('${context.tr('accept_application_message')} $applicantName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${context.tr('application_accepted')} - $applicantName'),
                    backgroundColor: Colors.green,
                  ),
                  );
                },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(context.tr('accept')),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, String applicantName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('reject_application')),
          content: Text('${context.tr('reject_application_message')} $applicantName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('cancel')),
                ),
            ElevatedButton(
              onPressed: () {
                  Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${context.tr('application_rejected')} - $applicantName'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(context.tr('reject')),
            ),
          ],
        );
      },
    );
  }
}

class JobSeekerProfileScreen extends StatelessWidget {
  final String name;
  final String jobTitle;
  final double rating;
  final String status;

  const JobSeekerProfileScreen({
    super.key,
    required this.name,
    required this.jobTitle,
    required this.rating,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile - $name'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
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
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: ThemeConstants.primaryColor,
                    child: Text(
                      name[0],
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Job Title
                  Text(
                    'Applicant for: $jobTitle',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${rating.toInt()}/5)',
                        style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
                  
                  // Status Badge
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: status == 'accepted' ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Personal Information
            Container(
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
                  Text(
                    'Personal Information',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _ProfileInfoRow(
                    icon: Icons.phone,
                    title: 'Phone',
                    value: '+255 123 456 789',
                  ),
                  const SizedBox(height: 8),
                  _ProfileInfoRow(
                    icon: Icons.email,
                    title: 'Email',
                    value: '${name.toLowerCase().replaceAll(' ', '.')}@email.com',
                  ),
                  const SizedBox(height: 8),
                  _ProfileInfoRow(
                    icon: Icons.location_on,
                    title: 'Location',
                    value: 'Dar es Salaam',
                  ),
                  const SizedBox(height: 8),
                  _ProfileInfoRow(
                    icon: Icons.work,
                    title: 'Experience',
                    value: '3 years',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Skills
            Container(
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
                  Text(
                    'Skills',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SkillChip('Cleaning'),
                      _SkillChip('Organization'),
                      _SkillChip('Time Management'),
                      _SkillChip('Communication'),
                      _SkillChip('Reliability'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAcceptDialog(context, name),
                    icon: const Icon(Icons.check),
                    label: Text(context.tr('accept')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context, name),
                    icon: const Icon(Icons.close),
                    label: Text(context.tr('reject')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, String applicantName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('accept_application')),
          content: Text('${context.tr('accept_application_message')} $applicantName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Close profile screen too
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${context.tr('application_accepted')} - $applicantName'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(context.tr('accept')),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, String applicantName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('reject_application')),
          content: Text('${context.tr('reject_application_message')} $applicantName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Close profile screen too
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${context.tr('application_rejected')} - $applicantName'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(context.tr('reject')),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String skill;

  const _SkillChip(this.skill);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeConstants.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: ThemeConstants.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AllApplicationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Chips
          Row(
            children: [
              Expanded(
                child: _FilterChip(
                  label: context.tr('all'),
                  selected: true,
                  onSelected: (value) {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterChip(
                  label: context.tr('pending'),
                  selected: false,
                  onSelected: (value) {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterChip(
                  label: context.tr('accepted'),
                  selected: false,
                  onSelected: (value) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Applications List
                _ApplicationCard(
                  name: 'John Doe',
                  job: 'Kusafisha Office',
                  status: 'pending',
                  rating: 4.5,
            onAccept: () => _showAcceptDialog(context, 'John Doe'),
            onReject: () => _showRejectDialog(context, 'John Doe'),
                ),
                const SizedBox(height: 12),
                _ApplicationCard(
                  name: 'Jane Smith',
                  job: 'Kusafisha Office',
                  status: 'accepted',
                  rating: 4.8,
            onAccept: () => _showAcceptDialog(context, 'Jane Smith'),
            onReject: () => _showRejectDialog(context, 'Jane Smith'),
                ),
                const SizedBox(height: 12),
                _ApplicationCard(
                  name: 'Mike Johnson',
                  job: 'Kumuhamisha Mtu',
                  status: 'pending',
                  rating: 4.2,
            onAccept: () => _showAcceptDialog(context, 'Mike Johnson'),
            onReject: () => _showRejectDialog(context, 'Mike Johnson'),
          ),
          const SizedBox(height: 12),
          _ApplicationCard(
            name: 'Sarah Wilson',
            job: 'Kusafisha Compound',
            status: 'pending',
            rating: 4.7,
            onAccept: () => _showAcceptDialog(context, 'Sarah Wilson'),
            onReject: () => _showRejectDialog(context, 'Sarah Wilson'),
                ),
              ],
            ),
    );
  }

  void _showAcceptDialog(BuildContext context, String applicantName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('accept_application')),
          content: Text('${context.tr('accept_application_message')} $applicantName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${context.tr('application_accepted')} - $applicantName'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(context.tr('accept')),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, String applicantName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('reject_application')),
          content: Text('${context.tr('reject_application_message')} $applicantName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${context.tr('application_rejected')} - $applicantName'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(context.tr('reject')),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String location;
  final String pay;
  final String status;
  final int applications;
  final VoidCallback? onTap;

  const _JobCard({
    required this.title,
    required this.location,
    required this.pay,
    required this.status,
    required this.applications,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'active' ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            location,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            pay,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ThemeConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '$applications ${context.tr('applications')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final String name;
  final String job;
  final String status;
  final double rating;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ApplicationCard({
    required this.name,
    required this.job,
    required this.status,
    required this.rating,
    required this.onAccept,
    required this.onReject,
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
            children: [
              GestureDetector(
                onTap: () => _showJobSeekerProfile(context),
                child: CircleAvatar(
            backgroundColor: ThemeConstants.primaryColor,
            child: Text(
              name[0],
              style: const TextStyle(color: Colors.white),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    GestureDetector(
                      onTap: () => _showJobSeekerProfile(context),
                      child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: ThemeConstants.primaryColor,
                        ),
                  ),
                ),
                Text(
                  job,
                  style: const TextStyle(color: Colors.grey),
                ),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'accepted' ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
            ],
          ),
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(context.tr('accept')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(context.tr('reject')),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showJobSeekerProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobSeekerProfileScreen(
          name: name,
          jobTitle: job,
          rating: rating,
          status: status,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
      checkmarkColor: ThemeConstants.primaryColor,
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
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
            color: selected ? ThemeConstants.primaryColor : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? ThemeConstants.primaryColor : Colors.grey,
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
} 
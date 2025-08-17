import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/job_service.dart';
import '../../../../core/models/job_model.dart';
import 'dart:async';
import 'posted_jobs_screen.dart';
import 'applications_screen.dart';

class JobProviderProfileScreen extends StatefulWidget {
  const JobProviderProfileScreen({super.key});

  @override
  State<JobProviderProfileScreen> createState() =>
      _JobProviderProfileScreenState();
}

class _JobProviderProfileScreenState extends State<JobProviderProfileScreen> {
  String _selectedLanguage = 'sw';
  final JobService _jobService = JobService();

  // Add edit mode state
  bool _isEditMode = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  List<JobModel> _recentJobs = [];
  List<Map<String, dynamic>> _recentApplications = [];
  Map<String, dynamic> _statistics = {
    'totalJobs': 0,
    'activeJobs': 0,
    'completedJobs': 0,
    'totalApplications': 0,
  };
  bool _isLoadingStats = true;
  bool _isLoadingJobs = true;
  bool _isLoadingApplications = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Add method to initialize controllers with current data
  void _initializeControllers(AuthProvider authProvider) {
    _nameController.text = authProvider.userProfile?['name'] ?? '';
    _phoneController.text = authProvider.userProfile?['phoneNumber'] ?? '';
    _locationController.text = authProvider.userProfile?['location'] ?? '';
  }

  // Add method to save profile changes
  Future<void> _saveProfileChanges() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Validate input fields
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final location = _locationController.text.trim();

      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tafadhali weka jina lako'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tafadhali weka namba ya simu'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (location.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tafadhali weka mahali ulipo'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Update profile data
      final updatedData = {
        'name': name,
        'phoneNumber': phone,
        'location': location,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      final success = await authProvider.updateUserProfileWithMap(updatedData);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (success) {
        // Exit edit mode
        setState(() {
          _isEditMode = false;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wasifu umeboreshwa kikamilifu!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Show error message from AuthProvider
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Hitilafu katika kuhifadhi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hitilafu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Add method to cancel edit mode
  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
    });
  }

  // Add method to get current location
  Future<void> _getCurrentLocation() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Inapata mahali ulipo...'),
                ],
              ),
            ),
      );

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ruhusa ya mahali imekataliwa'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ruhusa ya mahali imekataliwa kabisa. Tafadhali weka mahali manually',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convert coordinates to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';

        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.subLocality!;
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }

        // Update location controller
        _locationController.text = address;
      } else {
        // Fallback to coordinates if no address found
        _locationController.text =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }

      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mahali umepatikana!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hitilafu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add method to show location picker dialog
  void _showLocationPickerDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chagua Mahali'),
            content: const Text(
              'Unaweza kuchagua mahali ulipo au kuandika manually',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _getCurrentLocation();
                },
                child: const Text('Pata Mahali Yangu'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Focus on location text field
                  FocusScope.of(context).requestFocus(FocusNode());
                  Future.delayed(const Duration(milliseconds: 100), () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
                child: const Text('Andika Manually'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ghairi'),
              ),
            ],
          ),
    );
  }

  // Add method to show verification dialog
  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thibitisha Utambulisho'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kuthibitisha utambulisho wako, unahitaji:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  '• Picha ya kitambulisho (NIDA, Passport, au Driver License)',
                ),
                SizedBox(height: 8),
                Text('• Picha ya uso wako'),
                SizedBox(height: 8),
                Text('• Maelezo ya ziada (optional)'),
                SizedBox(height: 16),
                Text(
                  'Utambulisho wako utahifadhiwa kwa usalama na utatumika tu kwa ajili ya uthibitisho.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Funga'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startVerificationProcess();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Anza Uthibitisho'),
              ),
            ],
          ),
    );
  }

  // Add method to start verification process
  void _startVerificationProcess() {
    // Navigate to verification page
    Navigator.pushNamed(context, '/id-verification');
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadStatistics(),
      _loadRecentJobs(),
      _loadRecentApplications(),
    ]);
  }

  Future<void> _loadStatistics() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final providerId = authProvider.currentUser?.uid ?? '';

      final stats = await _jobService.getJobStatistics(providerId);
      if (mounted) {
        setState(() {
          _statistics = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  Future<void> _loadRecentJobs() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final providerId = authProvider.currentUser?.uid ?? '';

      final jobsSnapshot =
          await _jobService.getJobsByProvider(providerId).first;
      if (mounted) {
        setState(() {
          _recentJobs = jobsSnapshot.take(3).toList(); // Get latest 3 jobs
          _isLoadingJobs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingJobs = false;
        });
      }
    }
  }

  Future<void> _loadRecentApplications() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final providerId = authProvider.currentUser?.uid ?? '';

      final applications =
          await _jobService.getProviderApplications(providerId).first;
      if (mounted) {
        setState(() {
          _recentApplications =
              applications.take(3).toList(); // Get latest 3 applications
          _isLoadingApplications = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingApplications = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} siku zilizopita';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saa zilizopita';
    } else {
      return 'Sasa hivi';
    }
  }

  String _formatJoinDate(dynamic date) {
    if (date == null) return 'Hivi karibuni';

    try {
      if (date is Timestamp) {
        final joinDate = date.toDate();
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];

        final day = joinDate.day.toString().padLeft(2, '0');
        final month = months[joinDate.month - 1];
        final year = joinDate.year;

        return '$day $month $year';
      }
      return 'Hivi karibuni';
    } catch (e) {
      return 'Hivi karibuni';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'paused':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Wasifu Wangu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: ThemeConstants.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.refreshUserProfile();
              await _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wasifu umeboreshwa!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            tooltip: 'Boresha Wasifu',
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header with Stats
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
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: ThemeConstants.primaryColor,
                        child: Text(
                          (authProvider.userProfile?['name'] ??
                                  authProvider.currentUser?.displayName ??
                                  'M')[0]
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        authProvider.userProfile?['name'] ??
                            authProvider.currentUser?.displayName ??
                            'Mtoa Kazi',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222B45),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mtoa Kazi',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      // Rating Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: ThemeConstants.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            authProvider.userProfile?['rating'] != null
                                ? '${authProvider.userProfile!['rating']}/5'
                                : 'Hakuna rating',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF222B45),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                            title: 'Kazi Zilizotolewa',
                            value:
                                _isLoadingStats
                                    ? '...'
                                    : '${_statistics['totalJobs']}',
                          ),
                          _StatItem(
                            title: 'Kazi Zilizokamilika',
                            value:
                                _isLoadingStats
                                    ? '...'
                                    : '${_statistics['completedJobs']}',
                          ),
                          _StatItem(
                            title: 'Maombi',
                            value:
                                _isLoadingStats
                                    ? '...'
                                    : '${_statistics['totalApplications']}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Personal Information Section
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Maelezo ya Kibinafsi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF222B45),
                              ),
                            ),
                          ),
                          if (!_isEditMode)
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: ThemeConstants.primaryColor,
                              ),
                              onPressed: () {
                                _initializeControllers(authProvider);
                                setState(() {
                                  _isEditMode = true;
                                });
                              },
                              tooltip: 'Hariri Wasifu',
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.save,
                                    color: Colors.green,
                                  ),
                                  onPressed: _saveProfileChanges,
                                  tooltip: 'Hifadhi',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: _cancelEdit,
                                  tooltip: 'Ghairi',
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!_isEditMode) ...[
                        // Read-only fields
                        _InfoRow(
                          icon: Icons.person,
                          label: 'Jina',
                          value:
                              authProvider.userProfile?['name'] ??
                              authProvider.currentUser?.displayName ??
                              'Haijabainishwa',
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.phone,
                          label: 'Simu',
                          value:
                              authProvider.userProfile?['phoneNumber'] ??
                              'Haijabainishwa',
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.location_on,
                          label: 'Mahali',
                          value:
                              authProvider.userProfile?['location'] ??
                              'Haijabainishwa',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Uthibitisho',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        authProvider.userProfile?['isVerified'] ==
                                                true
                                            ? 'Imethibitishwa'
                                            : 'Haijathibitishwa',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              authProvider.userProfile?['isVerified'] ==
                                                      true
                                                  ? Colors.green
                                                  : Colors.orange,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (authProvider
                                              .userProfile?['isVerified'] !=
                                          true) ...[
                                        const SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed:
                                              () => _showVerificationDialog(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            minimumSize: const Size(0, 32),
                                          ),
                                          child: const Text(
                                            'Thibitisha',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.calendar_today,
                          label: 'Alijiunga',
                          value: _formatJoinDate(
                            authProvider.userProfile?['createdAt'],
                          ),
                        ),
                      ] else ...[
                        // Editable fields
                        _EditableInfoRow(
                          icon: Icons.person,
                          label: 'Jina',
                          controller: _nameController,
                          hintText: 'Weka jina lako',
                        ),
                        const SizedBox(height: 12),
                        _EditableInfoRow(
                          icon: Icons.phone,
                          label: 'Simu',
                          controller: _phoneController,
                          hintText: 'Weka namba ya simu',
                        ),
                        const SizedBox(height: 12),
                        _EditableLocationRow(
                          icon: Icons.location_on,
                          label: 'Mahali',
                          controller: _locationController,
                          hintText: 'Weka mahali ulipo',
                          onLocationTap: _showLocationPickerDialog,
                        ),
                        const SizedBox(height: 12),
                        // Read-only fields in edit mode
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Uthibitisho',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        authProvider.userProfile?['isVerified'] ==
                                                true
                                            ? 'Imethibitishwa'
                                            : 'Haijathibitishwa',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              authProvider.userProfile?['isVerified'] ==
                                                      true
                                                  ? Colors.green
                                                  : Colors.orange,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (authProvider
                                              .userProfile?['isVerified'] !=
                                          true) ...[
                                        const SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed:
                                              () => _showVerificationDialog(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            minimumSize: const Size(0, 32),
                                          ),
                                          child: const Text(
                                            'Thibitisha',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.calendar_today,
                          label: 'Alijiunga',
                          value: _formatJoinDate(
                            authProvider.userProfile?['createdAt'],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Posted Jobs Section
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Kazi Zilizotolewa',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF222B45),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const PostedJobsScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Ona Zote',
                              style: TextStyle(
                                color: ThemeConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingJobs)
                        const Center(child: CircularProgressIndicator())
                      else if (_recentJobs.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.work_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Hakuna kazi zilizotolewa bado',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._recentJobs.map(
                          (job) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _JobCard(
                              title: job.title,
                              company:
                                  authProvider.userProfile?['name'] ??
                                  authProvider.currentUser?.displayName ??
                                  'Mtoa Kazi',
                              location: job.location,
                              salary: job.formattedPayment,
                              status: job.status.toString().split('.').last,
                              statusColor: _getStatusColor(
                                job.status.toString().split('.').last,
                              ),
                              postedDate: _formatDate(job.createdAt),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Applications Received Section
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Maombi Yaliyopokelewa',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF222B45),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const ApplicationsScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Ona Yote',
                              style: TextStyle(
                                color: ThemeConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingApplications)
                        const Center(child: CircularProgressIndicator())
                      else if (_recentApplications.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Hakuna maombi bado',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._recentApplications.map(
                          (application) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ApplicationCard(
                              applicantName:
                                  application['applicantName'] ?? 'Haijulikani',
                              jobTitle:
                                  application['jobTitle'] ?? 'Kazi Haijulikani',
                              appliedDate: _formatDate(
                                DateTime.parse(
                                  application['appliedAt'] ??
                                      DateTime.now().toIso8601String(),
                                ),
                              ),
                              status: application['status'] ?? 'pending',
                              statusColor: _getStatusColor(
                                application['status'] ?? 'pending',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Language Settings Section
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lugha',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222B45),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilterChip(
                              label: const Text('Kiswahili'),
                              selected: _selectedLanguage == 'sw',
                              onSelected: (selected) {
                                setState(() {
                                  _selectedLanguage = 'sw';
                                });
                                // Change language
                              },
                              selectedColor: ThemeConstants.primaryColor
                                  .withOpacity(0.2),
                              checkmarkColor: ThemeConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilterChip(
                              label: const Text('English'),
                              selected: _selectedLanguage == 'en',
                              onSelected: (selected) {
                                setState(() {
                                  _selectedLanguage = 'en';
                                });
                                // Change language
                              },
                              selectedColor: ThemeConstants.primaryColor
                                  .withOpacity(0.2),
                              checkmarkColor: ThemeConstants.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      await authProvider.signOut();
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Toka'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
          );
        },
      ),
    );
  }

  String _formatPriceRange(dynamic price) {
    if (price == null || price.toString().isEmpty) return 'TZS 10,000 - 50,000';

    try {
      final priceStr = price.toString();
      if (priceStr.contains('-')) {
        final parts = priceStr.split('-');
        if (parts.length == 2) {
          final min = int.tryParse(
            parts[0].trim().replaceAll(RegExp(r'[^\d]'), ''),
          );
          final max = int.tryParse(
            parts[1].trim().replaceAll(RegExp(r'[^\d]'), ''),
          );
          if (min != null && max != null) {
            return 'TZS ${_formatNumber(min)} - ${_formatNumber(max)}';
          }
        }
        return 'TZS $priceStr';
      } else {
        final numPrice = int.tryParse(
          priceStr.replaceAll(RegExp(r'[^\d]'), ''),
        );
        if (numPrice != null) {
          return 'TZS ${_formatNumber(numPrice)}';
        }
        return 'TZS $priceStr';
      }
    } catch (e) {
      return 'TZS 10,000 - 50,000';
    }
  }

  String _formatNumber(dynamic number) {
    final num = number is int ? number.toDouble() : (number ?? 0.0);
    return num.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A90E2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
        ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String salary;
  final String status;
  final Color statusColor;
  final String postedDate;

  const _JobCard({
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.status,
    required this.statusColor,
    required this.postedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222B45),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  salary,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                postedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final String applicantName;
  final String jobTitle;
  final String appliedDate;
  final String status;
  final Color statusColor;

  const _ApplicationCard({
    required this.applicantName,
    required this.jobTitle,
    required this.appliedDate,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: ThemeConstants.primaryColor,
                child: Text(
                  applicantName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicantName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222B45),
                      ),
                    ),
                    Text(
                      jobTitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                appliedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditableInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String hintText;

  const _EditableInfoRow({
    required this.icon,
    required this.label,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditableLocationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onLocationTap;

  const _EditableLocationRow({
    required this.icon,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: ThemeConstants.primaryColor,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: onLocationTap,
                      tooltip: 'Chagua Mahali',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

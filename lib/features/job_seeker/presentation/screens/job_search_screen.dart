import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/maps_service.dart';
import '../../../../core/services/job_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/models/job_model.dart';
import 'job_details_screen.dart';
import 'location_permission_screen.dart';

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  final JobService _jobService = JobService();
  final FirestoreService _firestoreService = FirestoreService();

  String _selectedCategory = 'all';
  String _selectedLocation = 'all';
  String _selectedSortBy = 'recent';
  bool _isLoading = false;
  bool _isLocationEnabled = false;
  String? _currentLocation;

  List<JobModel> _jobs = [];
  List<JobModel> _filteredJobs = [];
  Map<String, Map<String, dynamic>> _providerDetails = {};
  bool _hasLoadedJobs = false;

  // Real job data will be loaded from Firestore

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _initializeLocation();
  }

  @override
  void dispose() {
    // Cancel any ongoing operations if needed
    super.dispose();
  }

  Future<void> _loadJobs() async {
    if (_hasLoadedJobs && _jobs.isNotEmpty) {
      return;
    }

    try {
      if (mounted) setState(() => _isLoading = true);

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
                final recentJobs = jobs.toList();

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

                if (mounted) {
                  setState(() {
                    _jobs = recentJobs;
                    _filteredJobs = recentJobs;
                    _isLoading = false;
                    _hasLoadedJobs = true;
                  });
                  // Load provider details immediately after jobs are loaded
                  await _loadProviderDetailsInBackground();
                }
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
    if (_jobs.isEmpty) return;

    final providerIds = _jobs.map((job) => job.providerId).toSet();
    print('All provider IDs found: $providerIds');

    final missingProviderIds =
        providerIds
            .where(
              (providerId) =>
                  !_providerDetails.containsKey(providerId) &&
                  providerId.isNotEmpty,
            )
            .toList();

    if (missingProviderIds.isEmpty) {
      print('No missing provider IDs to load');
      return;
    }

    print(
      'Loading provider details for ${missingProviderIds.length} providers: $missingProviderIds',
    );

    final futures = missingProviderIds.map((providerId) async {
      try {
        print('Attempting to load provider data for: $providerId');
        final providerData = await _firestoreService.getUserProfile(providerId);
        print(
          'Successfully loaded provider data for $providerId: ${providerData?['name'] ?? 'No name'}',
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
            print('Added provider ${result['id']} to _providerDetails');
          } else {
            print('Failed to add provider data for result: $result');
          }
        }
      });
      print(
        'Updated provider details. Total providers loaded: ${_providerDetails.length}',
      );
      print('Current _providerDetails keys: ${_providerDetails.keys.toList()}');
    }
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

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if location services are enabled
      bool isEnabled = await _locationService.isLocationServiceEnabled();
      if (isEnabled) {
        // Request location permission
        bool hasPermission = await _locationService.requestLocationPermission();
        if (hasPermission) {
          // Get current location
          var locationData =
              await _locationService.getCurrentLocationWithAddress();
          if (locationData != null) {
            setState(() {
              _currentLocation = locationData['address'];
              _isLocationEnabled = true;
            });
            // Calculate distances after getting location
            await _calculateDistances();
          } else {
            print('Could not get location data');
            // For demo purposes, use fallback location
            setState(() {
              _currentLocation = 'Dar es Salaam, Tanzania';
              _isLocationEnabled = true;
            });
            await _calculateDistances();
          }
        } else {
          // Show location permission screen
          _showLocationPermissionScreen();
        }
      } else {
        // Show location services disabled dialog
        _showLocationServiceDialog();
      }
    } catch (e) {
      print('Error initializing location: $e');
      // For demo purposes, use fallback location
      setState(() {
        _currentLocation = 'Dar es Salaam, Tanzania';
        _isLocationEnabled = true;
      });
      await _calculateDistances();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLocationPermissionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => LocationPermissionScreen(
              onPermissionGranted: () async {
                await _initializeLocation();
              },
            ),
      ),
    );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('location_services_disabled')),
            content: Text(context.tr('enable_location_services_message')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.tr('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _initializeLocation();
                },
                child: Text(context.tr('enable')),
              ),
            ],
          ),
    );
  }

  void _showLocationErrorDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('error')),
            content: Text(context.tr('location_error_message')),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.tr('ok')),
              ),
            ],
          ),
    );
  }

  // TODO: Implement distance calculation for JobModel
  Future<void> _calculateDistances() async {
    // This will be implemented when we add location coordinates to JobModel
    print('Distance calculation not yet implemented for JobModel');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('search_jobs'),
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
            icon: const Icon(Icons.location_on, color: Colors.white),
            onPressed: () {
              if (_isLocationEnabled) {
                _initializeLocation();
              } else {
                _showLocationPermissionScreen();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Filter Chips
          _buildFilterChips(),

          // Job List
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredJobs.isEmpty
                    ? _buildEmptyState()
                    : _buildJobList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: context.tr('search_jobs_placeholder'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _performSearch();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (value) {
              _performSearch();
            },
          ),
          if (_isLocationEnabled && _currentLocation != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: ThemeConstants.primaryColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Near: $_currentLocation',
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeConstants.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await _initializeLocation();
                  },
                  child: Text(
                    'Refresh',
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeConstants.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('all', context.tr('all')),
          _buildFilterChip('transport', 'Transport'),
          _buildFilterChip('cleaning', 'Cleaning'),
          _buildFilterChip('events', 'Events'),
          _buildFilterChip('construction', 'Construction'),
          _buildFilterChip('delivery', 'Delivery'),
          if (_isLocationEnabled) _buildFilterChip('nearby', 'Nearby'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? value : 'all';
            _applyFilters();
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
        checkmarkColor: ThemeConstants.primaryColor,
      ),
    );
  }

  Widget _buildJobList() {
    return RefreshIndicator(
      onRefresh: () async {
        // Clear provider details and reload them
        setState(() {
          _providerDetails.clear();
        });
        await _loadProviderDetailsInBackground();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredJobs.length,
        itemBuilder: (context, index) {
          final job = _filteredJobs[index];
          print('Job ${job.id} has providerId: ${job.providerId}');
          print(
            'Available provider details keys: ${_providerDetails.keys.toList()}',
          );
          final providerData = _providerDetails[job.providerId];
          print('Provider data for ${job.providerId}: $providerData');
          final providerName =
              providerData?['name'] ??
              (job.providerId.isNotEmpty
                  ? 'Provider ${job.providerId.substring(0, 8)}...'
                  : 'Unknown Provider');
          final providerImage = providerData?['profileImageUrl'];
          print('Provider name for job ${job.id}: $providerName');
          print('Provider image for job ${job.id}: $providerImage');

          return Column(
            children: [
              _JobCard(
                title: job.title,
                location: job.location,
                pay: job.formattedPayment,
                distance: _isLocationEnabled ? '2.5 km' : null,
                estimatedTime: _isLocationEnabled ? '12 min' : null,
                image: job.imageUrl ?? 'assets/images/image_1.jpg',
                category: job.categoryDisplayName,
                providerName: providerName,
                providerImage: providerImage,
                description: job.description,
                postedTime: _formatTimeSinceCreation(job.createdAt),
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
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            context.tr('no_jobs_found'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('try_different_search'),
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredJobs =
          _jobs.where((job) {
            final title = job.title.toLowerCase();
            final location = job.location.toLowerCase();
            final category = job.categoryDisplayName.toLowerCase();

            return title.contains(query) ||
                location.contains(query) ||
                category.contains(query);
          }).toList();

      _applyFilters();
    });
  }

  void _applyFilters() {
    var filtered = _jobs;

    // Apply search filter
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered =
          filtered.where((job) {
            final title = job.title.toLowerCase();
            final location = job.location.toLowerCase();
            final category = job.categoryDisplayName.toLowerCase();

            return title.contains(query) ||
                location.contains(query) ||
                category.contains(query);
          }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'all') {
      if (_selectedCategory == 'nearby' && _isLocationEnabled) {
        // Filter jobs within 10km - for now, show all jobs since we don't have distance calculation
        // TODO: Implement distance calculation for JobModel
        filtered = filtered.take(10).toList(); // Show first 10 jobs as nearby
      } else {
        filtered =
            filtered.where((job) {
              return job.categoryDisplayName.toLowerCase() == _selectedCategory;
            }).toList();
      }
    }

    // Apply location filter
    if (_selectedLocation != 'all') {
      filtered =
          filtered.where((job) {
            return job.location.toLowerCase().contains(_selectedLocation);
          }).toList();
    }

    // Apply sorting
    switch (_selectedSortBy) {
      case 'recent':
        // Keep original order (most recent first)
        break;
      case 'payment_high':
        filtered.sort((a, b) {
          return b.maxPayment.compareTo(a.maxPayment);
        });
        break;
      case 'payment_low':
        filtered.sort((a, b) {
          return a.minPayment.compareTo(b.minPayment);
        });
        break;
    }

    setState(() {
      _filteredJobs = filtered;
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => _FilterBottomSheet(
            selectedLocation: _selectedLocation,
            selectedSortBy: _selectedSortBy,
            onLocationChanged: (location) {
              setState(() {
                _selectedLocation = location;
                _applyFilters();
              });
            },
            onSortByChanged: (sortBy) {
              setState(() {
                _selectedSortBy = sortBy;
                _applyFilters();
              });
            },
          ),
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
              child: InkWell(
                onTap: onPressed,
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
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job title and payment - Fixed layout
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

                const SizedBox(height: 8),

                // Description
                if (description != null && description!.isNotEmpty) ...[
                  Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 12),

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

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Save job functionality
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
                        label: Text('Omba'),
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

class _FilterBottomSheet extends StatelessWidget {
  final String selectedLocation;
  final String selectedSortBy;
  final Function(String) onLocationChanged;
  final Function(String) onSortByChanged;

  const _FilterBottomSheet({
    required this.selectedLocation,
    required this.selectedSortBy,
    required this.onLocationChanged,
    required this.onSortByChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('filters'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Location Filter
          Text(
            context.tr('location'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChipWithCallback(
                'all',
                context.tr('all_locations'),
                selectedLocation,
                onLocationChanged,
              ),
              _buildFilterChipWithCallback(
                'dar_es_salaam',
                'Dar es Salaam',
                selectedLocation,
                onLocationChanged,
              ),
              _buildFilterChipWithCallback(
                'arusha',
                'Arusha',
                selectedLocation,
                onLocationChanged,
              ),
              _buildFilterChipWithCallback(
                'mwanza',
                'Mwanza',
                selectedLocation,
                onLocationChanged,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sort By
          Text(
            context.tr('sort_by'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChipWithCallback(
                'recent',
                context.tr('most_recent'),
                selectedSortBy,
                onSortByChanged,
              ),
              _buildFilterChipWithCallback(
                'payment_high',
                context.tr('highest_payment'),
                selectedSortBy,
                onSortByChanged,
              ),
              _buildFilterChipWithCallback(
                'payment_low',
                context.tr('lowest_payment'),
                selectedSortBy,
                onSortByChanged,
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterChipWithCallback(
    String value,
    String label,
    String selected,
    Function(String) onChanged,
  ) {
    final isSelected = selected == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onChanged(value);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
      checkmarkColor: ThemeConstants.primaryColor,
    );
  }
}

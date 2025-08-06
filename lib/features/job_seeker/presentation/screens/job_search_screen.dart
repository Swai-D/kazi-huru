import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/maps_service.dart';
import 'job_details_screen.dart';
import 'location_permission_screen.dart';

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedLocation = 'all';
  String _selectedSortBy = 'recent';
  bool _isLoading = false;
  bool _isLocationEnabled = false;
  String? _currentLocation;
  final LocationService _locationService = LocationService();

  // Mock job data with location coordinates
  final List<Map<String, dynamic>> _jobs = [
    {
      'id': '1',
      'title': 'Kumuhamisha Mtu',
      'location': 'Dar es Salaam, Sala Sala',
                      'payment': 'TZS 15,000 - TZS 20,000',
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
      'distance': null,
      'image': 'assets/images/image_1.jpg',
    },
    {
      'id': '2',
      'title': 'Kusafisha Compound',
      'location': 'Dar es Salaam, Mbezi Beach',
                      'payment': 'TZS 12,000 - TZS 15,000',
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
      'distance': null,
      'image': 'assets/images/image_2.jpg',
    },
    {
      'id': '3',
      'title': 'Kusaidia Kwenye Event',
      'location': 'Dar es Salaam, Masaki',
                      'payment': 'TZS 20,000 - TZS 25,000',
      'category': 'Events',
      'type': 'Part-time',
      'description': 'Event assistance needed for a wedding ceremony.',
      'requirements': ['Event experience', 'Good communication', 'Team player'],
      'provider_name': 'Event Masters',
      'provider_location': 'Dar es Salaam',
      'schedule': 'Weekend',
      'start_date': 'Next Saturday',
      'payment_method': 'M-Pesa',
      'latitude': -6.8235,
      'longitude': 39.2695,
      'distance': null,
      'image': 'assets/images/image_3.jpg',
    },
    {
      'id': '4',
      'title': 'Kusaidia Kwenye Construction',
      'location': 'Dar es Salaam, Oyster Bay',
                      'payment': 'TZS 25,000 - TZS 30,000',
      'category': 'Construction',
      'type': 'Full-time',
      'description': 'Construction assistance needed for building project.',
      'requirements': ['Construction experience', 'Safety awareness', 'Physical fitness'],
      'provider_name': 'Build Pro Ltd',
      'provider_location': 'Dar es Salaam',
      'schedule': 'Daily',
      'start_date': 'Next Monday',
      'payment_method': 'M-Pesa',
      'latitude': -6.8235,
      'longitude': 39.2695,
      'distance': null,
      'image': 'assets/images/image_1.jpg',
    },
    {
      'id': '5',
      'title': 'Kusambaza Vitu',
      'location': 'Dar es Salaam, City Centre',
                      'payment': 'TZS 15,000 - TZS 18,000',
      'category': 'Delivery',
      'type': 'Part-time',
      'description': 'Delivery services needed for packages and documents.',
      'requirements': ['Motorcycle license', 'Good navigation', 'Reliable'],
      'provider_name': 'Quick Delivery',
      'provider_location': 'Dar es Salaam',
      'schedule': 'Flexible',
      'start_date': 'Immediate',
      'payment_method': 'M-Pesa',
      'latitude': -6.8235,
      'longitude': 39.2695,
      'distance': null,
      'image': 'assets/images/image_2.jpg',
    },
  ];

  List<Map<String, dynamic>> _filteredJobs = [];

  @override
  void initState() {
    super.initState();
    _filteredJobs = _jobs;
    _initializeLocation();
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
          var locationData = await _locationService.getCurrentLocationWithAddress();
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
        builder: (context) => LocationPermissionScreen(
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
      builder: (context) => AlertDialog(
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
      builder: (context) => AlertDialog(
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

  Future<void> _calculateDistances() async {
    if (!_isLocationEnabled) return;

    // Get current location for distance calculation
    final currentPosition = await MapsService.getCurrentLocation();
    if (currentPosition == null) return;

    for (int i = 0; i < _jobs.length; i++) {
      try {
        double distance = MapsService.calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          _jobs[i]['latitude'],
          _jobs[i]['longitude'],
        );
        
        String formattedDistance = MapsService.formatDistance(distance);
        String estimatedTime = MapsService.getEstimatedTravelTime(distance);
        
        setState(() {
          _jobs[i]['distance'] = formattedDistance;
          _jobs[i]['estimated_time'] = estimatedTime;
        });
      } catch (e) {
        print('Error calculating distance for job ${_jobs[i]['id']}: $e');
      }
    }
  }

  void _sortJobsByDistance() {
    _filteredJobs.sort((a, b) {
      String? distanceA = a['distance'];
      String? distanceB = b['distance'];
      
      if (distanceA == null && distanceB == null) return 0;
      if (distanceA == null) return 1;
      if (distanceB == null) return -1;
      
      // Extract numeric value from distance string (e.g., "2.5 km" -> 2.5)
      double? valueA = _extractDistanceValue(distanceA);
      double? valueB = _extractDistanceValue(distanceB);
      
      if (valueA == null && valueB == null) return 0;
      if (valueA == null) return 1;
      if (valueB == null) return -1;
      
      return valueA.compareTo(valueB);
    });
  }

  double? _extractDistanceValue(String distance) {
    try {
      if (distance.contains('km')) {
        return double.parse(distance.replaceAll(' km', ''));
      } else if (distance.contains('m')) {
        return double.parse(distance.replaceAll(' m', '')) / 1000;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('search_jobs')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              if (_isLocationEnabled) {
                _initializeLocation();
              } else {
                _showLocationPermissionScreen();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
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
            child: _isLoading
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
                Icon(Icons.location_on, size: 16, color: ThemeConstants.primaryColor),
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredJobs.length,
      itemBuilder: (context, index) {
        final job = _filteredJobs[index];
        return _JobCard(
          job: job,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailsScreen(job: job),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredJobs = _jobs.where((job) {
        final title = job['title'].toString().toLowerCase();
        final location = job['location'].toString().toLowerCase();
        final category = job['category'].toString().toLowerCase();
        
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
      filtered = filtered.where((job) {
        final title = job['title'].toString().toLowerCase();
        final location = job['location'].toString().toLowerCase();
        final category = job['category'].toString().toLowerCase();
        
        return title.contains(query) ||
               location.contains(query) ||
               category.contains(query);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'all') {
      if (_selectedCategory == 'nearby' && _isLocationEnabled) {
        // Filter jobs within 10km
        filtered = filtered.where((job) {
          String? distance = job['distance'];
          if (distance == null) return false;
          
          double? distanceValue = _extractDistanceValue(distance);
          return distanceValue != null && distanceValue <= 10.0;
        }).toList();
        // Sort by distance
        _sortJobsByDistance();
      } else {
      filtered = filtered.where((job) {
        return job['category'].toString().toLowerCase() == _selectedCategory;
      }).toList();
      }
    }

    // Apply location filter
    if (_selectedLocation != 'all') {
      filtered = filtered.where((job) {
        return job['location'].toString().toLowerCase() == _selectedLocation;
      }).toList();
    }

    // Apply sorting
    switch (_selectedSortBy) {
      case 'recent':
        // Keep original order (most recent first)
        break;
      case 'payment_high':
        filtered.sort((a, b) {
          // Extract max payment from range (e.g., "15,000 - 20,000" -> 20000)
          final aPayment = int.tryParse(a['payment'].toString().split('-').last.trim().replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
          final bPayment = int.tryParse(b['payment'].toString().split('-').last.trim().replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
          return bPayment.compareTo(aPayment);
        });
        break;
      case 'payment_low':
        filtered.sort((a, b) {
          // Extract min payment from range (e.g., "15,000 - 20,000" -> 15000)
          final aPayment = int.tryParse(a['payment'].toString().split('-').first.trim().replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
          final bPayment = int.tryParse(b['payment'].toString().split('-').first.trim().replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
          return aPayment.compareTo(bPayment);
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
      builder: (context) => _FilterBottomSheet(
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

class _JobCard extends StatefulWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.onTap,
  });

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  Future<void> _openNavigation() async {
    if (widget.job['latitude'] == null || widget.job['longitude'] == null) {
      return;
    }

    final success = await MapsService.openNavigation(
      widget.job['latitude'] as double,
      widget.job['longitude'] as double,
      destinationName: widget.job['title'],
    );

    if (!success) {
      // Show error message using the correct context
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('navigation_failed')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
                        widget.job['location'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.job['category'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.job['category'],
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
              child: InkWell(
                onTap: widget.onTap,
                child: Image.asset(
                  widget.job['image'] ?? 'assets/images/image_1.jpg',
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
                // Job title and payment
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.job['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      widget.job['payment'],
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
                        widget.job['location'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    if (widget.job['distance'] != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ThemeConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.job['distance'],
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeConstants.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (widget.job['estimated_time'] != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.job['estimated_time'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Description
                Text(
                  widget.job['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
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
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: ThemeConstants.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _openNavigation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.directions_outlined, size: 18),
                                const SizedBox(width: 4),
                                Text('Directions', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConstants.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: widget.onTap,
                        child: Text(
                          context.tr('apply'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('all', context.tr('all_locations'), selectedLocation, onLocationChanged),
              _buildFilterChip('dar_es_salaam', 'Dar es Salaam', selectedLocation, onLocationChanged),
              _buildFilterChip('arusha', 'Arusha', selectedLocation, onLocationChanged),
              _buildFilterChip('mwanza', 'Mwanza', selectedLocation, onLocationChanged),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Sort By
          Text(
            context.tr('sort_by'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('recent', context.tr('most_recent'), selectedSortBy, onSortByChanged),
              _buildFilterChip('payment_high', context.tr('highest_payment'), selectedSortBy, onSortByChanged),
              _buildFilterChip('payment_low', context.tr('lowest_payment'), selectedSortBy, onSortByChanged),
            ],
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, String selected, Function(String) onChanged) {
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
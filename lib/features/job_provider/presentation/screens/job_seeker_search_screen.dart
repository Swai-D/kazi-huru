import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/maps_service.dart';
import '../../../job_seeker/presentation/screens/location_permission_screen.dart';

class JobSeekerSearchScreen extends StatefulWidget {
  const JobSeekerSearchScreen({super.key});

  @override
  State<JobSeekerSearchScreen> createState() => _JobSeekerSearchScreenState();
}

class _JobSeekerSearchScreenState extends State<JobSeekerSearchScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  // final ScrollController _scrollController = ScrollController(); // Unused for now
  QueryDocumentSnapshot<Map<String, dynamic>>? _lastDoc;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final Set<String> _availableCategories = {'all'};
  final Set<String> _favoriteIds = {};
  String _selectedCategory = 'all';
  String _selectedLocation = 'all';
  String _selectedExperience = 'all';
  String _selectedSortBy = 'recent';
  bool _isLoading = false;
  bool _isLocationEnabled = false;
  String? _currentLocation;
  final LocationService _locationService = LocationService();

  // Data from Firestore
  final List<Map<String, dynamic>> _jobSeekers = [];

  List<Map<String, dynamic>> _filteredJobSeekers = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      await _fetchJobSeekersFromFirestore(initial: true);
      if (mounted) {
        _filteredJobSeekers = List.from(_jobSeekers);
        _performSearch();
      }
      await _initializeLocation();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchJobSeekersFromFirestore({bool initial = false}) async {
    try {
      Query<Map<String, dynamic>> q = FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'job_seeker')
          .orderBy('createdAt', descending: true)
          .limit(30);
      if (!initial && _lastDoc != null) {
        q = q.startAfterDocument(_lastDoc!);
      }
      final query = await q.get();

      final List<Map<String, dynamic>> loaded = [];
      for (final doc in query.docs) {
        final data = doc.data();
        loaded.add({
          'id': doc.id, // for sorting fallback
          'uid': doc.id, // guaranteed uid for navigation
          'name': data['name'] ?? '—',
          'location': data['location'] ?? '—',
          'category': data['category'] ?? 'all',
          'experience': data['experience']?.toString() ?? '—',
          'rating': (data['rating'] ?? 0).toDouble(),
          'completed_jobs': data['completed_jobs'] ?? 0,
          'description': data['description'] ?? data['bio'] ?? '',
          'skills': List<String>.from(
            (data['skills'] ?? const <String>[]) as List,
          ),
          'availability': data['availability'] ?? '',
          'hourly_rate': data['hourly_rate'] ?? '',
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'distance': null,
          'image': data['profileImageUrl'],
          'verified': data['verified'] ?? data['isVerified'] ?? false,
          'createdAt': data['createdAt'],
        });
        if (data['category'] != null &&
            data['category'].toString().isNotEmpty) {
          _availableCategories.add(data['category']);
        }
      }
      if (mounted) {
        setState(() {
          if (initial) {
            _jobSeekers
              ..clear()
              ..addAll(loaded);
          } else {
            _jobSeekers.addAll(loaded);
          }
          if (query.docs.isNotEmpty) {
            _lastDoc = query.docs.last;
          }
          if (query.docs.length < 30) {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching job seekers: $e');
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    if (mounted) setState(() => _isLoadingMore = true);
    try {
      await _fetchJobSeekersFromFirestore(initial: false);
      if (mounted) _performSearch();
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final favoritesQuery =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('favorites')
              .get();

      setState(() {
        _favoriteIds.clear();
        _favoriteIds.addAll(favoritesQuery.docs.map((doc) => doc.id));
      });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _toggleFavorite(String jobSeekerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(jobSeekerId);

      if (_favoriteIds.contains(jobSeekerId)) {
        await docRef.delete();
        setState(() => _favoriteIds.remove(jobSeekerId));
      } else {
        await docRef.set({'addedAt': FieldValue.serverTimestamp()});
        setState(() => _favoriteIds.add(jobSeekerId));
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  String _formatPriceRange(dynamic price) {
    if (price == null || price.toString().isEmpty) return '—';

    try {
      final priceStr = price.toString();
      if (priceStr.contains('-')) {
        // Already a range
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
        // Single price
        final numPrice = int.tryParse(
          priceStr.replaceAll(RegExp(r'[^\d]'), ''),
        );
        if (numPrice != null) {
          return 'TZS ${_formatNumber(numPrice)}';
        }
        return 'TZS $priceStr';
      }
    } catch (e) {
      return 'TZS $price';
    }
  }

  String _formatNumber(dynamic number) {
    final num = number is int ? number.toDouble() : (number ?? 0.0);
    return num.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hasPermission = await _locationService.requestLocationPermission();
      if (hasPermission) {
        final location = await _locationService.getCurrentPosition();
        if (location != null) {
          setState(() {
            _isLocationEnabled = true;
            _currentLocation =
                '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
          });
          await _calculateDistances();
        }
      } else {
        _showLocationPermissionScreen();
      }
    } catch (e) {
      print('Error initializing location: $e');
      _showLocationErrorDialog();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLocationPermissionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPermissionScreen()),
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

  Future<void> _calculateDistances() async {
    if (!_isLocationEnabled) return;

    final currentPosition = await MapsService.getCurrentLocation();
    if (currentPosition == null) return;

    for (int i = 0; i < _jobSeekers.length; i++) {
      try {
        // Check if job seeker has valid coordinates
        final latitude = _jobSeekers[i]['latitude'];
        final longitude = _jobSeekers[i]['longitude'];

        if (latitude == null || longitude == null) {
          // Set default values for job seekers without coordinates
          if (mounted) {
            setState(() {
              _jobSeekers[i]['distance'] = '—';
              _jobSeekers[i]['estimated_time'] = '—';
            });
          }
          continue;
        }

        double distance = MapsService.calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          latitude.toDouble(),
          longitude.toDouble(),
        );

        String formattedDistance = MapsService.formatDistance(distance);
        String estimatedTime = MapsService.getEstimatedTravelTime(distance);

        if (mounted) {
          setState(() {
            _jobSeekers[i]['distance'] = formattedDistance;
            _jobSeekers[i]['estimated_time'] = estimatedTime;
          });
        }
      } catch (e) {
        print(
          'Error calculating distance for job seeker ${_jobSeekers[i]['id']}: $e',
        );
        // Set default values on error
        if (mounted) {
          setState(() {
            _jobSeekers[i]['distance'] = '—';
            _jobSeekers[i]['estimated_time'] = '—';
          });
        }
      }
    }
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _filteredJobSeekers =
              _jobSeekers.where((jobSeeker) {
                final name = (jobSeeker['name'] ?? '').toString().toLowerCase();
                final desc =
                    (jobSeeker['description'] ?? '').toString().toLowerCase();
                final skills = (jobSeeker['skills'] as List)
                    .map((e) => e.toString().toLowerCase())
                    .join(' ');
                final matchesSearch =
                    name.contains(query) ||
                    desc.contains(query) ||
                    skills.contains(query);
                final matchesCategory =
                    _selectedCategory == 'all' ||
                    (jobSeeker['category'] ?? '').toString().toLowerCase() ==
                        _selectedCategory.toLowerCase();
                final matchesLocation =
                    _selectedLocation == 'all' ||
                    (jobSeeker['location'] ?? '')
                        .toString()
                        .toLowerCase()
                        .contains(_selectedLocation.toLowerCase());
                final matchesExperience =
                    _selectedExperience == 'all' ||
                    (jobSeeker['experience'] ?? '').toString() ==
                        _selectedExperience;
                return matchesSearch &&
                    matchesCategory &&
                    matchesLocation &&
                    matchesExperience;
              }).toList();
        });
        _sortJobSeekers();
      }
    });
  }

  void _sortJobSeekers() {
    switch (_selectedSortBy) {
      case 'recent':
        _filteredJobSeekers.sort((a, b) => b['id'].compareTo(a['id']));
        break;
      case 'rating':
        _filteredJobSeekers.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
      case 'experience':
        _filteredJobSeekers.sort(
          (a, b) => b['completed_jobs'].compareTo(a['completed_jobs']),
        );
        break;
      case 'distance':
        if (_isLocationEnabled) {
          _sortJobSeekersByDistance();
        }
        break;
    }
  }

  void _sortJobSeekersByDistance() {
    _filteredJobSeekers.sort((a, b) {
      String? distanceA = a['distance'];
      String? distanceB = b['distance'];

      // Handle null or invalid distance values
      if (distanceA == null || distanceA == '—' || distanceA.isEmpty) {
        distanceA = null;
      }
      if (distanceB == null || distanceB == '—' || distanceB.isEmpty) {
        distanceB = null;
      }

      if (distanceA == null && distanceB == null) return 0;
      if (distanceA == null) return 1;
      if (distanceB == null) return -1;

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
      if (distance.isEmpty || distance == '—') {
        return null;
      }

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

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => _FilterBottomSheet(
            selectedCategory: _selectedCategory,
            selectedLocation: _selectedLocation,
            selectedExperience: _selectedExperience,
            selectedSortBy: _selectedSortBy,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
                _performSearch();
              });
            },
            onLocationChanged: (location) {
              setState(() {
                _selectedLocation = location;
                _performSearch();
              });
            },
            onExperienceChanged: (experience) {
              setState(() {
                _selectedExperience = experience;
                _performSearch();
              });
            },
            onSortByChanged: (sortBy) {
              setState(() {
                _selectedSortBy = sortBy;
                _performSearch();
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tafuta Watumishi',
          style: TextStyle(
            fontSize: 18,
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

          // Job Seeker List
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredJobSeekers.isEmpty
                    ? _buildEmptyState()
                    : _buildJobSeekerList(),
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
              hintText: 'Tafuta watumishi...',
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
                    'Karibu: $_currentLocation',
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
                    'Onyesha upya',
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
          _buildFilterChip('Zote', _selectedCategory == 'all', () {
            setState(() {
              _selectedCategory = 'all';
            });
            _performSearch();
          }),
          _buildFilterChip('Usafiri', _selectedCategory == 'Transport', () {
            setState(() {
              _selectedCategory = 'Transport';
            });
            _performSearch();
          }),
          _buildFilterChip('Kusafisha', _selectedCategory == 'Cleaning', () {
            setState(() {
              _selectedCategory = 'Cleaning';
            });
            _performSearch();
          }),
          _buildFilterChip('Matukio', _selectedCategory == 'Events', () {
            setState(() {
              _selectedCategory = 'Events';
            });
            _performSearch();
          }),
          _buildFilterChip('Ujenzi', _selectedCategory == 'Construction', () {
            setState(() {
              _selectedCategory = 'Construction';
            });
            _performSearch();
          }),
          _buildFilterChip('Kupika', _selectedCategory == 'Cooking', () {
            setState(() {
              _selectedCategory = 'Cooking';
            });
            _performSearch();
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => onTap(),
        backgroundColor: Colors.grey[200],
        selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? ThemeConstants.primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildJobSeekerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredJobSeekers.length,
      itemBuilder: (context, index) {
        final jobSeeker = _filteredJobSeekers[index];
        return _buildJobSeekerCard(jobSeeker);
      },
    );
  }

  Widget _buildJobSeekerCard(Map<String, dynamic> jobSeeker) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/job_seeker_profile',
            arguments: jobSeeker,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        jobSeeker['image'] != null
                            ? AssetImage(jobSeeker['image'])
                            : null,
                    backgroundColor: ThemeConstants.primaryColor.withOpacity(
                      0.1,
                    ),
                    child:
                        jobSeeker['image'] == null
                            ? Icon(
                              Icons.person,
                              color: ThemeConstants.primaryColor,
                              size: 30,
                            )
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                jobSeeker['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (jobSeeker['verified']) ...[
                              Icon(
                                Icons.verified,
                                color: ThemeConstants.primaryColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                jobSeeker['location'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${jobSeeker['rating']} (${jobSeeker['completed_jobs']} kazi)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                jobSeeker['description'],
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    jobSeeker['skills'].map<Widget>((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            fontSize: 10,
                            color: ThemeConstants.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 12),
              // Showcase preview
              if (jobSeeker['completed_jobs'] > 0) ...[
                GestureDetector(
                  onTap: () {
                    // Navigate to the job seeker profile to see full showcase
                    Navigator.pushNamed(
                      context,
                      '/job_seeker_profile',
                      arguments: {
                        'jobSeekerId': jobSeeker['uid'],
                        'jobSeeker': jobSeeker,
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.work_history,
                          size: 16,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${jobSeeker['completed_jobs']} kazi zilizokamilika - Tazama showcase',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.green[700],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uzoefu: ${jobSeeker['experience']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPriceRange(jobSeeker['hourly_rate']),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (jobSeeker['distance'] != null) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          jobSeeker['distance'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          jobSeeker['availability'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Hakuna watumishi walioonekana',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jaribu kubadilisha vigezo vya utafutaji',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatelessWidget {
  final String selectedCategory;
  final String selectedLocation;
  final String selectedExperience;
  final String selectedSortBy;
  final Function(String) onCategoryChanged;
  final Function(String) onLocationChanged;
  final Function(String) onExperienceChanged;
  final Function(String) onSortByChanged;

  const _FilterBottomSheet({
    required this.selectedCategory,
    required this.selectedLocation,
    required this.selectedExperience,
    required this.selectedSortBy,
    required this.onCategoryChanged,
    required this.onLocationChanged,
    required this.onExperienceChanged,
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
              const Text(
                'Filtisha',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Category Filter
          const Text(
            'Kategoria',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                'all',
                'Zote',
                selectedCategory,
                onCategoryChanged,
              ),
              _buildFilterChip(
                'Transport',
                'Usafiri',
                selectedCategory,
                onCategoryChanged,
              ),
              _buildFilterChip(
                'Cleaning',
                'Kusafisha',
                selectedCategory,
                onCategoryChanged,
              ),
              _buildFilterChip(
                'Events',
                'Matukio',
                selectedCategory,
                onCategoryChanged,
              ),
              _buildFilterChip(
                'Construction',
                'Ujenzi',
                selectedCategory,
                onCategoryChanged,
              ),
              _buildFilterChip(
                'Cooking',
                'Kupika',
                selectedCategory,
                onCategoryChanged,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Location Filter
          const Text(
            'Mahali',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                'all',
                'Kote',
                selectedLocation,
                onLocationChanged,
              ),
              _buildFilterChip(
                'Dar es Salaam',
                'Dar es Salaam',
                selectedLocation,
                onLocationChanged,
              ),
              _buildFilterChip(
                'Arusha',
                'Arusha',
                selectedLocation,
                onLocationChanged,
              ),
              _buildFilterChip(
                'Mwanza',
                'Mwanza',
                selectedLocation,
                onLocationChanged,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Experience Filter
          const Text(
            'Uzoefu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                'all',
                'Yote',
                selectedExperience,
                onExperienceChanged,
              ),
              _buildFilterChip(
                '1 year',
                'Mwaka 1',
                selectedExperience,
                onExperienceChanged,
              ),
              _buildFilterChip(
                '2 years',
                'Miaka 2',
                selectedExperience,
                onExperienceChanged,
              ),
              _buildFilterChip(
                '3 years',
                'Miaka 3',
                selectedExperience,
                onExperienceChanged,
              ),
              _buildFilterChip(
                '4 years',
                'Miaka 4',
                selectedExperience,
                onExperienceChanged,
              ),
              _buildFilterChip(
                '5 years',
                'Miaka 5+',
                selectedExperience,
                onExperienceChanged,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sort By
          const Text(
            'Panga kwa',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                'recent',
                'Hivi karibuni',
                selectedSortBy,
                onSortByChanged,
              ),
              _buildFilterChip(
                'rating',
                'Ukadiriaji',
                selectedSortBy,
                onSortByChanged,
              ),
              _buildFilterChip(
                'experience',
                'Uzoefu',
                selectedSortBy,
                onSortByChanged,
              ),
              _buildFilterChip(
                'distance',
                'Umbali',
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

  Widget _buildFilterChip(
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

  String _formatPriceRange(dynamic price) {
    if (price == null || price.toString().isEmpty) return '—';

    try {
      final priceStr = price.toString();
      if (priceStr.contains('-')) {
        // Already a range
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
        // Single price
        final numPrice = int.tryParse(
          priceStr.replaceAll(RegExp(r'[^\d]'), ''),
        );
        if (numPrice != null) {
          return 'TZS ${_formatNumber(numPrice)}';
        }
        return 'TZS $priceStr';
      }
    } catch (e) {
      return 'TZS $price';
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

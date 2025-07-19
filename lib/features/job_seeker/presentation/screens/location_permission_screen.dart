import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/location_service.dart';

class LocationPermissionScreen extends StatefulWidget {
  final VoidCallback? onPermissionGranted;

  const LocationPermissionScreen({
    super.key,
    this.onPermissionGranted,
  });

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  final LocationService _locationService = LocationService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('location_permission')),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Location Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: ThemeConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.location_on,
                size: 60,
                color: ThemeConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            
            // Title
            Text(
              context.tr('enable_location'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              context.tr('location_permission_description'),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Benefits List
            _buildBenefitItem(
              icon: Icons.search,
              title: context.tr('find_nearby_jobs'),
              description: context.tr('find_nearby_jobs_desc'),
            ),
            const SizedBox(height: 16),
            _buildBenefitItem(
              icon: Icons.directions,
              title: context.tr('get_directions'),
              description: context.tr('get_directions_desc'),
            ),
            const SizedBox(height: 16),
            _buildBenefitItem(
              icon: Icons.schedule,
              title: context.tr('save_time'),
              description: context.tr('save_time_desc'),
            ),
            const SizedBox(height: 40),
            
            // Enable Location Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _requestLocationPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        context.tr('enable_location'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Skip Button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                context.tr('skip_for_now'),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ThemeConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: ThemeConstants.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if location services are enabled
      bool isEnabled = await _locationService.isLocationServiceEnabled();
      if (!isEnabled) {
        _showLocationServiceDialog();
        return;
      }

      // Request location permission
      bool hasPermission = await _locationService.requestLocationPermission();
      if (hasPermission) {
        // Get current location
        var locationData = await _locationService.getCurrentLocationWithAddress();
        if (locationData != null) {
          if (widget.onPermissionGranted != null) {
            widget.onPermissionGranted!();
          }
          Navigator.pop(context);
        } else {
          _showErrorDialog();
        }
      } else {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      print('Error requesting location permission: $e');
      _showErrorDialog();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              _locationService.isLocationServiceEnabled();
            },
            child: Text(context.tr('enable')),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('permission_denied')),
        content: Text(context.tr('location_permission_denied_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _requestLocationPermission();
            },
            child: Text(context.tr('try_again')),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
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
} 
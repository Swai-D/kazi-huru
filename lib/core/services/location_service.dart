import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  String? _currentAddress;

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        print('Location services are disabled');
        return null;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permission denied forever');
        return null;
      }

      // Try to get current position with a shorter timeout first
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        );
        return _currentPosition;
      } catch (e) {
        print('First attempt failed, trying with lower accuracy: $e');
        
        // If first attempt fails, try with lower accuracy and longer timeout
        try {
          _currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 15),
          );
          return _currentPosition;
        } catch (e2) {
          print('Second attempt also failed: $e2');
          
          // Last resort: try to get last known position
          try {
            _currentPosition = await Geolocator.getLastKnownPosition();
            if (_currentPosition != null) {
              print('Using last known position');
              return _currentPosition;
            }
          } catch (e3) {
            print('Could not get last known position: $e3');
          }
          
          return null;
        }
      }
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Get current address
  Future<String?> getCurrentAddress() async {
    try {
      if (_currentPosition == null) {
        await getCurrentPosition();
      }

      if (_currentPosition != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          _currentAddress = '${place.street}, ${place.locality}, ${place.administrativeArea}';
          return _currentAddress;
        }
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  // Calculate distance between two points
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      double km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  // Get distance from current location to a job
  Future<String?> getDistanceToJob(double jobLat, double jobLon) async {
    try {
      if (_currentPosition == null) {
        await getCurrentPosition();
      }

      if (_currentPosition != null) {
        double distance = calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          jobLat,
          jobLon,
        );
        return formatDistance(distance);
      }
      return null;
    } catch (e) {
      print('Error calculating distance: $e');
      return null;
    }
  }

  // Request location permissions
  Future<bool> requestLocationPermission() async {
    try {
      PermissionStatus status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Get current position with address
  Future<Map<String, dynamic>?> getCurrentLocationWithAddress() async {
    try {
      Position? position = await getCurrentPosition();
      if (position != null) {
        String? address = await getCurrentAddress();
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'address': address ?? 'Unknown location',
        };
      }
      return null;
    } catch (e) {
      print('Error getting location with address: $e');
      return null;
    }
  }

  // Get cached current position
  Position? get cachedCurrentPosition => _currentPosition;

  // Get cached current address
  String? get cachedCurrentAddress => _currentAddress;
} 
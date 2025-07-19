import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsService {
  static const String _googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // Add your API key here

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  // Get address from coordinates
  static Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get coordinates from address
  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations[0].latitude, locations[0].longitude);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Calculate distance between two points
  static double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // Open Google Maps navigation
  static Future<bool> openNavigation(double destinationLat, double destinationLng, {String? destinationName}) async {
    final Uri url;
    
    if (destinationName != null) {
      url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&destination_place_id=$destinationName'
      );
    } else {
      url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng'
      );
    }

    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Open Google Maps with job location
  static Future<bool> openJobLocation(double lat, double lng, String jobTitle) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$jobTitle'
    );

    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Format distance for display
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      double km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  // Get estimated travel time (mock for now)
  static String getEstimatedTravelTime(double distanceInMeters) {
    // Rough estimate: 5 minutes per km
    double timeInMinutes = (distanceInMeters / 1000) * 5;
    if (timeInMinutes < 1) {
      return '${timeInMinutes.toStringAsFixed(0)} min';
    } else if (timeInMinutes < 60) {
      return '${timeInMinutes.toStringAsFixed(0)} min';
    } else {
      double hours = timeInMinutes / 60;
      return '${hours.toStringAsFixed(1)} hr';
    }
  }
} 
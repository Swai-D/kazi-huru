class LocationModel {
  final double latitude;
  final double longitude;
  final String address;
  final String? city;
  final String? region;
  final String? country;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.city,
    this.region,
    this.country,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      address: map['address'] ?? '',
      city: map['city'],
      region: map['region'],
      country: map['country'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'region': region,
      'country': country,
    };
  }

  @override
  String toString() {
    return 'LocationModel(latitude: $latitude, longitude: $longitude, address: $address)';
  }
}

class JobLocationModel {
  final String jobId;
  final LocationModel location;
  final String? distance;
  final bool isNearby;

  JobLocationModel({
    required this.jobId,
    required this.location,
    this.distance,
    this.isNearby = false,
  });

  factory JobLocationModel.fromMap(Map<String, dynamic> map) {
    return JobLocationModel(
      jobId: map['jobId'] ?? '',
      location: LocationModel.fromMap(map['location'] ?? {}),
      distance: map['distance'],
      isNearby: map['isNearby'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'location': location.toMap(),
      'distance': distance,
      'isNearby': isNearby,
    };
  }
} 
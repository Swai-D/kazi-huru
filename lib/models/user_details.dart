import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  final String uid;
  final String? email;
  final String? name;
  final String? username;
  final String? photoURL;
  final String? phoneNumber;
  final bool isPhoneVerified;
  final bool isProfileComplete;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserDetails({
    required this.uid,
    this.email,
    this.name,
    this.username,
    this.photoURL,
    this.phoneNumber,
    this.isPhoneVerified = false,
    this.isProfileComplete = false,
    this.role = 'job_seeker',
    this.createdAt,
    this.updatedAt,
  });

  factory UserDetails.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserDetails(
      uid: doc.id,
      email: data['email'] as String?,
      name: data['name'] as String?,
      username: data['username'] as String?,
      photoURL: data['photoURL'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      isPhoneVerified: data['isPhoneVerified'] as bool? ?? false,
      isProfileComplete: data['isProfileComplete'] as bool? ?? false,
      role: data['role'] as String? ?? 'job_seeker',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'username': username,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'isPhoneVerified': isPhoneVerified,
      'isProfileComplete': isProfileComplete,
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  UserDetails copyWith({
    String? uid,
    String? email,
    String? name,
    String? username,
    String? photoURL,
    String? phoneNumber,
    bool? isPhoneVerified,
    bool? isProfileComplete,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserDetails(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 
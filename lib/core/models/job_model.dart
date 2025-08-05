import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum JobStatus {
  active,
  paused,
  completed,
  cancelled,
}

enum PaymentType {
  per_job,
  per_hour,
  per_day,
}

enum ContactPreference {
  in_app,
  phone,
}

class JobModel {
  final String id;
  final String providerId;
  final String title;
  final String description;
  final String category; // usafi, kufua, kubeba, etc.
  final String location;
  final double minPayment;
  final double maxPayment;
  final PaymentType paymentType;
  final String duration; // 1_hour, 2_hours, 1_day, etc.
  final int workersNeeded;
  final String requirements;
  final ContactPreference contactPreference;
  final DateTime startDate;
  final TimeOfDay startTime;
  final DateTime deadline;
  final String? imageUrl;
  final JobStatus status;
  final int applicationsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobModel({
    required this.id,
    required this.providerId,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.minPayment,
    required this.maxPayment,
    required this.paymentType,
    required this.duration,
    required this.workersNeeded,
    required this.requirements,
    required this.contactPreference,
    required this.startDate,
    required this.startTime,
    required this.deadline,
    this.imageUrl,
    this.status = JobStatus.active,
    this.applicationsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobModel.fromMap(Map<String, dynamic> map, String documentId) {
    return JobModel(
      id: documentId,
      providerId: map['providerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      minPayment: (map['minPayment'] ?? map['payment'] ?? 0).toDouble(),
      maxPayment: (map['maxPayment'] ?? map['payment'] ?? 0).toDouble(),
      paymentType: PaymentType.values.firstWhere(
        (e) => e.toString() == 'PaymentType.${map['paymentType']}',
        orElse: () => PaymentType.per_job,
      ),
      duration: map['duration'] ?? '',
      workersNeeded: map['workersNeeded'] ?? 1,
      requirements: map['requirements'] ?? '',
      contactPreference: ContactPreference.values.firstWhere(
        (e) => e.toString() == 'ContactPreference.${map['contactPreference']}',
        orElse: () => ContactPreference.in_app,
      ),
      startDate: (map['startDate'] as Timestamp).toDate(),
      startTime: TimeOfDay(
        hour: map['startTimeHour'] ?? 0,
        minute: map['startTimeMinute'] ?? 0,
      ),
      deadline: (map['deadline'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'],
      status: JobStatus.values.firstWhere(
        (e) => e.toString() == 'JobStatus.${map['status']}',
        orElse: () => JobStatus.active,
      ),
      applicationsCount: map['applicationsCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'minPayment': minPayment,
      'maxPayment': maxPayment,
      'paymentType': paymentType.toString().split('.').last,
      'duration': duration,
      'workersNeeded': workersNeeded,
      'requirements': requirements,
      'contactPreference': contactPreference.toString().split('.').last,
      'startDate': Timestamp.fromDate(startDate),
      'startTimeHour': startTime.hour,
      'startTimeMinute': startTime.minute,
      'deadline': Timestamp.fromDate(deadline),
      'imageUrl': imageUrl,
      'status': status.toString().split('.').last,
      'applicationsCount': applicationsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  JobModel copyWith({
    String? id,
    String? providerId,
    String? title,
    String? description,
    String? category,
    String? location,
    double? minPayment,
    double? maxPayment,
    PaymentType? paymentType,
    String? duration,
    int? workersNeeded,
    String? requirements,
    ContactPreference? contactPreference,
    DateTime? startDate,
    TimeOfDay? startTime,
    DateTime? deadline,
    String? imageUrl,
    JobStatus? status,
    int? applicationsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      minPayment: minPayment ?? this.minPayment,
      maxPayment: maxPayment ?? this.maxPayment,
      paymentType: paymentType ?? this.paymentType,
      duration: duration ?? this.duration,
      workersNeeded: workersNeeded ?? this.workersNeeded,
      requirements: requirements ?? this.requirements,
      contactPreference: contactPreference ?? this.contactPreference,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      deadline: deadline ?? this.deadline,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      applicationsCount: applicationsCount ?? this.applicationsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case 'usafi':
        return 'Usafi';
      case 'kufua':
        return 'Kufua Nguo';
      case 'kubeba':
        return 'Kubeba Mizigo';
      case 'kusafisha_gari':
        return 'Kusafisha Gari';
      case 'kupika':
        return 'Kupika';
      case 'kutunza_watoto':
        return 'Kutunza Watoto';
      case 'kujenga':
        return 'Kujenga';
      case 'kilimo':
        return 'Kilimo';
      case 'nyingine':
        return 'Nyingine';
      default:
        return 'Nyingine';
    }
  }

  String get paymentTypeDisplayName {
    switch (paymentType) {
      case PaymentType.per_job:
        return 'Malipo ya Kazi Moja';
      case PaymentType.per_hour:
        return 'Malipo kwa Saa';
      case PaymentType.per_day:
        return 'Malipo kwa Siku';
    }
  }

  String get durationDisplayName {
    switch (duration) {
      case '1_hour':
        return 'Saa 1';
      case '2_hours':
        return 'Saa 2';
      case '4_hours':
        return 'Saa 4';
      case '1_day':
        return 'Siku 1';
      case '2_days':
        return 'Siku 2';
      case '1_week':
        return 'Wiki 1';
      default:
        return duration;
    }
  }

  String get formattedPayment {
    if (minPayment == maxPayment) {
      return 'TZS ${minPayment.toStringAsFixed(0)}';
    }
    return 'TZS ${minPayment.toStringAsFixed(0)} - ${maxPayment.toStringAsFixed(0)}';
  }

  String get formattedDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  String get formattedTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  bool get isActive => status == JobStatus.active;
  bool get isCompleted => status == JobStatus.completed;
  bool get isCancelled => status == JobStatus.cancelled;
} 
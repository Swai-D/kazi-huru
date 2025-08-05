import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/job_model.dart';
import 'firestore_service.dart';
import 'firebase_storage_service.dart';

class JobService {
  static final JobService _instance = JobService._internal();
  factory JobService() => _instance;
  JobService._internal();

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new job posting
  Future<String> createJob({
    required String title,
    required String description,
    required String category,
    required String location,
    required double minPayment,
    required double maxPayment,
    required PaymentType paymentType,
    required String duration,
    required int workersNeeded,
    required String requirements,
    required ContactPreference contactPreference,
    required DateTime startDate,
    required TimeOfDay startTime,
    required DateTime deadline,
    String? imageUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final jobData = {
        'jobProviderId': user.uid,
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'salary': minPayment, // Single salary value
        'salaryType': paymentType.toString().split('.').last,
        'duration': duration,
        'workersNeeded': workersNeeded,
        'requirements': requirements.split(',').map((e) => e.trim()).toList(), // Array of requirements
        'contactPreference': contactPreference.toString().split('.').last,
        'startDate': Timestamp.fromDate(startDate),
        'startTimeHour': startTime.hour,
        'startTimeMinute': startTime.minute,
        'deadline': Timestamp.fromDate(deadline),
        'imageUrl': imageUrl,
        'status': 'active',
        'applicationsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final jobId = await _firestoreService.createJob(
        jobProviderId: user.uid,
        title: title,
        description: description,
        location: location,
        salary: minPayment,
        salaryType: paymentType.toString().split('.').last,
        requirements: requirements.split(',').map((e) => e.trim()).toList(),
        jobType: 'temporary', // For Kazi Huru jobs
        additionalData: {
          'category': category,
          'duration': duration,
          'workersNeeded': workersNeeded,
          'contactPreference': contactPreference.toString().split('.').last,
          'startDate': Timestamp.fromDate(startDate),
          'startTimeHour': startTime.hour,
          'startTimeMinute': startTime.minute,
          'deadline': Timestamp.fromDate(deadline),
          'imageUrl': imageUrl,
        },
      );
      
      // Track analytics
      await _trackJobPosting(jobId, category, minPayment, location);
      
      return jobId;
    } catch (e) {
      throw Exception('Failed to create job: $e');
    }
  }

  // Get all active jobs
  Stream<List<JobModel>> getActiveJobs({
    String? category,
    String? location,
    double? minPayment,
    double? maxPayment,
  }) {
    // Use a simple query without ordering to avoid composite index requirement
    return _firestoreService
        .getJobsSimple(status: 'active')
        .map((snapshot) {
          final jobs = snapshot.docs
              .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .where((job) {
                // Filter by category if specified
                if (category != null && job.category != category) return false;
                // Filter by location if specified
                if (location != null && !job.location.toLowerCase().contains(location.toLowerCase())) return false;
                // Filter by payment range if specified
                if (minPayment != null && job.minPayment < minPayment) return false;
                if (maxPayment != null && job.maxPayment > maxPayment) return false;
                return true;
              })
              .toList();
          
          // Sort by createdAt in descending order (newest first) on client side
          jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return jobs;
        });
  }

  // Get jobs by provider
  Stream<List<JobModel>> getJobsByProvider(String providerId) {
    return _firestoreService
        .getJobsByProvider(providerId)
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get a single job by ID
  Future<JobModel?> getJob(String jobId) async {
    try {
      final jobData = await _firestoreService.getJob(jobId);
      if (jobData != null) {
        return JobModel.fromMap(jobData, jobId);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get job: $e');
    }
  }

  // Update job status
  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    try {
      await _firestoreService.updateJob(
        jobId: jobId,
        updateData: {
          'status': status.toString().split('.').last,
        },
      );
    } catch (e) {
      throw Exception('Failed to update job status: $e');
    }
  }

  // Delete job (placeholder - implement when needed)
  Future<void> deleteJob(String jobId) async {
    try {
      // TODO: Implement delete job functionality
      print('Delete job: $jobId');
    } catch (e) {
      throw Exception('Failed to delete job: $e');
    }
  }

  // Upload job image (placeholder - implement when needed)
  Future<String?> uploadJobImage(String jobId, List<int> imageBytes) async {
    try {
      // TODO: Implement image upload functionality
      print('Upload job image: $jobId');
      return null;
    } catch (e) {
      throw Exception('Failed to upload job image: $e');
    }
  }

  // Search jobs with filters
  Stream<List<JobModel>> searchJobs({
    String? query,
    String? category,
    String? location,
    double? minPayment,
    double? maxPayment,
    String? duration,
  }) {
    return _firestoreService
        .getJobs(
          location: location,
          jobType: 'temporary',
          minSalary: minPayment,
          maxSalary: maxPayment,
          status: 'active',
        )
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .where((job) {
              if (category != null && job.category != category) return false;
              if (duration != null && job.duration != duration) return false;
              return true;
            })
            .toList());
  }

  // Get job categories
  List<Map<String, String>> getJobCategories() {
    return [
      {'value': 'usafi', 'label': 'Usafi', 'icon': '🧹'},
      {'value': 'kufua', 'label': 'Kufua Nguo', 'icon': '👕'},
      {'value': 'kubeba', 'label': 'Kubeba Mizigo', 'icon': '📦'},
      {'value': 'kusafisha_gari', 'label': 'Kusafisha Gari', 'icon': '🚗'},
      {'value': 'kupika', 'label': 'Kupika', 'icon': '🍳'},
      {'value': 'kutunza_watoto', 'label': 'Kutunza Watoto', 'icon': '👶'},
      {'value': 'kujenga', 'label': 'Kujenga', 'icon': '🏗️'},
      {'value': 'kilimo', 'label': 'Kilimo', 'icon': '🌱'},
      {'value': 'nyingine', 'label': 'Nyingine', 'icon': '🔧'},
    ];
  }

  // Get payment types
  List<Map<String, String>> getPaymentTypes() {
    return [
      {'value': 'per_job', 'label': 'Malipo ya Kazi Moja'},
      {'value': 'per_hour', 'label': 'Malipo kwa Saa'},
      {'value': 'per_day', 'label': 'Malipo kwa Siku'},
    ];
  }

  // Get duration options
  List<Map<String, String>> getDurationOptions() {
    return [
      {'value': '1_hour', 'label': 'Saa 1'},
      {'value': '2_hours', 'label': 'Saa 2'},
      {'value': '4_hours', 'label': 'Saa 4'},
      {'value': '1_day', 'label': 'Siku 1'},
      {'value': '2_days', 'label': 'Siku 2'},
      {'value': '1_week', 'label': 'Wiki 1'},
    ];
  }

  // Analytics tracking
  Future<void> _trackJobPosting(String jobId, String category, double payment, String location) async {
    // This would integrate with your analytics service
    print('Job posted: $jobId, Category: $category, Payment: TZS $payment, Location: $location');
  }

  // Validate job data
  bool validateJobData({
    required String title,
    required String description,
    required String location,
    required double minPayment,
  }) {
    if (title.trim().isEmpty) return false;
    if (description.trim().isEmpty) return false;
    if (location.trim().isEmpty) return false;
    if (minPayment <= 0) return false;
    return true;
  }
} 
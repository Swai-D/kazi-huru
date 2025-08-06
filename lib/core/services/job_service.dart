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
      await _trackJobPosting(jobId, category, minPayment, maxPayment, location);
      
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
        .getJobsSimple(status: 'active') // Use simple query without ordering
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .where((job) => job.providerId == providerId) // Filter on client side
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

  // Update job
  Future<void> updateJob({
    required String jobId,
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
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (location != null) updateData['location'] = location;
      if (minPayment != null) updateData['salary'] = minPayment;
      if (paymentType != null) updateData['salaryType'] = paymentType.toString().split('.').last;
      if (duration != null) updateData['duration'] = duration;
      if (workersNeeded != null) updateData['workersNeeded'] = workersNeeded;
      if (requirements != null) updateData['requirements'] = requirements.split(',').map((e) => e.trim()).toList();
      if (contactPreference != null) updateData['contactPreference'] = contactPreference.toString().split('.').last;
      if (startDate != null) updateData['startDate'] = Timestamp.fromDate(startDate);
      if (startTime != null) {
        updateData['startTimeHour'] = startTime.hour;
        updateData['startTimeMinute'] = startTime.minute;
      }
      if (deadline != null) updateData['deadline'] = Timestamp.fromDate(deadline);
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;
      if (status != null) updateData['status'] = status.toString().split('.').last;

      await _firestoreService.updateJob(
        jobId: jobId,
        updateData: updateData,
      );
    } catch (e) {
      throw Exception('Failed to update job: $e');
    }
  }

  // Delete job
  Future<void> deleteJob(String jobId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Delete the job directly
      await _firestoreService.deleteJob(jobId);
    } catch (e) {
      throw Exception('Failed to delete job: $e');
    }
  }

  // Get job statistics for provider
  Future<Map<String, dynamic>> getJobStatistics(String providerId) async {
    try {
      final jobs = await getJobsByProvider(providerId).first;
      
      int totalJobs = jobs.length;
      int activeJobs = jobs.where((job) => job.status == JobStatus.active).length;
      int completedJobs = jobs.where((job) => job.status == JobStatus.completed).length;
      int totalApplications = jobs.fold(0, (sum, job) => sum + job.applicationsCount);
      
      return {
        'totalJobs': totalJobs,
        'activeJobs': activeJobs,
        'completedJobs': completedJobs,
        'totalApplications': totalApplications,
      };
    } catch (e) {
      throw Exception('Failed to get job statistics: $e');
    }
  }

  // Get applications with user details
  Stream<List<Map<String, dynamic>>> getJobApplicationsWithDetails(String jobId) {
    return _firestoreService.getJobApplicationsWithUserDetails(jobId);
  }

  // Get all applications for a provider
  Stream<List<Map<String, dynamic>>> getProviderApplications(String providerId) {
    return _firestoreService.getProviderApplications(providerId);
  }

  // Send message to applicant
  Future<void> sendMessageToApplicant({
    required String jobId,
    required String applicationId,
    required String message,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestoreService.sendMessageToApplicant(
        jobId: jobId,
        applicationId: applicationId,
        message: message,
        senderId: user.uid,
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Mark job as completed
  Future<void> markJobAsCompleted(String jobId) async {
    try {
      await updateJobStatus(jobId, JobStatus.completed);
    } catch (e) {
      throw Exception('Failed to mark job as completed: $e');
    }
  }

  // Pause job
  Future<void> pauseJob(String jobId) async {
    try {
      await updateJobStatus(jobId, JobStatus.paused);
    } catch (e) {
      throw Exception('Failed to pause job: $e');
    }
  }

  // Resume job
  Future<void> resumeJob(String jobId) async {
    try {
      await updateJobStatus(jobId, JobStatus.active);
    } catch (e) {
      throw Exception('Failed to resume job: $e');
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

  // Format salary range for display
  String formatSalaryRange(double minPayment, double maxPayment) {
    if (minPayment == maxPayment) {
      return 'TZS ${minPayment.toStringAsFixed(0)}';
    }
    return 'TZS ${minPayment.toStringAsFixed(0)} - ${maxPayment.toStringAsFixed(0)}';
  }

  // Get jobs by salary range
  Stream<List<JobModel>> getJobsBySalaryRange(double minSalary, double maxSalary) {
    return _firestoreService.getJobsSimple().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return JobModel.fromMap(data, doc.id);
      }).where((job) => 
        (job.minPayment >= minSalary && job.minPayment <= maxSalary) ||
        (job.maxPayment >= minSalary && job.maxPayment <= maxSalary) ||
        (job.minPayment <= minSalary && job.maxPayment >= maxSalary)
      ).toList();
    });
  }

  // Get duration options
  List<Map<String, String>> getDurationOptions() {
    return [
      {'value': '1_hour', 'label': 'Saa 1'},
      {'value': '2_hours', 'label': 'Saa 2'},
      {'value': '4_hours', 'label': 'Saa 4'},
      {'value': '6_hours', 'label': 'Saa 6'},
      {'value': '8_hours', 'label': 'Saa 8'},
      {'value': '1_day', 'label': 'Siku 1'},
      {'value': '2_days', 'label': 'Siku 2'},
      {'value': '1_week', 'label': 'Wiki 1'},
    ];
  }

  // Application Management Methods
  Future<void> acceptApplication(String jobId, String applicationId) async {
    try {
      // Update application status in Firestore
      await _firestoreService.updateJob(
        jobId: jobId,
        updateData: {
          'applications.$applicationId.status': 'accepted',
          'applications.$applicationId.updatedAt': DateTime.now(),
        },
      );
    } catch (e) {
      throw Exception('Failed to accept application: $e');
    }
  }

  Future<void> rejectApplication(String jobId, String applicationId) async {
    try {
      // Update application status in Firestore
      await _firestoreService.updateJob(
        jobId: jobId,
        updateData: {
          'applications.$applicationId.status': 'rejected',
          'applications.$applicationId.updatedAt': DateTime.now(),
        },
      );
    } catch (e) {
      throw Exception('Failed to reject application: $e');
    }
  }

  // Get applications for a specific job
  Stream<List<Map<String, dynamic>>> getJobApplications(String jobId) {
    return _firestoreService.getJobApplicationsWithUserDetails(jobId);
  }

  // Analytics tracking
  Future<void> _trackJobPosting(String jobId, String category, double minPayment, double maxPayment, String location) async {
    // This would integrate with your analytics service
    final paymentRange = minPayment == maxPayment 
        ? 'TZS $minPayment' 
        : 'TZS $minPayment - $maxPayment';
    print('Job posted: $jobId, Category: $category, Payment: $paymentRange, Location: $location');
  }

  // Validate job data
  bool validateJobData({
    required String title,
    required String description,
    required String location,
    required double minPayment,
    required double maxPayment,
  }) {
    if (title.trim().isEmpty) return false;
    if (description.trim().isEmpty) return false;
    if (location.trim().isEmpty) return false;
    if (minPayment <= 0) return false;
    if (maxPayment <= 0) return false;
    if (maxPayment < minPayment) return false;
    return true;
  }
} 
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

class JobService {
  static final JobService _instance = JobService._internal();
  factory JobService() => _instance;
  JobService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Job Categories
  List<Map<String, String>> getJobCategories() {
    return [
      {'value': 'usafi', 'label': 'Usafi (Cleaning)'},
      {'value': 'kufua', 'label': 'Kufua (Laundry)'},
      {'value': 'kubeba', 'label': 'Kubeba (Moving/Carrying)'},
      {'value': 'uongozi', 'label': 'Uongozi (Management)'},
      {'value': 'utumishi', 'label': 'Utumishi (Service)'},
      {'value': 'ujenzi', 'label': 'Ujenzi (Construction)'},
      {'value': 'kilimo', 'label': 'Kilimo (Agriculture)'},
      {'value': 'biashara', 'label': 'Biashara (Business)'},
      {'value': 'teknolojia', 'label': 'Teknolojia (Technology)'},
      {'value': 'mengine', 'label': 'Mengine (Other)'},
    ];
  }

  // Payment Types
  List<Map<String, String>> getPaymentTypes() {
    return [
      {'value': 'per_job', 'label': 'Kwa Kazi (Per Job)'},
      {'value': 'per_hour', 'label': 'Kwa Saa (Per Hour)'},
      {'value': 'per_day', 'label': 'Kwa Siku (Per Day)'},
    ];
  }

  // Duration Options
  List<Map<String, String>> getDurationOptions() {
    return [
      {'value': '1_hour', 'label': 'Saa 1 (1 Hour)'},
      {'value': '2_hours', 'label': 'Masaa 2 (2 Hours)'},
      {'value': '3_hours', 'label': 'Masaa 3 (3 Hours)'},
      {'value': '4_hours', 'label': 'Masaa 4 (4 Hours)'},
      {'value': '6_hours', 'label': 'Masaa 6 (6 Hours)'},
      {'value': '8_hours', 'label': 'Masaa 8 (8 Hours)'},
      {'value': '1_day', 'label': 'Siku 1 (1 Day)'},
      {'value': '2_days', 'label': 'Siku 2 (2 Days)'},
      {'value': '3_days', 'label': 'Siku 3 (3 Days)'},
      {'value': '1_week', 'label': 'Wiki 1 (1 Week)'},
      {'value': '2_weeks', 'label': 'Wiki 2 (2 Weeks)'},
      {'value': '1_month', 'label': 'Mwezi 1 (1 Month)'},
    ];
  }

  // Create Job
  Future<String> createJob({
    required String providerId,
    required String title,
    required String description,
    required String category,
    required String location,
    required double minPayment,
    required double maxPayment,
    required String paymentType,
    required String duration,
    required int workersNeeded,
    required String requirements,
    required String contactPreference,
    required DateTime startDate,
    required String startTime,
    required DateTime deadline,
    String? imageUrl,
  }) async {
    try {
      final jobData = {
        'providerId': providerId,
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'minPayment': minPayment,
        'maxPayment': maxPayment,
        'paymentType': paymentType,
        'duration': duration,
        'workersNeeded': workersNeeded,
        'requirements': requirements,
        'contactPreference': contactPreference,
        'startDate': Timestamp.fromDate(startDate),
        'startTime': startTime,
        'deadline': Timestamp.fromDate(deadline),
        'imageUrl': imageUrl,
        'status': 'active',
        'applicationsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      DocumentReference docRef = await _firestore.collection('jobs').add(jobData);
      return docRef.id;
    } catch (e) {
      throw Exception('Hitilafu katika kuunda kazi: $e');
    }
  }

  // Update Job
  Future<void> updateJob(
    String jobId, {
    required String title,
    required String description,
    required String category,
    required String location,
    required double minPayment,
    required double maxPayment,
    required String paymentType,
    required String duration,
    required int workersNeeded,
    required String requirements,
    required String contactPreference,
    required DateTime startDate,
    required String startTime,
    required DateTime deadline,
    String? imageUrl,
  }) async {
    try {
      final updateData = {
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'minPayment': minPayment,
        'maxPayment': maxPayment,
        'paymentType': paymentType,
        'duration': duration,
        'workersNeeded': workersNeeded,
        'requirements': requirements,
        'contactPreference': contactPreference,
        'startDate': Timestamp.fromDate(startDate),
        'startTime': startTime,
        'deadline': Timestamp.fromDate(deadline),
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('jobs').doc(jobId).update(updateData);
    } catch (e) {
      throw Exception('Hitilafu katika kusasisha kazi: $e');
    }
  }

  // Get Active Jobs Stream
  Stream<List<JobModel>> getActiveJobs() {
    return _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get Jobs by Provider Stream
  Stream<List<JobModel>> getJobsByProvider(String providerId) {
    return _firestore
        .collection('jobs')
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Update Job Status
  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Hitilafu katika kusasisha hali ya kazi: $e');
    }
  }

  // Delete Job
  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
    } catch (e) {
      throw Exception('Hitilafu katika kufuta kazi: $e');
    }
  }

  // Apply for Job
  Future<bool> applyForJob({
    required String jobId,
    required String seekerId,
    required String message,
  }) async {
    try {
      // Check if already applied
      final existingApplication = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .where('seekerId', isEqualTo: seekerId)
          .get();

      if (existingApplication.docs.isNotEmpty) {
        throw Exception('Umeshakwisha omba kazi hii');
      }

      // Create application
      await _firestore.collection('applications').add({
        'jobId': jobId,
        'seekerId': seekerId,
        'message': message,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update applications count
      await _firestore.collection('jobs').doc(jobId).update({
        'applicationsCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      throw Exception('Hitilafu katika kuomba kazi: $e');
    }
  }

  // Get Job Statistics
  Future<Map<String, dynamic>> getJobStatistics(String providerId) async {
    try {
      final jobsSnapshot = await _firestore
          .collection('jobs')
          .where('providerId', isEqualTo: providerId)
          .get();

      int totalJobs = jobsSnapshot.docs.length;
      int activeJobs = jobsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'active')
          .length;
      int completedJobs = jobsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;

      int totalApplications = 0;
      for (final doc in jobsSnapshot.docs) {
        totalApplications += (doc.data()['applicationsCount'] as int? ?? 0);
      }

      return {
        'totalJobs': totalJobs,
        'activeJobs': activeJobs,
        'completedJobs': completedJobs,
        'totalApplications': totalApplications,
      };
    } catch (e) {
      throw Exception('Hitilafu katika kupata takwimu: $e');
    }
  }

  // Get Provider Applications Stream
  Stream<List<Map<String, dynamic>>> getProviderApplications(String providerId) {
    return _firestore
        .collection('jobs')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .asyncMap((jobsSnapshot) async {
      List<Map<String, dynamic>> allApplications = [];
      
      for (final jobDoc in jobsSnapshot.docs) {
        final applicationsSnapshot = await _firestore
            .collection('applications')
            .where('jobId', isEqualTo: jobDoc.id)
            .orderBy('createdAt', descending: true)
            .get();
        
        for (final appDoc in applicationsSnapshot.docs) {
          final appData = appDoc.data();
          appData['id'] = appDoc.id;
          appData['jobTitle'] = jobDoc.data()['title'];
          appData['jobId'] = jobDoc.id;
          allApplications.add(appData);
        }
      }
      
      return allApplications;
    });
  }

  // Accept Application
  Future<void> acceptApplication(String jobId, String applicationId) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Hitilafu katika kukubali ombi: $e');
    }
  }

  // Reject Application
  Future<void> rejectApplication(String jobId, String applicationId) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Hitilafu katika kukataa ombi: $e');
    }
  }

  // Format Salary Range
  String formatSalaryRange(double minSalary, double maxSalary) {
    if (minSalary == maxSalary) {
      return 'TSh ${_formatCurrency(minSalary)}';
    } else {
      return 'TSh ${_formatCurrency(minSalary)} - ${_formatCurrency(maxSalary)}';
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  // Get Job by ID
  Future<JobModel?> getJob(String jobId) async {
    try {
      final doc = await _firestore.collection('jobs').doc(jobId).get();
      if (doc.exists) {
        return JobModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Hitilafu katika kupata kazi: $e');
    }
  }

  // Get Job Applications with Details
  Stream<List<Map<String, dynamic>>> getJobApplicationsWithDetails(String jobId) {
    return _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            })
            .toList());
  }
}

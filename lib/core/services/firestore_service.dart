import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String jobsCollection = 'jobs';
  static const String applicationsCollection = 'applications';
  static const String notificationsCollection = 'notifications';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String verificationsCollection = 'verifications';
  static const String walletCollection = 'wallet';

  // User Management
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String phoneNumber,
    required String role, // 'job_seeker' or 'job_provider'
    String? email,
    String? profileImageUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).set({
        'name': name,
        'phoneNumber': phoneNumber,
        'role': role,
        'email': email,
        'profileImageUrl': profileImageUrl,
        'isVerified': false,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      });
    } catch (e) {
      throw Exception('Hitilafu katika kuunda wasifu: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(usersCollection).doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Hitilafu katika kupata wasifu: $e');
    }
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return query.docs.first.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Hitilafu katika kupata mtumiaji na barua pepe: $e');
    }
  }

  // Get user by phone number
  Future<Map<String, dynamic>?> getUserByPhone(String phoneNumber) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(usersCollection)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return query.docs.first.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Hitilafu katika kupata mtumiaji na namba ya simu: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update({
        ...updateData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Hitilafu katika kusasisha wasifu: $e');
    }
  }

  // Update existing user profile with proper data
  Future<void> fixExistingUserProfile({
    required String userId,
    required String name,
    required String phoneNumber,
    String? email,
  }) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update({
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Hitilafu katika kusasisha wasifu: $e');
    }
  }

  // Job Management
  Future<String> createJob({
    required String jobProviderId,
    required String title,
    required String description,
    required String location,
    required double salary,
    required String salaryType, // 'hourly', 'daily', 'weekly', 'monthly'
    required List<String> requirements,
    required String jobType, // 'full_time', 'part_time', 'contract', 'temporary'
    String? companyName,
    String? companyLogoUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection(jobsCollection).add({
        'jobProviderId': jobProviderId,
        'title': title,
        'description': description,
        'location': location,
        'salary': salary,
        'salaryType': salaryType,
        'requirements': requirements,
        'jobType': jobType,
        'companyName': companyName,
        'companyLogoUrl': companyLogoUrl,
        'status': 'active', // 'active', 'paused', 'closed'
        'applicationsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Hitilafu katika kuunda kazi: $e');
    }
  }

  Future<void> updateJob({
    required String jobId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      await _firestore.collection(jobsCollection).doc(jobId).update({
        ...updateData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Hitilafu katika kusasisha kazi: $e');
    }
  }

  Future<Map<String, dynamic>?> getJob(String jobId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(jobsCollection).doc(jobId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Hitilafu katika kupata kazi: $e');
    }
  }

  Stream<QuerySnapshot> getJobs({
    String? location,
    String? jobType,
    double? minSalary,
    double? maxSalary,
    String? status,
  }) {
    Query query = _firestore.collection(jobsCollection);
    
    if (location != null && location.isNotEmpty) {
      query = query.where('location', isEqualTo: location);
    }
    if (jobType != null && jobType.isNotEmpty) {
      query = query.where('jobType', isEqualTo: jobType);
    }
    if (minSalary != null) {
      query = query.where('salary', isGreaterThanOrEqualTo: minSalary);
    }
    if (maxSalary != null) {
      query = query.where('salary', isLessThanOrEqualTo: maxSalary);
    }
    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }
    
    return query.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getJobsByProvider(String jobProviderId) {
    return _firestore
        .collection(jobsCollection)
        .where('jobProviderId', isEqualTo: jobProviderId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get jobs with simple query (no composite index required)
  Stream<QuerySnapshot> getJobsSimple({String? status}) {
    Query query = _firestore.collection(jobsCollection);
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    // Don't use orderBy to avoid composite index requirement
    // We'll sort on the client side instead
    return query.snapshots();
  }

  // Delete job
  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection(jobsCollection).doc(jobId).delete();
    } catch (e) {
      throw Exception('Hitilafu katika kufuta kazi: $e');
    }
  }

  // Get applications with user details
  Stream<List<Map<String, dynamic>>> getJobApplicationsWithUserDetails(String jobId) {
    return _firestore
        .collection(jobsCollection)
        .doc(jobId)
        .collection(applicationsCollection)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> applicationsWithDetails = [];
          
          for (final doc in snapshot.docs) {
            final applicationData = doc.data();
            final applicantId = applicationData['applicantId'];
            
            // Get user details
            final userDoc = await _firestore.collection(usersCollection).doc(applicantId).get();
            final userData = userDoc.data() as Map<String, dynamic>?;
            
            applicationsWithDetails.add({
              'id': doc.id,
              ...applicationData,
              'applicantName': userData?['name'] ?? 'Unknown',
              'applicantPhone': userData?['phoneNumber'] ?? '',
              'applicantEmail': userData?['email'] ?? '',
              'applicantProfileImage': userData?['profileImageUrl'] ?? '',
            });
          }
          
          return applicationsWithDetails;
        });
  }

  // Get all applications for a provider
  Stream<List<Map<String, dynamic>>> getProviderApplications(String providerId) {
    return _firestore
        .collection(jobsCollection)
        .where('jobProviderId', isEqualTo: providerId)
        .snapshots()
        .asyncMap((jobsSnapshot) async {
          List<Map<String, dynamic>> allApplications = [];
          
          for (final jobDoc in jobsSnapshot.docs) {
            final applicationsSnapshot = await _firestore
                .collection(jobsCollection)
                .doc(jobDoc.id)
                .collection(applicationsCollection)
                .get();
            
            for (final appDoc in applicationsSnapshot.docs) {
              final applicationData = appDoc.data();
              final applicantId = applicationData['applicantId'];
              
              // Get user details
              final userDoc = await _firestore.collection(usersCollection).doc(applicantId).get();
              final userData = userDoc.data() as Map<String, dynamic>?;
              
              allApplications.add({
                'id': appDoc.id,
                'jobId': jobDoc.id,
                'jobTitle': jobDoc.data()['title'] ?? '',
                'jobLocation': jobDoc.data()['location'] ?? '',
                ...applicationData,
                'applicantName': userData?['name'] ?? 'Unknown',
                'applicantPhone': userData?['phoneNumber'] ?? '',
                'applicantEmail': userData?['email'] ?? '',
                'applicantProfileImage': userData?['profileImageUrl'] ?? '',
              });
            }
          }
          
          return allApplications;
        });
  }

  // Send message to applicant
  Future<void> sendMessageToApplicant({
    required String jobId,
    required String applicationId,
    required String message,
    required String senderId,
  }) async {
    try {
      // Create or get chat room
      final chatRoomId = '${jobId}_${applicationId}';
      
      // Add message to chat
      await _firestore
          .collection(chatsCollection)
          .doc(chatRoomId)
          .collection(messagesCollection)
          .add({
        'senderId': senderId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      
      // Update chat room metadata
      await _firestore.collection(chatsCollection).doc(chatRoomId).set({
        'jobId': jobId,
        'applicationId': applicationId,
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'participants': [senderId, applicationId], // applicationId here represents the applicant
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Hitilafu katika kutuma ujumbe: $e');
    }
  }

  // Job Applications
  Future<String> applyForJob({
    required String jobId,
    required String jobSeekerId,
    required String coverLetter,
    String? resumeUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Check if already applied
      QuerySnapshot existingApplication = await _firestore
          .collection(applicationsCollection)
          .where('jobId', isEqualTo: jobId)
          .where('jobSeekerId', isEqualTo: jobSeekerId)
          .get();

      if (existingApplication.docs.isNotEmpty) {
        throw Exception('Umeshaomba kazi hii');
      }

      DocumentReference docRef = await _firestore.collection(applicationsCollection).add({
        'jobId': jobId,
        'jobSeekerId': jobSeekerId,
        'coverLetter': coverLetter,
        'resumeUrl': resumeUrl,
        'status': 'pending', // 'pending', 'accepted', 'rejected', 'withdrawn'
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      });

      // Update job applications count
      await _firestore.collection(jobsCollection).doc(jobId).update({
        'applicationsCount': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Hitilafu katika kuomba kazi: $e');
    }
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? feedback,
  }) async {
    try {
      await _firestore.collection(applicationsCollection).doc(applicationId).update({
        'status': status,
        'feedback': feedback,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Hitilafu katika kusasisha hali ya maombi: $e');
    }
  }

  Stream<QuerySnapshot> getApplicationsByJobSeeker(String jobSeekerId) {
    return _firestore
        .collection(applicationsCollection)
        .where('jobSeekerId', isEqualTo: jobSeekerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getApplicationsForJob(String jobId) {
    return _firestore
        .collection(applicationsCollection)
        .where('jobId', isEqualTo: jobId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Notifications
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type, // 'job_application', 'job_update', 'system', etc.
    String? jobId,
    String? applicationId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _firestore.collection(notificationsCollection).add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'jobId': jobId,
        'applicationId': applicationId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      });
    } catch (e) {
      throw Exception('Hitilafu katika kuunda arifa: $e');
    }
  }

  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection(notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection(notificationsCollection).doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Hitilafu katika kusasisha arifa: $e');
    }
  }

  // Verification
  Future<void> submitVerification({
    required String userId,
    required String idType, // 'national_id', 'passport', 'driving_license'
    required String idNumber,
    required String fullName,
    required String dateOfBirth,
    String? idImageUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _firestore.collection(verificationsCollection).add({
        'userId': userId,
        'idType': idType,
        'idNumber': idNumber,
        'fullName': fullName,
        'dateOfBirth': dateOfBirth,
        'idImageUrl': idImageUrl,
        'status': 'pending', // 'pending', 'approved', 'rejected'
        'submittedAt': FieldValue.serverTimestamp(),
        'reviewedAt': null,
        'reviewerId': null,
        'feedback': null,
        ...?additionalData,
      });
    } catch (e) {
      throw Exception('Hitilafu katika kuwasilisha uthibitishaji: $e');
    }
  }

  Stream<QuerySnapshot> getVerificationRequests({String? status}) {
    Query query = _firestore.collection(verificationsCollection);
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query.orderBy('submittedAt', descending: true).snapshots();
  }

  // Wallet
  Future<void> createWallet({
    required String userId,
    double initialBalance = 0.0,
  }) async {
    try {
      await _firestore.collection(walletCollection).doc(userId).set({
        'balance': initialBalance,
        'currency': 'TZS',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Hitilafu katika kuunda pochi: $e');
    }
  }

  Future<Map<String, dynamic>?> getWallet(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(walletCollection).doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Hitilafu katika kupata pochi: $e');
    }
  }

  Future<void> updateWalletBalance({
    required String userId,
    required double amount,
    required String transactionType, // 'credit', 'debit'
    String? description,
  }) async {
    try {
      await _firestore.collection(walletCollection).doc(userId).update({
        'balance': FieldValue.increment(transactionType == 'credit' ? amount : -amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add transaction record
      await _firestore.collection(walletCollection).doc(userId).collection('transactions').add({
        'amount': amount,
        'type': transactionType,
        'description': description ?? 'Transaction',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Hitilafu katika kusasisha salio: $e');
    }
  }

  // Get completed jobs for a specific user (job seeker)
  Future<List<Map<String, dynamic>>> getCompletedJobsForUser(String userId) async {
    try {
      // Get jobs where the user was hired and completed
      QuerySnapshot jobsSnapshot = await _firestore
          .collection(jobsCollection)
          .where('hiredJobSeekerId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .orderBy('completedAt', descending: true)
          .limit(10)
          .get();

      List<Map<String, dynamic>> completedJobs = [];
      
      for (final doc in jobsSnapshot.docs) {
        final jobData = doc.data() as Map<String, dynamic>;
        
        // Get job provider details
        final providerId = jobData['jobProviderId'];
        Map<String, dynamic>? providerData;
        if (providerId != null) {
          final providerDoc = await _firestore.collection(usersCollection).doc(providerId).get();
          if (providerDoc.exists) {
            providerData = providerDoc.data() as Map<String, dynamic>;
          }
        }

        completedJobs.add({
          'id': doc.id,
          'title': jobData['title'] ?? 'Unknown Job',
          'description': jobData['description'] ?? '',
          'location': jobData['location'] ?? '',
          'salary': jobData['salary'] ?? 0,
          'completedAt': jobData['completedAt'],
          'duration': jobData['duration'] ?? '',
          'rating': jobData['rating'] ?? 0,
          'review': jobData['review'] ?? '',
          'providerName': providerData?['name'] ?? 'Unknown Provider',
          'providerImage': providerData?['profileImageUrl'],
          'jobType': jobData['jobType'] ?? '',
          'category': jobData['category'] ?? '',
        });
      }
      
      return completedJobs;
    } catch (e) {
      throw Exception('Hitilafu katika kupata kazi zilizokamilika: $e');
    }
  }

  // Get user's portfolio/showcase data
  Future<Map<String, dynamic>> getUserShowcase(String userId) async {
    try {
      final userDoc = await _firestore.collection(usersCollection).doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('Mtumiaji hajapatikana');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      
      // Get completed jobs
      final completedJobs = await getCompletedJobsForUser(userId);
      
      // Calculate statistics
      double totalEarnings = 0;
      double totalRating = 0;
      int ratedJobs = 0;
      
      for (final job in completedJobs) {
        totalEarnings += (job['salary'] ?? 0).toDouble();
        if ((job['rating'] ?? 0) > 0) {
          totalRating += (job['rating'] ?? 0).toDouble();
          ratedJobs++;
        }
      }
      
      final averageRating = ratedJobs > 0 ? totalRating / ratedJobs : 0.0;
      
      return {
        'userId': userId,
        'name': userData['name'] ?? '',
        'profileImage': userData['profileImageUrl'],
        'completedJobs': completedJobs,
        'totalEarnings': totalEarnings,
        'averageRating': averageRating,
        'totalJobs': completedJobs.length,
        'skills': userData['skills'] ?? [],
        'experience': userData['experience'] ?? '',
        'category': userData['category'] ?? '',
        'verified': userData['verified'] ?? false,
      };
    } catch (e) {
      throw Exception('Hitilafu katika kupata showcase: $e');
    }
  }

  // Get showcase preview for multiple users (for search results)
  Future<Map<String, Map<String, dynamic>>> getShowcasePreviewForUsers(List<String> userIds) async {
    try {
      Map<String, Map<String, dynamic>> showcaseData = {};
      
      // Get completed jobs for all users in batches
      for (final userId in userIds) {
        try {
          final completedJobs = await getCompletedJobsForUser(userId);
          
          // Calculate quick stats
          double totalEarnings = 0;
          double totalRating = 0;
          int ratedJobs = 0;
          
          for (final job in completedJobs) {
            totalEarnings += (job['salary'] ?? 0).toDouble();
            if ((job['rating'] ?? 0) > 0) {
              totalRating += (job['rating'] ?? 0).toDouble();
              ratedJobs++;
            }
          }
          
          final averageRating = ratedJobs > 0 ? totalRating / ratedJobs : 0.0;
          
          showcaseData[userId] = {
            'totalJobs': completedJobs.length,
            'totalEarnings': totalEarnings,
            'averageRating': averageRating,
            'recentJobs': completedJobs.take(3).toList(), // Show only 3 most recent
          };
        } catch (e) {
          // Skip this user if there's an error
          continue;
        }
      }
      
      return showcaseData;
    } catch (e) {
      throw Exception('Hitilafu katika kupata showcase preview: $e');
    }
  }
} 
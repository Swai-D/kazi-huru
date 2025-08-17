import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/job_service.dart';
import '../../../../core/models/job_model.dart' show JobModel;
import '../../../../core/services/chat_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/sms_service.dart';

class JobSeekerProfileScreen extends StatefulWidget {
  final String? jobSeekerId; // Preferred: Firestore userId (uid)
  final Map<String, dynamic>? jobSeeker; // Fallback for mock/local data

  const JobSeekerProfileScreen({super.key, this.jobSeekerId, this.jobSeeker});

  @override
  State<JobSeekerProfileScreen> createState() => _JobSeekerProfileScreenState();
}

class _JobSeekerProfileScreenState extends State<JobSeekerProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final JobService _jobService = JobService();
  final ChatService _chatService = ChatService();
  final NotificationService _notificationService = NotificationService();
  final SMSService _smsService = SMSService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  bool _isHiring = false;
  bool _isSendingMessage = false;
  Map<String, dynamic> _data = {};
  List<Map<String, dynamic>> _showcaseJobs = [];
  bool _isLoadingShowcase = false;
  List<Map<String, dynamic>> _activeJobs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadActiveJobs();
  }

  Future<void> _loadData() async {
    try {
      Map<String, dynamic>? fetched;
      String? id =
          widget.jobSeekerId ??
          widget.jobSeeker?['uid'] ??
          widget.jobSeeker?['userId'];
      if (id != null && id.toString().isNotEmpty) {
        fetched = await _firestoreService.getUserProfile(id);
        // Load showcase data
        await _loadShowcaseData(id);
      }
      final source = fetched ?? widget.jobSeeker ?? {};
      _data = _normalizeToTemplate(source);
    } catch (_) {
      _data = _normalizeToTemplate(widget.jobSeeker ?? {});
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadActiveJobs() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final jobs = await _jobService.getJobsByProvider(currentUser.uid).first;
        setState(() {
          _activeJobs =
              jobs
                  .map(
                    (job) => {
                      'id': job.id,
                      'title': job.title,
                      'status': job.status,
                    },
                  )
                  .toList();
        });
      }
    } catch (e) {
      print('Error loading active jobs: $e');
    }
  }

  Future<void> _loadShowcaseData(String userId) async {
    setState(() => _isLoadingShowcase = true);
    try {
      final completedJobs = await _firestoreService.getCompletedJobsForUser(
        userId,
      );
      if (mounted) {
        setState(() {
          _showcaseJobs = completedJobs;
          _isLoadingShowcase = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingShowcase = false);
      }
    }
  }

  Map<String, dynamic> _normalizeToTemplate(Map<String, dynamic> raw) {
    // Map Firestore or mock fields to the template keys used in UI
    return {
      'name': raw['name'] ?? raw['fullName'] ?? 'Mtumishi',
      'image': raw['profileImageUrl'],
      'verified': raw['verified'] ?? raw['isVerified'] ?? false,
      'location': raw['location'] ?? '—',
      'rating': (raw['rating'] ?? 0).toDouble(),
      'completed_jobs': raw['completed_jobs'] ?? raw['completedJobs'] ?? 0,
      'description': raw['description'] ?? raw['bio'] ?? '',
      'availability': raw['availability'] ?? '',
      'daily_rate': raw['daily_rate'] ?? raw['rate'] ?? null,
      'job_rate': raw['job_rate'] ?? null,
      'skills': List<String>.from((raw['skills'] ?? const <String>[]) as List),
      'experience': raw['experience']?.toString() ?? '—',
      'category': raw['category']?.toString() ?? '—',
      'createdAt': raw['createdAt'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wasifu wa Mtumishi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: ThemeConstants.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white),
            onPressed: () {
              // TODO: Navigate to chat screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat functionality coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    _buildActionButtons(),
                    _buildBioSection(),
                    _buildAboutSection(),
                    _buildSkillsSection(),
                    _buildExperienceSection(),
                    _buildShowcaseSection(),
                    _buildReviewsSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage:
                    _data['image'] != null
                        ? NetworkImage(_data['image']) as ImageProvider
                        : null,
                backgroundColor: ThemeConstants.primaryColor.withOpacity(0.1),
                child:
                    _data['image'] == null
                        ? Icon(
                          Icons.person,
                          color: ThemeConstants.primaryColor,
                          size: 40,
                        )
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _data['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_data['verified'] == true) ...[
                          Icon(
                            Icons.verified,
                            color: ThemeConstants.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _data['location'] ?? '—',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${_data['rating']} (${_data['completed_jobs']} kazi zilizokamilika)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Uzoefu', _data['experience'] ?? '—'),
              _buildStatItem(
                'Kazi Zilizokamilika',
                '${_data['completed_jobs']}',
              ),
              _buildStatItem('Ukadiriaji', '${_data['rating']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeConstants.primaryColor,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isHiring ? null : _showHireDialog,
              icon:
                  _isHiring
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.work),
              label: Text(_isHiring ? 'Inatumwa...' : 'Mpange Kazi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isSendingMessage ? null : _sendDirectMessage,
              icon:
                  _isSendingMessage
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ThemeConstants.primaryColor,
                        ),
                      )
                      : const Icon(Icons.message),
              label: Text(_isSendingMessage ? 'Inatumwa...' : 'Tuma Ujumbe'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ThemeConstants.primaryColor,
                side: BorderSide(color: ThemeConstants.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHireDialog() {
    if (_activeJobs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hakuna kazi zilizopo. Tafadhali unda kazi kwanza.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Mpange Kazi'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Chagua kazi unayotaka kumpa:'),
                const SizedBox(height: 16),
                ...(_activeJobs
                    .where((job) => job['status'] == 'active')
                    .map(
                      (job) => ListTile(
                        title: Text(job['title']),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pop(context);
                          _hireJobSeeker(job['id']);
                        },
                      ),
                    )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Futa'),
              ),
            ],
          ),
    );
  }

  Future<void> _hireJobSeeker(String jobId) async {
    setState(() => _isHiring = true);

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Huna uwezo wa kufanya hii kitendo');
      }

      final jobSeekerId =
          widget.jobSeekerId ??
          widget.jobSeeker?['uid'] ??
          widget.jobSeeker?['userId'];

      if (jobSeekerId == null) {
        throw Exception('ID ya mtumishi haijulikani');
      }

      // Get job details
      final job = await _jobService.getJob(jobId);
      if (job == null) {
        throw Exception('Kazi haijulikani');
      }

      // Get job seeker details
      final jobSeekerData = await _firestoreService.getUserProfile(jobSeekerId);
      if (jobSeekerData == null) {
        throw Exception('Maelezo ya mtumishi hayajulikani');
      }

      // Create job assignment
      await _createJobAssignment(jobId, jobSeekerId, job, jobSeekerData);

      // Send notifications and SMS
      await _sendHireNotifications(jobId, jobSeekerId, job, jobSeekerData);

      // Update job status to assigned
      await _jobService.updateJobStatus(jobId, 'assigned');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mtumishi ameajiriwa kwa mafanikio!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hitilafu: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isHiring = false);
    }
  }

  Future<void> _createJobAssignment(
    String jobId,
    String jobSeekerId,
    dynamic job,
    Map<String, dynamic> jobSeekerData,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Get provider details
    final providerData = await _firestoreService.getUserProfile(
      currentUser.uid,
    );

    await FirebaseFirestore.instance.collection('job_assignments').add({
      'jobId': jobId,
      'jobSeekerId': jobSeekerId,
      'providerId': currentUser.uid,
      'jobTitle': job.title,
      'jobSeekerName': jobSeekerData['name'] ?? 'Unknown',
      'providerName': providerData?['name'] ?? 'Unknown',
      'assignedAt': FieldValue.serverTimestamp(),
      'status': 'assigned',
      'paymentStatus': 'pending',
    });
  }

  Future<void> _sendHireNotifications(
    String jobId,
    String jobSeekerId,
    dynamic job,
    Map<String, dynamic> jobSeekerData,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Get provider details
    final providerData = await _firestoreService.getUserProfile(
      currentUser.uid,
    );
    final providerName = providerData?['name'] ?? 'Unknown';

    // 1. Send notification to hired job seeker
    await _notificationService.sendSystemNotification(
      userId: jobSeekerId,
      title: 'Umeajiriwa! 🎉',
      body: 'Umeajiriwa kwenye kazi: ${job.title} na $providerName',
      data: {
        'type': 'job_assigned',
        'jobId': jobId,
        'providerId': currentUser.uid,
      },
    );

    // 2. Send SMS to hired job seeker
    final jobSeekerPhone = jobSeekerData['phone'];
    if (jobSeekerPhone != null) {
      await _sendHireSMS(
        phoneNumber: jobSeekerPhone,
        jobTitle: job.title,
        providerName: providerName,
        isHired: true,
      );
    }

    // 3. Send notifications to other applicants
    await _notifyOtherApplicants(jobId, jobSeekerId, job.title);

    // 4. Send notification to provider
    await _notificationService.sendSystemNotification(
      userId: currentUser.uid,
      title: 'Mtumishi Ameajiriwa ✅',
      body: 'Umeajiri ${jobSeekerData['name']} kwenye kazi: ${job.title}',
      data: {
        'type': 'job_seeker_hired',
        'jobId': jobId,
        'jobSeekerId': jobSeekerId,
      },
    );
  }

  Future<void> _notifyOtherApplicants(
    String jobId,
    String hiredJobSeekerId,
    String jobTitle,
  ) async {
    try {
      // Get all applications for this job
      final applications =
          await FirebaseFirestore.instance
              .collection('applications')
              .where('jobId', isEqualTo: jobId)
              .where('status', isEqualTo: 'pending')
              .get();

      for (final appDoc in applications.docs) {
        final appData = appDoc.data();
        final applicantId = appData['seekerId'];

        // Skip the hired applicant
        if (applicantId == hiredJobSeekerId) continue;

        // Send notification to other applicants
        await _notificationService.sendSystemNotification(
          userId: applicantId,
          title: 'Kazi Imekwisha 🚫',
          body: 'Samahani, kazi "$jobTitle" imekwisha kwa mtumishi mwingine',
          data: {'type': 'job_filled', 'jobId': jobId},
        );

        // Get applicant phone and send SMS
        final applicantData = await _firestoreService.getUserProfile(
          applicantId,
        );
        final applicantPhone = applicantData?['phone'];
        if (applicantPhone != null) {
          await _sendHireSMS(
            phoneNumber: applicantPhone,
            jobTitle: jobTitle,
            providerName: 'Mwenye Kazi',
            isHired: false,
          );
        }
      }
    } catch (e) {
      print('Error notifying other applicants: $e');
    }
  }

  Future<void> _sendHireSMS({
    required String phoneNumber,
    required String jobTitle,
    required String providerName,
    required bool isHired,
  }) async {
    try {
      String message;
      if (isHired) {
        message =
            'Hongera! Umeajiriwa kwenye kazi "$jobTitle" na $providerName. '
            'Tafadhali wasiliana na mwenye kazi kupikia Kazi Huru SMS Chat kwa maelezo zaidi. - Kazi Huru';
      } else {
        message =
            'Samahani, kazi "$jobTitle" imekwisha kwa mtumishi mwingine. '
            'Endelea kutafuta kazi nyingine. - Kazi Huru';
      }

      // Use SMS service to send message
      await SMSService.sendCustomMessage(phoneNumber, message);
    } catch (e) {
      print('Error sending SMS: $e');
    }
  }

  Future<void> _sendDirectMessage() async {
    setState(() => _isSendingMessage = true);

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Huna uwezo wa kufanya hii kitendo');
      }

      final jobSeekerId =
          widget.jobSeekerId ??
          widget.jobSeeker?['uid'] ??
          widget.jobSeeker?['userId'];

      if (jobSeekerId == null) {
        throw Exception('ID ya mtumishi haijulikani');
      }

      // Get user details
      final currentUserData = await _firestoreService.getUserProfile(
        currentUser.uid,
      );
      final jobSeekerData = await _firestoreService.getUserProfile(jobSeekerId);

      if (currentUserData == null || jobSeekerData == null) {
        throw Exception('Maelezo ya mtumiaji hayajulikani');
      }

      // Create or get chat room
      final chatRoomId = await _chatService.createChatRoom(
        participant1Id: currentUser.uid,
        participant1Name: currentUserData['name'] ?? 'Unknown',
        participant2Id: jobSeekerId,
        participant2Name: jobSeekerData['name'] ?? 'Unknown',
      );

      if (chatRoomId != null) {
        // Navigate to chat screen
        Navigator.pushNamed(
          context,
          '/chat-detail',
          arguments: {'chatRoomId': chatRoomId},
        );
      } else {
        throw Exception('Hitilafu katika kuunda chat room');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hitilafu: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSendingMessage = false);
    }
  }

  Widget _buildBioSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: ThemeConstants.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Kuhusu Mimi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_data['description'] != null &&
              _data['description'].toString().isNotEmpty)
            Text(
              _data['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(
                    'Hakuna maelezo ya kibinafsi yaliyowekwa',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: ThemeConstants.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Maelezo ya Kibinafsi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Upatikanaji: ${_data['availability'] ?? '—'}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Bei ya Siku: ${_data['daily_rate'] != null ? 'TZS ${_formatNumber(_data['daily_rate'])}' : '—'}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.work, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Bei ya Kazi: ${_data['job_rate'] != null ? 'TZS ${_formatNumber(_data['job_rate'])}' : '—'}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Alijiunga: ${_formatJoinDate(_data['createdAt'])}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: ThemeConstants.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Ujuzi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if ((_data['skills'] as List).isEmpty)
            Text(
              'Hakuna ujuzi uliowekwa',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  (_data['skills'] as List).map<Widget>((skill) {
                    final s = skill.toString();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ThemeConstants.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeConstants.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work_outline, color: ThemeConstants.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Uzoefu wa Kazi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildExperienceItem(
            'Kazi Zilizokamilika',
            '${_data['completed_jobs']}',
            Icons.check_circle_outline,
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildExperienceItem(
            'Miaka ya Uzoefu',
            _data['experience'] ?? '—',
            Icons.timer_outlined,
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildExperienceItem(
            'Kategoria',
            _data['category'] ?? '—',
            Icons.category_outlined,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShowcaseSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work_history, color: ThemeConstants.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Kazi Zilizokamilika (Showcase)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingShowcase)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_showcaseJobs.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.work_off, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Hakuna kazi zilizokamilika bado',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                // Summary stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShowcaseStat('Jumla', '${_showcaseJobs.length}'),
                    _buildShowcaseStat(
                      'Mapato',
                      'TZS ${_calculateTotalEarnings()}',
                    ),
                    _buildShowcaseStat('Ukadiriaji', _calculateAverageRating()),
                  ],
                ),
                const SizedBox(height: 16),
                // Jobs list
                ..._showcaseJobs
                    .take(3)
                    .map((job) => _buildShowcaseJobCard(job)),
                if (_showcaseJobs.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: Text(
                        'na kazi ${_showcaseJobs.length - 3} zaidi...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // View all completed jobs button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to completed jobs screen
                      Navigator.pushNamed(context, '/completed_jobs');
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Tazama Kazi Zote Zilizokamilika'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeConstants.primaryColor,
                      side: BorderSide(color: ThemeConstants.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildShowcaseStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ThemeConstants.primaryColor,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildShowcaseJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  job['title'] ?? 'Unknown Job',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${job['rating'] ?? 0}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.business, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                job['providerName'] ?? 'Unknown Provider',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                job['location'] ?? 'Unknown Location',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TZS ${_formatNumber(job['salary'] ?? 0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                job['completedAt'] != null
                    ? _formatDate(job['completedAt'])
                    : 'Recently',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _calculateTotalEarnings() {
    double total = 0;
    for (final job in _showcaseJobs) {
      total += (job['salary'] ?? 0).toDouble();
    }
    return _formatNumber(total);
  }

  String _calculateAverageRating() {
    if (_showcaseJobs.isEmpty) return '0.0';

    double total = 0;
    int ratedJobs = 0;
    for (final job in _showcaseJobs) {
      if ((job['rating'] ?? 0) > 0) {
        total += (job['rating'] ?? 0).toDouble();
        ratedJobs++;
      }
    }
    return ratedJobs > 0 ? (total / ratedJobs).toStringAsFixed(1) : '0.0';
  }

  String _formatNumber(dynamic number) {
    final num = number is int ? number.toDouble() : (number ?? 0.0);
    return num.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Recently';

    try {
      if (date is Timestamp) {
        final now = DateTime.now();
        final jobDate = date.toDate();
        final difference = now.difference(jobDate);

        if (difference.inDays == 0) {
          return 'Today';
        } else if (difference.inDays == 1) {
          return 'Yesterday';
        } else if (difference.inDays < 7) {
          return '${difference.inDays} days ago';
        } else if (difference.inDays < 30) {
          final weeks = (difference.inDays / 7).floor();
          return '$weeks weeks ago';
        } else {
          return '${jobDate.day}/${jobDate.month}/${jobDate.year}';
        }
      }
      return 'Recently';
    } catch (e) {
      return 'Recently';
    }
  }

  String _formatJoinDate(dynamic date) {
    if (date == null) return 'Hivi karibuni';

    try {
      if (date is Timestamp) {
        final joinDate = date.toDate();
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];

        final day = joinDate.day.toString().padLeft(2, '0');
        final month = months[joinDate.month - 1];
        final year = joinDate.year;

        return '$day $month $year';
      }
      return 'Hivi karibuni';
    } catch (e) {
      return 'Hivi karibuni';
    }
  }

  Widget _buildReviewsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_outline, color: ThemeConstants.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Ukadiriaji na Maoni',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${_data['rating']}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(5, (index) {
                  final rating = (_data['rating'] ?? 0).toDouble();
                  return Icon(
                    index < rating.floor() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                '(${_data['completed_jobs']} kazi)',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Hakuna maoni bado',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

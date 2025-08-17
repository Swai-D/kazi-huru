import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/image_upload_widget.dart';

class UserProfileScreen extends StatefulWidget {
  final String userRole; // 'job_seeker' or 'job_provider'

  const UserProfileScreen({super.key, required this.userRole});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  String? _profileImageUrl;

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController(text: 'Dar es Salaam');
  final _bioController = TextEditingController(
    text:
        'Experienced software developer with a passion for building scalable applications.',
  );

  // Company information for job providers
  final _companyNameController = TextEditingController(
    text: 'Tech Solutions Ltd',
  );
  final _companyWebsiteController = TextEditingController(
    text: 'www.techsolutions.co.tz',
  );
  final _companyDescriptionController = TextEditingController(
    text: 'Leading technology company in Tanzania',
  );

  String _selectedLanguage = LocalizationService().currentLocale.languageCode;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.userName ?? '';
    final userPhone = authProvider.userPhoneNumber ?? '';

    _nameController.text = userName;
    _phoneController.text = userPhone;
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          context.tr('profile'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: ThemeConstants.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Save changes
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.tr('profile_updated'))),
                    );
                  }
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(),
              const SizedBox(height: 24),

              // Basic Information
              _buildBasicInformation(),
              const SizedBox(height: 24),

              // Job Seeker basic info (MVP only)
              if (widget.userRole == 'job_seeker') ...[
                _buildBasicJobSeekerInfo(context),
                const SizedBox(height: 24),
              ],

              // Company Information (for job providers)
              if (widget.userRole == 'job_provider') ...[
                _buildCompanyInformation(),
                const SizedBox(height: 24),
              ],

              // Jobs Summary (MVP only)
              if (widget.userRole == 'job_seeker') ...[
                _buildJobsSummary(),
                const SizedBox(height: 24),
                _buildSavedJobs(),
                const SizedBox(height: 24),
              ],

              // Posted Jobs (for job providers)
              if (widget.userRole == 'job_provider') ...[
                _buildPostedJobs(),
                const SizedBox(height: 24),
              ],

              // Applications Received (for job providers)
              if (widget.userRole == 'job_provider') ...[
                _buildApplicationsReceived(),
                const SizedBox(height: 24),
              ],

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // --- MVP Job Seeker sections ---
  Widget _buildBasicJobSeekerInfo(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final profile = auth.userProfile ?? {};
    final location =
        (profile['location'] ?? _locationController.text).toString();
    final availability = (profile['availability'] ?? '').toString();

    return Container(
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
              const Icon(
                Icons.info_outline,
                color: ThemeConstants.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Maelezo Muhimu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Eneo: ${location.isEmpty ? 'Haijabainishwa' : location}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Upatikanaji: ${availability.isEmpty ? 'Haijabainishwa' : availability}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobsSummary() {
    return Container(
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
              const Icon(Icons.work, color: ThemeConstants.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Kazi Zangu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/assigned-jobs');
                },
                child: Text(
                  'Tazama Zote',
                  style: TextStyle(color: ThemeConstants.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(title: 'Zilizopewa', value: '2'),
              _StatItem(title: 'Zilizokamilika', value: '8'),
              _StatItem(title: 'Ukadiriaji', value: '4.5'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedJobs() {
    return Container(
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
              const Icon(Icons.bookmark, color: ThemeConstants.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Kazi Zilizohifadhiwa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to saved jobs screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kazi zilizohifadhiwa zitaonekana hapa'),
                    ),
                  );
                },
                child: Text(
                  'Tazama Zote',
                  style: TextStyle(color: ThemeConstants.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Example saved jobs
          _buildSavedJobItem(
            title: 'Usafi wa Nyumba',
            location: 'Dar es Salaam',
            payment: 'TZS 25,000',
            category: 'Usafi',
          ),
          const SizedBox(height: 8),
          _buildSavedJobItem(
            title: 'Kubeba Mizigo',
            location: 'Mwanza',
            payment: 'TZS 15,000',
            category: 'Kubeba',
          ),
        ],
      ),
    );
  }

  Widget _buildSavedJobItem({
    required String title,
    required String location,
    required String payment,
    required String category,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                payment,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ThemeConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 10,
                    color: ThemeConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          // Profile Picture
          ImageUploadWidget(
            folder: 'profile_pictures',
            currentImageUrl: _profileImageUrl,
            onImageUploaded: (imageUrl) {
              setState(() {
                _profileImageUrl = imageUrl;
              });
              // TODO: Update user profile in Firestore with new image URL
              _updateProfileImage(imageUrl);
            },
            onImageDeleted: () {
              setState(() {
                _profileImageUrl = null;
              });
              // TODO: Remove image URL from user profile in Firestore
              _removeProfileImage();
            },
            width: 100,
            height: 100,
            label: null, // No label for profile picture
            showDeleteButton: _isEditing,
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            _nameController.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ThemeConstants.textColor,
            ),
          ),
          const SizedBox(height: 8),
          // Role
          Text(
            widget.userRole == 'job_seeker'
                ? context.tr('job_seeker')
                : context.tr('job_provider'),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          if (widget.userRole == 'job_seeker') ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(title: context.tr('applied_jobs'), value: '12'),
                _StatItem(title: context.tr('completed_jobs'), value: '8'),
                _StatItem(title: context.tr('rating'), value: '4.5'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  context.tr('personal_information'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textColor,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: ThemeConstants.primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.person,
            label: context.tr('full_name'),
            value: _nameController.text,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.phone,
            label: context.tr('phone'),
            value: _phoneController.text,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.location_on,
            label: context.tr('location'),
            value: _locationController.text,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.description,
            label: context.tr('bio'),
            value: _bioController.text,
          ),
        ],
      ),
    );
  }

  Widget _buildJobStatistics() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(title: context.tr('applied_jobs'), value: '12'),
          ),
          Expanded(
            child: _StatItem(title: context.tr('completed_jobs'), value: '8'),
          ),
          Expanded(child: _StatItem(title: context.tr('rating'), value: '4.5')),
        ],
      ),
    );
  }

  Widget _buildCompanyStatistics() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(title: context.tr('posted_jobs'), value: '8'),
          ),
          Expanded(
            child: _StatItem(title: context.tr('active_jobs'), value: '5'),
          ),
          Expanded(
            child: _StatItem(title: context.tr('applications'), value: '24'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedJobs() {
    return Card(
      color: ThemeConstants.cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('applied_jobs'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/applied_jobs');
                  },
                  child: Text(
                    context.tr('view_all'),
                    style: TextStyle(color: ThemeConstants.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildJobItem(
              title: 'Software Developer',
              company: 'Tech Solutions Ltd',
              status: 'Pending',
              statusColor: Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildJobItem(
              title: 'Data Entry Clerk',
              company: 'Office Solutions',
              status: 'Under Review',
              statusColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedJobs() {
    return Card(
      color: ThemeConstants.cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kazi Zangu',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/assigned-jobs');
                  },
                  child: Text(
                    'Tazama Zote',
                    style: TextStyle(color: ThemeConstants.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildJobItem(
              title: 'Usafi wa Nyumba',
              company: 'Mama Sarah',
              status: 'Ilipewa',
              statusColor: Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildJobItem(
              title: 'Kubeba Mizigo',
              company: 'Baba John',
              status: 'Inafanywa',
              statusColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedJobs() {
    return Card(
      color: ThemeConstants.cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('completed_jobs'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/completed_jobs');
                  },
                  child: Text(
                    context.tr('view_all'),
                    style: TextStyle(color: ThemeConstants.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildJobItem(
              title: 'Website Development',
              company: 'Digital Agency',
              status: 'Completed',
              statusColor: Colors.green,
              showRating: true,
              rating: 4.8,
            ),
            const SizedBox(height: 8),
            _buildJobItem(
              title: 'Mobile App Testing',
              company: 'Tech Startup',
              status: 'Completed',
              statusColor: Colors.green,
              showRating: true,
              rating: 4.5,
            ),
          ],
        ),
      ),
    );
  }

  // --- MVP Job Provider sections ---
  Widget _buildApplicationsReceived() {
    return Container(
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
              const Icon(Icons.people, color: ThemeConstants.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Maombi Yaliyopokelewa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/applications_received');
                },
                child: Text(
                  'Tazama Zote',
                  style: TextStyle(color: ThemeConstants.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(title: 'Yaliyopokelewa', value: '8'),
              _StatItem(title: 'Yaliyokubaliwa', value: '3'),
              _StatItem(title: 'Yaliyokataliwa', value: '2'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobItem({
    required String title,
    required String company,
    required String status,
    required Color statusColor,
    bool showRating = false,
    double? rating,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.business, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                company,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          if (showRating && rating != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  rating.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostedJobs() {
    return Container(
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
              const Icon(Icons.work, color: ThemeConstants.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Kazi Zangu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/posted_jobs');
                },
                child: Text(
                  'Tazama Zote',
                  style: TextStyle(color: ThemeConstants.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(title: 'Zilizotangazwa', value: '5'),
              _StatItem(title: 'Zilizopo', value: '3'),
              _StatItem(title: 'Maombi', value: '12'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInformation() {
    return Card(
      color: ThemeConstants.cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('company_information'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.textColor,
              ),
            ),
            const SizedBox(height: 16),

            // Company Name Field
            TextFormField(
              controller: _companyNameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: context.tr('company_name'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.tr('please_enter_company_name');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Company Website Field
            TextFormField(
              controller: _companyWebsiteController,
              enabled: _isEditing,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: context.tr('company_website'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.language),
              ),
            ),
            const SizedBox(height: 16),

            // Company Description Field
            TextFormField(
              controller: _companyDescriptionController,
              enabled: _isEditing,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.tr('company_description'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsAndReviews() {
    return Card(
      color: ThemeConstants.cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('ratings_reviews'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.textColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  children: [
                    Text(
                      '4.5',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: ThemeConstants.primaryColor,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < 4 ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 20,
                        );
                      }),
                    ),
                    Text(
                      '${context.tr('based_on')} 15 ${context.tr('reviews')}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar(5, 8),
                      _buildRatingBar(4, 4),
                      _buildRatingBar(3, 2),
                      _buildRatingBar(2, 1),
                      _buildRatingBar(1, 0),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: count / 15,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Language Settings
        Container(
          padding: const EdgeInsets.all(20),
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
              Text(
                context.tr('language'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeConstants.textColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilterChip(
                      label: const Text('Swahili'),
                      selected: _selectedLanguage == 'sw',
                      onSelected: (selected) {
                        setState(() {
                          _selectedLanguage = 'sw';
                          LocalizationService().setLocale(const Locale('sw'));
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${context.tr('language_changed')} Swahili',
                            ),
                          ),
                        );
                      },
                      selectedColor: ThemeConstants.primaryColor.withOpacity(
                        0.2,
                      ),
                      checkmarkColor: ThemeConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilterChip(
                      label: const Text('English'),
                      selected: _selectedLanguage == 'en',
                      onSelected: (selected) {
                        setState(() {
                          _selectedLanguage = 'en';
                          LocalizationService().setLocale(const Locale('en'));
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${context.tr('language_changed')} English',
                            ),
                          ),
                        );
                      },
                      selectedColor: ThemeConstants.primaryColor.withOpacity(
                        0.2,
                      ),
                      checkmarkColor: ThemeConstants.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Account Actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to change password screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.tr('change_password'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.tr('logout'),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('logout')),
          content: Text(context.tr('logout_confirmation')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout();
              },
              child: Text(
                context.tr('logout'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Update profile image in Firestore
  Future<void> _updateProfileImage(String imageUrl) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateProfileImage(imageUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Picha ya profaili imewekwa kikamilifu!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hitilafu: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Remove profile image from Firestore
  Future<void> _removeProfileImage() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.removeProfileImage();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Picha ya profaili imefutwa!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hitilafu: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ThemeConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ThemeConstants.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ThemeConstants.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

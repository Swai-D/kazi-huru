import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String userRole; // 'job_seeker' or 'job_provider'
  
  const UserProfileScreen({
    super.key,
    required this.userRole,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  
  // Controllers for form fields
  final _nameController = TextEditingController(text: 'John Doe');
  final _phoneController = TextEditingController(text: '+255767265780');
  final _emailController = TextEditingController(text: 'john.doe@example.com');
  final _locationController = TextEditingController(text: 'Dar es Salaam');
  final _bioController = TextEditingController(text: 'Mtaalamu wa IT na uzoefu wa miaka 3');
  
  // Company information for job providers
  final _companyNameController = TextEditingController(text: 'Tech Solutions Ltd');
  final _companyWebsiteController = TextEditingController(text: 'www.techsolutions.co.tz');
  final _companyDescriptionController = TextEditingController(text: 'Leading technology company in Tanzania');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.tr('profile')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: ThemeConstants.primaryColor),
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
              
              // Company Information (for job providers)
              if (widget.userRole == 'job_provider') ...[
                _buildCompanyInformation(),
                const SizedBox(height: 24),
              ],
              

              
              // Applied Jobs
              if (widget.userRole == 'job_seeker') ...[
                _buildAppliedJobs(),
                const SizedBox(height: 24),
              ],
              
              // Completed Jobs
              if (widget.userRole == 'job_seeker') ...[
                _buildCompletedJobs(),
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

  Widget _buildProfileHeader() {
    return Column(
        children: [
          // Profile Picture
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: ThemeConstants.primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: ThemeConstants.primaryColor,
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: ThemeConstants.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          ),
          const SizedBox(height: 16),
        
        // Name and Role
        Center(
          child: Column(
            children: [
          Text(
            _nameController.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
                  color: ThemeConstants.textColor,
            ),
          ),
          Text(
            widget.userRole == 'job_seeker' 
                ? context.tr('job_seeker')
                : context.tr('job_provider'),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
        ),
        
        // Job Statistics (Instagram style)
        if (widget.userRole == 'job_seeker') ...[
          const SizedBox(height: 24),
          _buildJobStatistics(),
        ],
        
        // Company Statistics (for job providers)
        if (widget.userRole == 'job_provider') ...[
          const SizedBox(height: 24),
          _buildCompanyStatistics(),
        ],
      ],
    );
  }

  Widget _buildBasicInformation() {
    return Card(
      color: ThemeConstants.cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('personal_information'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
                color: ThemeConstants.textColor,
          ),
        ),
        const SizedBox(height: 16),
        
        // Name Field
        TextFormField(
          controller: _nameController,
          enabled: _isEditing,
          decoration: InputDecoration(
            labelText: context.tr('full_name'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.person_outline),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.tr('please_enter_name');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Phone Field
        TextFormField(
          controller: _phoneController,
          enabled: _isEditing,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: context.tr('phone'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.tr('please_enter_phone');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Email Field
        TextFormField(
          controller: _emailController,
          enabled: _isEditing,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: context.tr('email'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        
        // Location Field
        TextFormField(
          controller: _locationController,
          enabled: _isEditing,
          decoration: InputDecoration(
            labelText: context.tr('location'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
        ),
        const SizedBox(height: 16),
        
        // Bio Field
        TextFormField(
          controller: _bioController,
          enabled: _isEditing,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.tr('bio'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.description_outlined),
          ),
        ),
      ],
        ),
      ),
    );
  }

  Widget _buildJobStatistics() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.work_outline,
              title: context.tr('applied_jobs'),
              value: '12',
              color: ThemeConstants.primaryColor,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle_outline,
              title: context.tr('completed_jobs'),
              value: '8',
              color: Colors.green,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.star_outline,
              title: context.tr('rating'),
              value: '4.5',
              color: Colors.orange,
            ),
          ),
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
            child: _buildStatItem(
              icon: Icons.post_add,
              title: context.tr('posted_jobs'),
              value: '8',
              color: ThemeConstants.primaryColor,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.work,
              title: context.tr('active_jobs'),
              value: '5',
              color: Colors.green,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.people,
              title: context.tr('applications'),
              value: '24',
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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

  Widget _buildPostedJobs() {
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
                  context.tr('posted_jobs'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to posted jobs list
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.tr('viewing_posted_jobs'))),
                    );
                  },
                  child: Text(
                    context.tr('view_all'),
                    style: TextStyle(color: ThemeConstants.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPostedJobItem(
              title: 'Software Developer',
              status: 'Active',
              statusColor: Colors.green,
              applications: 12,
            ),
            const SizedBox(height: 8),
            _buildPostedJobItem(
              title: 'Data Entry Clerk',
              status: 'Active',
              statusColor: Colors.green,
              applications: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsReceived() {
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
                  context.tr('applications_received'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to applications list
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.tr('viewing_applications'))),
                    );
                  },
                  child: Text(
                    context.tr('view_all'),
                    style: TextStyle(color: ThemeConstants.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildApplicationItem(
              applicantName: 'Sarah Johnson',
              jobTitle: 'Software Developer',
              status: 'Pending',
              statusColor: Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildApplicationItem(
              applicantName: 'Michael Chen',
              jobTitle: 'Data Entry Clerk',
              status: 'Under Review',
              statusColor: Colors.blue,
            ),
          ],
        ),
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
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
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
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textColor,
                  ),
                ),
                Text(
                  company,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (showRating && rating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostedJobItem({
    required String title,
    required String status,
    required Color statusColor,
    required int applications,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
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
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textColor,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.people, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$applications applications',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationItem({
    required String applicantName,
    required String jobTitle,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  applicantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textColor,
                  ),
                ),
                Text(
                  jobTitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
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
          Text(
            '$stars',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: count / 15,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(fontSize: 12),
          ),
      ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Language Settings
        Card(
          color: ThemeConstants.cardBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('language_settings'),
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
                      child: _buildLanguageOption(
                        'English',
                        'en',
                        Icons.language,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLanguageOption(
                        'Kiswahili',
                        'sw',
                        Icons.language,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Account Actions
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to change password screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              context.tr('change_password'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Show logout confirmation dialog
              _showLogoutDialog();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.red),
            ),
            child: Text(
              context.tr('logout'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(String language, String code, IconData icon, Color color) {
    final isSelected = LocalizationService().currentLocale.languageCode == code;
    
    return GestureDetector(
      onTap: () {
        // Change language
        LocalizationService().setLocale(Locale(code));
        setState(() {
          // Refresh UI
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('language_changed')} $language')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? ThemeConstants.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? ThemeConstants.primaryColor.withOpacity(0.1) : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              color: isSelected ? ThemeConstants.primaryColor : Colors.grey.shade600, 
              size: 24
            ),
            const SizedBox(height: 8),
            Text(
              language,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? ThemeConstants.primaryColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
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
              onPressed: () {
                Navigator.of(context).pop();
                // Perform logout
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('logged_out'))),
                );
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
} 
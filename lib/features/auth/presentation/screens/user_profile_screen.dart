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
  final _bioController = TextEditingController(text: 'Experienced professional looking for opportunities');
  final _companyController = TextEditingController(text: 'Tech Solutions Ltd');
  final _websiteController = TextEditingController(text: 'www.techsolutions.co.tz');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('profile')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
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
              
              // Profile Information
              _buildProfileInformation(),
              const SizedBox(height: 24),
              
              // Role-specific sections
              if (widget.userRole == 'job_provider') ...[
                _buildCompanyInformation(),
                const SizedBox(height: 24),
              ],
              
              // Settings Section
              _buildSettingsSection(),
              const SizedBox(height: 24),
              
              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          // Profile Picture
          Stack(
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
          const SizedBox(height: 16),
          Text(
            _nameController.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildProfileInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('personal_information'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.tr('please_enter_email');
            }
            if (!value.contains('@')) {
              return context.tr('please_enter_valid_email');
            }
            return null;
          },
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.tr('please_enter_location');
            }
            return null;
          },
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
    );
  }

  Widget _buildCompanyInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('company_information'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Company Name
        TextFormField(
          controller: _companyController,
          enabled: _isEditing,
          decoration: InputDecoration(
            labelText: context.tr('company_name'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.business_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.tr('please_enter_company_name');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Website
        TextFormField(
          controller: _websiteController,
          enabled: _isEditing,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: context.tr('website'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.language_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('settings'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Settings List
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(context.tr('notifications')),
                subtitle: Text(context.tr('manage_notifications')),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(context.tr('language')),
                subtitle: Text(context.tr('change_language')),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  LocalizationService.showLanguageDialog(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.security_outlined),
                title: Text(context.tr('privacy')),
                subtitle: Text(context.tr('privacy_settings')),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Privacy settings
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Logout functionality
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              context.tr('logout'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Delete account functionality
              _showDeleteAccountDialog();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              context.tr('delete_account'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('delete_account')),
          content: Text(context.tr('delete_account_confirmation')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Delete account logic
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(context.tr('delete')),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _companyController.dispose();
    _websiteController.dispose();
    super.dispose();
  }
} 
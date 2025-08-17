import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/job_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/models/job_model.dart';
import '../../../../core/widgets/image_upload_widget.dart';

class PostJobScreen extends StatefulWidget {
  final JobModel? jobToEdit;

  const PostJobScreen({super.key, this.jobToEdit});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _minPaymentController = TextEditingController();
  final _maxPaymentController = TextEditingController();
  final _requirementsController = TextEditingController();
  // Verification service removed temporarily
  final JobService _jobService = JobService();
  final LocationService _locationService = LocationService();
  bool _isVerified = false;

  String _selectedCategory = 'usafi';
  String _selectedSalaryType = 'per_job';
  String _selectedDuration = '1_hour';
  String _selectedWorkers = '1';
  String _contactPreference = 'in_app';
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));

  // Requirements list
  List<String> _requirements = [];

  bool _isLoading = false;
  bool _hasImage = false;
  bool _isEditMode = false;
  String? _jobImageUrl;
  File? _selectedImage; // Added for backward compatibility

  // Get categories, payment types, and durations from service
  late final List<Map<String, String>> _categories =
      _jobService.getJobCategories();
  late final List<Map<String, String>> _salaryTypes =
      _jobService.getPaymentTypes();
  late final List<Map<String, String>> _durations =
      _jobService.getDurationOptions();

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
    _initializeForm();

    // Add listener to title controller for real-time character count
    _titleController.addListener(() {
      setState(() {
        // This will trigger rebuild to update character count
      });
    });
  }

  void _initializeForm() {
    if (widget.jobToEdit != null) {
      _isEditMode = true;
      _populateFormWithJobData(widget.jobToEdit!);
    }
  }

  void _populateFormWithJobData(JobModel job) {
    // Populate text controllers
    _titleController.text = job.title;
    _descriptionController.text = job.description;
    _locationController.text = job.location;
    _minPaymentController.text = job.minPayment.toString();
    _maxPaymentController.text = job.maxPayment.toString();

    // Populate dropdowns
    _selectedCategory = job.category;
    _selectedSalaryType = job.paymentType.toString().split('.').last;
    _selectedDuration = job.duration;
    _selectedWorkers = job.workersNeeded.toString();
    _contactPreference = job.contactPreference.toString().split('.').last;

    // Populate dates
    _startDate = job.startDate;
    _startTime = job.startTime;
    _deadline = job.deadline;

    // Populate requirements
    if (job.requirements.isNotEmpty) {
      _requirements = job.requirements.split(',').map((e) => e.trim()).toList();
    }

    // Set image if exists
    if (job.imageUrl != null && job.imageUrl!.isNotEmpty) {
      _hasImage = true;
    }
  }

  Future<void> _checkVerificationStatus() async {
    // Mock verification check - temporarily disabled
    setState(() {
      _isVerified = false; // Default to false for now
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _minPaymentController.dispose();
    _maxPaymentController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final locationData =
          await _locationService.getCurrentLocationWithAddress();
      if (locationData != null) {
        setState(() {
          _locationController.text =
              locationData['address'] ??
              '${locationData['latitude']}, ${locationData['longitude']}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('location_updated_successfully')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.tr('failed_to_get_location')}: ${e.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Image picker methods removed - using ImageUploadWidget instead

  void _addRequirement() {
    if (_requirementsController.text.trim().isNotEmpty) {
      setState(() {
        _requirements.add(_requirementsController.text.trim());
        _requirementsController.clear();
      });
    }
  }

  void _removeRequirement(int index) {
    setState(() {
      _requirements.removeAt(index);
    });
  }



  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ThemeConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ThemeConstants.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222B45),
          ),
        ),
      ],
    );
  }

  String _getCategoryImage(String categoryValue) {
    // Map categories to sample images
    switch (categoryValue) {
      case 'usafi':
        return 'assets/images/image_2.jpg'; // Cleaning image
      case 'kufua':
        return 'assets/images/image_1.jpg'; // Transport image
      case 'kubeba':
        return 'assets/images/image_1.jpg'; // Transport image
      case 'kusafisha_gari':
        return 'assets/images/image_2.jpg'; // Cleaning image
      case 'kupika':
        return 'assets/images/image_3.jpg'; // Events image
      case 'kutunza_watoto':
        return 'assets/images/image_3.jpg'; // Events image
      case 'kujenga':
        return 'assets/images/image_1.jpg'; // Construction image
      case 'kilimo':
        return 'assets/images/image_2.jpg'; // Farming image
      default:
        return 'assets/images/image_1.jpg'; // Default image
    }
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate job data
      final minSalary = double.tryParse(_minPaymentController.text) ?? 0;
      final maxSalary = double.tryParse(_maxPaymentController.text) ?? 0;

      // Validate required fields
      if (_titleController.text.trim().isEmpty ||
          _descriptionController.text.trim().isEmpty ||
          _locationController.text.trim().isEmpty) {
        throw Exception('Please fill in all required fields correctly');
      }

      if (minSalary <= 0) {
        throw Exception('Minimum salary must be greater than 0');
      }

      if (maxSalary <= 0) {
        throw Exception('Maximum salary must be greater than 0');
      }

      if (maxSalary < minSalary) {
        throw Exception(
          'Maximum salary must be greater than or equal to minimum salary',
        );
      }

      if (_isEditMode && widget.jobToEdit != null) {
        // Update existing job
        await _jobService.updateJob(
          widget.jobToEdit!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          location: _locationController.text.trim(),
          minPayment: minSalary,
          maxPayment: maxSalary,
          paymentType: _selectedSalaryType,
          duration: _selectedDuration,
          workersNeeded: int.parse(_selectedWorkers),
          requirements:
              _requirements.isNotEmpty ? _requirements.join(', ') : '',
          contactPreference: _contactPreference,
          startDate: _startDate,
          startTime:
              '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
          deadline: _deadline,
          imageUrl: _hasImage ? _getCategoryImage(_selectedCategory) : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Job updated successfully! Salary range: ${_jobService.formatSalaryRange(minSalary, maxSalary)}',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Create new job
        await _jobService.createJob(
          providerId: 'provider_123', // TODO: Get actual provider ID
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          location: _locationController.text.trim(),
          minPayment: minSalary,
          maxPayment: maxSalary,
          paymentType: _selectedSalaryType,
          duration: _selectedDuration,
          workersNeeded: int.parse(_selectedWorkers),
          requirements:
              _requirements.isNotEmpty ? _requirements.join(', ') : '',
          contactPreference: _contactPreference,
          startDate: _startDate,
          startTime:
              '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
          deadline: _deadline,
          imageUrl: _hasImage ? _getCategoryImage(_selectedCategory) : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Job posted successfully! Salary range: ${_jobService.formatSalaryRange(minSalary, maxSalary)}',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${_isEditMode ? 'update' : 'post'} job: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          _isEditMode ? context.tr('edit_job') : context.tr('post_job'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: ThemeConstants.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Verification Warning
              if (!_isVerified)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.verified_user_outlined,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verification Required',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Verify your account to post jobs and attract more workers',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/id-verification');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Verify Now',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!_isVerified) const SizedBox(height: 24),

              // Welcome Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeConstants.primaryColor.withOpacity(0.1),
                      ThemeConstants.primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ThemeConstants.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ThemeConstants.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_circle_outline,
                        color: ThemeConstants.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditMode ? 'Edit Job' : 'Post a New Job',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ThemeConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isEditMode
                                ? 'Update the job details below'
                                : 'Fill in the details below to find the perfect worker. Set a salary range to allow negotiation.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Job Title Section
              _buildSectionHeader('Job Title', Icons.work_outline),
              const SizedBox(height: 12),
              Container(
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
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Kusafisha Office, Kubeba Mizigo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.work_outline,
                      color: ThemeConstants.primaryColor,
                    ),
                    counterText: '${_titleController.text.length}/50',
                    counterStyle: TextStyle(
                      color:
                          _titleController.text.length > 45
                              ? Colors.red
                              : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  maxLength: 50,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a job title';
                    }
                    if (value.length < 3) {
                      return 'Job title must be at least 3 characters';
                    }
                    if (value.length > 50) {
                      return 'Job title must be 50 characters or less';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Job Category Section
              _buildSectionHeader('Job Category', Icons.category_outlined),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                      'Select the type of work you need',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected =
                            _selectedCategory == category['value'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category['value']!;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? ThemeConstants.primaryColor.withOpacity(
                                        0.15,
                                      )
                                      : Colors.grey[50],
                              border: Border.all(
                                color:
                                    isSelected
                                        ? ThemeConstants.primaryColor
                                        : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? ThemeConstants.primaryColor
                                                .withOpacity(0.2)
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    category['icon'] ?? '📋',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Text(
                                    category['label'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 11,
                                      height: 1.2,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                      color:
                                          isSelected
                                              ? ThemeConstants.primaryColor
                                              : Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textHeightBehavior:
                                        const TextHeightBehavior(
                                          applyHeightToFirstAscent: false,
                                          applyHeightToLastDescent: false,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Job Description Section
              _buildSectionHeader(
                'Job Description',
                Icons.description_outlined,
              ),
              const SizedBox(height: 12),
              Container(
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
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText:
                        'Describe the work in detail...\n\n• What needs to be done?\n• Any specific requirements?\n• Location details?\n• Working conditions?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.description_outlined,
                      color: ThemeConstants.primaryColor,
                    ),
                  ),
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a job description';
                    }
                    if (value.length < 20) {
                      return 'Description should be at least 20 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Job Image (Optional)
              _buildSectionHeader('Job Image', Icons.image_outlined),
              const SizedBox(height: 12),
              Container(
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
                        Icon(Icons.image_outlined, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('job_image'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            context.tr('optional'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Image Preview or Placeholder
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ImageUploadWidget(
                        folder: 'job_images',
                        currentImageUrl: _jobImageUrl,
                        onImageUploaded: (imageUrl) {
                          setState(() {
                            _jobImageUrl = imageUrl;
                            _hasImage = true;
                          });
                        },
                        onImageDeleted: () {
                          setState(() {
                            _jobImageUrl = null;
                            _hasImage = false;
                          });
                        },
                        width: double.infinity,
                        height: 200,
                        label: context.tr('add_job_image'),
                        showDeleteButton: true,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('image_optional_desc'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Location
              _buildSectionHeader('Location', Icons.location_on_outlined),
              const SizedBox(height: 12),
              Container(
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
                child: TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: context.tr('job_location'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: ThemeConstants.primaryColor,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: _getCurrentLocation,
                    ),
                    hintText: context.tr('location_hint'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('please_enter_location');
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Date and Time Row
              _buildSectionHeader('Date & Time', Icons.calendar_today_outlined),
              const SizedBox(height: 12),
              Container(
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
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('start_date'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('start_time'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _startTime.format(context),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Duration
              _buildSectionHeader('Duration', Icons.schedule_outlined),
              const SizedBox(height: 12),
              Container(
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
                child: DropdownButtonFormField<String>(
                  value: _selectedDuration,
                  decoration: InputDecoration(
                    labelText: context.tr('job_duration'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.schedule_outlined,
                      color: ThemeConstants.primaryColor,
                    ),
                  ),
                  items:
                      _durations.map((duration) {
                        return DropdownMenuItem(
                          value: duration['value'],
                          child: Text(context.tr(duration['value'] ?? '')),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDuration = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Salary Section
              _buildSectionHeader('Salary Range', Icons.payment_outlined),
              const SizedBox(height: 12),
              Container(
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.payment_outlined,
                            color: ThemeConstants.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Salary Range (TZS)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Cash Only',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: TextFormField(
                        controller: _minPaymentController,
                        decoration: InputDecoration(
                          labelText: 'Minimum Salary',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.all(16),
                          suffixText: 'TZS',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter minimum salary';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter valid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _maxPaymentController,
                        decoration: InputDecoration(
                          labelText: 'Maximum Salary',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.all(16),
                          suffixText: 'TZS',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter maximum salary';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter valid amount';
                          }
                          final minSalary =
                              double.tryParse(_minPaymentController.text) ?? 0;
                          final maxSalary = double.tryParse(value) ?? 0;
                          if (maxSalary < minSalary) {
                            return 'Maximum must be greater than minimum';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Salary Type
              _buildSectionHeader('Salary Type', Icons.attach_money_outlined),
              const SizedBox(height: 12),
              Container(
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
                child: DropdownButtonFormField<String>(
                  value: _selectedSalaryType,
                  decoration: InputDecoration(
                    labelText: 'Salary Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.attach_money_outlined,
                      color: ThemeConstants.primaryColor,
                    ),
                  ),
                  items:
                      _salaryTypes.map((type) {
                        return DropdownMenuItem(
                          value: type['value'],
                          child: Text(type['label'] ?? ''),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSalaryType = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Number of Workers
              _buildSectionHeader('Workers', Icons.people_outlined),
              const SizedBox(height: 12),
              Container(
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
                child: DropdownButtonFormField<String>(
                  value: _selectedWorkers,
                  decoration: InputDecoration(
                    labelText: context.tr('workers_needed'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.people_outlined,
                      color: ThemeConstants.primaryColor,
                    ),
                  ),
                  items:
                      ['1', '2', '3', '4', '5+'].map((workers) {
                        return DropdownMenuItem(
                          value: workers,
                          child: Text('$workers ${context.tr('person')}'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWorkers = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Special Requirements (Optional)
              _buildSectionHeader(
                'Special Requirements',
                Icons.checklist_outlined,
              ),
              const SizedBox(height: 12),
              Container(
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _requirementsController,
                              decoration: InputDecoration(
                                labelText: 'Add Requirement',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.all(16),
                                hintText: 'Enter a requirement...',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _addRequirement,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeConstants.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: Text(context.tr('add')),
                          ),
                        ],
                      ),
                    ),
                    if (_requirements.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Requirements:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._requirements.asMap().entries.map((entry) {
                              final index = entry.key;
                              final requirement = entry.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '• $requirement',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed:
                                          () => _removeRequirement(index),
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                      ),
                                      iconSize: 20,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Contact Preference
              _buildSectionHeader(
                'Contact Preference',
                Icons.chat_bubble_outline,
              ),
              const SizedBox(height: 12),
              Container(
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
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Chat'),
                        subtitle: const Text('In-app messaging'),
                        value: 'in_app',
                        groupValue: _contactPreference,
                        onChanged: (value) {
                          setState(() {
                            _contactPreference = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Call'),
                        subtitle: const Text('Phone call'),
                        value: 'phone',
                        groupValue: _contactPreference,
                        onChanged: (value) {
                          setState(() {
                            _contactPreference = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          _isEditMode
                              ? context.tr('update_job')
                              : context.tr('post_job'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

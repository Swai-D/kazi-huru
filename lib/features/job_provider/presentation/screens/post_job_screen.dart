import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _paymentController = TextEditingController();
  final _requirementsController = TextEditingController();
  
  String _selectedCategory = 'usafi';
  String _selectedPaymentType = 'per_job';
  String _selectedDuration = '2_hours';
  String _selectedWorkers = '1';
  String _contactPreference = 'in_app';
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));
  
  bool _isLoading = false;

  // Simplified categories for non-professional jobs
  final List<Map<String, String>> _categories = [
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

  final List<Map<String, String>> _paymentTypes = [
    {'value': 'per_job', 'label': 'Malipo ya Kazi Moja'},
    {'value': 'per_hour', 'label': 'Malipo kwa Saa'},
    {'value': 'per_day', 'label': 'Malipo kwa Siku'},
  ];

  final List<Map<String, String>> _durations = [
    {'value': '1_hour', 'label': 'Saa 1'},
    {'value': '2_hours', 'label': 'Saa 2'},
    {'value': '4_hours', 'label': 'Saa 4'},
    {'value': '1_day', 'label': 'Siku 1'},
    {'value': '2_days', 'label': 'Siku 2'},
    {'value': '1_week', 'label': 'Wiki 1'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _paymentController.dispose();
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

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('job_posted_successfully')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('job_posting_failed')),
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
      appBar: AppBar(
        title: Text(context.tr('post_job')),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.work_outline,
                      color: ThemeConstants.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.tr('post_job_header'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Job Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: context.tr('job_title'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.work_outline),
                  hintText: context.tr('job_title_hint'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('please_enter_job_title');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Job Category (Grid)
              Text(
                context.tr('job_category'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category['value'];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['value']!;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? ThemeConstants.primaryColor.withOpacity(0.2)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected 
                              ? ThemeConstants.primaryColor
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category['icon']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                                                     Text(
                             context.tr(category['value'] ?? ''),
                             style: TextStyle(
                               fontSize: 12,
                               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                               color: isSelected ? ThemeConstants.primaryColor : Colors.black87,
                             ),
                             textAlign: TextAlign.center,
                           ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: context.tr('job_location'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: () {
                      // TODO: Get current location
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.tr('location_updated'))),
                      );
                    },
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
              const SizedBox(height: 16),

              // Date and Time Row
              Row(
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
                              style: const TextStyle(fontWeight: FontWeight.w600),
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
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Duration
              DropdownButtonFormField<String>(
                value: _selectedDuration,
                decoration: InputDecoration(
                  labelText: context.tr('job_duration'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.schedule_outlined),
                ),
                items: _durations.map((duration) {
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
              const SizedBox(height: 16),

              // Payment Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _paymentController,
                      decoration: InputDecoration(
                        labelText: context.tr('payment_amount'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.payment_outlined),
                        suffixText: 'TZS',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.tr('please_enter_payment');
                        }
                        if (int.tryParse(value) == null) {
                          return context.tr('please_enter_valid_amount');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPaymentType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _paymentTypes.map((type) {
                        return DropdownMenuItem(
                          value: type['value'],
                                                   child: Text(
                           context.tr(type['value'] ?? ''),
                           style: const TextStyle(fontSize: 12),
                         ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Number of Workers
              DropdownButtonFormField<String>(
                value: _selectedWorkers,
                decoration: InputDecoration(
                  labelText: context.tr('workers_needed'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.people_outlined),
                ),
                items: ['1', '2', '3', '4', '5+'].map((workers) {
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
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: context.tr('job_description'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description_outlined),
                  hintText: context.tr('description_hint'),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('please_enter_description');
                  }
                  if (value.length < 10) {
                    return context.tr('description_too_short');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Special Requirements (Optional)
              TextFormField(
                controller: _requirementsController,
                decoration: InputDecoration(
                  labelText: context.tr('special_requirements'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.checklist_outlined),
                  hintText: context.tr('requirements_hint'),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Contact Preference
              Text(
                context.tr('contact_preference'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(context.tr('in_app_chat')),
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
                      title: Text(context.tr('phone_call')),
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
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        context.tr('post_job'),
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
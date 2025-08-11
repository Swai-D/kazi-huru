import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/providers/auth_provider.dart';

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
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController(text: 'Dar es Salaam');
  final _bioController = TextEditingController(text: 'Experienced software developer with a passion for building scalable applications.');
  
  // Company information for job providers
  final _companyNameController = TextEditingController(text: 'Tech Solutions Ltd');
  final _companyWebsiteController = TextEditingController(text: 'www.techsolutions.co.tz');
  final _companyDescriptionController = TextEditingController(text: 'Leading technology company in Tanzania');

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
              
              // Job Seeker detailed profile sections (mirror of job giver view)
              if (widget.userRole == 'job_seeker') ...[
                _buildDoerAboutSection(context),
                const SizedBox(height: 16),
                _buildDoerSkillsSection(context),
                const SizedBox(height: 16),
                _buildDoerExperienceSection(context),
                const SizedBox(height: 16),
                _buildDoerRatesSection(context),
                const SizedBox(height: 16),
                _buildDoerAvailabilityLocationSection(context),
                const SizedBox(height: 16),
                _buildDoerStatsSection(context),
                const SizedBox(height: 24),
              ],
              
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

  // --- Job Doer mirrored sections ---
  Widget _buildDoerAboutSection(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final profile = auth.userProfile ?? {};
    final description = (profile['description'] ?? _bioController.text).toString();
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
              const Icon(Icons.info_outline, color: ThemeConstants.primaryColor),
              const SizedBox(width: 8),
              const Text('Kuhusu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit, color: ThemeConstants.primaryColor),
                  onPressed: () => _editBio(context, auth, initial: description),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description.isEmpty ? 'Ongeza maelezo kukuhusu...' : description,
            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDoerSkillsSection(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final profile = auth.userProfile ?? {};
    final skills = List<String>.from((profile['skills'] ?? const <String>[]) as List);
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
              const Icon(Icons.psychology, color: ThemeConstants.primaryColor),
              const SizedBox(width: 8),
              const Text('Ujuzi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit, color: ThemeConstants.primaryColor),
                  onPressed: () => _editSkills(context, auth, initial: skills),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (skills.isEmpty)
            Text('Ongeza ujuzi wako...', style: TextStyle(fontSize: 14, color: Colors.grey[600]))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ThemeConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: ThemeConstants.primaryColor.withOpacity(0.3)),
                        ),
                        child: Text(s, style: TextStyle(fontSize: 12, color: ThemeConstants.primaryColor, fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDoerExperienceSection(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final profile = auth.userProfile ?? {};
    final experience = (profile['experience'] ?? '').toString();
    final category = (profile['category'] ?? '').toString();
    final completed = (profile['completed_jobs'] ?? 0).toString();
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
              const Icon(Icons.work_outline, color: ThemeConstants.primaryColor),
              const SizedBox(width: 8),
              const Text('Uzoefu wa Kazi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit, color: ThemeConstants.primaryColor),
                  onPressed: () => _editExperience(context, auth, initialExperience: experience, initialCategory: category),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _experienceItem('Kazi Zilizokamilika', completed, Icons.check_circle_outline, Colors.green),
          const SizedBox(height: 8),
          _experienceItem('Miaka ya Uzoefu', experience.isEmpty ? '—' : experience, Icons.timer_outlined, Colors.blue),
          const SizedBox(height: 8),
          _experienceItem('Kategoria', category.isEmpty ? '—' : category, Icons.category_outlined, Colors.orange),
        ],
      ),
    );
  }

  Widget _experienceItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoerRatesSection(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final profile = auth.userProfile ?? {};
    final rate = profile['hourly_rate'];
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
      child: Row(
        children: [
          const Icon(Icons.attach_money, color: ThemeConstants.primaryColor),
          const SizedBox(width: 8),
          const Text('Bei ya Kazi (kwa saa): ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              rate == null ? 'Weka kiwango chako' : 'TZS $rate',
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: ThemeConstants.primaryColor),
              onPressed: () => _editRate(context, auth, initial: rate?.toString() ?? ''),
            ),
        ],
      ),
    );
  }

  Widget _buildDoerAvailabilityLocationSection(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final profile = auth.userProfile ?? {};
    final availability = (profile['availability'] ?? '').toString();
    final location = (profile['location'] ?? _locationController.text).toString();
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
              const Icon(Icons.place, color: ThemeConstants.primaryColor),
              const SizedBox(width: 8),
              const Text('Upatikanaji & Eneo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit, color: ThemeConstants.primaryColor),
                  onPressed: () => _editAvailabilityLocation(context, auth, initialAvailability: availability, initialLocation: location),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.access_time, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text('Upatikanaji: ${availability.isEmpty ? '—' : availability}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text('Eneo: ${location.isEmpty ? '—' : location}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          ]),
        ],
      ),
    );
  }

  Widget _buildDoerStatsSection(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final profile = auth.userProfile ?? {};
    final rating = (profile['rating'] ?? 0).toDouble();
    final completed = (profile['completed_jobs'] ?? 0).toString();
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
      child: Row(
        children: [
          const Icon(Icons.star_outline, color: Colors.amber),
          const SizedBox(width: 8),
          Text('$rating', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
          const SizedBox(width: 16),
          Text('(${completed} kazi)', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // --- Edit flows ---
  Future<void> _editBio(BuildContext context, AuthProvider auth, {required String initial}) async {
    final controller = TextEditingController(text: initial);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hariri Kuhusu (Bio)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Andika kuhusu wewe...'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Hifadhi'),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (saved == true) {
      await auth.updateUserProfile(additionalData: {'description': controller.text.trim()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bio imehifadhiwa')));
      }
    }
  }

  Future<void> _editSkills(BuildContext context, AuthProvider auth, {required List<String> initial}) async {
    final input = TextEditingController();
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final skills = List<String>.from(initial);
        return StatefulBuilder(builder: (ctx, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hariri Ujuzi', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map((s) => InputChip(
                            label: Text(s),
                            onDeleted: () => setState(() => skills.remove(s)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      decoration: const InputDecoration(hintText: 'Ongeza ujuzi', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final v = input.text.trim();
                      if (v.isNotEmpty && !skills.contains(v)) {
                        setState(() => skills.add(v));
                        input.clear();
                      }
                    },
                    child: const Icon(Icons.add),
                  ),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, skills),
                    child: const Text('Hifadhi'),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
    if (result != null) {
      await auth.updateUserProfile(additionalData: {'skills': result});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ujuzi umehifadhiwa')));
      }
    }
  }

  Future<void> _editExperience(BuildContext context, AuthProvider auth, {required String initialExperience, required String initialCategory}) async {
    final expController = TextEditingController(text: initialExperience);
    final catController = TextEditingController(text: initialCategory);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hariri Uzoefu', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: expController,
                decoration: const InputDecoration(labelText: 'Miaka ya Uzoefu (mf: 3 years)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: catController,
                decoration: const InputDecoration(labelText: 'Kategoria', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Hifadhi'),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (saved == true) {
      await auth.updateUserProfile(additionalData: {
        'experience': expController.text.trim(),
        'category': catController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uzoefu umehifadhiwa')));
      }
    }
  }

  Future<void> _editRate(BuildContext context, AuthProvider auth, {required String initial}) async {
    final controller = TextEditingController(text: initial);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hariri Bei kwa Saa (TZS)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Mf: 10000', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Hifadhi'),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (saved == true) {
      final value = int.tryParse(controller.text.trim());
      if (value != null && value >= 0) {
        await auth.updateUserProfile(additionalData: {'hourly_rate': value});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bei imehifadhiwa')));
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Weka namba sahihi')));
      }
    }
  }

  Future<void> _editAvailabilityLocation(BuildContext context, AuthProvider auth, {required String initialAvailability, required String initialLocation}) async {
    String availability = initialAvailability;
    final locController = TextEditingController(text: initialLocation);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(builder: (ctx, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hariri Upatikanaji & Eneo', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: availability.isEmpty ? null : availability,
                  items: const [
                    DropdownMenuItem(value: 'Available', child: Text('Available')),
                    DropdownMenuItem(value: 'Part-time', child: Text('Part-time')),
                    DropdownMenuItem(value: 'Full-time', child: Text('Full-time')),
                    DropdownMenuItem(value: 'On-call', child: Text('On-call')),
                  ],
                  onChanged: (v) => setState(() => availability = v ?? ''),
                  decoration: const InputDecoration(labelText: 'Upatikanaji', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locController,
                  decoration: const InputDecoration(labelText: 'Eneo (mji/eneo)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Hifadhi'),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
    if (saved == true) {
      await auth.updateUserProfile(additionalData: {
        'availability': availability,
        'location': locController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upatikanaji na eneo vimehifadhiwa')));
      }
    }
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
              CircleAvatar(
                radius: 50,
            backgroundColor: ThemeConstants.primaryColor,
            child: Text(
              _nameController.text.isNotEmpty ? _nameController.text[0] : '',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
          ),
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
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          if (widget.userRole == 'job_seeker') ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  title: context.tr('applied_jobs'),
                  value: '12',
                ),
                _StatItem(
                  title: context.tr('completed_jobs'),
                  value: '8',
                ),
                _StatItem(
                  title: context.tr('rating'),
                  value: '4.5',
                ),
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
                icon: const Icon(Icons.edit, color: ThemeConstants.primaryColor),
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
            child: _StatItem(
              title: context.tr('applied_jobs'),
              value: '12',
            ),
          ),
          Expanded(
            child: _StatItem(
              title: context.tr('completed_jobs'),
              value: '8',
            ),
          ),
          Expanded(
            child: _StatItem(
              title: context.tr('rating'),
              value: '4.5',
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
            child: _StatItem(
              title: context.tr('posted_jobs'),
              value: '8',
            ),
          ),
          Expanded(
            child: _StatItem(
              title: context.tr('active_jobs'),
              value: '5',
            ),
          ),
          Expanded(
            child: _StatItem(
              title: context.tr('applications'),
              value: '24',
            ),
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
                          SnackBar(content: Text('${context.tr('language_changed')} Swahili')),
                        );
                      },
                      selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
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
                          SnackBar(content: Text('${context.tr('language_changed')} English')),
                        );
                      },
                      selectedColor: ThemeConstants.primaryColor.withOpacity(0.2),
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
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({
    required this.title,
    required this.value,
  });

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
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
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
        Icon(
          icon,
          color: ThemeConstants.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
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
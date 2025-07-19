import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/localization_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String phoneNumber;
  final String password;
  final String name;

  const RoleSelectionScreen({
    super.key,
    required this.phoneNumber,
    required this.password,
    required this.name,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _completeRegistration() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('please_select_role')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate registration completion
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        // Navigate to appropriate dashboard based on role
        if (_selectedRole == 'job_provider') {
          Navigator.pushReplacementNamed(context, '/job_provider_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/job_seeker_dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('registration_failed')),
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
        title: Text(context.tr('select_role')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('choose_your_role'),
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('role_description'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Job Seeker Option
            _RoleCard(
              title: context.tr('job_seeker'),
              description: context.tr('job_seeker_description'),
              icon: Icons.work_outline,
              isSelected: _selectedRole == 'job_seeker',
              onTap: () {
                setState(() {
                  _selectedRole = 'job_seeker';
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Job Provider Option
            _RoleCard(
              title: context.tr('job_provider'),
              description: context.tr('job_provider_description'),
              icon: Icons.business_outlined,
              isSelected: _selectedRole == 'job_provider',
              onTap: () {
                setState(() {
                  _selectedRole = 'job_provider';
                });
              },
            ),
            
            const Spacer(),
            
            // Continue Button
            ElevatedButton(
              onPressed: _isLoading ? null : _completeRegistration,
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
                      context.tr('continue'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? ThemeConstants.primaryColor.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected 
                ? ThemeConstants.primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? ThemeConstants.primaryColor
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? ThemeConstants.primaryColor
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: ThemeConstants.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
} 
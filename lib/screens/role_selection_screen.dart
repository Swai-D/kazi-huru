import 'package:flutter/material.dart';
import '../core/constants/theme_constants.dart';
import '../services/auth_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String phoneNumber;
  final String password;
  final String name;

  const RoleSelectionScreen({
    Key? key,
    required this.phoneNumber,
    required this.password,
    required this.name,
  }) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedRole;

  Future<void> _registerWithRole(String role) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Registering user with role: $role');
      
      // Register user with selected role
      final userCredential = await _authService.registerUser(
        phoneNumber: widget.phoneNumber,
        password: widget.password,
        name: widget.name,
        role: role,
      );

      print('Registration result: ${userCredential.user?.uid}');

      if (userCredential.user == null) {
        throw Exception('Imeshindwa kusajili. Tafadhali jaribu tena');
      }

      // Navigate to appropriate dashboard based on role
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          role == 'job_provider' ? '/job_provider_dashboard' : '/job_seeker_dashboard',
          (route) => false,
        );
      }
    } catch (e) {
      print('Error in _registerWithRole: $e');
      setState(() {
        _errorMessage = e.toString();
      });
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
        title: const Text('Chagua Aina ya Akaunti'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Chagua aina ya akaunti unayotaka kutumia',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildRoleCard(
              title: 'Mtafuta Kazi',
              description: 'Unaweza kutafuta kazi na kufanya maombi ya kazi',
              icon: Icons.work_outline,
              role: 'job_seeker',
            ),
            const SizedBox(height: 16),
            _buildRoleCard(
              title: 'Mtoa Kazi',
              description: 'Unaweza kutangaza kazi na kuwafanyia kazi watu',
              icon: Icons.business,
              role: 'job_provider',
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required String role,
  }) {
    final isSelected = _selectedRole == role;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? ThemeConstants.primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: _isLoading ? null : () {
          setState(() {
            _selectedRole = role;
          });
          _registerWithRole(role);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: isSelected ? ThemeConstants.primaryColor : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? ThemeConstants.primaryColor : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              if (_isLoading && isSelected)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.primaryColor),
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
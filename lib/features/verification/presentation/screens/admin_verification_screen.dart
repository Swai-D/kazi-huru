import 'package:flutter/material.dart';
import '../../../../core/models/verification_model.dart';
import '../../../../core/services/localization_service.dart';

class AdminVerificationScreen extends StatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  State<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  // Verification service removed temporarily
  final _localizationService = LocalizationService();
  
  List<VerificationModel> _pendingVerifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingVerifications();
  }

  Future<void> _loadPendingVerifications() async {
    setState(() => _isLoading = true);
    
    // Mock pending verifications - temporarily disabled
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
    
    setState(() {
      _pendingVerifications = []; // Empty list for now
      _isLoading = false;
    });
  }

  Future<void> _verifyUser(VerificationModel verification) async {
    try {
      // Mock verification success - temporarily disabled
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      _showSnackBar('User verified successfully');
      _loadPendingVerifications(); // Reload list
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _rejectUser(VerificationModel verification) async {
    final reasonController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_localizationService.translate('reject_verification')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_localizationService.translate('reject_reason_required')),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: _localizationService.translate('enter_rejection_reason'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_localizationService.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(reasonController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(_localizationService.translate('reject')),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        const adminId = 'admin_123'; // Mock admin ID
        // Mock rejection success - temporarily disabled
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
        final success = true;
        
        if (success) {
          _showSnackBar('User rejected successfully');
          _loadPendingVerifications();
        } else {
          _showSnackBar('Failed to reject user');
        }
      } catch (e) {
        _showSnackBar('Error: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildVerificationCard(VerificationModel verification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    verification.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verification.fullName ?? 'Unknown',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'ID: ${verification.idNumber ?? 'N/A'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _localizationService.translate('pending'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Details
            _buildDetailRow(
              _localizationService.translate('user_id'),
              verification.userId,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              _localizationService.translate('submitted_date'),
              _formatDate(verification.submittedAt!),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _verifyUser(verification),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: Text(_localizationService.translate('approve')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectUser(verification),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: Text(_localizationService.translate('reject')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_localizationService.translate('admin_verification')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadPendingVerifications,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingVerifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _localizationService.translate('no_pending_verifications'),
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _localizationService.translate('no_pending_verifications_desc'),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPendingVerifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingVerifications.length,
                    itemBuilder: (context, index) {
                      return _buildVerificationCard(_pendingVerifications[index]);
                    },
                  ),
                ),
    );
  }
} 
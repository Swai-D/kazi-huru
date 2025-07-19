import 'package:flutter/material.dart';
import '../../../../core/services/verification_service.dart';
import '../../../../core/models/verification_model.dart';
import '../../../../core/services/localization_service.dart';

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() => _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  final _verificationService = VerificationService();
  final _localizationService = LocalizationService();
  
  VerificationModel? _verification;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    setState(() => _isLoading = true);
    
    // Mock user ID - in real app, get from auth service
    const userId = 'user_123';
    final verification = _verificationService.getVerificationStatus(userId);
    
    setState(() {
      _verification = verification;
      _isLoading = false;
    });
  }

  Widget _buildStatusCard() {
    if (_verification == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                _localizationService.translate('not_verified'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _localizationService.translate('not_verified_desc'),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/id-verification');
                },
                child: Text(_localizationService.translate('verify_now')),
              ),
            ],
          ),
        ),
      );
    }

    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;

    switch (_verification!.status) {
      case VerificationStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = _localizationService.translate('verification_pending');
        statusDescription = _localizationService.translate('verification_pending_desc');
        break;
      case VerificationStatus.verified:
        statusColor = Colors.green;
        statusIcon = Icons.verified;
        statusText = _localizationService.translate('verification_verified');
        statusDescription = _localizationService.translate('verification_verified_desc');
        break;
      case VerificationStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = _localizationService.translate('verification_rejected');
        statusDescription = _localizationService.translate('verification_rejected_desc');
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = _localizationService.translate('verification_unknown');
        statusDescription = _localizationService.translate('verification_unknown_desc');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              statusIcon,
              size: 48,
              color: statusColor,
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusDescription,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (_verification!.status == VerificationStatus.rejected && 
                _verification!.rejectionReason != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _localizationService.translate('rejection_reason'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _verification!.rejectionReason!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
            if (_verification!.status == VerificationStatus.rejected) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/id-verification');
                },
                child: Text(_localizationService.translate('resubmit_verification')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationDetails() {
    if (_verification == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _localizationService.translate('verification_details'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // ID Number
            if (_verification!.idNumber != null) ...[
              _buildDetailRow(
                _localizationService.translate('id_number'),
                _verification!.idNumber!,
              ),
              const SizedBox(height: 8),
            ],
            
            // Full Name
            if (_verification!.fullName != null) ...[
              _buildDetailRow(
                _localizationService.translate('full_name'),
                _verification!.fullName!,
              ),
              const SizedBox(height: 8),
            ],
            
            // Submitted Date
            if (_verification!.submittedAt != null) ...[
              _buildDetailRow(
                _localizationService.translate('submitted_date'),
                _formatDate(_verification!.submittedAt!),
              ),
              const SizedBox(height: 8),
            ],
            
            // Verified Date
            if (_verification!.verifiedAt != null) ...[
              _buildDetailRow(
                _localizationService.translate('verified_date'),
                _formatDate(_verification!.verifiedAt!),
              ),
              const SizedBox(height: 8),
            ],
            
            // Verified By
            if (_verification!.verifiedBy != null) ...[
              _buildDetailRow(
                _localizationService.translate('verified_by'),
                _verification!.verifiedBy!,
              ),
            ],
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
        title: Text(_localizationService.translate('verification_status')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadVerificationStatus,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 24),
                  _buildVerificationDetails(),
                ],
              ),
            ),
    );
  }
} 
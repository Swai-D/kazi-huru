import '../models/wallet_model.dart';
import 'wallet_service.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final WalletService _walletService = WalletService();

  // Simple event tracking (placeholder for Firebase)
  Future<void> trackEvent(String eventName, Map<String, dynamic> eventData) async {
    // TODO: Implement Firebase tracking later
    print('Analytics Event: $eventName - $eventData');
  }

  // Essential wallet tracking
  Future<void> trackWalletTopUp(double amount, String paymentMethod) async {
    await trackEvent('wallet_top_up', {
      'amount': amount,
      'paymentMethod': paymentMethod,
      'currency': 'TZS',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    print('Analytics: Wallet top-up of TZS ${amount.toStringAsFixed(0)} via $paymentMethod');
  }

  Future<void> trackWalletWithdrawal(double amount, String reason) async {
    await trackEvent('wallet_withdrawal', {
      'amount': amount,
      'reason': reason,
      'currency': 'TZS',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    print('Analytics: Wallet withdrawal of TZS ${amount.toStringAsFixed(0)} - $reason');
  }

  Future<void> trackApplicationFee(String jobId, double amount) async {
    await trackEvent('application_fee', {
      'jobId': jobId,
      'amount': amount,
      'currency': 'TZS',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    print('Analytics: Application fee of TZS ${amount.toStringAsFixed(0)} for job $jobId');
  }

  Future<void> trackJobApplication(String jobId, String jobTitle, String category) async {
    await trackEvent('job_application', {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'category': category,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    print('Analytics: Job application for "$jobTitle" (ID: $jobId)');
  }

  Future<void> trackJobPosting(String jobId, String category, double value, String location) async {
    await trackEvent('job_posting', {
      'jobId': jobId,
      'category': category,
      'value': value,
      'location': location,
      'currency': 'TZS',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    print('Analytics: Job posted - $category job worth TZS ${value.toStringAsFixed(0)} (ID: $jobId)');
  }

  Future<void> trackPaymentSuccess(String paymentMethod, double amount, String transactionId) async {
    await trackEvent('payment_success', {
      'paymentMethod': paymentMethod,
      'amount': amount,
      'transactionId': transactionId,
      'currency': 'TZS',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    print('Analytics: Payment successful - TZS ${amount.toStringAsFixed(0)} via $paymentMethod');
  }

  Future<void> trackPaymentFailure(String paymentMethod, double amount, String reason) async {
    await trackEvent('payment_failure', {
      'paymentMethod': paymentMethod,
      'amount': amount,
      'reason': reason,
      'currency': 'TZS',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    print('Analytics: Payment failed - TZS ${amount.toStringAsFixed(0)} via $paymentMethod. Reason: $reason');
  }

  // Simple wallet analytics summary
  Map<String, dynamic> getWalletAnalyticsSummary() {
    final wallet = _walletService.currentWallet;
    final transactions = wallet.transactions;
    
    double totalTopUps = 0;
    double totalWithdrawals = 0;
    double totalFees = 0;
    
         for (var transaction in transactions) {
       if (transaction.type == TransactionType.topUp) {
         totalTopUps += transaction.amount.abs();
       } else if (transaction.type == TransactionType.applicationFee) {
         totalFees += transaction.amount.abs();
       } else if (transaction.type == TransactionType.bonus) {
         totalWithdrawals += transaction.amount.abs();
  }
     }
     
     return {
       'currentBalance': wallet.balance,
       'totalTopUps': totalTopUps,
       'totalWithdrawals': totalWithdrawals,
       'totalFees': totalFees,
       'transactionCount': transactions.length,
       'lastTransaction': transactions.isNotEmpty ? transactions.last.timestamp : null,
     };
  }
} 
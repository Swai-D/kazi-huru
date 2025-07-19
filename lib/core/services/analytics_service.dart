import '../models/analytics_model.dart';
import '../models/wallet_model.dart';
import 'wallet_service.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final WalletService _walletService = WalletService();

  // Track real-time events (placeholder for Firebase)
  Future<void> trackEvent(String eventName, Map<String, dynamic> eventData) async {
    // TODO: Implement Firebase tracking later
    print('Analytics Event: $eventName - $eventData');
  }

  // Enhanced wallet tracking
  Future<void> trackWalletTopUp(double amount, String paymentMethod) async {
    await trackEvent('wallet_top_up', {
      'amount': amount,
      'paymentMethod': paymentMethod,
      'currency': 'TZS',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Update daily analytics
    await _updateDailyWalletAnalytics('topUp', amount);
    
    print('Analytics: Wallet top-up of TZS ${amount.toStringAsFixed(0)} via $paymentMethod');
  }

  Future<void> trackWalletWithdrawal(double amount, String reason) async {
    await trackEvent('wallet_withdrawal', {
      'amount': amount,
      'reason': reason,
      'currency': 'TZS',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    await _updateDailyWalletAnalytics('withdrawal', amount);
    
    print('Analytics: Wallet withdrawal of TZS ${amount.toStringAsFixed(0)} - $reason');
  }

  Future<void> trackApplicationFee(String jobId, double amount) async {
    await trackEvent('application_fee', {
      'jobId': jobId,
      'amount': amount,
      'currency': 'TZS',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    await _updateDailyWalletAnalytics('applicationFee', amount);
    await _updateDailyRevenueAnalytics('applicationFees', amount);
    
    print('Analytics: Application fee of TZS ${amount.toStringAsFixed(0)} for job $jobId');
  }

  Future<void> trackJobApplication(String jobId, String jobTitle, String category) async {
    await trackEvent('job_application', {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'category': category,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    await _updateDailyBusinessMetrics('applications', 1);
    
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
    
    await _updateDailyBusinessMetrics('jobPostings', 1);
    
    print('Analytics: Job posted - $category job worth TZS ${value.toStringAsFixed(0)} (ID: $jobId)');
  }

  Future<void> trackUserRegistration(String userId, String userType, String location) async {
    await trackEvent('user_registration', {
      'userId': userId,
      'userType': userType,
      'location': location,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    await _updateDailyUserMetrics('registrations', 1);
    
    print('Analytics: New user registration - $userType (ID: $userId)');
  }

  Future<void> trackPaymentSuccess(String paymentMethod, double amount, String transactionId) async {
    await trackEvent('payment_success', {
      'paymentMethod': paymentMethod,
      'amount': amount,
      'transactionId': transactionId,
      'currency': 'TZS',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    await _updateDailyRevenueAnalytics('payments', amount);
    
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

  Future<void> trackUserSession(String sessionId, int durationMinutes) async {
    await trackEvent('user_session', {
      'sessionId': sessionId,
      'durationMinutes': durationMinutes,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    await _updateDailyUserMetrics('sessions', 1);
    await _updateDailyUserMetrics('sessionDuration', durationMinutes);
    
    print('Analytics: User session - $durationMinutes minutes (ID: $sessionId)');
  }

  // Update daily analytics (placeholder for Firebase)
  Future<void> _updateDailyWalletAnalytics(String type, double amount) async {
    // TODO: Implement Firebase daily analytics later
    print('Daily Wallet Analytics: $type - $amount');
  }

  Future<void> _updateDailyRevenueAnalytics(String source, double amount) async {
    // TODO: Implement Firebase daily revenue analytics later
    print('Daily Revenue Analytics: $source - $amount');
  }

  Future<void> _updateDailyBusinessMetrics(String metric, int value) async {
    // TODO: Implement Firebase daily business metrics later
    print('Daily Business Metrics: $metric - $value');
  }

  Future<void> _updateDailyUserMetrics(String metric, int value) async {
    // TODO: Implement Firebase daily user metrics later
    print('Daily User Metrics: $metric - $value');
  }

  // Get real analytics (placeholder for Firebase)
  Future<AnalyticsModel> getRealAnalytics(String userId, DateTime startDate, DateTime endDate) async {
    // TODO: Implement Firebase analytics retrieval later
    print('Getting analytics for user: $userId from $startDate to $endDate');
    return generateMockAnalytics(userId);
  }

  Future<WalletAnalytics> _getRealWalletAnalytics(DateTime startDate, DateTime endDate) async {
    // TODO: Implement Firebase wallet analytics retrieval later
    print('Getting real wallet analytics from $startDate to $endDate');
    return _generateWalletAnalytics();
  }

  Future<RevenueAnalytics> _getRealRevenueAnalytics(DateTime startDate, DateTime endDate) async {
    // TODO: Implement Firebase revenue analytics retrieval later
    print('Getting real revenue analytics from $startDate to $endDate');
    return _generateRevenueAnalytics();
  }

  Future<UserBehaviorAnalytics> _getRealUserBehaviorAnalytics(DateTime startDate, DateTime endDate) async {
    // TODO: Implement Firebase user behavior analytics retrieval later
    print('Getting real user behavior analytics from $startDate to $endDate');
    return _generateUserBehaviorAnalytics();
  }

  Future<BusinessMetricsAnalytics> _getRealBusinessMetrics(DateTime startDate, DateTime endDate) async {
    // TODO: Implement Firebase business metrics retrieval later
    print('Getting real business metrics from $startDate to $endDate');
    return _generateBusinessMetricsAnalytics();
  }

  // Generate mock analytics data
  AnalyticsModel generateMockAnalytics(String userId) {
    return AnalyticsModel(
      userId: userId,
      date: DateTime.now(),
      walletAnalytics: _generateWalletAnalytics(),
      revenueAnalytics: _generateRevenueAnalytics(),
      userBehaviorAnalytics: _generateUserBehaviorAnalytics(),
      businessMetricsAnalytics: _generateBusinessMetricsAnalytics(),
    );
  }

  WalletAnalytics _generateWalletAnalytics() {
    final stats = _walletService.getTransactionStats();
    
    return WalletAnalytics(
      totalBalance: _walletService.currentBalance,
      totalTopUps: stats['totalTopUps'] ?? 0.0,
      totalApplicationFees: stats['totalApplicationFees'] ?? 0.0,
      totalBonuses: stats['totalBonuses'] ?? 0.0,
      totalTransactions: stats['totalTransactions'] ?? 0,
      topUpCount: _walletService.getTransactionsByType(TransactionType.topUp).length,
      applicationCount: _walletService.getTransactionsByType(TransactionType.applicationFee).length,
      bonusCount: _walletService.getTransactionsByType(TransactionType.bonus).length,
      transactionTrends: _generateTransactionTrends(),
      paymentMethodUsage: _generatePaymentMethodUsage(),
    );
  }

  RevenueAnalytics _generateRevenueAnalytics() {
    final stats = _walletService.getTransactionStats();
    final applicationFeeRevenue = stats['totalApplicationFees'] ?? 0.0;
    
    return RevenueAnalytics(
      totalRevenue: applicationFeeRevenue + 50000.0, // Mock total revenue
      applicationFeeRevenue: applicationFeeRevenue,
      commissionRevenue: 25000.0, // Mock commission revenue
      premiumRevenue: 15000.0, // Mock premium revenue
      monthlyRevenue: 45000.0, // Mock monthly revenue
      weeklyRevenue: 12000.0, // Mock weekly revenue
      dailyRevenue: 2500.0, // Mock daily revenue
      revenueTrends: _generateRevenueTrends(),
      revenueSources: _generateRevenueSources(),
    );
  }

  UserBehaviorAnalytics _generateUserBehaviorAnalytics() {
    return UserBehaviorAnalytics(
      totalUsers: 1250,
      activeUsers: 850,
      newUsers: 45,
      returningUsers: 805,
      averageSessionDuration: 12.5, // minutes
      totalSessions: 3200,
      userActivities: _generateUserActivities(),
      userSegments: _generateUserSegments(),
    );
  }

  BusinessMetricsAnalytics _generateBusinessMetricsAnalytics() {
    return BusinessMetricsAnalytics(
      totalJobs: 450,
      activeJobs: 180,
      completedJobs: 270,
      totalApplications: 1200,
      averageJobValue: 25000.0,
      completionRate: 60.0, // 60%
      applicationSuccessRate: 75.0, // 75%
      jobCategoryMetrics: _generateJobCategoryMetrics(),
      locationMetrics: _generateLocationMetrics(),
    );
  }

  List<TransactionTrend> _generateTransactionTrends() {
    final now = DateTime.now();
    return [
      TransactionTrend(
        date: now.subtract(const Duration(days: 6)),
        amount: 5000.0,
        type: 'topUp',
      ),
      TransactionTrend(
        date: now.subtract(const Duration(days: 5)),
        amount: -500.0,
        type: 'applicationFee',
      ),
      TransactionTrend(
        date: now.subtract(const Duration(days: 4)),
        amount: 1000.0,
        type: 'bonus',
      ),
      TransactionTrend(
        date: now.subtract(const Duration(days: 3)),
        amount: -500.0,
        type: 'applicationFee',
      ),
      TransactionTrend(
        date: now.subtract(const Duration(days: 2)),
        amount: 10000.0,
        type: 'topUp',
      ),
      TransactionTrend(
        date: now.subtract(const Duration(days: 1)),
        amount: -500.0,
        type: 'applicationFee',
      ),
      TransactionTrend(
        date: now,
        amount: 2000.0,
        type: 'topUp',
      ),
    ];
  }

  List<PaymentMethodUsage> _generatePaymentMethodUsage() {
    return [
      PaymentMethodUsage(
        method: 'M-Pesa',
        count: 45,
        totalAmount: 125000.0,
      ),
      PaymentMethodUsage(
        method: 'Tigo Pesa',
        count: 28,
        totalAmount: 75000.0,
      ),
      PaymentMethodUsage(
        method: 'Airtel Money',
        count: 15,
        totalAmount: 45000.0,
      ),
      PaymentMethodUsage(
        method: 'Bank Transfer',
        count: 8,
        totalAmount: 25000.0,
      ),
    ];
  }

  List<RevenueTrend> _generateRevenueTrends() {
    final now = DateTime.now();
    return [
      RevenueTrend(
        date: now.subtract(const Duration(days: 6)),
        amount: 2500.0,
        source: 'applicationFees',
      ),
      RevenueTrend(
        date: now.subtract(const Duration(days: 5)),
        amount: 3200.0,
        source: 'applicationFees',
      ),
      RevenueTrend(
        date: now.subtract(const Duration(days: 4)),
        amount: 1800.0,
        source: 'applicationFees',
      ),
      RevenueTrend(
        date: now.subtract(const Duration(days: 3)),
        amount: 4100.0,
        source: 'applicationFees',
      ),
      RevenueTrend(
        date: now.subtract(const Duration(days: 2)),
        amount: 2900.0,
        source: 'applicationFees',
      ),
      RevenueTrend(
        date: now.subtract(const Duration(days: 1)),
        amount: 3600.0,
        source: 'applicationFees',
      ),
      RevenueTrend(
        date: now,
        amount: 2800.0,
        source: 'applicationFees',
      ),
    ];
  }

  List<RevenueSource> _generateRevenueSources() {
    return [
      RevenueSource(
        source: 'Application Fees',
        amount: 45000.0,
        percentage: 60.0,
      ),
      RevenueSource(
        source: 'Commission',
        amount: 25000.0,
        percentage: 33.3,
      ),
      RevenueSource(
        source: 'Premium Features',
        amount: 5000.0,
        percentage: 6.7,
      ),
    ];
  }

  List<UserActivity> _generateUserActivities() {
    final now = DateTime.now();
    return [
      UserActivity(
        activity: 'Job Applications',
        count: 45,
        date: now.subtract(const Duration(days: 1)),
      ),
      UserActivity(
        activity: 'Wallet Top-ups',
        count: 12,
        date: now.subtract(const Duration(days: 1)),
      ),
      UserActivity(
        activity: 'Job Postings',
        count: 8,
        date: now.subtract(const Duration(days: 1)),
      ),
      UserActivity(
        activity: 'Profile Updates',
        count: 25,
        date: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  List<UserSegment> _generateUserSegments() {
    return [
      UserSegment(
        segment: 'Job Seekers',
        count: 850,
        percentage: 68.0,
      ),
      UserSegment(
        segment: 'Job Providers',
        count: 400,
        percentage: 32.0,
      ),
    ];
  }

  List<JobCategoryMetrics> _generateJobCategoryMetrics() {
    return [
      JobCategoryMetrics(
        category: 'Cleaning',
        jobCount: 120,
        applicationCount: 360,
        averageValue: 15000.0,
      ),
      JobCategoryMetrics(
        category: 'Moving',
        jobCount: 85,
        applicationCount: 255,
        averageValue: 25000.0,
      ),
      JobCategoryMetrics(
        category: 'Construction',
        jobCount: 65,
        applicationCount: 195,
        averageValue: 35000.0,
      ),
      JobCategoryMetrics(
        category: 'Gardening',
        jobCount: 45,
        applicationCount: 135,
        averageValue: 12000.0,
      ),
      JobCategoryMetrics(
        category: 'Other',
        jobCount: 135,
        applicationCount: 255,
        averageValue: 18000.0,
      ),
    ];
  }

  List<LocationMetrics> _generateLocationMetrics() {
    return [
      LocationMetrics(
        location: 'Dar es Salaam',
        jobCount: 280,
        userCount: 750,
        averageJobValue: 22000.0,
      ),
      LocationMetrics(
        location: 'Arusha',
        jobCount: 85,
        userCount: 220,
        averageJobValue: 18000.0,
      ),
      LocationMetrics(
        location: 'Mwanza',
        jobCount: 65,
        userCount: 180,
        averageJobValue: 16000.0,
      ),
      LocationMetrics(
        location: 'Dodoma',
        jobCount: 20,
        userCount: 100,
        averageJobValue: 15000.0,
      ),
    ];
  }

  // Get wallet analytics
  Future<WalletAnalytics> getWalletAnalytics() async {
    try {
      return await _getRealWalletAnalytics(
        DateTime.now().subtract(const Duration(days: 7)),
        DateTime.now(),
      );
    } catch (e) {
      print('Error getting wallet analytics: $e');
      return _generateWalletAnalytics();
    }
  }
} 
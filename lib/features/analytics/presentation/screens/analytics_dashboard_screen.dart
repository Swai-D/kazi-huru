import 'package:flutter/material.dart';
import '../../../../core/models/analytics_model.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/theme_constants.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  final AnalyticsService _analyticsService = AnalyticsService();
  AnalyticsModel? _analytics;
  bool _isLoading = true;
  String _selectedPeriod = '7d';
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final analytics = await _analyticsService.getRealAnalytics(
        'current_user',
        DateTime.now().subtract(const Duration(days: 7)),
        DateTime.now(),
      );
      
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading analytics: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('analytics_dashboard'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: ThemeConstants.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analytics == null
              ? const Center(child: Text('No analytics data available'))
              : Column(
                  children: [
                    _buildPeriodSelector(),
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildWalletTab(),
                          _buildRevenueTab(),
                          _buildUserBehaviorTab(),
                          _buildBusinessMetricsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'Period:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: '7d', child: Text('Last 7 days')),
                DropdownMenuItem(value: '30d', child: Text('Last 30 days')),
                DropdownMenuItem(value: '90d', child: Text('Last 90 days')),
                DropdownMenuItem(value: '1y', child: Text('Last year')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
                _loadAnalytics();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.grey[100],
      child: TabBar(
        controller: _tabController,
        labelColor: ThemeConstants.primaryColor,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: ThemeConstants.primaryColor,
        tabs: const [
          Tab(text: 'Wallet'),
          Tab(text: 'Revenue'),
          Tab(text: 'Users'),
          Tab(text: 'Business'),
        ],
      ),
    );
  }

  Widget _buildWalletTab() {
    final wallet = _analytics!.walletAnalytics;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricCard(
            'Total Balance',
            'TZS ${wallet.totalBalance.toStringAsFixed(0)}',
            Icons.account_balance_wallet,
            Colors.green,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Top-ups',
                  'TZS ${wallet.totalTopUps.toStringAsFixed(0)}',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Application Fees',
                  'TZS ${wallet.totalApplicationFees.toStringAsFixed(0)}',
                  Icons.receipt,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Transactions',
                  wallet.totalTransactions.toString(),
                  Icons.swap_horiz,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Bonuses',
                  'TZS ${wallet.totalBonuses.toStringAsFixed(0)}',
                  Icons.card_giftcard,
                  Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTransactionTrendsChart(wallet.transactionTrends),
          const SizedBox(height: 24),
          _buildPaymentMethodsChart(wallet.paymentMethodUsage),
        ],
      ),
    );
  }

  Widget _buildRevenueTab() {
    final revenue = _analytics!.revenueAnalytics;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricCard(
            'Total Revenue',
            'TZS ${revenue.totalRevenue.toStringAsFixed(0)}',
            Icons.attach_money,
            Colors.green,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Application Fees',
                  'TZS ${revenue.applicationFeeRevenue.toStringAsFixed(0)}',
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Commission',
                  'TZS ${revenue.commissionRevenue.toStringAsFixed(0)}',
                  Icons.percent,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Daily Revenue',
                  'TZS ${revenue.dailyRevenue.toStringAsFixed(0)}',
                  Icons.today,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Weekly Revenue',
                  'TZS ${revenue.weeklyRevenue.toStringAsFixed(0)}',
                  Icons.date_range,
                  Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildRevenueTrendsChart(revenue.revenueTrends),
          const SizedBox(height: 24),
          _buildRevenueSourcesChart(revenue.revenueSources),
        ],
      ),
    );
  }

  Widget _buildUserBehaviorTab() {
    final userBehavior = _analytics!.userBehaviorAnalytics;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricCard(
            'Total Users',
            userBehavior.totalUsers.toString(),
            Icons.people,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context.tr('active_users'),
                  userBehavior.activeUsers.toString(),
                  Icons.person,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'New Users',
                  userBehavior.newUsers.toString(),
                  Icons.person_add,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Avg Session',
                  '${userBehavior.averageSessionDuration.toStringAsFixed(1)} min',
                  Icons.timer,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  context.tr('total_sessions'),
                  userBehavior.totalSessions.toString(),
                  Icons.access_time,
                  Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildUserSegmentsChart(userBehavior.userSegments),
          const SizedBox(height: 24),
          _buildUserActivitiesChart(userBehavior.userActivities),
        ],
      ),
    );
  }

  Widget _buildBusinessMetricsTab() {
    final business = _analytics!.businessMetricsAnalytics;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricCard(
            'Total Jobs',
            business.totalJobs.toString(),
            Icons.work,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Active Jobs',
                  business.activeJobs.toString(),
                  Icons.work_outline,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Completed Jobs',
                  business.completedJobs.toString(),
                  Icons.task_alt,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Success Rate',
                  '${business.applicationSuccessRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Avg Job Value',
                  'TZS ${business.averageJobValue.toStringAsFixed(0)}',
                  Icons.attach_money,
                  Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildJobCategoryMetricsChart(business.jobCategoryMetrics),
          const SizedBox(height: 24),
          _buildLocationMetricsChart(business.locationMetrics),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
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
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTrendsChart(List<TransactionTrend> trends) {
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
          const Text(
            'Transaction Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trends.length,
              itemBuilder: (context, index) {
                final trend = trends[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 40,
                          decoration: BoxDecoration(
                            color: trend.type == 'topUp' ? Colors.green : 
                                   trend.type == 'applicationFee' ? Colors.red : Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              'TZS ${trend.amount.abs().toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${trend.date.day}/${trend.date.month}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsChart(List<PaymentMethodUsage> methods) {
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
          const Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...methods.map((method) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    method.method,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: method.totalAmount / methods.fold(0.0, (sum, m) => sum + m.totalAmount),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'TZS ${method.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRevenueTrendsChart(List<RevenueTrend> trends) {
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
          const Text(
            'Revenue Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trends.length,
              itemBuilder: (context, index) {
                final trend = trends[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              'TZS ${trend.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${trend.date.day}/${trend.date.month}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSourcesChart(List<RevenueSource> sources) {
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
          const Text(
            'Revenue Sources',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sources.map((source) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    source.source,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: source.percentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${source.percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildUserSegmentsChart(List<UserSegment> segments) {
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
          const Text(
            'User Segments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...segments.map((segment) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    segment.segment,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: segment.percentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${segment.percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildUserActivitiesChart(List<UserActivity> activities) {
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
          const Text(
            'User Activities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    activity.activity,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: activity.count / activities.fold(0, (sum, a) => sum + a.count),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  activity.count.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildJobCategoryMetricsChart(List<JobCategoryMetrics> categories) {
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
          const Text(
            'Job Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...categories.map((category) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    category.category,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: category.jobCount / categories.fold(0, (sum, c) => sum + c.jobCount),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${category.jobCount} jobs',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLocationMetricsChart(List<LocationMetrics> locations) {
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
          const Text(
            'Location Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...locations.map((location) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    location.location,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: location.jobCount / locations.fold(0, (sum, l) => sum + l.jobCount),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${location.jobCount} jobs',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
} 
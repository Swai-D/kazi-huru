import 'package:flutter/material.dart';
import '../../../../core/models/analytics_model.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/theme_constants.dart';

class AnalyticsSummaryWidget extends StatelessWidget {
  final AnalyticsModel analytics;
  final String title;
  final VoidCallback? onTap;

  const AnalyticsSummaryWidget({
    super.key,
    required this.analytics,
    this.title = 'Analytics Summary',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: ThemeConstants.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                                     Expanded(
                     child: _buildQuickMetric(
                       context.tr('revenue'),
                       'TZS ${analytics.revenueAnalytics.totalRevenue.toStringAsFixed(0)}',
                       Icons.attach_money,
                       Colors.green,
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: _buildQuickMetric(
                       context.tr('users'),
                       analytics.userBehaviorAnalytics.totalUsers.toString(),
                       Icons.people,
                       Colors.blue,
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                                     Expanded(
                     child: _buildQuickMetric(
                       context.tr('jobs'),
                       analytics.businessMetricsAnalytics.totalJobs.toString(),
                       Icons.work,
                       Colors.orange,
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: _buildQuickMetric(
                       context.tr('balance'),
                       'TZS ${analytics.walletAnalytics.totalBalance.toStringAsFixed(0)}',
                       Icons.account_balance_wallet,
                       Colors.purple,
                     ),
                   ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMetric(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class WalletAnalyticsWidget extends StatelessWidget {
  final WalletAnalytics walletAnalytics;
  final VoidCallback? onTap;

  const WalletAnalyticsWidget({
    super.key,
    required this.walletAnalytics,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: ThemeConstants.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Wallet Analytics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildWalletMetric(
                      'Balance',
                      'TZS ${walletAnalytics.totalBalance.toStringAsFixed(0)}',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildWalletMetric(
                      'Top-ups',
                      'TZS ${walletAnalytics.totalTopUps.toStringAsFixed(0)}',
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildWalletMetric(
                      'Fees',
                      'TZS ${walletAnalytics.totalApplicationFees.toStringAsFixed(0)}',
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildWalletMetric(
                      'Transactions',
                      walletAnalytics.totalTransactions.toString(),
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class RevenueAnalyticsWidget extends StatelessWidget {
  final RevenueAnalytics revenueAnalytics;
  final VoidCallback? onTap;

  const RevenueAnalyticsWidget({
    super.key,
    required this.revenueAnalytics,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    color: ThemeConstants.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Revenue Analytics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildRevenueMetric(
                      'Total Revenue',
                      'TZS ${revenueAnalytics.totalRevenue.toStringAsFixed(0)}',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRevenueMetric(
                      'Daily',
                      'TZS ${revenueAnalytics.dailyRevenue.toStringAsFixed(0)}',
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildRevenueMetric(
                      'Application Fees',
                      'TZS ${revenueAnalytics.applicationFeeRevenue.toStringAsFixed(0)}',
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRevenueMetric(
                      'Commission',
                      'TZS ${revenueAnalytics.commissionRevenue.toStringAsFixed(0)}',
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
} 
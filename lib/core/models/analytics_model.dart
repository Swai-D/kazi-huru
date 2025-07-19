class AnalyticsModel {
  final String userId;
  final DateTime date;
  final WalletAnalytics walletAnalytics;
  final RevenueAnalytics revenueAnalytics;
  final UserBehaviorAnalytics userBehaviorAnalytics;
  final BusinessMetricsAnalytics businessMetricsAnalytics;

  AnalyticsModel({
    required this.userId,
    required this.date,
    required this.walletAnalytics,
    required this.revenueAnalytics,
    required this.userBehaviorAnalytics,
    required this.businessMetricsAnalytics,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'walletAnalytics': walletAnalytics.toJson(),
      'revenueAnalytics': revenueAnalytics.toJson(),
      'userBehaviorAnalytics': userBehaviorAnalytics.toJson(),
      'businessMetricsAnalytics': businessMetricsAnalytics.toJson(),
    };
  }

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      walletAnalytics: WalletAnalytics.fromJson(json['walletAnalytics']),
      revenueAnalytics: RevenueAnalytics.fromJson(json['revenueAnalytics']),
      userBehaviorAnalytics: UserBehaviorAnalytics.fromJson(json['userBehaviorAnalytics']),
      businessMetricsAnalytics: BusinessMetricsAnalytics.fromJson(json['businessMetricsAnalytics']),
    );
  }
}

class WalletAnalytics {
  final double totalBalance;
  final double totalTopUps;
  final double totalApplicationFees;
  final double totalBonuses;
  final int totalTransactions;
  final int topUpCount;
  final int applicationCount;
  final int bonusCount;
  final List<TransactionTrend> transactionTrends;
  final List<PaymentMethodUsage> paymentMethodUsage;

  WalletAnalytics({
    required this.totalBalance,
    required this.totalTopUps,
    required this.totalApplicationFees,
    required this.totalBonuses,
    required this.totalTransactions,
    required this.topUpCount,
    required this.applicationCount,
    required this.bonusCount,
    required this.transactionTrends,
    required this.paymentMethodUsage,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalBalance': totalBalance,
      'totalTopUps': totalTopUps,
      'totalApplicationFees': totalApplicationFees,
      'totalBonuses': totalBonuses,
      'totalTransactions': totalTransactions,
      'topUpCount': topUpCount,
      'applicationCount': applicationCount,
      'bonusCount': bonusCount,
      'transactionTrends': transactionTrends.map((t) => t.toJson()).toList(),
      'paymentMethodUsage': paymentMethodUsage.map((p) => p.toJson()).toList(),
    };
  }

  factory WalletAnalytics.fromJson(Map<String, dynamic> json) {
    return WalletAnalytics(
      totalBalance: json['totalBalance']?.toDouble() ?? 0.0,
      totalTopUps: json['totalTopUps']?.toDouble() ?? 0.0,
      totalApplicationFees: json['totalApplicationFees']?.toDouble() ?? 0.0,
      totalBonuses: json['totalBonuses']?.toDouble() ?? 0.0,
      totalTransactions: json['totalTransactions'] ?? 0,
      topUpCount: json['topUpCount'] ?? 0,
      applicationCount: json['applicationCount'] ?? 0,
      bonusCount: json['bonusCount'] ?? 0,
      transactionTrends: (json['transactionTrends'] as List?)
          ?.map((t) => TransactionTrend.fromJson(t))
          .toList() ?? [],
      paymentMethodUsage: (json['paymentMethodUsage'] as List?)
          ?.map((p) => PaymentMethodUsage.fromJson(p))
          .toList() ?? [],
    );
  }
}

class RevenueAnalytics {
  final double totalRevenue;
  final double applicationFeeRevenue;
  final double commissionRevenue;
  final double premiumRevenue;
  final double monthlyRevenue;
  final double weeklyRevenue;
  final double dailyRevenue;
  final List<RevenueTrend> revenueTrends;
  final List<RevenueSource> revenueSources;

  RevenueAnalytics({
    required this.totalRevenue,
    required this.applicationFeeRevenue,
    required this.commissionRevenue,
    required this.premiumRevenue,
    required this.monthlyRevenue,
    required this.weeklyRevenue,
    required this.dailyRevenue,
    required this.revenueTrends,
    required this.revenueSources,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'applicationFeeRevenue': applicationFeeRevenue,
      'commissionRevenue': commissionRevenue,
      'premiumRevenue': premiumRevenue,
      'monthlyRevenue': monthlyRevenue,
      'weeklyRevenue': weeklyRevenue,
      'dailyRevenue': dailyRevenue,
      'revenueTrends': revenueTrends.map((r) => r.toJson()).toList(),
      'revenueSources': revenueSources.map((s) => s.toJson()).toList(),
    };
  }

  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) {
    return RevenueAnalytics(
      totalRevenue: json['totalRevenue']?.toDouble() ?? 0.0,
      applicationFeeRevenue: json['applicationFeeRevenue']?.toDouble() ?? 0.0,
      commissionRevenue: json['commissionRevenue']?.toDouble() ?? 0.0,
      premiumRevenue: json['premiumRevenue']?.toDouble() ?? 0.0,
      monthlyRevenue: json['monthlyRevenue']?.toDouble() ?? 0.0,
      weeklyRevenue: json['weeklyRevenue']?.toDouble() ?? 0.0,
      dailyRevenue: json['dailyRevenue']?.toDouble() ?? 0.0,
      revenueTrends: (json['revenueTrends'] as List?)
          ?.map((r) => RevenueTrend.fromJson(r))
          .toList() ?? [],
      revenueSources: (json['revenueSources'] as List?)
          ?.map((s) => RevenueSource.fromJson(s))
          .toList() ?? [],
    );
  }
}

class UserBehaviorAnalytics {
  final int totalUsers;
  final int activeUsers;
  final int newUsers;
  final int returningUsers;
  final double averageSessionDuration;
  final int totalSessions;
  final List<UserActivity> userActivities;
  final List<UserSegment> userSegments;

  UserBehaviorAnalytics({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsers,
    required this.returningUsers,
    required this.averageSessionDuration,
    required this.totalSessions,
    required this.userActivities,
    required this.userSegments,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'newUsers': newUsers,
      'returningUsers': returningUsers,
      'averageSessionDuration': averageSessionDuration,
      'totalSessions': totalSessions,
      'userActivities': userActivities.map((a) => a.toJson()).toList(),
      'userSegments': userSegments.map((s) => s.toJson()).toList(),
    };
  }

  factory UserBehaviorAnalytics.fromJson(Map<String, dynamic> json) {
    return UserBehaviorAnalytics(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      newUsers: json['newUsers'] ?? 0,
      returningUsers: json['returningUsers'] ?? 0,
      averageSessionDuration: json['averageSessionDuration']?.toDouble() ?? 0.0,
      totalSessions: json['totalSessions'] ?? 0,
      userActivities: (json['userActivities'] as List?)
          ?.map((a) => UserActivity.fromJson(a))
          .toList() ?? [],
      userSegments: (json['userSegments'] as List?)
          ?.map((s) => UserSegment.fromJson(s))
          .toList() ?? [],
    );
  }
}

class BusinessMetricsAnalytics {
  final int totalJobs;
  final int activeJobs;
  final int completedJobs;
  final int totalApplications;
  final double averageJobValue;
  final double completionRate;
  final double applicationSuccessRate;
  final List<JobCategoryMetrics> jobCategoryMetrics;
  final List<LocationMetrics> locationMetrics;

  BusinessMetricsAnalytics({
    required this.totalJobs,
    required this.activeJobs,
    required this.completedJobs,
    required this.totalApplications,
    required this.averageJobValue,
    required this.completionRate,
    required this.applicationSuccessRate,
    required this.jobCategoryMetrics,
    required this.locationMetrics,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalJobs': totalJobs,
      'activeJobs': activeJobs,
      'completedJobs': completedJobs,
      'totalApplications': totalApplications,
      'averageJobValue': averageJobValue,
      'completionRate': completionRate,
      'applicationSuccessRate': applicationSuccessRate,
      'jobCategoryMetrics': jobCategoryMetrics.map((j) => j.toJson()).toList(),
      'locationMetrics': locationMetrics.map((l) => l.toJson()).toList(),
    };
  }

  factory BusinessMetricsAnalytics.fromJson(Map<String, dynamic> json) {
    return BusinessMetricsAnalytics(
      totalJobs: json['totalJobs'] ?? 0,
      activeJobs: json['activeJobs'] ?? 0,
      completedJobs: json['completedJobs'] ?? 0,
      totalApplications: json['totalApplications'] ?? 0,
      averageJobValue: json['averageJobValue']?.toDouble() ?? 0.0,
      completionRate: json['completionRate']?.toDouble() ?? 0.0,
      applicationSuccessRate: json['applicationSuccessRate']?.toDouble() ?? 0.0,
      jobCategoryMetrics: (json['jobCategoryMetrics'] as List?)
          ?.map((j) => JobCategoryMetrics.fromJson(j))
          .toList() ?? [],
      locationMetrics: (json['locationMetrics'] as List?)
          ?.map((l) => LocationMetrics.fromJson(l))
          .toList() ?? [],
    );
  }
}

// Supporting Classes
class TransactionTrend {
  final DateTime date;
  final double amount;
  final String type;

  TransactionTrend({
    required this.date,
    required this.amount,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'type': type,
    };
  }

  factory TransactionTrend.fromJson(Map<String, dynamic> json) {
    return TransactionTrend(
      date: DateTime.parse(json['date']),
      amount: json['amount']?.toDouble() ?? 0.0,
      type: json['type'],
    );
  }
}

class PaymentMethodUsage {
  final String method;
  final int count;
  final double totalAmount;

  PaymentMethodUsage({
    required this.method,
    required this.count,
    required this.totalAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'count': count,
      'totalAmount': totalAmount,
    };
  }

  factory PaymentMethodUsage.fromJson(Map<String, dynamic> json) {
    return PaymentMethodUsage(
      method: json['method'],
      count: json['count'] ?? 0,
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
    );
  }
}

class RevenueTrend {
  final DateTime date;
  final double amount;
  final String source;

  RevenueTrend({
    required this.date,
    required this.amount,
    required this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'source': source,
    };
  }

  factory RevenueTrend.fromJson(Map<String, dynamic> json) {
    return RevenueTrend(
      date: DateTime.parse(json['date']),
      amount: json['amount']?.toDouble() ?? 0.0,
      source: json['source'],
    );
  }
}

class RevenueSource {
  final String source;
  final double amount;
  final double percentage;

  RevenueSource({
    required this.source,
    required this.amount,
    required this.percentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'amount': amount,
      'percentage': percentage,
    };
  }

  factory RevenueSource.fromJson(Map<String, dynamic> json) {
    return RevenueSource(
      source: json['source'],
      amount: json['amount']?.toDouble() ?? 0.0,
      percentage: json['percentage']?.toDouble() ?? 0.0,
    );
  }
}

class UserActivity {
  final String activity;
  final int count;
  final DateTime date;

  UserActivity({
    required this.activity,
    required this.count,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'activity': activity,
      'count': count,
      'date': date.toIso8601String(),
    };
  }

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      activity: json['activity'],
      count: json['count'] ?? 0,
      date: DateTime.parse(json['date']),
    );
  }
}

class UserSegment {
  final String segment;
  final int count;
  final double percentage;

  UserSegment({
    required this.segment,
    required this.count,
    required this.percentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'segment': segment,
      'count': count,
      'percentage': percentage,
    };
  }

  factory UserSegment.fromJson(Map<String, dynamic> json) {
    return UserSegment(
      segment: json['segment'],
      count: json['count'] ?? 0,
      percentage: json['percentage']?.toDouble() ?? 0.0,
    );
  }
}

class JobCategoryMetrics {
  final String category;
  final int jobCount;
  final int applicationCount;
  final double averageValue;

  JobCategoryMetrics({
    required this.category,
    required this.jobCount,
    required this.applicationCount,
    required this.averageValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'jobCount': jobCount,
      'applicationCount': applicationCount,
      'averageValue': averageValue,
    };
  }

  factory JobCategoryMetrics.fromJson(Map<String, dynamic> json) {
    return JobCategoryMetrics(
      category: json['category'],
      jobCount: json['jobCount'] ?? 0,
      applicationCount: json['applicationCount'] ?? 0,
      averageValue: json['averageValue']?.toDouble() ?? 0.0,
    );
  }
}

class LocationMetrics {
  final String location;
  final int jobCount;
  final int userCount;
  final double averageJobValue;

  LocationMetrics({
    required this.location,
    required this.jobCount,
    required this.userCount,
    required this.averageJobValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'jobCount': jobCount,
      'userCount': userCount,
      'averageJobValue': averageJobValue,
    };
  }

  factory LocationMetrics.fromJson(Map<String, dynamic> json) {
    return LocationMetrics(
      location: json['location'],
      jobCount: json['jobCount'] ?? 0,
      userCount: json['userCount'] ?? 0,
      averageJobValue: json['averageJobValue']?.toDouble() ?? 0.0,
    );
  }
} 
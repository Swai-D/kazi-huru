# Analytics Implementation for Kazi Huru

## Overview

The analytics system for Kazi Huru tracks wallet usage, revenue, user behavior, and business metrics to provide insights into app performance and user engagement.

## Features Implemented

### 1. Analytics Model (`lib/core/models/analytics_model.dart`)

Comprehensive data models for tracking:
- **Wallet Analytics**: Balance, top-ups, application fees, bonuses, transactions
- **Revenue Analytics**: Total revenue, application fees, commission, premium features
- **User Behavior Analytics**: User counts, sessions, activities, segments
- **Business Metrics Analytics**: Jobs, applications, completion rates, categories

### 2. Analytics Service (`lib/core/services/analytics_service.dart`)

Enhanced with Firebase integration for real-time tracking:

#### Real-time Event Tracking
- `trackWalletTopUp()` - Track wallet top-ups with payment method
- `trackWalletWithdrawal()` - Track wallet withdrawals
- `trackApplicationFee()` - Track job application fees
- `trackJobApplication()` - Track job applications
- `trackJobPosting()` - Track job postings
- `trackUserRegistration()` - Track new user registrations
- `trackPaymentSuccess()` - Track successful payments
- `trackPaymentFailure()` - Track failed payments
- `trackUserSession()` - Track user session duration

#### Daily Analytics Updates
- `_updateDailyWalletAnalytics()` - Update daily wallet metrics
- `_updateDailyRevenueAnalytics()` - Update daily revenue metrics
- `_updateDailyBusinessMetrics()` - Update daily business metrics
- `_updateDailyUserMetrics()` - Update daily user metrics

#### Analytics Retrieval
- `getRealAnalytics()` - Get analytics for specific time period
- `getWalletAnalytics()` - Get wallet-specific analytics
- `getRevenueAnalytics()` - Get revenue analytics
- `getBusinessMetrics()` - Get business metrics
- `getUserBehaviorAnalytics()` - Get user behavior analytics

### 3. Analytics Dashboard (`lib/features/analytics/presentation/screens/analytics_dashboard_screen.dart`)

Comprehensive dashboard with:
- **Period Selector**: Choose time periods (7d, 30d, 90d, 1y)
- **Tabbed Interface**: Wallet, Revenue, Users, Business metrics
- **Interactive Charts**: Transaction trends, payment methods, revenue sources
- **Metric Cards**: Key performance indicators with visual indicators

### 4. Analytics Widgets (`lib/features/analytics/presentation/widgets/analytics_summary_widget.dart`)

Reusable widgets for displaying analytics:
- `AnalyticsSummaryWidget` - Quick overview of key metrics
- `WalletAnalyticsWidget` - Wallet-specific analytics
- `RevenueAnalyticsWidget` - Revenue-specific analytics

### 5. Wallet Integration

Enhanced wallet screen with analytics tracking:
- Real-time tracking of wallet operations
- Analytics summary widget integration
- Navigation to detailed analytics dashboard

## Firebase Integration

### Collections Structure
```
analytics/
├── wallet_analytics/
│   └── daily/
│       └── YYYY-MM-DD
├── revenue_analytics/
│   └── daily/
│       └── YYYY-MM-DD
├── business_metrics/
│   └── daily/
│       └── YYYY-MM-DD
├── user_metrics/
│   └── daily/
│       └── YYYY-MM-DD
└── analytics_events/
    └── event_documents
```

### Event Tracking
Each event includes:
- User ID
- Event name
- Event data
- Timestamp
- Platform (mobile)
- App version

## Usage Examples

### Tracking Wallet Top-up
```dart
final analyticsService = AnalyticsService();
await analyticsService.trackWalletTopUp(50000.0, 'M-Pesa');
```

### Tracking Job Application
```dart
await analyticsService.trackJobApplication(
  'job_123',
  'House Cleaning',
  'Cleaning'
);
```

### Getting Analytics
```dart
final analytics = await analyticsService.getRealAnalytics(
  'user_id',
  DateTime.now().subtract(Duration(days: 7)),
  DateTime.now(),
);
```

### Displaying Analytics Widget
```dart
WalletAnalyticsWidget(
  walletAnalytics: walletAnalytics,
  onTap: () => Navigator.pushNamed(context, '/analytics-dashboard'),
)
```

## Key Metrics Tracked

### Wallet Metrics
- Total balance
- Top-up amounts and frequency
- Application fees
- Transaction counts
- Payment method usage

### Revenue Metrics
- Total revenue
- Application fee revenue
- Commission revenue
- Premium feature revenue
- Daily/weekly/monthly trends

### User Behavior Metrics
- Total users
- Active users
- New vs returning users
- Session duration
- User activities

### Business Metrics
- Total jobs posted
- Active vs completed jobs
- Application success rates
- Job categories performance
- Location-based metrics

## Benefits

1. **Business Intelligence**: Understand revenue patterns and user behavior
2. **Performance Monitoring**: Track app usage and engagement
3. **Decision Making**: Data-driven insights for business decisions
4. **User Experience**: Identify areas for improvement
5. **Revenue Optimization**: Track payment methods and fee structures

## Future Enhancements

1. **Advanced Charts**: Implement more sophisticated charting libraries
2. **Real-time Updates**: WebSocket integration for live updates
3. **Export Features**: PDF/Excel export capabilities
4. **Custom Dashboards**: User-configurable dashboard layouts
5. **Predictive Analytics**: Machine learning for trend prediction
6. **A/B Testing**: Analytics for feature testing
7. **Push Notifications**: Analytics-driven user engagement

## Dependencies Added

```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.3
cloud_firestore: ^5.5.0
firebase_storage: ^12.3.3
firebase_messaging: ^15.1.3
```

## Setup Requirements

1. Firebase project configured
2. Google Services files added to Android/iOS
3. Firebase initialization in main.dart
4. Proper security rules for Firestore collections

## Security Considerations

- User authentication required for analytics access
- Data privacy compliance (GDPR, etc.)
- Secure API keys and configuration
- Regular data backup and retention policies 
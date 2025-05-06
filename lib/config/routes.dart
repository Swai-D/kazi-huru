import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/job_seeker/presentation/screens/job_seeker_dashboard_screen.dart';
import '../features/job_provider/presentation/screens/job_provider_dashboard_screen.dart';
import '../features/job_seeker/presentation/screens/job_details_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String jobSeekerDashboard = '/job-seeker-dashboard';
  static const String jobProviderDashboard = '/job-provider-dashboard';
  static const String jobDetails = '/job-details';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String chat = '/chat';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case jobSeekerDashboard:
        return MaterialPageRoute(builder: (_) => const JobSeekerDashboardScreen());
      case jobProviderDashboard:
        return MaterialPageRoute(builder: (_) => const JobProviderDashboardScreen());
      case jobDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => JobDetailsScreen(jobId: args['jobId']),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case chat:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(userId: args['userId']),
        );
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
} 
import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_page.dart';
import '../screens/register_page.dart';
import '../screens/job_seeker/job_seeker_dashboard.dart';
import '../screens/job_provider/job_provider_dashboard.dart';
import '../screens/job_details_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/notifications_screen.dart';

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
        return MaterialPageRoute(builder: (_) => const JobSeekerDashboard());
      case jobProviderDashboard:
        return MaterialPageRoute(builder: (_) => const JobProviderDashboard());
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
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'features/job_seeker/presentation/screens/job_seeker_dashboard_screen.dart';
import 'features/auth/presentation/screens/login_page.dart';
import 'features/auth/presentation/screens/register_page.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'core/widgets/auth_wrapper.dart';

import 'features/job_provider/presentation/screens/job_provider_dashboard_screen.dart';
import 'features/job_provider/presentation/screens/post_job_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/notifications/presentation/screens/notification_settings_screen.dart';
import 'features/notifications/presentation/screens/notification_permission_screen.dart';
import 'features/notifications/presentation/screens/notification_test_screen.dart';
import 'features/notifications/presentation/screens/notification_detail_screen.dart';
import 'features/chat/presentation/screens/chat_list_screen.dart';
import 'features/auth/presentation/screens/user_profile_screen.dart';
import 'features/job_seeker/presentation/screens/job_search_screen.dart';
import 'features/job_provider/presentation/screens/company_profile_screen.dart';
import 'features/wallet/presentation/screens/wallet_screen.dart';
import 'features/auth/presentation/screens/role_selection_screen.dart';
import 'features/verification/presentation/screens/id_verification_screen.dart';
import 'features/verification/presentation/screens/verification_status_screen.dart';
import 'features/verification/presentation/screens/admin_verification_screen.dart';
import 'features/job_seeker/presentation/screens/applied_jobs_screen.dart';
import 'features/job_seeker/presentation/screens/completed_jobs_screen.dart';
import 'features/job_provider/presentation/screens/posted_jobs_screen.dart';
import 'features/job_provider/presentation/screens/applications_received_screen.dart';
import 'features/auth/presentation/screens/firebase_test_screen.dart';
import 'features/auth/presentation/screens/auth_test_screen.dart';

import 'core/services/localization_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/firestore_notification_service.dart';

import 'core/constants/theme_constants.dart';
import 'core/providers/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Global navigation key for notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize services
  await LocalizationService().loadTranslations();
  
  // Initialize notification services
  await NotificationService().initialize();
  await PushNotificationService().initialize();
  await FirestoreNotificationService().initialize();
  
  print('🚀 Kazi Huru app starting...');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => FirestoreNotificationService()),
      ],
      child: const KaziHuruApp(),
    ),
  );
}

class KaziHuruApp extends StatefulWidget {
  const KaziHuruApp({super.key});

  @override
  State<KaziHuruApp> createState() => _KaziHuruAppState();
}

class _KaziHuruAppState extends State<KaziHuruApp> {
  @override
  void initState() {
    super.initState();
    // Set up language change callback
    LocalizationService().setLanguageChangedCallback(() {
      setState(() {
        // Rebuild the app when language changes
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kazi Huru',
      navigatorKey: navigatorKey, // Add global navigation key
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: ThemeConstants.primaryColor,
        scaffoldBackgroundColor: ThemeConstants.scaffoldBackgroundColor,
        cardColor: ThemeConstants.cardBackgroundColor,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeConstants.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: ThemeConstants.primaryColor,
            side: const BorderSide(color: ThemeConstants.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      
      // Localization support
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService().supportedLocales,
      locale: LocalizationService().currentLocale,
      
      // Routes
      routes: {
        '/': (context) => const AuthWrapper(), // Main app route - handles authentication routing
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const JobSeekerDashboardScreen(),
        '/job_seeker_dashboard': (context) => const JobSeekerDashboardScreen(),
        '/job_provider_dashboard': (context) => const JobProviderDashboardScreen(), // Job provider dashboard
        '/post_job': (context) => const PostJobScreen(), // Post job screen
        '/role_selection': (context) => const RoleSelectionScreen(
          phoneNumber: 'demo@example.com',
          password: 'password',
          name: 'Demo User',
        ), // Role selection screen
        '/notifications': (context) => const NotificationsScreen(), // Notifications
        '/notification-settings': (context) => const NotificationSettingsScreen(), // Notification settings
        '/notification-permission': (context) => const NotificationPermissionScreen(), // Notification permission
        '/notification-test': (context) => const NotificationTestScreen(), // Notification test
        '/notification-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final notificationId = args?['notificationId'] ?? '';
          return NotificationDetailScreen(notificationId: notificationId);
        }, // Notification detail
        '/chat': (context) => const ChatListScreen(), // Chat
        '/profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final userRole = args?['userRole'] ?? 'job_seeker';
          return UserProfileScreen(userRole: userRole);
        }, // User profile
        '/job_search': (context) => const JobSearchScreen(), // Job search
                          '/company_profile': (context) => const CompanyProfileScreen(), // Company profile
                  '/wallet': (context) => const WalletScreen(), // Wallet screen
        '/id-verification': (context) => const IdVerificationScreen(), // ID verification
        '/verification-status': (context) => const VerificationStatusScreen(), // Verification status
        '/admin-verification': (context) => const AdminVerificationScreen(), // Admin verification
        '/applied_jobs': (context) => const AppliedJobsScreen(), // Applied jobs list
        '/completed_jobs': (context) => const CompletedJobsScreen(), // Completed jobs list
        '/posted_jobs': (context) => const PostedJobsScreen(), // Posted jobs list
        '/applications_received': (context) => const ApplicationsReceivedScreen(), // Applications received list
        '/payment_details': (context) => const WalletScreen(), // Payment details (redirect to wallet)
        '/job_application_details': (context) => const JobSeekerDashboardScreen(), // Job application details (redirect to dashboard)
        '/firebase_test': (context) => const FirebaseTestScreen(), // Firebase test screen
        '/auth_test': (context) => const AuthTestScreen(), // Auth test screen
      },
    );
  }
}

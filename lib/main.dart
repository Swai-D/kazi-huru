import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/job_seeker/presentation/screens/job_seeker_dashboard_screen.dart';
import 'features/auth/presentation/screens/login_page.dart';
import 'features/auth/presentation/screens/register_page.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

import 'features/job_provider/presentation/screens/job_provider_dashboard_screen.dart';
import 'features/job_provider/presentation/screens/post_job_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/chat/presentation/screens/chat_list_screen.dart';
import 'features/auth/presentation/screens/user_profile_screen.dart';
import 'features/job_seeker/presentation/screens/job_search_screen.dart';
import 'features/job_provider/presentation/screens/company_profile_screen.dart';
import 'features/wallet/presentation/screens/wallet_screen.dart';
import 'features/auth/presentation/screens/role_selection_screen.dart';
import 'features/verification/presentation/screens/id_verification_screen.dart';
import 'features/verification/presentation/screens/verification_status_screen.dart';
import 'features/verification/presentation/screens/admin_verification_screen.dart';

import 'core/services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize localization service
  await LocalizationService().loadTranslations();
  
  runApp(const KaziHuruApp());
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Start with splash screen
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
        '/chat': (context) => const ChatListScreen(), // Chat
        '/profile': (context) => const UserProfileScreen(userRole: 'job_seeker'), // User profile
        '/job_search': (context) => const JobSearchScreen(), // Job search
                          '/company_profile': (context) => const CompanyProfileScreen(), // Company profile
                  '/wallet': (context) => const WalletScreen(), // Wallet screen
        '/id-verification': (context) => const IdVerificationScreen(), // ID verification
        '/verification-status': (context) => const VerificationStatusScreen(), // Verification status
        '/admin-verification': (context) => const AdminVerificationScreen(), // Admin verification

      },
    );
  }
}

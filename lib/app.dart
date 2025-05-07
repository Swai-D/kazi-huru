import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/job_seeker/job_seeker_dashboard.dart';
import 'screens/splash_screen.dart';
import 'screens/login_page.dart';
import 'screens/phone_login_page.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/job_provider/job_provider_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const KaziHuruApp());
}

class KaziHuruApp extends StatelessWidget {
  const KaziHuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kazi Huru',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/phone_login': (context) => const PhoneLoginPage(),
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/job_seeker_dashboard': (context) => const JobSeekerDashboard(),
        '/job_provider_dashboard': (context) => const JobProviderDashboard(),
      },
      
      // Add localization support
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('sw'), // Swahili
      ],
      onGenerateRoute: (settings) {
        if (settings.name == '/otp_verification') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              phoneNumber: args['phoneNumber'] as String,
            ),
          );
        }
        return null;
      },
    );
  }
} 
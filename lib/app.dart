import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
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
    return GetMaterialApp(
      title: 'Kazi Huru',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: true,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/phone_login', page: () => PhoneLoginPage(
          email: '',
          password: '',
        )),
        GetPage(name: '/role_selection', page: () => const RoleSelectionScreen()),
        GetPage(name: '/job_seeker_dashboard', page: () => const JobSeekerDashboard()),
        GetPage(name: '/job_provider_dashboard', page: () => const JobProviderDashboard()),
      ],
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
              otp: args['otp'] as String,
              email: args['email'] as String,
              password: args['password'] as String,
            ),
          );
        }
        return null;
      },
    );
  }
} 
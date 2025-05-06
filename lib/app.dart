import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/routes.dart';
import 'config/theme.dart';

class KaziHuruApp extends StatelessWidget {
  const KaziHuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kazi Huru',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: AppRoutes.jobSeekerDashboard,
    );
  }
} 
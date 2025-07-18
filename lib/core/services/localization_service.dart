import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Map<String, dynamic> _translations = {};
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  Future<void> loadTranslations() async {
    // Load English translations
    final enJson = await rootBundle.loadString('assets/translations/en.json');
    final enTranslations = json.decode(enJson) as Map<String, dynamic>;
    
    // Load Swahili translations
    final swJson = await rootBundle.loadString('assets/translations/sw.json');
    final swTranslations = json.decode(swJson) as Map<String, dynamic>;
    
    _translations = {
      'en': enTranslations,
      'sw': swTranslations,
    };
  }

  String translate(String key, [Map<String, String>? args]) {
    final locale = _currentLocale.languageCode;
    final translations = _translations[locale] ?? _translations['en'];
    
    String translation = translations[key] ?? key;
    
    if (args != null) {
      args.forEach((key, value) {
        translation = translation.replaceAll('{$key}', value);
      });
    }
    
    return translation;
  }

  void setLocale(Locale locale) {
    _currentLocale = locale;
  }

  List<Locale> get supportedLocales => [
    const Locale('en'),
    const Locale('sw'),
  ];
}

// Extension for easy translation access
extension LocalizationExtension on BuildContext {
  String tr(String key, [Map<String, String>? args]) {
    return LocalizationService().translate(key, args);
  }
} 
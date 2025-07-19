import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Map<String, dynamic> _translations = {};
  Locale _currentLocale = const Locale('sw');
  
  // Callback for language changes
  VoidCallback? _onLanguageChanged;

  Locale get currentLocale => _currentLocale;

  // Register callback for language changes
  void setLanguageChangedCallback(VoidCallback callback) {
    _onLanguageChanged = callback;
  }

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
    final translations = _translations[locale] ?? _translations['sw'];
    
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
    // Notify listeners about language change
    _onLanguageChanged?.call();
  }

  List<Locale> get supportedLocales => [
    const Locale('sw'),
    const Locale('en'),
  ];

  // Show language selection dialog
  static Future<void> showLanguageDialog(BuildContext context) async {
    final localizationService = LocalizationService();
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizationService.translate('select_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Kiswahili'),
                subtitle: const Text('Swahili'),
                trailing: localizationService.currentLocale.languageCode == 'sw' 
                  ? const Icon(Icons.check, color: Colors.green) 
                  : null,
                onTap: () {
                  localizationService.setLocale(const Locale('sw'));
                  Navigator.pop(context);
                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizationService.translate('language_changed')),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('English'),
                subtitle: const Text('English'),
                trailing: localizationService.currentLocale.languageCode == 'en' 
                  ? const Icon(Icons.check, color: Colors.green) 
                  : null,
                onTap: () {
                  localizationService.setLocale(const Locale('en'));
                  Navigator.pop(context);
                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizationService.translate('language_changed')),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizationService.translate('cancel')),
            ),
          ],
        );
      },
    );
  }
}

// Extension for easy translation access
extension LocalizationExtension on BuildContext {
  String tr(String key, [Map<String, String>? args]) {
    return LocalizationService().translate(key, args);
  }
} 
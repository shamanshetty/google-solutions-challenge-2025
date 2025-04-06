import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  // Default locale
  Locale _currentLocale = const Locale('en', '');
  Map<String, dynamic> _localizedStrings = {};
  
  // Supported languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'हिन्दी',  // Hindi
  };
  
  // Getter for current locale
  Locale get currentLocale => _currentLocale;
  
  // Initialize the service
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedLocale = prefs.getString('locale') ?? 'en';
      await changeLocale(Locale(storedLocale, ''));
      
      // Print success message to the console
      print('Localization initialized with locale: $storedLocale');
    } catch (e) {
      print('Error initializing localization service: $e');
      // Fallback to English on error
      await changeLocale(const Locale('en', ''));
    }
  }
  
  // Load the language JSON file
  Future<bool> _loadLanguage(String languageCode) async {
    try {
      // Load the JSON file from the assets
      String jsonString = await rootBundle.loadString('assets/locales/$languageCode.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      _localizedStrings = jsonMap;
      print('Loaded ${_localizedStrings.length} translations for $languageCode');
      return true;
    } catch (e) {
      print('Error loading language file for $languageCode: $e');
      
      // If we can't load the requested language, fall back to English
      if (languageCode != 'en') {
        try {
          String jsonString = await rootBundle.loadString('assets/locales/en.json');
          _localizedStrings = json.decode(jsonString);
          print('Falling back to English translations');
          return true;
        } catch (fallbackError) {
          print('Even fallback to English failed: $fallbackError');
          // Initialize with empty map if even English fails
          _localizedStrings = {};
        }
      }
      return false;
    }
  }
  
  // Change the current locale
  Future<void> changeLocale(Locale locale) async {
    if (!supportedLanguages.containsKey(locale.languageCode)) {
      print('Unsupported language: ${locale.languageCode}');
      return;
    }
    
    bool success = await _loadLanguage(locale.languageCode);
    if (success) {
      _currentLocale = locale;
      
      // Save the selected locale
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale', locale.languageCode);
      
      // Also save language_code for API use
      await prefs.setString('language_code', locale.languageCode);
      
      print('Locale changed to: ${locale.languageCode}');
      notifyListeners();
    } else {
      print('Failed to change locale to: ${locale.languageCode}');
    }
  }
  
  // Get a translated string by key
  String translate(String key) {
    try {
      // Try to find the key in our loaded strings
      List<String> parts = key.split('.');
      dynamic result = _localizedStrings;
      
      for (String part in parts) {
        if (result == null || !(result is Map)) {
          print('Translation key not found: $key (failed at $part)');
          return key; // Return the key itself if not found
        }
        result = result[part];
      }
      
      if (result == null) {
        print('Translation key not found: $key');
        return key; // Return the key itself if not found
      }
      
      return result.toString();
    } catch (e) {
      print('Error translating key "$key": $e');
      return key; // Return the key itself in case of error
    }
  }
  
  // Get current language code for API use
  String get languageCode => _currentLocale.languageCode;
  
  // Check if current language is Hindi
  bool get isHindi => _currentLocale.languageCode == 'hi';
  
  // Short form translator that can be used directly
  String tr(String key) => translate(key);
  
  // Create a predefined set of common translations
  // This is useful for when JSON files might not be loaded correctly
  Map<String, Map<String, String>> get hardcodedTranslations => {
    'en': {
      'common.app_name': 'KisanSaathi',
      'common.tagline': 'Empowering Indian Farmers with AI',
      'common.continue': 'Continue',
      'common.retry': 'Retry',
      'common.loading': 'Loading...',
      'common.error': 'Error',
      'common.success': 'Success',
      
      'auth.login': 'Login',
      'auth.register': 'Register',
      'auth.email': 'Email',
      'auth.password': 'Password',
      'auth.username': 'Username',
      
      'language.select': 'Select Your Language',
      'language.subtitle': 'Choose your preferred language to use KisanSaathi',
    },
    'hi': {
      'common.app_name': 'किसान साथी',
      'common.tagline': 'एआई के साथ भारतीय किसानों को सशक्त बनाना',
      'common.continue': 'जारी रखें',
      'common.retry': 'पुनः प्रयास करें',
      'common.loading': 'लोड हो रहा है...',
      'common.error': 'त्रुटि',
      'common.success': 'सफलता',
      
      'auth.login': 'लॉगिन',
      'auth.register': 'पंजीकरण',
      'auth.email': 'ईमेल',
      'auth.password': 'पासवर्ड',
      'auth.username': 'उपयोगकर्ता नाम',
      
      'language.select': 'अपनी भाषा चुनें',
      'language.subtitle': 'किसान साथी का उपयोग करने के लिए अपनी पसंदीदा भाषा चुनें',
    },
  };
  
  // Fallback translation method that uses hardcoded translations when JSON fails
  String getFallbackTranslation(String key) {
    final lang = _currentLocale.languageCode;
    final translations = hardcodedTranslations[lang] ?? hardcodedTranslations['en']!;
    return translations[key] ?? hardcodedTranslations['en']![key] ?? key;
  }
}

// Extension method for easier translation in widgets
extension TranslateExtension on BuildContext {
  String tr(String key) {
    return Provider.of<LocalizationService>(this, listen: false).translate(key);
  }
  
  bool get isHindi => Provider.of<LocalizationService>(this, listen: false).isHindi;
  
  LocalizationService get localization => Provider.of<LocalizationService>(this, listen: false);
} 
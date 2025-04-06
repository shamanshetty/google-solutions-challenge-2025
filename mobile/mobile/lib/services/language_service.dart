import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  // Supported languages
  static const List<String> supportedLanguages = ['en', 'hi'];
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिन्दी (Hindi)',
  };
  
  // Default language
  String _currentLanguage = 'en';
  
  String get currentLanguage => _currentLanguage;
  
  // Initialize the service
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    
    if (savedLanguage != null && supportedLanguages.contains(savedLanguage)) {
      _currentLanguage = savedLanguage;
      notifyListeners();
    }
  }
  
  // Change the language
  Future<void> setLanguage(String languageCode) async {
    if (supportedLanguages.contains(languageCode) && _currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      
      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      notifyListeners();
    }
  }
  
  // Get localized text based on language code
  String getLocalizedText(String englishText, String hindiText) {
    return _currentLanguage == 'hi' ? hindiText : englishText;
  }
  
  // Toggle between English and Hindi
  Future<void> toggleLanguage() async {
    final newLanguage = _currentLanguage == 'en' ? 'hi' : 'en';
    await setLanguage(newLanguage);
  }
  
  // Get the current language name
  String get currentLanguageName => languageNames[_currentLanguage] ?? 'English';
} 
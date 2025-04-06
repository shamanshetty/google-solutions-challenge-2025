import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:kisan_saathi/config/api_config.dart';

class EnvConfig {
  // Load environment variables from .env file
  static Future<void> load() async {
    try {
      // Load .env file
      await dotenv.dotenv.load(fileName: ".env");
      
      // Set API keys
      ApiConfig.geminiApiKey = dotenv.dotenv.env['GEMINI_API_KEY'];
      
      // Print a success message (only in debug mode)
      if (kDebugMode) {
        print('Environment variables loaded successfully');
        // Mask API key for security while still confirming it was loaded
        final String? maskedKey = ApiConfig.geminiApiKey != null 
            ? '${ApiConfig.geminiApiKey!.substring(0, 3)}...' + 
              (ApiConfig.geminiApiKey!.length > 6 
                ? ApiConfig.geminiApiKey!.substring(ApiConfig.geminiApiKey!.length - 3) 
                : '')
            : null;
        print('Gemini API Key: ${maskedKey ?? 'Not set'}');
      }
    } catch (e) {
      // Print error message
      if (kDebugMode) {
        print('Failed to load environment variables: $e');
      }
      
      // Set default values (for development/testing)
      if (kDebugMode) {
        // Only in debug mode, you might want to set a default key for testing
        // In production, this will remain null and the app will fall back to mock mode
        ApiConfig.mockMode = false;
      }
    }
  }
} 
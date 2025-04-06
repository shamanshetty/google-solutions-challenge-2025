class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();
  
  // Toggle to use mock data instead of real API calls
  static bool mockMode = true;
  
  // Base URL for API calls
  static const String baseUrl = 'https://api.kisansaathi.com';
  
  // Gemini API key from environment
  static String? geminiApiKey;
  
  // Initialize API configuration
  static Future<void> init() async {
    // Load environment variables (will be implemented in a separate file)
    await loadEnvVariables();
  }
  
  // Load environment variables
  static Future<void> loadEnvVariables() async {
    try {
      // In a real implementation, you would properly load from .env file
      // For now, this is a placeholder that will be replaced with actual loading
      geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY');
    } catch (e) {
      print('Error loading environment variables: $e');
    }
  }
  
  // API Endpoints
  static const String healthCheckEndpoint = '/api/health';
  static const String diseaseDetectionEndpoint = '/api/detect-disease';
  static const String soilAnalysisEndpoint = '/api/analyze-soil';
  static const String weatherEndpoint = '/api/weather';
  
  // Timeout durations (in seconds)
  static const int connectionTimeout = 5; // Reduced timeout for better UX
  static const int receiveTimeout = 10;
  
  // Headers
  static Map<String, String> get headers => {
    'Accept': 'application/json',
  };
  
  // Static methods to get full endpoint URLs
  static String getHealthCheckUrl() => '$baseUrl$healthCheckEndpoint';
  static String getDiseaseDetectionUrl() => '$baseUrl$diseaseDetectionEndpoint';
  static String getSoilAnalysisUrl() => '$baseUrl$soilAnalysisEndpoint';
  static String getWeatherUrl({required double lat, required double lon}) {
    return '$baseUrl$weatherEndpoint?lat=$lat&lon=$lon';
  }
} 
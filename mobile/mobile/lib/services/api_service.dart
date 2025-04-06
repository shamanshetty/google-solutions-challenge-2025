import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kisan_saathi/config/api_config.dart';
import 'package:kisan_saathi/models/disease_result.dart';
import 'package:kisan_saathi/models/soil_result.dart';
import 'package:kisan_saathi/models/weather_result.dart';
import 'package:provider/provider.dart';
import 'package:kisan_saathi/services/localization_service.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  // HTTP client
  final http.Client _client = http.Client();
  
  // Random number generator for mock data
  final Random _random = Random();

  // Get the current language code from shared preferences
  Future<String> _getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language_code') ?? 'en';
  }
  
  // Check API health
  Future<bool> checkApiHealth() async {
    if (ApiConfig.mockMode) {
      // In mock mode, always return true after a short delay to simulate a real request
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }
    
    try {
      final response = await _client.get(
        Uri.parse(ApiConfig.getHealthCheckUrl()),
        headers: ApiConfig.headers,
      ).timeout(const Duration(seconds: ApiConfig.connectionTimeout));
      
      return response.statusCode == 200;
    } catch (e) {
      print('API health check error: $e');
      return false;
    }
  }
  
  // Detect plant disease
  Future<DiseaseResult> detectDisease(File imageFile, {String? language}) async {
    // Get language from parameters or shared preferences
    language ??= await _getCurrentLanguage();
    
    if (ApiConfig.mockMode) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate mock disease detection result
      return _getMockDiseaseResult(language);
    }
    
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.getDiseaseDetectionUrl()),
      );
      
      // Add language parameter
      request.fields['language'] = language;
      
      // Add image file
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
      
      // Send request
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: ApiConfig.connectionTimeout),
      );
      
      // Get response
      var response = await http.Response.fromStream(streamedResponse);
      
      // Check status code
      if (response.statusCode == 200) {
        return DiseaseResult.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to detect disease: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Disease detection error: $e');
      rethrow;
    }
  }
  
  // Detect plant disease with image bytes (for web)
  Future<DiseaseResult> detectDiseaseWithBytes(Uint8List imageBytes, {String? language}) async {
    // Get language from parameters or shared preferences
    language ??= await _getCurrentLanguage();
    
    if (ApiConfig.mockMode) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate mock disease detection result
      return _getMockDiseaseResult(language);
    }
    
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.getDiseaseDetectionUrl()),
      );
      
      // Add language parameter
      request.fields['language'] = language;
      
      // Add image as bytes
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
      
      // Send request
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: ApiConfig.connectionTimeout),
      );
      
      // Get response
      var response = await http.Response.fromStream(streamedResponse);
      
      // Check status code
      if (response.statusCode == 200) {
        return DiseaseResult.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to detect disease: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Disease detection error: $e');
      rethrow;
    }
  }
  
  // Analyze soil
  Future<SoilResult> analyzeSoil(File imageFile, {String? language}) async {
    // Get language from parameters or shared preferences
    language ??= await _getCurrentLanguage();
    
    if (ApiConfig.mockMode) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate mock soil analysis result
      return _getMockSoilResult(language);
    }
    
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.getSoilAnalysisUrl()),
      );
      
      // Add language parameter
      request.fields['language'] = language;
      
      // Add image file
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
      
      // Send request
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: ApiConfig.connectionTimeout),
      );
      
      // Get response
      var response = await http.Response.fromStream(streamedResponse);
      
      // Check status code
      if (response.statusCode == 200) {
        return SoilResult.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to analyze soil: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Soil analysis error: $e');
      rethrow;
    }
  }
  
  // Analyze soil with image bytes (for web)
  Future<SoilResult> analyzeSoilWithBytes(Uint8List imageBytes, {String? language}) async {
    // Get language from parameters or shared preferences
    language ??= await _getCurrentLanguage();
    
    if (ApiConfig.mockMode) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate mock soil analysis result
      return _getMockSoilResult(language);
    }
    
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.getSoilAnalysisUrl()),
      );
      
      // Add language parameter
      request.fields['language'] = language;
      
      // Add image as bytes
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
      
      // Send request
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: ApiConfig.connectionTimeout),
      );
      
      // Get response
      var response = await http.Response.fromStream(streamedResponse);
      
      // Check status code
      if (response.statusCode == 200) {
        return SoilResult.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to analyze soil: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Soil analysis error: $e');
      rethrow;
    }
  }
  
  // Get weather data and recommendations
  Future<WeatherResult> getWeather(double lat, double lon, {String? language}) async {
    // Get language from parameters or shared preferences
    language ??= await _getCurrentLanguage();
    
    if (ApiConfig.mockMode) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate mock weather result
      return _getMockWeatherResult(language);
    }
    
    try {
      // Add language parameter to URL
      final url = '${ApiConfig.getWeatherUrl(lat: lat, lon: lon)}&language=$language';
      
      final response = await _client.get(
        Uri.parse(url),
        headers: ApiConfig.headers,
      ).timeout(const Duration(seconds: ApiConfig.connectionTimeout));
      
      if (response.statusCode == 200) {
        return WeatherResult.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get weather data: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Weather data error: $e');
      rethrow;
    }
  }
  
  // Helper method to handle cross-platform image analysis
  Future<SoilResult> analyzeSoilImage({File? file, Uint8List? bytes, String language = 'en'}) async {
    if (ApiConfig.mockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return _getMockSoilResult(language);
    }
    
    if (kIsWeb && bytes != null) {
      return analyzeSoilWithBytes(bytes, language: language);
    } else if (file != null) {
      return analyzeSoil(file, language: language);
    } else {
      throw Exception('No valid image provided for analysis');
    }
  }
  
  // Helper method to handle cross-platform disease detection
  Future<DiseaseResult> detectDiseaseImage({File? file, Uint8List? bytes, String language = 'en'}) async {
    if (ApiConfig.mockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return _getMockDiseaseResult(language);
    }
    
    if (kIsWeb && bytes != null) {
      return detectDiseaseWithBytes(bytes, language: language);
    } else if (file != null) {
      return detectDisease(file, language: language);
    } else {
      throw Exception('No valid image provided for disease detection');
    }
  }
  
  // MOCK DATA GENERATORS
  
  // Generate mock disease detection result
  DiseaseResult _getMockDiseaseResult(String language) {
    final diseases = [
      'Healthy',
      'Early Blight',
      'Late Blight',
      'Bacterial Spot',
      'Target Spot'
    ];
    
    final diseasesHindi = [
      'स्वस्थ',
      'अर्ली ब्लाइट',
      'लेट ब्लाइट',
      'बैक्टीरियल स्पॉट',
      'टारगेट स्पॉट'
    ];
    
    final descriptions = [
      'The plant appears to be healthy with no signs of disease.',
      'Early blight is caused by the fungus Alternaria solani and affects tomatoes and potatoes.',
      'Late blight is a serious disease affecting potatoes and tomatoes, caused by Phytophthora infestans.',
      'Bacterial spot is caused by Xanthomonas bacteria and affects tomatoes and peppers.',
      'Target spot is caused by the fungus Corynespora cassiicola and creates circular lesions on leaves.'
    ];
    
    final descriptionsHindi = [
      'पौधा स्वस्थ दिखाई दे रहा है और उसमें रोग के कोई लक्षण नहीं हैं।',
      'अर्ली ब्लाइट अल्टरनारिया सोलानी नामक फंगस के कारण होता है और टमाटर और आलू को प्रभावित करता है।',
      'लेट ब्लाइट एक गंभीर रोग है जो आलू और टमाटर को प्रभावित करता है, जिसका कारण फाइटोफ्थोरा इन्फेस्टैन्स है।',
      'बैक्टीरियल स्पॉट जैंथोमोनास बैक्टीरिया के कारण होता है और टमाटर और शिमला मिर्च को प्रभावित करता है।',
      'टारगेट स्पॉट कोरिनेस्पोरा कैसिकोला नामक फंगस के कारण होता है और पत्तियों पर गोलाकार घाव बनाता है।'
    ];
    
    final recommendations = [
      ['Plant is healthy, no treatment needed.'],
      [
        'Remove infected leaves.',
        'Apply copper-based fungicide.',
        'Ensure proper spacing for air circulation.'
      ],
      [
        'Remove infected plants to prevent spread.',
        'Apply fungicide with chlorothalonil.',
        'Avoid overhead irrigation.'
      ],
      [
        'Apply copper-based bactericide.',
        'Rotate crops.',
        'Avoid working with wet plants.'
      ],
      [
        'Remove infected leaves.',
        'Apply fungicide.',
        'Maintain proper plant spacing.'
      ]
    ];
    
    final recommendationsHindi = [
      ['पौधा स्वस्थ है, कोई उपचार की आवश्यकता नहीं है।'],
      [
        'संक्रमित पत्तियों को हटा दें।',
        'कॉपर-आधारित फफूंदनाशक लगाएं।',
        'हवा के संचार के लिए उचित स्पेसिंग सुनिश्चित करें।'
      ],
      [
        'प्रसार को रोकने के लिए संक्रमित पौधों को हटा दें।',
        'क्लोरोथालोनिल वाले फफूंदनाशक लगाएं।',
        'ऊपरी सिंचाई से बचें।'
      ],
      [
        'कॉपर-आधारित बैक्टीरियासाइड लगाएं।',
        'फसलों का रोटेशन करें।',
        'गीले पौधों के साथ काम करने से बचें।'
      ],
      [
        'संक्रमित पत्तियों को हटा दें।',
        'फफूंदनाशक लगाएं।',
        'उचित पौधों की स्पेसिंग बनाए रखें।'
      ]
    ];
    
    final diseaseIndex = _random.nextInt(diseases.length);
    
    return DiseaseResult(
      disease: language == 'hi' ? diseasesHindi[diseaseIndex] : diseases[diseaseIndex],
      description: language == 'hi' ? descriptionsHindi[diseaseIndex] : descriptions[diseaseIndex],
      confidence: 0.7 + _random.nextDouble() * 0.29,
      recommendations: language == 'hi' 
          ? recommendationsHindi[diseaseIndex]
          : recommendations[diseaseIndex],
    );
  }
  
  // Generate mock soil analysis result
  SoilResult _getMockSoilResult(String language) {
    final soilTypes = ['Clay Soil', 'Sandy Soil', 'Loamy Soil', 'Silty Soil'];
    final soilTypesHindi = ['चिकनी मिट्टी', 'रेतीली मिट्टी', 'दोमट मिट्टी', 'गादयुक्त मिट्टी'];
    
    final soilRecommendations = [
      [
        'Add organic matter to improve drainage.',
        'Avoid overwatering as clay retains moisture well.',
        'Plant crops that thrive in clay soil like cabbage and broccoli.'
      ],
      [
        'Add compost to improve water retention.',
        'Water frequently as sandy soil drains quickly.',
        'Plant root vegetables like carrots and potatoes.'
      ],
      [
        'Maintain organic matter levels with regular compost additions.',
        'Most crops will grow well in this balanced soil type.',
        'Rotate crops to maintain soil health.'
      ],
      [
        'Add organic matter to improve structure.',
        'Avoid walking on soil when wet to prevent compaction.',
        'Good for growing most vegetables and fruits.'
      ]
    ];
    
    final soilRecommendationsHindi = [
      [
        'जल निकासी में सुधार के लिए जैविक पदार्थ जोड़ें।',
        'अधिक पानी देने से बचें क्योंकि मिट्टी नमी को अच्छी तरह से बनाए रखती है।',
        'पत्तागोभी और ब्रोकोली जैसी फसलें लगाएं जो चिकनी मिट्टी में अच्छी तरह से उगती हैं।'
      ],
      [
        'पानी के धारण को बेहतर बनाने के लिए कम्पोस्ट जोड़ें।',
        'बार-बार पानी दें क्योंकि रेतीली मिट्टी जल्दी सूख जाती है।',
        'गाजर और आलू जैसी जड़ वाली सब्जियां लगाएं।'
      ],
      [
        'नियमित कम्पोस्ट जोड़कर जैविक पदार्थ के स्तर को बनाए रखें।',
        'अधिकांश फसलें इस संतुलित मिट्टी के प्रकार में अच्छी तरह से उगेंगी।',
        'मिट्टी के स्वास्थ्य को बनाए रखने के लिए फसलों को घुमाएं।'
      ],
      [
        'संरचना में सुधार के लिए जैविक पदार्थ जोड़ें।',
        'संघनन को रोकने के लिए गीली मिट्टी पर चलने से बचें।',
        'अधिकांश सब्जियों और फलों के लिए अच्छी है।'
      ]
    ];
    
    final phRecommendations = [
      'Your soil pH is low. Consider adding lime to raise pH.',
      'Your soil pH is high. Consider adding sulfur to lower pH.',
      'Your soil pH is in the optimal range for most crops.'
    ];
    
    final phRecommendationsHindi = [
      'आपकी मिट्टी का पीएच कम है। पीएच बढ़ाने के लिए चूना जोड़ने पर विचार करें।',
      'आपकी मिट्टी का पीएच अधिक है। पीएच कम करने के लिए सल्फर जोड़ने पर विचार करें।',
      'आपकी मिट्टी का पीएच अधिकांश फसलों के लिए इष्टतम सीमा में है।'
    ];
    
    final soilIndex = _random.nextInt(soilTypes.length);
    final ph = 5.5 + _random.nextDouble() * 2.0;
    
    // Add pH recommendation
    List<String> recommendations = language == 'hi' 
        ? List.from(soilRecommendationsHindi[soilIndex])
        : List.from(soilRecommendations[soilIndex]);
    
    if (ph < 6.0) {
      recommendations.add(language == 'hi' ? phRecommendationsHindi[0] : phRecommendations[0]);
    } else if (ph > 7.2) {
      recommendations.add(language == 'hi' ? phRecommendationsHindi[1] : phRecommendations[1]);
    } else {
      recommendations.add(language == 'hi' ? phRecommendationsHindi[2] : phRecommendations[2]);
    }
    
    return SoilResult(
      soilType: language == 'hi' ? soilTypesHindi[soilIndex] : soilTypes[soilIndex],
      properties: {
        'pH': ph.toStringAsFixed(1),
        'nitrogen': (10 + _random.nextInt(30)).toString(),
        'phosphorus': (5 + _random.nextInt(15)).toString(),
        'potassium': (5 + _random.nextInt(15)).toString(),
        'organic_matter': (1 + _random.nextInt(4) + _random.nextDouble()).toStringAsFixed(1),
      },
      recommendations: recommendations,
    );
  }
  
  // Generate mock weather result
  WeatherResult _getMockWeatherResult(String language) {
    final weatherConditions = ['Clear', 'Cloudy', 'Rain', 'Thunderstorm'];
    final weatherConditionsHindi = ['साफ़', 'बादल', 'बारिश', 'आंधी'];
    
    final weatherIndex = _random.nextInt(weatherConditions.length);
    
    final recommendations = [
      ['Clear weather: Good time for harvesting or planting.'],
      ['Cloudy weather: Good time for transplanting seedlings.'],
      ['Rainfall expected: Hold off on pesticide application.'],
      ['Thunderstorm warning: Secure your equipment and livestock.']
    ];
    
    final recommendationsHindi = [
      ['साफ मौसम: फसल काटने या बोने का अच्छा समय।'],
      ['बादल वाला मौसम: रोपाई का अच्छा समय।'],
      ['वर्षा की उम्मीद है: कीटनाशक के छिड़काव को रोक दें।'],
      ['आंधी की चेतावनी: अपने उपकरण और पशुधन को सुरक्षित करें।']
    ];
    
    return WeatherResult(
      temperature: (20 + _random.nextInt(15)).toDouble(),
      humidity: 40 + _random.nextInt(50),
      condition: language == 'hi' ? weatherConditionsHindi[weatherIndex] : weatherConditions[weatherIndex],
      recommendations: language == 'hi' ? recommendationsHindi[weatherIndex] : recommendations[weatherIndex],
    );
  }
} 
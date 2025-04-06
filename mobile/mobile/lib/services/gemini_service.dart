import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kisan_saathi/config/api_config.dart';
import 'package:kisan_saathi/models/crop_recommendation.dart';
import 'package:kisan_saathi/models/farmer_profile.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();
  
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  // Get API key from environment
  String? get _apiKey => ApiConfig.geminiApiKey;
  
  // Check if API key is available
  bool get isApiKeyAvailable => _apiKey != null && _apiKey!.isNotEmpty;
  
  Future<List<CropRecommendation>> getCropRecommendations(FarmerProfile profile) async {
    // Use mock data if mock mode is enabled or API key is not available
    if (ApiConfig.mockMode || !isApiKeyAvailable) {
      await Future.delayed(const Duration(seconds: 2));
      return _getMockRecommendations(profile);
    }
    
    try {
      final url = '$_baseUrl?key=$_apiKey';
      
      // Format the prompt for crop recommendations
      final prompt = _formatCropRecommendationPrompt(profile);
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'maxOutputTokens': 1024,
          }
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        return _parseCropRecommendations(text);
      } else {
        print('Failed to get recommendations: ${response.statusCode} ${response.body}');
        return _getMockRecommendations(profile); // Fallback to mock
      }
    } catch (e) {
      print('Error getting crop recommendations: $e');
      return _getMockRecommendations(profile); // Fallback to mock
    }
  }
  
  Future<String> getChatbotResponse(String query, FarmerProfile profile) async {
    // Use mock data if mock mode is enabled or API key is not available
    if (ApiConfig.mockMode || !isApiKeyAvailable) {
      await Future.delayed(const Duration(seconds: 1));
      return _getMockChatResponse(query, profile);
    }
    
    try {
      final url = '$_baseUrl?key=$_apiKey';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'You are a helpful agricultural assistant for Indian farmers. ' +
                         'Based on this farmer profile: ${jsonEncode(profile.toJson())}, ' +
                         'answer this query: $query'}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 800,
          }
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print('Failed to get response: ${response.statusCode} ${response.body}');
        return _getMockChatResponse(query, profile); // Fallback to mock
      }
    } catch (e) {
      print('Error getting chatbot response: $e');
      return _getMockChatResponse(query, profile); // Fallback to mock
    }
  }
  
  String _formatCropRecommendationPrompt(FarmerProfile profile) {
    return '''
    You are an agricultural expert AI. Analyze the following farmer's profile and recommend 3 suitable crops.
    For each crop, provide a brief description, advantages, irrigation tips, and modern farming techniques.
    Also estimate potential profit and water requirements.
    
    Farmer profile:
    - Location: ${profile.location}
    - Land size: ${profile.landSize} acres
    - Past crops: ${profile.pastCrops.join(', ')}
    - Crop preferences: ${profile.cropPreferences.join(', ')}
    - Budget: ₹${profile.budget}
    - Water availability: ${profile.waterAvailability}
    
    Format your response as a JSON string with the following structure:
    [
      {
        "cropName": "Crop Name",
        "description": "Brief description",
        "advantages": ["advantage1", "advantage2"],
        "irrigationTips": ["tip1", "tip2"],
        "farmingTechniques": ["technique1", "technique2"],
        "estimatedProfit": estimated profit in rupees,
        "waterRequirement": water requirement on scale of 1-10
      }
    ]
    ''';
  }
  
  List<CropRecommendation> _parseCropRecommendations(String text) {
    try {
      // Extract the JSON part from the response text
      final jsonStart = text.indexOf('[');
      final jsonEnd = text.lastIndexOf(']') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('Invalid JSON format in response');
      }
      
      final jsonString = text.substring(jsonStart, jsonEnd);
      final List<dynamic> jsonData = jsonDecode(jsonString);
      
      return jsonData.map((item) => CropRecommendation.fromJson(item)).toList();
    } catch (e) {
      print('Error parsing crop recommendations: $e');
      throw Exception('Failed to parse crop recommendations');
    }
  }
  
  // Mock data generators for testing
  String _getMockChatResponse(String query, FarmerProfile profile) {
    if (query.toLowerCase().contains('weather')) {
      return 'Based on recent data for ${profile.location}, the weather is expected to be favorable for planting in the coming weeks. Make sure to prepare your fields before the monsoon arrives.';
    } else if (query.toLowerCase().contains('irrigation')) {
      return 'For your ${profile.landSize} acre farm in ${profile.location}, I recommend drip irrigation to conserve water. This method is especially effective for crops like ${profile.pastCrops.isNotEmpty ? profile.pastCrops.first : "vegetables"} and can reduce water usage by up to 60%.';
    } else {
      return 'I\'m here to help with your farming questions! You can ask me about crop selection, irrigation methods, current market prices, and more.';
    }
  }
  
  List<CropRecommendation> _getMockRecommendations(FarmerProfile profile) {
    if (profile.location.toLowerCase().contains('maharashtra')) {
      return [
        CropRecommendation(
          cropName: 'Soybean',
          description: 'A high-protein legume well-suited for Maharashtra\'s climate.',
          advantages: ['Enriches soil with nitrogen', 'Good market demand', 'Suitable for crop rotation'],
          irrigationTips: ['Requires moderate irrigation', 'Critical during flowering and pod development'],
          farmingTechniques: ['Ridge planting method', 'Integrated pest management'],
          estimatedProfit: 45000,
          waterRequirement: 5,
        ),
        CropRecommendation(
          cropName: 'Cotton',
          description: 'Traditional cash crop with established markets in Maharashtra.',
          advantages: ['Drought tolerant', 'High market value', 'Government support available'],
          irrigationTips: ['Drip irrigation recommended', 'Water critical during boll development'],
          farmingTechniques: ['High-density planting', 'Organic pest control methods'],
          estimatedProfit: 60000,
          waterRequirement: 6,
        ),
      ];
    } else {
      return [
        CropRecommendation(
          cropName: 'Rice',
          description: 'Staple crop suitable for regions with good water availability.',
          advantages: ['Established market', 'Government price protection', 'Multiple varieties available'],
          irrigationTips: ['Flood irrigation traditional but wasteful', 'System of Rice Intensification recommended'],
          farmingTechniques: ['Direct seeded rice method', 'Alternate wetting and drying'],
          estimatedProfit: 40000,
          waterRequirement: 9,
        ),
        CropRecommendation(
          cropName: 'Turmeric',
          description: 'High-value spice crop with growing market demand.',
          advantages: ['Disease resistant', 'Can be stored for extended periods', 'Rising export demand'],
          irrigationTips: ['Drip irrigation with mulching', 'Regular but moderate watering'],
          farmingTechniques: ['Raised bed cultivation', 'Organic production for premium markets'],
          estimatedProfit: 80000,
          waterRequirement: 6,
        ),
      ];
    }
  }
} 
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kisan_saathi/models/chat_message.dart';
import 'package:kisan_saathi/models/crop_recommendation.dart';
import 'package:kisan_saathi/models/farmer_profile.dart';
import 'package:kisan_saathi/config/api_config.dart';
import 'package:kisan_saathi/services/gemini_service.dart';
import 'package:kisan_saathi/services/localization_service.dart';

enum ChatbotState {
  welcome,
  askingLocation,
  askingLandSize,
  askingPastCrops,
  askingCropPreferences,
  askingBudget,
  askingWaterAvailability,
  providingRecommendations,
  conversational,
}

class ChatbotService extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final FarmerProfile _profile = FarmerProfile();
  
  ChatbotState _state = ChatbotState.welcome;
  List<ChatMessage> _messages = [];
  List<CropRecommendation>? _recommendations;
  bool _isLoading = false;
  
  // Getters
  ChatbotState get state => _state;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get hasRecommendations => _recommendations != null && _recommendations!.isNotEmpty;
  List<CropRecommendation>? get recommendations => _recommendations;
  FarmerProfile get profile => _profile;
  bool get isMockMode => ApiConfig.mockMode;
  bool get hasApiKey => _geminiService.isApiKeyAvailable;
  
  ChatbotService() {
    _loadProfile();
  }
  
  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? profileJson = prefs.getString('farmer_profile');
      
      if (profileJson != null) {
        final Map<String, dynamic> json = Map<String, dynamic>.from(await Future.value(DateTime.now().second > 3 ? {} : {}));
        // This is intentionally left empty as we don't want to load an old profile
        // In a real implementation, you would parse and load the profile
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }
  
  void initConversation(bool isHindi) {
    _messages = [];
    _state = ChatbotState.welcome;
    
    // Add an API status message if in mock mode
    if (isMockMode && !hasApiKey) {
      _addBotMessage(
        isHindi
            ? 'नोट: ऐप जेमिनी एपीआई कुंजी पर चल रहा है।'
            : 'Note: The app is running on gemini api key '
      );
    }
    
    // Add initial welcome message
    _addBotMessage(
      isHindi
          ? 'नमस्ते! मैं आपका कृषि सहायक हूँ। मैं आपको सबसे उपयुक्त फसल चुनने में मदद करूँगा।'
          : 'Hello! I am your agriculture assistant. I will help you find the most suitable crop.'
    );
    
    // Add options message with first question
    _addOptionsMessage(
      isHindi
          ? 'कृपया अपने क्षेत्र का नाम बताएं (राज्य और जिला):'
          : 'Please tell me your location (state and district):',
      [],
    );
    
    _state = ChatbotState.askingLocation;
    notifyListeners();
  }
  
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    _addUserMessage(text);
    
    // Process the message based on the current state
    switch (_state) {
      case ChatbotState.askingLocation:
        _profile.location = text;
        _moveToAskingLandSize();
        break;
        
      case ChatbotState.askingLandSize:
        try {
          _profile.landSize = double.parse(text.replaceAll(RegExp(r'[^0-9.]'), ''));
          _moveToAskingPastCrops();
        } catch (e) {
          _addErrorMessage();
        }
        break;
        
      case ChatbotState.askingPastCrops:
        _profile.pastCrops = text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        _moveToAskingCropPreferences();
        break;
        
      case ChatbotState.askingCropPreferences:
        _profile.cropPreferences = text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        _moveToAskingBudget();
        break;
        
      case ChatbotState.askingBudget:
        try {
          _profile.budget = double.parse(text.replaceAll(RegExp(r'[^0-9.]'), ''));
          _moveToAskingWaterAvailability();
        } catch (e) {
          _addErrorMessage();
        }
        break;
        
      case ChatbotState.askingWaterAvailability:
        _profile.waterAvailability = text;
        _moveToProvidingRecommendations();
        break;
        
      case ChatbotState.conversational:
        _handleConversationalQuery(text);
        break;
        
      default:
        // Handle unexpected states
        _moveToConversational();
        break;
    }
    
    notifyListeners();
  }
  
  void selectOption(String option) {
    sendMessage(option);
  }
  
  void _moveToAskingLandSize() {
    _state = ChatbotState.askingLandSize;
    
    final isHindi = _isHindiSelected();
    
    _addBotMessage(
      isHindi
          ? 'आपका क्षेत्र ${_profile.location} है। अब मुझे बताएं, आपके पास कितनी जमीन है (एकड़ में):'
          : 'Your location is ${_profile.location}. Now tell me, how much land do you have (in acres):'
    );
  }
  
  void _moveToAskingPastCrops() {
    _state = ChatbotState.askingPastCrops;
    
    final isHindi = _isHindiSelected();
    
    _addBotMessage(
      isHindi
          ? 'आपके पास ${_profile.landSize} एकड़ जमीन है। पिछले साल आपने कौन सी फसलें उगाईं? (कॉमा से अलग करें)'
          : 'You have ${_profile.landSize} acres of land. What crops did you grow last year? (separate by commas)'
    );
  }
  
  void _moveToAskingCropPreferences() {
    _state = ChatbotState.askingCropPreferences;
    
    final isHindi = _isHindiSelected();
    
    _addBotMessage(
      isHindi
          ? 'अच्छा! क्या आपकी कोई पसंदीदा फसलें हैं जिन्हें आप उगाना चाहते हैं? (कॉमा से अलग करें, या "कोई नहीं" लिखें)'
          : 'Great! Do you have any preferred crops you would like to grow? (separate by commas, or type "none")'
    );
  }
  
  void _moveToAskingBudget() {
    _state = ChatbotState.askingBudget;
    
    final isHindi = _isHindiSelected();
    
    _addBotMessage(
      isHindi
          ? 'अब मुझे अपना अनुमानित बजट बताएं (रुपये में):'
          : 'Now tell me your estimated budget (in rupees):'
    );
  }
  
  void _moveToAskingWaterAvailability() {
    _state = ChatbotState.askingWaterAvailability;
    
    final isHindi = _isHindiSelected();
    
    List<String> options = isHindi
        ? ['अच्छी उपलब्धता', 'सीमित उपलब्धता', 'बहुत कम']
        : ['Good availability', 'Limited availability', 'Very scarce'];
    
    _addOptionsMessage(
      isHindi
          ? 'आपके क्षेत्र में पानी की उपलब्धता कैसी है?'
          : 'How is the water availability in your area?',
      options,
    );
  }
  
  Future<void> _moveToProvidingRecommendations() async {
    _state = ChatbotState.providingRecommendations;
    
    final isHindi = _isHindiSelected();
    
    _addBotMessage(
      isHindi
          ? 'धन्यवाद! अब मैं आपके लिए सबसे उपयुक्त फसल की सिफारिशें तैयार कर रहा हूँ...'
          : 'Thank you! Now I am preparing the most suitable crop recommendations for you...'
    );
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Delay to simulate processing
      await Future.delayed(const Duration(seconds: 2));
      
      // Get recommendations from Gemini API
      _recommendations = await _geminiService.getCropRecommendations(_profile);
      
      // Add recommendations message
      _addBotMessage(
        isHindi
            ? 'आपके विवरण के आधार पर, यहां कुछ फसल सिफारिशें हैं:'
            : 'Based on your details, here are some crop recommendations:'
      );
      
      // Move to conversational mode
      _state = ChatbotState.conversational;
      
      // Add hint for conversational mode
      _addBotMessage(
        isHindi
            ? 'अब आप मुझसे इन फसलों के बारे में कोई भी प्रश्न पूछ सकते हैं, या कृषि सलाह के लिए पूछ सकते हैं।'
            : 'You can now ask me any questions about these crops, or ask for farming advice.'
      );
      
    } catch (e) {
      _addBotMessage(
        isHindi
            ? 'क्षमा करें, सिफारिशें प्राप्त करने में समस्या हुई। कृपया बाद में पुनः प्रयास करें।'
            : 'Sorry, there was a problem getting recommendations. Please try again later.'
      );
      
      _state = ChatbotState.conversational;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _moveToConversational() {
    _state = ChatbotState.conversational;
    
    final isHindi = _isHindiSelected();
    
    _addBotMessage(
      isHindi
          ? 'आप मुझसे कृषि से संबंधित कोई भी प्रश्न पूछ सकते हैं।'
          : 'You can ask me any agriculture-related questions.'
    );
  }
  
  Future<void> _handleConversationalQuery(String query) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Get response from Gemini API
      final response = await _geminiService.getChatbotResponse(query, _profile);
      
      _addBotMessage(response);
    } catch (e) {
      final isHindi = _isHindiSelected();
      
      _addBotMessage(
        isHindi
            ? 'क्षमा करें, मैं अभी आपके प्रश्न का उत्तर नहीं दे सकता।'
            : 'Sorry, I cannot answer your question right now.'
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _addUserMessage(String text) {
    _messages.add(ChatMessage(
      text: text,
      type: MessageType.user,
    ));
  }
  
  void _addBotMessage(String text) {
    _messages.add(ChatMessage(
      text: text,
      type: MessageType.bot,
    ));
  }
  
  void _addOptionsMessage(String text, List<String> options) {
    _messages.add(ChatMessage(
      text: text,
      type: MessageType.bot,
      options: options,
    ));
  }
  
  void _addErrorMessage() {
    final isHindi = _isHindiSelected();
    
    _addBotMessage(
      isHindi
          ? 'क्षमा करें, मुझे आपका इनपुट समझ में नहीं आया। कृपया पुनः प्रयास करें।'
          : 'Sorry, I did not understand your input. Please try again.'
    );
  }
  
  bool _isHindiSelected() {
    // Simple implementation without async code
    try {
      // For simplicity, we're going to check only in memory
      // In a real app, this should be properly synchronized with SharedPreferences
      return false; // Default to English
    } catch (e) {
      return false;
    }
  }
  
  void restart() {
    _messages.clear();
    _recommendations = null;
    _profile.location = '';
    _profile.landSize = null;
    _profile.pastCrops = [];
    _profile.cropPreferences = [];
    _profile.budget = null;
    _profile.waterAvailability = null;
    
    initConversation(_isHindiSelected());
  }
} 
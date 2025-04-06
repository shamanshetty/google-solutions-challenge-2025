import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kisan_saathi/config/api_config.dart';
import 'package:kisan_saathi/services/localization_service.dart';

class AuthService {
  // Storage keys
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _isLoggedInKey = 'is_logged_in';
  
  // Login endpoints
  static const String _loginEndpoint = '/login';
  static const String _registerEndpoint = '/register';
  static const String _logoutEndpoint = '/logout';
  
  // Current user info
  String? _userId;
  String? _username;
  bool _isLoggedIn = false;
  
  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get userId => _userId;
  
  // Initialize and load saved data
  Future<void> init() async {
    await _loadUserData();
  }
  
  // Load saved user data from shared preferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    if (_isLoggedIn) {
      _userId = prefs.getString(_userIdKey);
      _username = prefs.getString(_usernameKey);
    }
  }
  
  // Save user data to shared preferences
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, _isLoggedIn);
    if (_isLoggedIn && _userId != null) {
      await prefs.setString(_userIdKey, _userId!);
      if (_username != null) {
        await prefs.setString(_usernameKey, _username!);
      }
    }
  }
  
  // Clear user data from shared preferences
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
  }
  
  // Login user
  Future<bool> login({required String email, required String password}) async {
    if (ApiConfig.mockMode) {
      // Mock mode - simulate login
      await Future.delayed(const Duration(seconds: 1));
      _isLoggedIn = true;
      _userId = 'mock-user-id';
      _username = email.split('@')[0];
      await _saveUserData();
      return true;
    }
    
    try {
      // Get locale from LocalizationService for language parameter
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('language_code') ?? 'en';
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_loginEndpoint'),
        body: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isLoggedIn = true;
        _userId = data['user_id'];
        _username = data['username'];
        await _saveUserData();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
  
  // Register user
  Future<bool> register({
    required String email, 
    required String password,
    required String username,
  }) async {
    if (ApiConfig.mockMode) {
      // Mock mode - simulate registration
      await Future.delayed(const Duration(seconds: 1));
      _isLoggedIn = true;
      _userId = 'mock-user-id';
      _username = username;
      await _saveUserData();
      return true;
    }
    
    try {
      // Get locale from LocalizationService for language parameter
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('language_code') ?? 'en';
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_registerEndpoint'),
        body: {
          'email': email,
          'password': password,
          'username': username,
          'language': language,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isLoggedIn = true;
        _userId = data['user_id'];
        _username = username;
        await _saveUserData();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }
  
  // Logout user
  Future<bool> logout() async {
    if (ApiConfig.mockMode) {
      // Mock mode - simulate logout
      await Future.delayed(const Duration(milliseconds: 500));
      _isLoggedIn = false;
      _userId = null;
      _username = null;
      await _clearUserData();
      return true;
    }
    
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_logoutEndpoint'),
      );
      
      _isLoggedIn = false;
      _userId = null;
      _username = null;
      await _clearUserData();
      
      return response.statusCode == 200;
    } catch (e) {
      print('Logout error: $e');
      // Still clear data locally even if server request fails
      _isLoggedIn = false;
      _userId = null;
      _username = null;
      await _clearUserData();
      return false;
    }
  }
} 
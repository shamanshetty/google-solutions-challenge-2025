import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kisan_saathi/config/api_config.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => ApiConfig.mockMode ? true : _isOnline; // Always return online in mock mode
  
  late StreamSubscription<ConnectivityResult> _subscription;
  
  ConnectivityService() {
    // Initialize the connectivity service
    _initConnectivity();
    
    // Listen for connectivity changes
    _subscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  // Initialize connectivity
  Future<void> _initConnectivity() async {
    if (ApiConfig.mockMode) {
      _isOnline = true;
      notifyListeners();
      return;
    }
    
    try {
      ConnectivityResult result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Error checking connectivity: $e');
      _isOnline = false;
      notifyListeners();
    }
  }
  
  // Update connection status based on connectivity result
  void _updateConnectionStatus(ConnectivityResult result) {
    if (ApiConfig.mockMode) {
      _isOnline = true;
      return;
    }
    
    bool wasOnline = _isOnline;
    _isOnline = (result != ConnectivityResult.none);
    
    // Only notify if the status changed
    if (wasOnline != _isOnline) {
      notifyListeners();
    }
  }
  
  // Check current connectivity
  Future<bool> checkConnectivity() async {
    if (ApiConfig.mockMode) {
      return true;
    }
    
    try {
      ConnectivityResult result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
      return _isOnline;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
} 
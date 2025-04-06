import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:kisan_saathi/config/app_theme.dart';
import 'package:kisan_saathi/models/weather_result.dart';
import 'package:kisan_saathi/services/api_service.dart';
import 'package:kisan_saathi/services/connectivity_service.dart';
import 'package:kisan_saathi/services/localization_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String _errorMessage = '';
  WeatherResult? _weatherResult;
  Position? _currentPosition;
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  
  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(context);
    final localizationService = Provider.of<LocalizationService>(context);
    final isHindi = localizationService.isHindi;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'मौसम की जानकारी' : 'Weather Information'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Location info
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            isHindi ? 'वर्तमान स्थान' : 'Current Location',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Weather data
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (_weatherResult != null)
                        _buildWeatherInfo(isHindi)
                      else
                        Center(
                          child: Text(
                            isHindi ? 'कोई मौसम डेटा उपलब्ध नहीं है' : 'No weather data available',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        
                      const SizedBox(height: 16),
                      
                      // Get weather button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (_currentPosition != null && 
                                      !_isLoading && 
                                      connectivityService.isOnline)
                              ? _getWeatherData
                              : null,
                          icon: _isLoading
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2.0),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(_isLoading 
                                  ? (isHindi ? 'प्राप्त कर रहा है...' : 'Fetching...') 
                                  : (isHindi ? 'मौसम प्राप्त करें' : 'Get Weather')),
                        ),
                      ),
                      
                      // Offline warning
                      if (!connectivityService.isOnline)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.signal_wifi_off, color: Colors.orange, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isHindi 
                                    ? 'आप ऑफ़लाइन हैं। मौसम अपडेट प्राप्त करने के लिए कृपया इंटरनेट से कनेक्ट करें।'
                                    : 'You are offline. Please connect to the internet to get weather updates.',
                                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Error message
              if (_errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Recommendations
              if (_weatherResult != null && _weatherResult!.recommendations.isNotEmpty) ...[
                Text(
                  isHindi ? 'कृषि अनुशंसाएँ:' : 'Farming Recommendations:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...(_weatherResult!.recommendations.map((recommendation) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  recommendation,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ))),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildWeatherInfo(bool isHindi) {
    if (_weatherResult == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        Text(
          isHindi ? 'वर्तमान मौसम' : 'Current Weather',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: _weatherResult!.iconUrl,
              width: 60,
              height: 60,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            const SizedBox(width: 8),
            Text(
              '${_weatherResult!.temperature.toStringAsFixed(1)}°C',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          _weatherResult!.condition.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWeatherDetail(
              Icons.water_drop, 
              isHindi ? 'आर्द्रता' : 'Humidity', 
              '${_weatherResult!.humidity}%'
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  // Get the current location
  Future<void> _getCurrentLocation() async {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final isHindi = localizationService.isHindi;
    
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = isHindi
              ? 'स्थान सेवाएं अक्षम हैं।'
              : 'Location services are disabled.';
        });
        return;
      }
      
      // Check for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = isHindi
                ? 'स्थान अनुमतियां अस्वीकृत हैं।'
                : 'Location permissions are denied.';
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = isHindi
              ? 'स्थान अनुमतियां स्थायी रूप से अस्वीकृत हैं, हम अनुमतियां नहीं मांग सकते।'
              : 'Location permissions are permanently denied, we cannot request permissions.';
        });
        return;
      }
      
      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      
      setState(() {
        _currentPosition = position;
        _errorMessage = '';
      });
      
      // Get weather data automatically
      await _getWeatherData();
      
    } catch (e) {
      setState(() {
        _errorMessage = isHindi
            ? 'स्थान प्राप्त करने में त्रुटि: $e'
            : 'Error getting location: $e';
      });
    }
  }
  
  // Get weather data from the API
  Future<void> _getWeatherData() async {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final isHindi = localizationService.isHindi;
    
    if (_currentPosition == null) {
      setState(() {
        _errorMessage = isHindi ? 'स्थान उपलब्ध नहीं है' : 'Location not available';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final result = await _apiService.getWeather(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        language: localizationService.languageCode,
      );
      
      setState(() {
        _weatherResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = isHindi
            ? 'मौसम डेटा प्राप्त करने में त्रुटि: $e'
            : 'Error fetching weather data: $e';
        _isLoading = false;
      });
    }
  }
} 
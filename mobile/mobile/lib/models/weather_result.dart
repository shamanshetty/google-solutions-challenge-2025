class WeatherResult {
  final double temperature;
  final int humidity;
  final String condition;
  final List<String> recommendations;

  WeatherResult({
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.recommendations,
  });

  factory WeatherResult.fromJson(Map<String, dynamic> json) {
    return WeatherResult(
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0).toInt(),
      condition: json['condition'] ?? 'Unknown',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'condition': condition,
      'recommendations': recommendations,
    };
  }
  
  // Get weather icon based on condition
  String get weatherIcon {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'साफ़':
        return '01d';
      case 'cloudy':
      case 'बादल':
        return '03d';
      case 'rain':
      case 'बारिश':
        return '10d';
      case 'thunderstorm':
      case 'आंधी':
        return '11d';
      default:
        return '01d';
    }
  }
  
  String get iconUrl => 'https://openweathermap.org/img/wn/$weatherIcon@2x.png';
} 
class SoilResult {
  final String soilType;
  final Map<String, dynamic> properties;
  final List<String> recommendations;

  SoilResult({
    required this.soilType,
    required this.properties,
    required this.recommendations,
  });

  factory SoilResult.fromJson(Map<String, dynamic> json) {
    return SoilResult(
      soilType: json['soil_type'] ?? 'Unknown',
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soil_type': soilType,
      'properties': properties,
      'recommendations': recommendations,
    };
  }
  
  // Helper methods to get specific soil properties
  double get ph {
    try {
      return double.parse(properties['pH'] ?? '0.0');
    } catch (e) {
      return 0.0;
    }
  }
  
  int get nitrogen {
    try {
      return int.parse(properties['nitrogen'] ?? '0');
    } catch (e) {
      return 0;
    }
  }
  
  int get phosphorus {
    try {
      return int.parse(properties['phosphorus'] ?? '0');
    } catch (e) {
      return 0;
    }
  }
  
  int get potassium {
    try {
      return int.parse(properties['potassium'] ?? '0');
    } catch (e) {
      return 0;
    }
  }
  
  double get organicMatter {
    try {
      return double.parse(properties['organic_matter'] ?? '0.0');
    } catch (e) {
      return 0.0;
    }
  }
}

// Extension to provide access to properties through the properties map
extension PropertiesExtension on Map<String, dynamic> {
  double get ph {
    try {
      return double.parse(this['pH'] ?? '0.0');
    } catch (e) {
      return 0.0;
    }
  }
  
  int get nitrogen {
    try {
      return int.parse(this['nitrogen'] ?? '0');
    } catch (e) {
      return 0;
    }
  }
  
  int get phosphorus {
    try {
      return int.parse(this['phosphorus'] ?? '0');
    } catch (e) {
      return 0;
    }
  }
  
  int get potassium {
    try {
      return int.parse(this['potassium'] ?? '0');
    } catch (e) {
      return 0;
    }
  }
  
  double get organicMatter {
    try {
      return double.parse(this['organic_matter'] ?? '0.0');
    } catch (e) {
      return 0.0;
    }
  }
} 
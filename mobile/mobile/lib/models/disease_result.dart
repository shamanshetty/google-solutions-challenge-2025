class DiseaseResult {
  final String disease;
  final double confidence;
  final String description;
  final List<String> recommendations;

  DiseaseResult({
    required this.disease,
    required this.confidence,
    this.description = '',
    required this.recommendations,
  });

  factory DiseaseResult.fromJson(Map<String, dynamic> json) {
    return DiseaseResult(
      disease: json['disease'] ?? 'Unknown',
      confidence: json['confidence']?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disease': disease,
      'confidence': confidence,
      'description': description,
      'recommendations': recommendations,
    };
  }
} 
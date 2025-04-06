class CropRecommendation {
  final String cropName;
  final String description;
  final List<String> advantages;
  final List<String> irrigationTips;
  final List<String> farmingTechniques;
  final double estimatedProfit;
  final int waterRequirement; // 1-10 scale
  
  CropRecommendation({
    required this.cropName,
    required this.description,
    required this.advantages,
    required this.irrigationTips,
    required this.farmingTechniques,
    required this.estimatedProfit,
    required this.waterRequirement,
  });
  
  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      cropName: json['cropName'] as String,
      description: json['description'] as String,
      advantages: List<String>.from(json['advantages']),
      irrigationTips: List<String>.from(json['irrigationTips']),
      farmingTechniques: List<String>.from(json['farmingTechniques']),
      estimatedProfit: json['estimatedProfit'] as double,
      waterRequirement: json['waterRequirement'] as int,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'cropName': cropName,
      'description': description,
      'advantages': advantages,
      'irrigationTips': irrigationTips,
      'farmingTechniques': farmingTechniques,
      'estimatedProfit': estimatedProfit,
      'waterRequirement': waterRequirement,
    };
  }
} 
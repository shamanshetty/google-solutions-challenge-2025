class FarmerProfile {
  String location;
  double? landSize;
  List<String> pastCrops;
  List<String> cropPreferences;
  double? budget;
  String? waterAvailability;
  
  FarmerProfile({
    this.location = '',
    this.landSize,
    this.pastCrops = const [],
    this.cropPreferences = const [],
    this.budget,
    this.waterAvailability,
  });
  
  bool get isComplete {
    return location.isNotEmpty && 
           landSize != null && 
           pastCrops.isNotEmpty && 
           budget != null;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'landSize': landSize,
      'pastCrops': pastCrops,
      'cropPreferences': cropPreferences,
      'budget': budget,
      'waterAvailability': waterAvailability,
    };
  }
  
  factory FarmerProfile.fromJson(Map<String, dynamic> json) {
    return FarmerProfile(
      location: json['location'] as String? ?? '',
      landSize: json['landSize'] as double?,
      pastCrops: List<String>.from(json['pastCrops'] ?? []),
      cropPreferences: List<String>.from(json['cropPreferences'] ?? []),
      budget: json['budget'] as double?,
      waterAvailability: json['waterAvailability'] as String?,
    );
  }
} 
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:kisan_saathi/config/app_theme.dart';
import 'package:kisan_saathi/models/soil_result.dart';
import 'package:kisan_saathi/services/api_service.dart';
import 'package:kisan_saathi/services/connectivity_service.dart';
import 'package:kisan_saathi/services/localization_service.dart';
import 'package:kisan_saathi/utils/image_helper.dart';
import 'package:kisan_saathi/widgets/recommendation_card.dart';

class SoilAnalysisScreen extends StatefulWidget {
  const SoilAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<SoilAnalysisScreen> createState() => _SoilAnalysisScreenState();
}

class _SoilAnalysisScreenState extends State<SoilAnalysisScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  
  File? _image;
  Uint8List? _webImage; // For web platform
  bool _isAnalyzing = false;
  String _errorMessage = '';
  SoilResult? _soilResult;
  
  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final connectivityService = Provider.of<ConnectivityService>(context);
    final isHindi = localizationService.currentLocale.languageCode == 'hi';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'मिट्टी विश्लेषण' : 'Soil Analysis'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            isHindi ? 'निर्देश:' : 'Instructions:',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isHindi
                            ? '1. अपने खेत की मिट्टी का एक क्लोज-अप फोटो खींचें।'
                            : '1. Take a close-up photo of your field soil.',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isHindi
                            ? '2. सूखी मिट्टी का फोटो लें, रात में फोटो न लें।'
                            : '2. Capture dry soil, avoid night photos.',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isHindi
                            ? '3. धूप में फोटो लें और कोई छाया न डालें।'
                            : '3. Take photo in sunlight without shadows.',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Image preview
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: _hasImage
                    ? _buildImagePreview()
                    : Center(
                        child: Text(
                          isHindi ? 'कोई छवि नहीं चुनी गई' : 'No image selected',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Image capture buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _takePicture,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(isHindi ? 'कैमरा' : 'Camera'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: Text(isHindi ? 'गैलरी' : 'Gallery'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Analyze button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_hasImage && !_isAnalyzing && connectivityService.isOnline)
                      ? _analyzeSoil
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isAnalyzing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isHindi ? 'मिट्टी का विश्लेषण करें' : 'Analyze Soil',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                              ? 'आप ऑफलाइन हैं। मिट्टी विश्लेषण के लिए इंटरनेट कनेक्शन की आवश्यकता है।'
                              : 'You are offline. Internet connection is required for soil analysis.',
                          style: const TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
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
              
              const SizedBox(height: 24),
              
              // Results
              if (_soilResult != null) ...[
                Text(
                  isHindi ? 'मिट्टी का विश्लेषण:' : 'Soil Analysis Results:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Soil Type
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'मिट्टी का प्रकार:' : 'Soil Type:',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: getSoilColor(_soilResult!.soilType),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _soilResult!.soilType,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Soil Properties
                        Text(
                          isHindi ? 'मिट्टी के गुण:' : 'Soil Properties:',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Properties grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 2.0,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: [
                            _buildPropertyCard(
                              Icons.power_input,
                              'pH:',
                              _soilResult!.properties.ph.toString(),
                              Colors.purple.shade100,
                            ),
                            _buildPropertyCard(
                              Icons.energy_savings_leaf,
                              isHindi ? 'नाइट्रोजन:' : 'Nitrogen:',
                              '${_soilResult!.properties.nitrogen} mg/kg',
                              Colors.green.shade100,
                            ),
                            _buildPropertyCard(
                              Icons.grass,
                              isHindi ? 'फास्फोरस:' : 'Phosphorus:',
                              '${_soilResult!.properties.phosphorus} mg/kg',
                              Colors.orange.shade100,
                            ),
                            _buildPropertyCard(
                              Icons.compost,
                              isHindi ? 'जैविक पदार्थ:' : 'Organic Matter:',
                              '${_soilResult!.properties.organicMatter}%',
                              Colors.brown.shade100,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Recommendations
                if (_soilResult!.recommendations.isNotEmpty) ...[
                  Text(
                    isHindi ? 'अनुशंसाएँ:' : 'Recommendations:',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ...List.generate(
                    _soilResult!.recommendations.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: RecommendationCard(
                        recommendation: _soilResult!.recommendations[index],
                        index: index,
                        isHindi: isHindi,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper to check if we have an image
  bool get _hasImage => _image != null || _webImage != null;
  
  // Build image preview widget based on platform
  Widget _buildImagePreview() {
    if (kIsWeb && _webImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          _webImage!,
          fit: BoxFit.cover,
        ),
      );
    } else if (!kIsWeb && _image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          _image!,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const Center(
        child: Text('Error loading image'),
      );
    }
  }
  
  Widget _buildPropertyCard(
    IconData icon,
    String title,
    String value,
    Color backgroundColor,
  ) {
    return Card(
      color: backgroundColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color getSoilColor(String soilType) {
    switch (soilType.toLowerCase()) {
      case 'sandy soil':
        return Colors.amber.shade600;
      case 'clay soil':
        return Colors.brown.shade500;
      case 'loamy soil':
        return Colors.brown.shade300;
      case 'silt soil':
        return Colors.grey.shade400;
      case 'peat soil':
        return Colors.brown.shade800;
      case 'chalky soil':
        return Colors.grey.shade300;
      default:
        return Colors.brown.shade400;
    }
  }
  
  Future<void> _takePicture() async {
    try {
      final XFile? picture = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (picture != null) {
        if (kIsWeb) {
          // For web, read the image as bytes
          final bytes = await picture.readAsBytes();
          setState(() {
            _webImage = bytes;
            _image = null; // Clear the file version
            _errorMessage = '';
            _soilResult = null;
          });
        } else {
          setState(() {
            _image = File(picture.path);
            _webImage = null; // Clear the web version
            _errorMessage = '';
            _soilResult = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error taking picture: $e';
      });
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image != null) {
        if (kIsWeb) {
          // For web, read the image as bytes
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
            _image = null; // Clear the file version
            _errorMessage = '';
            _soilResult = null;
          });
        } else {
          setState(() {
            _image = File(image.path);
            _webImage = null; // Clear the web version
            _errorMessage = '';
            _soilResult = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
    }
  }
  
  Future<void> _analyzeSoil() async {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final isHindi = localizationService.isHindi;
    final language = localizationService.languageCode;
    
    if (!_hasImage) {
      setState(() {
        _errorMessage = isHindi 
            ? 'कृपया पहले कोई छवि चुनें' 
            : 'Please select an image first';
      });
      return;
    }
    
    setState(() {
      _isAnalyzing = true;
      _errorMessage = '';
    });
    
    try {
      // Use the cross-platform helper method
      final result = await _apiService.analyzeSoilImage(
        file: _image,
        bytes: _webImage,
        language: language,
      );
      
      setState(() {
        _soilResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = isHindi
            ? 'मिट्टी का विश्लेषण करने में त्रुटि: $e'
            : 'Error analyzing soil: $e';
        _isAnalyzing = false;
      });
    }
  }
} 
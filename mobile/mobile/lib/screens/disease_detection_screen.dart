import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:kisan_saathi/models/disease_result.dart';
import 'package:kisan_saathi/services/api_service.dart';
import 'package:kisan_saathi/services/connectivity_service.dart';
import 'package:kisan_saathi/services/localization_service.dart';
import 'package:kisan_saathi/utils/image_helper.dart';
import 'package:kisan_saathi/widgets/result_card.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({Key? key}) : super(key: key);

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  
  File? _imageFile;
  Uint8List? _webImage; // For web platform
  bool _isLoading = false;
  String _errorMessage = '';
  DiseaseResult? _result;
  
  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final connectivityService = Provider.of<ConnectivityService>(context);
    final isHindi = localizationService.isHindi;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'पौधों के रोग का पता लगाएं' : 'Plant Disease Detection'),
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
                      Text(
                        isHindi ? 'उपयोग कैसे करें:' : 'How to use:',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isHindi
                            ? '1. पौधे के पत्ते या प्रभावित क्षेत्र की स्पष्ट तस्वीर लें'
                            : '1. Take a clear photo of the plant leaf or affected area',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        isHindi
                            ? '2. सुनिश्चित करें कि पत्ता अच्छी तरह से प्रकाशित और फोकस में है'
                            : '2. Make sure the leaf is well-lit and in focus',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        isHindi
                            ? '3. रोगों का पता लगाने के लिए विश्लेषण बटन पर टैप करें'
                            : '3. Tap the analyze button to detect diseases',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Image preview
              Card(
                child: Container(
                  width: double.infinity,
                  height: 250,
                  padding: const EdgeInsets.all(16.0),
                  child: _hasImage
                      ? _buildImagePreview()
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.photo_library,
                                size: 60,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isHindi ? 'कोई छवि चयनित नहीं' : 'No image selected',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Image selection and upload buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _takePicture,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(isHindi ? 'फोटो लें' : 'Take Photo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: Text(isHindi ? 'गैलरी' : 'Gallery'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Analyze button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _hasImage && !_isLoading && connectivityService.isOnline
                      ? _analyzeImage
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
                      : const Icon(Icons.search),
                  label: Text(_isLoading 
                      ? (isHindi ? 'विश्लेषण कर रहे हैं...' : 'Analyzing...')
                      : (isHindi ? 'छवि का विश्लेषण करें' : 'Analyze Image')),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              // Offline warning
              if (!connectivityService.isOnline && _hasImage)
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
                              ? 'आप ऑफलाइन हैं। छवियों का विश्लेषण करने के लिए कृपया इंटरनेट से कनेक्ट करें।'
                              : 'You are offline. Please connect to the internet to analyze images.',
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
              
              const SizedBox(height: 20),
              
              // Results
              if (_result != null) ...[
                Text(
                  isHindi ? 'परिणाम:' : 'Results:',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ResultCard(
                  diseaseName: _result!.disease,
                  confidence: _result!.confidence,
                  description: _result!.description,
                  recommendations: _result!.recommendations,
                  isHindi: isHindi,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper to check if we have an image
  bool get _hasImage => _imageFile != null || _webImage != null;
  
  // Build image preview widget based on platform
  Widget _buildImagePreview() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final isHindi = localizationService.isHindi;
    
    if (kIsWeb && _webImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          _webImage!,
          fit: BoxFit.contain,
        ),
      );
    } else if (!kIsWeb && _imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _imageFile!,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return Center(
        child: Text(isHindi ? 'छवि लोड करने में त्रुटि' : 'Error loading image'),
      );
    }
  }
  
  // Take a picture with camera
  Future<void> _takePicture() async {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final isHindi = localizationService.isHindi;
    
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        if (kIsWeb) {
          final imageBytes = await image.readAsBytes();
          setState(() {
            _webImage = imageBytes;
            _imageFile = null;
            _errorMessage = '';
            _result = null;
          });
        } else {
          setState(() {
            _imageFile = File(image.path);
            _webImage = null;
            _errorMessage = '';
            _result = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = isHindi
            ? 'कैमरा एक्सेस करने में त्रुटि: $e'
            : 'Error accessing camera: $e';
      });
    }
  }
  
  // Pick image from gallery
  Future<void> _pickImage() async {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final isHindi = localizationService.isHindi;
    
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (kIsWeb) {
          final imageBytes = await image.readAsBytes();
          setState(() {
            _webImage = imageBytes;
            _imageFile = null;
            _errorMessage = '';
            _result = null;
          });
        } else {
          setState(() {
            _imageFile = File(image.path);
            _webImage = null;
            _errorMessage = '';
            _result = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = isHindi
            ? 'गैलरी एक्सेस करने में त्रुटि: $e'
            : 'Error accessing gallery: $e';
      });
    }
  }
  
  // Analyze the selected image
  Future<void> _analyzeImage() async {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final isHindi = localizationService.isHindi;
    
    if (!_hasImage) {
      setState(() {
        _errorMessage = isHindi
            ? 'कृपया पहले कोई छवि चुनें'
            : 'Please select an image first';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Send to API for analysis using the helper method that handles platform differences
      final result = await _apiService.detectDiseaseImage(
        file: _imageFile,
        bytes: _webImage,
        language: localizationService.languageCode,
      );
      
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = isHindi
            ? 'छवि का विश्लेषण करने में त्रुटि: $e'
            : 'Error analyzing image: $e';
        _isLoading = false;
      });
    }
  }
} 
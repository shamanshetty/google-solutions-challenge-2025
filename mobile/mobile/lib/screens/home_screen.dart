import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kisan_saathi/config/app_theme.dart';
import 'package:kisan_saathi/screens/chatbot_screen.dart';
import 'package:kisan_saathi/screens/disease_detection_screen.dart';
import 'package:kisan_saathi/screens/soil_analysis_screen.dart';
import 'package:kisan_saathi/screens/weather_screen.dart';
import 'package:kisan_saathi/screens/wallet_screen.dart';
import 'package:kisan_saathi/services/connectivity_service.dart';
import 'package:kisan_saathi/services/localization_service.dart';
import 'package:kisan_saathi/widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final connectivityService = Provider.of<ConnectivityService>(context);
    final isHindi = localizationService.isHindi;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'किसान साथी' : 'KisanSaathi'),
        actions: [
          // Language toggle button
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              _showLanguageSelector(context, localizationService);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Connectivity status bar (only shown when offline)
          if (!connectivityService.isOnline)
            Container(
              width: double.infinity,
              color: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.signal_wifi_off, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isHindi
                          ? 'आप वर्तमान में ऑफलाइन हैं। कुछ सुविधाएं सीमित हो सकती हैं।'
                          : 'You are currently offline. Some features may be limited.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          
          // Greeting section
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'किसान साथी में आपका स्वागत है' : 'Welcome to KisanSaathi',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isHindi ? 'आज आप क्या करना चाहेंगे?' : 'What would you like to do today?',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // Crop Advisor Chatbot
                  FeatureCard(
                    title: isHindi ? 'फसल सलाहकार' : 'Crop Advisor',
                    icon: Icons.chat,
                    color: Colors.teal.shade600,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatbotScreen(),
                        ),
                      );
                    },
                  ),
                  
                  // Wallet Feature - New Card
                  FeatureCard(
                    title: isHindi ? 'वॉलेट' : 'Wallet',
                    icon: Icons.account_balance_wallet,
                    color: Colors.purple.shade600,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WalletScreen(),
                        ),
                      );
                    },
                  ),
                  
                  // Plant disease detection
                  FeatureCard(
                    title: isHindi ? 'पौधों के रोग का पता लगाएं' : 'Detect Plant Disease',
                    icon: Icons.local_florist,
                    color: Colors.green.shade700,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DiseaseDetectionScreen(),
                        ),
                      );
                    },
                  ),
                  
                  // Soil analysis
                  FeatureCard(
                    title: isHindi ? 'मिट्टी का विश्लेषण करें' : 'Analyze Soil',
                    icon: Icons.landscape,
                    color: Colors.brown.shade600,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SoilAnalysisScreen(),
                        ),
                      );
                    },
                  ),
                  
                  // Weather information
                  FeatureCard(
                    title: isHindi ? 'मौसम की जानकारी' : 'Weather Info',
                    icon: Icons.cloud,
                    color: Colors.blue.shade600,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WeatherScreen(),
                        ),
                      );
                    },
                  ),
                  
                  // Help & About
                  FeatureCard(
                    title: isHindi ? 'मदद और जानकारी' : 'Help & About',
                    icon: Icons.help_outline,
                    color: Colors.purple.shade600,
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showLanguageSelector(BuildContext context, LocalizationService localizationService) {
    final isHindi = localizationService.isHindi;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isHindi ? 'भाषा चुनें' : 'Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                trailing: localizationService.currentLocale.languageCode == 'en'
                    ? const Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  localizationService.changeLocale(const Locale('en', ''));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('हिन्दी (Hindi)'),
                trailing: localizationService.currentLocale.languageCode == 'hi'
                    ? const Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  localizationService.changeLocale(const Locale('hi', ''));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    final isHindi = Provider.of<LocalizationService>(context, listen: false).isHindi;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isHindi ? 'किसान साथी के बारे में' : 'About KisanSaathi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi 
                      ? 'किसान साथी एक AI-संचालित मोबाइल एप्लिकेशन है जो सुलभ प्रौद्योगिकी के माध्यम से भारतीय छोटे किसानों को सशक्त बनाने के लिए डिज़ाइन की गई है।'
                      : 'KisanSaathi is an AI-powered mobile application designed to empower Indian smallholder farmers through accessible technology.',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  isHindi ? 'विशेषताएं:' : 'Features:',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFeatureItem(isHindi ? '• AI-संचालित फसल निगरानी और निदान' : '• AI-powered crop monitoring and diagnosis'),
                _buildFeatureItem(isHindi ? '• बुनियादी मिट्टी स्वास्थ्य विश्लेषण' : '• Basic soil health analysis'),
                _buildFeatureItem(isHindi ? '• मौसम-आधारित सिफारिशें' : '• Weather-based recommendations'),
                _buildFeatureItem(isHindi ? '• सरल, आवाज-पहले बहुभाषी इंटरफेस' : '• Simple, voice-first multilingual interface'),
                _buildFeatureItem(isHindi ? '• मुख्य सुविधाओं के लिए ऑफलाइन कार्यक्षमता' : '• Offline functionality for core features'),
                const SizedBox(height: 16),
                Text(
                  isHindi ? 'संस्करण 1.0.0' : 'Version 1.0.0',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(isHindi ? 'बंद करें' : 'Close'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
} 
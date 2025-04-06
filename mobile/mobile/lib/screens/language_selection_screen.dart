import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kisan_saathi/config/app_theme.dart';
import 'package:kisan_saathi/screens/login_screen.dart';
import 'package:kisan_saathi/services/localization_service.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final isHindi = localizationService.currentLocale.languageCode == 'hi';
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App logo
              Icon(
                Icons.eco,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              
              const SizedBox(height: 20),
              
              // App name
              Text(
                'KisanSaathi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Tagline
              Text(
                isHindi ? 'एआई के साथ भारतीय किसानों को सशक्त बनाना' : 'Empowering Indian Farmers with AI',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Title
              Text(
                isHindi ? 'अपनी भाषा चुनें' : 'Select Your Language',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                isHindi ? 'किसान साथी का उपयोग करने के लिए अपनी पसंदीदा भाषा चुनें' : 'Choose your preferred language to use KisanSaathi',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Language options
              _buildLanguageOption(
                context,
                title: 'English',
                locale: const Locale('en', ''),
                isSelected: localizationService.currentLocale.languageCode == 'en',
                localizationService: localizationService,
              ),
              
              const SizedBox(height: 16),
              
              _buildLanguageOption(
                context,
                title: 'हिंदी (Hindi)',
                locale: const Locale('hi', ''),
                isSelected: localizationService.currentLocale.languageCode == 'hi',
                localizationService: localizationService,
              ),
              
              const SizedBox(height: 40),
              
              // Continue button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isHindi ? 'जारी रखें' : 'Continue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required Locale locale,
    required bool isSelected,
    required LocalizationService localizationService,
  }) {
    return GestureDetector(
      onTap: () {
        localizationService.changeLocale(locale);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.green.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: locale.languageCode,
              groupValue: localizationService.currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  localizationService.changeLocale(Locale(value, ''));
                }
              },
              activeColor: AppTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
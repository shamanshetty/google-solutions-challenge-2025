import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kisan_saathi/config/app_theme.dart';
import 'package:kisan_saathi/screens/home_screen.dart';
import 'package:kisan_saathi/screens/language_selection_screen.dart';
import 'package:kisan_saathi/services/api_service.dart';
import 'package:kisan_saathi/services/auth_service.dart';
import 'package:kisan_saathi/services/connectivity_service.dart';
import 'package:kisan_saathi/services/localization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;
  String _statusMessage = 'Initializing...';
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Initialize auth service
      await _authService.init();
      
      // Check internet connectivity
      final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
      bool isOnline = await connectivityService.checkConnectivity();
      
      // Get language
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      final isHindi = languageCode == 'hi';
      
      setState(() {
        _statusMessage = isHindi ? 'प्रारंभ हो रहा है...' : 'Initializing...';
      });
      
      if (isOnline) {
        setState(() {
          _statusMessage = isHindi ? 'सर्वर कनेक्शन की जांच कर रहा है...' : 'Checking server connection...';
        });
        
        // Check if API is reachable
        bool isApiHealthy = await _apiService.checkApiHealth();
        
        if (isApiHealthy) {
          setState(() {
            _statusMessage = isHindi ? 'संसाधन लोड हो रहे हैं...' : 'Loading resources...';
          });
          
          // Simulate loading resources for the demo
          await Future.delayed(const Duration(seconds: 2));
          
          // Decide which screen to show
          if (mounted) {
            _navigateToNextScreen();
          }
        } else {
          setState(() {
            _isLoading = false;
            _statusMessage = isHindi 
                ? 'सर्वर से कनेक्ट करने में असमर्थ। कृपया पुनः प्रयास करें।' 
                : 'Unable to connect to server. Please try again.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage = isHindi 
              ? 'कोई इंटरनेट कनेक्शन नहीं। कुछ सुविधाएं सीमित हो सकती हैं।' 
              : 'No internet connection. Some features may be limited.';
        });
        
        // Still navigate to appropriate screen after a delay
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          _navigateToNextScreen();
        }
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      final isHindi = languageCode == 'hi';
      
      setState(() {
        _isLoading = false;
        _statusMessage = isHindi 
            ? 'ऐप्लिकेशन को प्रारंभ करने में त्रुटि: $e' 
            : 'Error initializing app: $e';
      });
    }
  }
  
  Future<void> _navigateToNextScreen() async {
    // Check if user has selected a language
    final prefs = await SharedPreferences.getInstance();
    final hasSelectedLanguage = prefs.containsKey('language_code');
    
    if (!hasSelectedLanguage) {
      // If no language is selected, go to language selection page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
      );
    } else if (_authService.isLoggedIn) {
      // If language is selected and user is logged in, go to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // If language is selected but user is not logged in, go to language selection
      // We'll redirect to login from there
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = SharedPreferences.getInstance();
    
    // Get language code if possible
    String languageCode = 'en';
    prefs.then((value) {
      languageCode = value.getString('language_code') ?? 'en';
    });
    
    final isHindi = languageCode == 'hi';
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              const Color(0xFF0A1D10), // Darker shade for gradient
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              right: -50,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.eco,
                  size: 200,
                  color: AppTheme.accentColor,
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.public,
                  size: 180,
                  color: AppTheme.secondaryGreen,
                ),
              ),
            ),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and animation
                  FadeTransition(
                    opacity: _animation,
                    child: Column(
                      children: [
                        // App logo with green glow effect
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentColor.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: AppTheme.getLogoWidget(size: 150),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // App name
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              AppTheme.accentColor,
                              AppTheme.secondaryGreen,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'KisanSaathi',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Tagline
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
                          child: Text(
                            isHindi ? 'एआई के साथ भारतीय किसानों को सशक्त बनाना' : 'Empowering Indian Farmers with AI',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: AppTheme.lightTextColor.withOpacity(0.8),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Loading indicator or status message
                  if (_isLoading)
                    Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            _statusMessage,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: AppTheme.lightTextColor.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            _statusMessage,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: AppTheme.lightTextColor.withOpacity(0.7),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _statusMessage = isHindi ? 'पुनः प्रयास कर रहा है...' : 'Retrying...';
                            });
                            _initialize();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isHindi ? 'पुनः प्रयास करें' : 'Retry',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            // Hexagon decorations like in the CSR image
            Positioned(
              right: 30,
              bottom: 80,
              child: _buildHexagonIcon(Icons.eco, 30),
            ),
            Positioned(
              right: 70,
              bottom: 140,
              child: _buildHexagonIcon(Icons.water_drop, 24),
            ),
            Positioned(
              right: 40,
              bottom: 200,
              child: _buildHexagonIcon(Icons.spa, 28),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHexagonIcon(IconData icon, double size) {
    return Opacity(
      opacity: 0.7,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(size * 0.2),
        ),
        padding: EdgeInsets.all(size * 0.2),
        child: Icon(
          icon,
          color: AppTheme.accentColor,
          size: size * 0.6,
        ),
      ),
    );
  }
} 
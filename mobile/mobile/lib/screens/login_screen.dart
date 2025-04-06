import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kisan_saathi/config/app_theme.dart';
import 'package:kisan_saathi/screens/home_screen.dart';
import 'package:kisan_saathi/services/api_service.dart';
import 'package:kisan_saathi/services/auth_service.dart';
import 'package:kisan_saathi/services/localization_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
  
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      bool success;
      
      if (_isLogin) {
        // Login
        success = await _authService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        // Register
        success = await _authService.register(
          email: _emailController.text,
          password: _passwordController.text,
          username: _usernameController.text,
        );
      }
      
      if (success) {
        // Navigate to home screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        final localizationService = Provider.of<LocalizationService>(context, listen: false);
        final isHindi = localizationService.currentLocale.languageCode == 'hi';
        
        setState(() {
          _errorMessage = _isLogin 
              ? (isHindi ? 'लॉगिन विफल। कृपया अपनी जानकारी जांचें।' : 'Login failed. Please check your credentials.')
              : (isHindi ? 'पंजीकरण विफल। कृपया पुनः प्रयास करें।' : 'Registration failed. Please try again.');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final isHindi = localizationService.currentLocale.languageCode == 'hi';
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App logo
                    Icon(
                      Icons.eco,
                      size: 70,
                      color: AppTheme.primaryColor,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      _isLogin 
                          ? (isHindi ? 'किसान साथी में लॉगिन करें' : 'Login to KisanSaathi')
                          : (isHindi ? 'किसान साथी के लिए पंजीकरण करें' : 'Register for KisanSaathi'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Toggle buttons
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isLogin = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _isLogin 
                                      ? AppTheme.primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  isHindi ? 'लॉगिन' : 'Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _isLogin ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isLogin = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !_isLogin 
                                      ? AppTheme.primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  isHindi ? 'पंजीकरण' : 'Register',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !_isLogin ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.red.shade200,
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    if (_errorMessage != null)
                      const SizedBox(height: 20),
                    
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: isHindi ? 'ईमेल' : 'Email',
                        labelStyle: const TextStyle(color: Colors.black54),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isHindi ? 'कृपया अपना ईमेल दर्ज करें' : 'Please enter your email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return isHindi ? 'कृपया एक वैध ईमेल दर्ज करें' : 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Username field (only for register)
                    if (!_isLogin)
                      Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: isHindi ? 'उपयोगकर्ता नाम' : 'Username',
                              labelStyle: const TextStyle(color: Colors.black54),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return isHindi ? 'कृपया उपयोगकर्ता नाम दर्ज करें' : 'Please enter a username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: isHindi ? 'पासवर्ड' : 'Password',
                        labelStyle: const TextStyle(color: Colors.black54),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isHindi ? 'कृपया अपना पासवर्ड दर्ज करें' : 'Please enter your password';
                        }
                        if (!_isLogin && value.length < 6) {
                          return isHindi ? 'पासवर्ड कम से कम 6 अक्षर का होना चाहिए' : 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Submit button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isLogin 
                                ? (isHindi ? 'लॉगिन' : 'Login')
                                : (isHindi ? 'पंजीकरण' : 'Register'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Switch between login/register
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        _isLogin
                            ? (isHindi ? 'खाता नहीं है? पंजीकरण करें' : 'Don\'t have an account? Register')
                            : (isHindi ? 'पहले से खाता है? लॉगिन करें' : 'Already have an account? Login'),
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
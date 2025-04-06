import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kisan_saathi/config/app_theme.dart';
import 'package:kisan_saathi/config/api_config.dart';
import 'package:kisan_saathi/config/env_config.dart';
import 'package:kisan_saathi/screens/splash_screen.dart';
import 'package:kisan_saathi/services/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:kisan_saathi/services/connectivity_service.dart';
import 'package:kisan_saathi/services/auth_service.dart';
import 'package:kisan_saathi/services/chatbot_service.dart';
import 'package:kisan_saathi/services/wallet_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await EnvConfig.load();
  
  // Initialize API configuration
  await ApiConfig.init();
  
  // Initialize services
  final localizationService = LocalizationService();
  await localizationService.init();
  
  final authService = AuthService();
  await authService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => localizationService),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => ChatbotService()),
        ChangeNotifierProvider(create: (_) => WalletService()),
        Provider<AuthService>.value(value: authService),
      ],
      child: const KisanSaathiApp(),
    ),
  );
}

class KisanSaathiApp extends StatelessWidget {
  const KisanSaathiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    return MaterialApp(
      title: 'KisanSaathi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: localizationService.currentLocale,
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('hi', ''), // Hindi
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
} 
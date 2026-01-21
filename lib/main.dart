import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/recovery_screen.dart';
import 'screens/porn_warning_screen.dart';
import 'utils/performance_monitor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations (only for mobile platforms, not web)
  // On web, orientation lock is not needed/supported
  if (!kIsWeb) {
    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } catch (e) {
      // If orientation setting fails (e.g., on desktop), continue
    }
  }
  
  // Performance monitoring (beta testing)
  if (const bool.fromEnvironment('BETA_MODE', defaultValue: false)) {
    PerformanceMonitor.instance.startMonitoring();
  }
  
  // Initialize auth service
  final authService = AuthService();
  await authService.initialize();
  
  // Check if user is logged in
  final isLoggedIn = await authService.isLoggedIn();
  
  runApp(SecureFlutterApp(initialRoute: isLoggedIn ? '/home' : '/login'));
}

class SecureFlutterApp extends StatelessWidget {
  final String initialRoute;
  
  const SecureFlutterApp({super.key, this.initialRoute = '/login'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peaceled Pulse',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/recovery': (context) => RecoveryScreen(
          onContinue: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
        ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

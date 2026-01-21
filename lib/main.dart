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
      title: 'Recovery Journey',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        // cardTheme: const CardTheme(
        //   elevation: 2,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.all(Radius.circular(12)),
        //   ),
        // ),
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

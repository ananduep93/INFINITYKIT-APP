import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/tool_data_service.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('Starting Firebase initialization...');
  try {
    // Adding a timeout to Firebase initialization to prevent hanging on splash
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      debugPrint('Firebase initialization timed out.');
      return Firebase.app(); // Return existing app if possible
    });
    debugPrint('Firebase initialized successfully.');
    
    // Initialize tool data persistence
    await ToolDataService.init();
    debugPrint('ToolDataService initialized.');
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(const InfinityKitApp());
}

class InfinityKitApp extends StatelessWidget {
  const InfinityKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Infinity Kit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (_showSplash || !authService.initialized) {
      return const SplashScreen();
    }
    
    // Check if user is logged in
    if (authService.user != null) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

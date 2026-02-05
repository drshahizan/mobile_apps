import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Docs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF800000)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiService());
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await _authService.loadUser();
    
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      if (_authService.isLoggedIn()) {
        final isAdmin = _authService.isAdmin();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => isAdmin
                ? AdminHomeScreen(authService: _authService)
                : HomeScreen(authService: _authService),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(authService: _authService),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/AIM.jfif',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'E-Docs',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Document Management System',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

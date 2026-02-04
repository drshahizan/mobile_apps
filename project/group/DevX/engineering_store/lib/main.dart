import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // App Check disabled - using authentication-based security instead (free tier)
  // For production: enable App Check and upgrade to Blaze plan if needed
  
  // Disable reCAPTCHA for development (Android emulator)
  await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
  
  final authService = AuthService();
  runApp(
    Provider<AuthService>(
      create: (_) => authService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Engineering Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('=== StreamBuilder Auth State ===');
        print('Connection State: ${snapshot.connectionState}');
        print('Has Data: ${snapshot.hasData}');
        print('Error: ${snapshot.error}');
        if (snapshot.hasData) {
          print('User: ${snapshot.data?.email}');
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('→ Showing loading indicator');
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          print('→ Showing HomeScreen for: ${snapshot.data?.email}');
          return const HomeScreen();
        }

        print('→ Showing LoginScreen');
        return const LoginScreen();
      },
    );
  }
}
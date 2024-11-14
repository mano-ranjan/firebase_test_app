import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'config/firebase_options.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    }
    runApp(const MyApp());
  } catch (e) {
    print('Firebase initialization error: $e');
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Handle authentication state for protected routes
        final authService = AuthService();
        final isAuthenticated = authService.currentUser != null;

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) =>
                  isAuthenticated ? const HomeScreen() : const LoginScreen(),
            );

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());

          case '/home':
            // Redirect to login if not authenticated
            if (!isAuthenticated) {
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            }
            return MaterialPageRoute(builder: (_) => const HomeScreen());

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('Route ${settings.name} not found'),
                ),
              ),
            );
        }
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  Future<void> _retryInitialization(BuildContext context) async {
    try {
      if (!Firebase.apps.isNotEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MyApp()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Initialization failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize app',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _retryInitialization(context),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
